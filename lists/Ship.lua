targetless.Ship = {}

function targetless.Ship:new(id)
    if not (id and id ~= 0) then return end
    local ship = {
        id = id,
        name = ""..GetPlayerName(id),
        health = 0,
        shield = 0,
        distance = math.ceil(GetPlayerDistance(id) or 0),
        faction = GetPlayerFaction(id) or 0,
        istand = GetPlayerFactionStanding(1, id),
        sstand = GetPlayerFactionStanding(2, id),
        ustand = GetPlayerFactionStanding(3, id),
        lstand = GetPlayerFactionStanding("sector", id),
        ship = GetPrimaryShipNameOfPlayer(id),
        label = nil,
        numlabel = nil,
        fontcolor = "150 150 150",
        font = targetless.var.font
    }
    if GetGuildTag(id) ~= "" then ship.name = "[" .. GetGuildTag(id) .. "] "..ship.name end
    ship.health, ship.shield = GetPlayerHealth(id)
    ship.health = math.ceil(ship.health or 0)
    ship.shield = math.ceil(100*(ship.shield or 0))
    if not (ship.id and ship.name) then return end

    if(string.sub(ship.name, 1, string.len("*")) == "*") then
        ship.npc = true
    end
    if ship.name == "(reading transponder " .. id .. ")" then
        ship.name = "(reading transponder)"
    end

    local status = GetFriendlyStatus(ship.id)
    if status == 3 then ship.hostile = false
    else ship.hostile = true
    end

    if(ship.ship == "Robot" and string.find(ship.name, "Queen")) then
        ship.cap = true 
    elseif(ship.ship == "Leviathan") then ship.cap = true 
    elseif(ship.ship == "Heavy Assault Cruiser") then ship.cap = true 
    elseif(ship.ship == "TPG Teradon Frigate") then ship.cap = true 
    elseif(ship.ship == "TPG Constellation Heavy Transport") then ship.cap = true 
    elseif(ship.ship == "Trident Light Frigate") then ship.cap = true 
    elseif(ship.ship == "Trident Type M") then ship.cap = true 
    elseif(ship.ship == "Goliath") then ship.cap = true 
    elseif(ship.ship == "Capella") then ship.cap = true 
    end

    -- This should work and make things even better! But we don't get access =( 
    -- setmetatable(ship, { __index = targetless.Ship })

    -- These should all be set as functions of targetless.Ship, but I need meta tables for that =(
    
    function ship:getiup(layout)
        local format = ""
        if layout then format = layout
        elseif(HUD.targetname.title == "Turret ("..self.name..")") then
            format = targetless.var.layout.cap
        elseif self.cap then
            format = targetless.var.layout.cap
        elseif self.npc then
            format = targetless.var.layout.npc
        else
            format = targetless.var.layout.pc
        end
        -- Build the tag layers into a table
        local layers = format 
        local iupzbox = iup.zbox { iup.vbox{},all="YES" }
        for i,layerz in ipairs(layers) do
            local iupvbox = iup.vbox {}
            for j,layery in ipairs(layerz) do 
                local iuphbox = iup.hbox {}
                for k,layerx in ipairs(layery) do 
                    local iuplabel = self:getlabelbytag(layerx)
                    iup.Append(iuphbox, iuplabel)
                end
                iup.Append(iupvbox, iuphbox)
            end
            iup.Append(iupzbox, iupvbox)
        end
        return iupzbox
    end

    function ship:getlabelbytag(tag)
        local iuplabel
        if(tag == "<fill>") then
            iuplabel = iup.fill {}
        elseif(tag == "<tab>") then
            iuplabel = iup.label { title="    ", font=self.font }
        elseif(tag == "<name>") then
			iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
            local name = self.name
            local trim = targetless.var.trim
            if not self.npc then trim = trim - 6 end
            if(self.faction > 3) then 
                trim = trim - targetless.var.factions[self.faction]:len()
            end
            if(#name > trim+2) then name = name:sub(1,trim)..".." end
            iuplabel.title = name
            iuplabel.fgcolor=FactionColor_RGB[self.faction] 
            if(self.faction > 3) then 
                iuplabel.title = iuplabel.title .. "(" .. targetless.var.factions[self.faction] .. ")" 
            end
        elseif(tag == "<health>") then
            local hsize = 8
            local ssize = 6
            if self.font ~= targetless.var.font then 
                ssize = 8 
                hsize = 12
            end
            local iupbar = iup.stationprogressbar{visible=((self.health>=0) and "YES" or "NO"), active="NO",size="x"..hsize,expand="HORIZONTAL",title=""}
            iupbar.minvalue = 0
            iupbar.maxvalue = 100
            iupbar.uppercolor = "0 0 0 0 *"
            iupbar.lowercolor = "64 255 64 155 *"

            local shieldbar = iup.fill{size=2}
            if(self.shield>0) then
                shieldbar = iup.stationprogressbar{visible=((self.shield>=0) and "YES" or "NO"), active="NO",size="x"..ssize,expand="HORIZONTAL",title=""}
                shieldbar.minvalue = 0
                shieldbar.maxvalue = 100
                shieldbar.uppercolor = "0 0 0 0 *"
                shieldbar.lowercolor = "0 0 255 155 *"
                shieldbar.value = self.shield
            end

            if(self.name == HUD.targetname.title) then
                iupbar.lowercolor = calc_health_color(ship.health/100, 128)
            else
                iupbar.lowercolor = calc_health_color(ship.health/100, 64)
            end
            iupbar.value = self.health

            local iupbox = iup.vbox{
                shieldbar,
                iupbar,
                iup.fill{ size=4},
            }
            return iupbox 
        elseif(tag == "<healthtext>") then
            local healthcolor = calc_health_color(ship.health/100, 156)
            local health = ""..self.health

            if self.shield > 0 then
                -- shield is up, show that first instead of actual health
                healthcolor = "128 128 255 155 *"
                health = ""..(self.shield/100) -- shield is 10,000?  at least on tridentM it seems
            end

            if #health < 2 then health = "    "..health 
            elseif #health < 3 then health = "  "..health
            end
            if #health < 3 then health = health.." " end
            health = health.."%"

			iuplabel = iup.hbox{
                iup.label {title=" [", font = self.font, fgcolor = "255 255 255 156 *"},
                iup.label {title = health, font = self.font, fgcolor = healthcolor },
                iup.label {title="]", font = self.font, fgcolor = "255 255 255 156 *"},
            }
        elseif(tag == "<distance>") then
            local distance = tostring(self.distance).."m"
            local capname = string.sub(self.name, 3, string.len(self.name))
            local size = ""..(88 + ((targetless.var.fontscale*160)) - 80)
            if self.distance == 0 and targetless.var.mycaps[capname] ~= nil then
                distance = AbbrLocationStr(targetless.var.mycaps[capname].sectorid)
            end
            iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
            iuplabel.title = " " .. distance
            iuplabel.size = size
        elseif(tag == "<pcship>") then
			iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
            local ship = self.ship
            if(#ship+4 > targetless.var.trim) then ship = ship:sub(1,targetless.var.trim-6).."..." end
            iuplabel.title = ship
        elseif(tag == "<npcship>") then
			iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
            local ship = self.ship
            if(ship == "Robot") then ship = self.name end
            local faction = targetless.var.factions[self.faction] 
            if(self.faction < 3) then faction = "" end
            local trim = targetless.var.trim-#faction-8
            if(trim < 1) then trim = 1 end
            if(#ship+4 > trim) then ship = ship:sub(1,trim)..".." end
            iuplabel.title = ship
            local iupfaction = iup.label {title = "", font = self.font, fgcolor = ShipPalette_string[FactionColor[self.faction]]}
            if(self.faction > 3) then 
                iupfaction.title = "("..faction..")" 
            end
            iuplabel.fgcolor=FactionColor_RGB[self.faction] 
            local iupbox = iup.hbox{
                iuplabel,
                iupfaction,
            }
            return iupbox 
        elseif(tag == "<capship>") then
			iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
            local ship = self.ship
            if(ship == "Robot") then
                ship = self.name
            else
                -- append ship name, but only if it's not queen/levi?
                ship = ship.." "..self.name
            end
            local faction = targetless.var.factions[self.faction] 
            if(self.faction < 3) then faction = "" end

            local trim = targetless.var.trim-#faction-8
            if(trim < 1) then trim = 1 end
            if(#ship+4 > trim) then ship = ship:sub(1,trim)..".." end
            iuplabel.title = ship
            local iupfaction = iup.label {title = "", font = self.font, fgcolor = ShipPalette_string[FactionColor[self.faction]]}
            if(self.faction > 3) then 
                iupfaction.title = "("..faction..")" 
            end
            iuplabel.fgcolor=FactionColor_RGB[self.faction] 
            local iupbox = iup.hbox{
                iuplabel,
                iupfaction,
            }
            return iupbox 
        elseif(tag == "<turrets>") then
            --[[
            local turrets = self:getturrets()
            local iupbox = iup.hbox {}
            for offset,health in ipairs(turrets) do
                if(offset==turrets.current) then
                    iup.Append(iupbox,targetless.Ship.turretbar(health, true))
                else
                    iup.Append(iupbox,targetless.Ship.turretbar(health))
                end
                iup.Append(iupbox, iup.fill{size=5})
            end
            return iupbox
            ]]
        elseif(tag == "<istand>") then
            -- only allow for player ships, other ships don't really differ
            if(self.id == GetCharacterID() or self.npc) then
                iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
                iuplabel.title = ""
            else
                return targetless.Ship.standing(self.istand,1)
            end
        elseif(tag == "<sstand>") then
            -- only allow for player ships, other ships don't really differ
            if(self.id == GetCharacterID() or self.npc) then
                iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
                iuplabel.title = ""
            else
                return targetless.Ship.standing(self.sstand,2)
            end
        elseif(tag == "<ustand>") then
            -- only allow for player ships, other ships don't really differ
            if(self.id == GetCharacterID() or self.npc) then
                iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
                iuplabel.title = ""
            else
                return targetless.Ship.standing(self.ustand,3)
            end
        elseif(tag == "<lstand>") then
            if(GetSectorMonitoredStatus() == 1) then 
				iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
                iuplabel.title = ""
            else
                if(self.id ~= GetCharacterID() and (not self.npc) and GetSectorAlignment() < 4) then
					iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
                    iuplabel.title = ""
                else
                    return targetless.Ship.standing(self.lstand,GetSectorAlignment())
                end
            end
        end
		if not iuplabel then iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor } end
        return iuplabel
    end

    function ship:targetchild(offset)
        radar.SetRadarSelection(GetPlayerNodeID(self.id), GetPrimaryShipIDOfPlayer(self.id))
        local starttype,startid = radar.GetRadarSelectionID()
        radar.SetRadarSelection(GetPlayerNodeID(self.id), GetPrimaryShipIDOfPlayer(self.id+offset))
        local targettype,targetid = radar.GetRadarSelectionID()
        if((targetid == startid) and targettype == starttype) then
            return false
        end
        return true
    end

    -- get turret healths 
    function ship:getturrets()
        local turrets = {}
        local count = 0
        if(self.ship == "Heavy Assault Cruiser") then count = 21 
        elseif(self.ship == "TPG Teradon Frigate") then count = 32 
        elseif(self.ship == "Trident Light Frigate") then count = 4 
        elseif(self.ship == "TPG Constellation Heavy Transport") then count = 12
        end

        local starttype,startid = radar.GetRadarSelectionID()
        local i = 1
        while(i <= count) do
            local active = self:targetchild(4-count)
            turrets[i] = 0
            if active then
                turrets[i] = tonumber(HUD.targethealth.value or 0)
                if startid == GetPrimaryShipIDOfPlayer(self.id)+i then 
                    turrets.current = i
                end
            end
            i = i + 1
            --if(#turrets > 10) then break end
        end
        radar.SetRadarSelection(starttype, startid)
        return turrets
    end

    function ship:target()
        radar.SetRadarSelection(GetPlayerNodeID(self.id), GetPrimaryShipIDOfPlayer(self.id))
        targetless.Controller:update()
    end

    function ship:targetchild(offset)
        radar.SetRadarSelection(GetPlayerNodeID(self.id), GetPrimaryShipIDOfPlayer(self.id))
        local starttype,startid = radar.GetRadarSelectionID()
        radar.SetRadarSelection(GetPlayerNodeID(self.id), GetPrimaryShipIDOfPlayer(self.id+offset))
        local targettype,targetid = radar.GetRadarSelectionID()
        if((targetid == startid) and targettype == starttype) then
            return false
        end
        return true
    end

    return ship
end

function targetless.Ship.turretbar(health, active)
    local fade = 64
    if active then fade = 255 end
    local bar = iup.stationprogressbar{visible="YES",active="NO",size="10x4",title=""}
    bar.minvalue = 0 
    bar.maxvalue = 100 
    bar.uppercolor = "64 64 64 64 *"
    bar.lowercolor = calc_health_color(health/100, fade)
    bar.value = health 
    local topbar = iup.stationprogressbar{visible="YES",active="NO",size="10x3",title=""}
    topbar.minvalue = 0
    topbar.maxvalue = 100 
    topbar.uppercolor = "255 255 128 "..fade.." *"
    topbar.lowercolor = "255 255 128 "..fade.." *"
    topbar.value = 0 

    local iupbox = iup.vbox{
        topbar,
        bar,
        iup.fill{size=2},
    }
    return iupbox
end

function targetless.Ship.standing(stand, faction)
    if(targetless.var.faction == "smile" or targetless.var.faction == "wheel") then
        local standstr = factionfriendlyness(stand)
        if standstr == "Kill on Sight" then
            standstr = targetless.var.faction.."/KOS.png"
        elseif standstr == "Hate" then
            standstr = targetless.var.faction.."/hate.png"
        elseif standstr == "Dislike" then
            standstr = targetless.var.faction.."/dislike.png"
        elseif standstr == "Neutral" then
            standstr = targetless.var.faction.."/neutral.png"
        elseif standstr == "Respect" then
            standstr = targetless.var.faction.."/respect.png"
        elseif standstr == "Admire" then
            standstr = targetless.var.faction.."/admire.png"
        elseif standstr == "Pillar of Society" then
            standstr = targetless.var.faction.."/POS.png"
        end
        local iuplabel = iup.label {title = "", font = targetless.var.font}
        iuplabel.title = standstr
        iuplabel.fgcolor = FactionColor_RGB[faction]
        iuplabel.image = targetless.var.IMAGE_DIR .. iuplabel.title
        return iuplabel
    else
        local standbar = iup.stationprogressbar{visible="YES",active="NO",size="32x8",title=""}
        standbar.minvalue = -100 
        standbar.maxvalue = 65535 
        standbar.uppercolor = "64 64 64 64 *"
        standbar.lowercolor = "255 255 255 128 *"
        standbar.value = stand
        local factbar = iup.stationprogressbar{visible="YES",active="NO",size="32x6",title=""}
        factbar.minvalue = 0
        factbar.maxvalue = 100 
        factbar.uppercolor = FactionColor_RGB[faction]
        factbar.lowercolor = FactionColor_RGB[faction]
        factbar.value = 0 

        local iupbox = iup.vbox{
            iup.fill{size=4},
            factbar,
            standbar,
        }
        return iupbox
    end
end

