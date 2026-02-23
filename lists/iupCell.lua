--[[
--
-- This class will hold empty iup cells, pre-fillable to any ship type, 
-- and clearable of all data.  For a future version of targetless that 
-- will NOT rebuild all iup containers.
--
--]]
targetless.Cell = {}

function targetless.Cell:new()
    local cell = {
        numlabel = nil,
        name = nil,
        ship = nil,
        istand = nil,
        sstand = nil,
        ustand = nil,
        lstand = nil,
        distance = nil,
        healthbar = nil,
        healthtext = nil,
        fontcolor = "150 150 150",
        font = targetless.var.font
    }

    function cell:getiup(layout)
        local format = ""
        if layout then format = layout
        elseif(HUD.targetname.title == "Turret ("..self.name..")") then
            format = targetless.var.layout.cap
        elseif self.cap then
            if(self.name == HUD.targetname.title) then
                format = targetless.var.layout.cap
            else
                format = targetless.var.layout.npc
            end
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

    function cell:getlabelbytag(tag)
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
            local hsize = 6
            local ssize = 3
            if self.font ~= targetless.var.font then 
                ssize = 6 
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
			iuplabel = iup.label {title = "", font = self.font, fgcolor = self.fontcolor }
            iuplabel.title = " " .. tostring(self.distance) .. "m "
            iuplabel.size = "60"
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

    return cell
end

function targetless.Cell.turretbar(health, active)
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

function targetless.Cell.standing(stand, faction)
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
        local standbar = iup.stationprogressbar{visible="YES",active="NO",size="16x4",title=""}
        standbar.minvalue = -100 
        standbar.maxvalue = 65535 
        standbar.uppercolor = "64 64 64 64 *"
        standbar.lowercolor = "255 255 255 128 *"
        standbar.value = stand
        local factbar = iup.stationprogressbar{visible="YES",active="NO",size="16x3",title=""}
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

