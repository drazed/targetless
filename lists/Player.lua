targetless.Player = {}

function targetless.Player:new(charid)
    if not (charid and charid ~= 0 and charid ~= GetCharacterID()) then return end
    local player = {}
    player["id"] = charid
    player["name"] = ""..GetPlayerName(charid)
    if GetGuildTag(charid) ~= "" then player["name"] = "[" .. GetGuildTag(charid) .. "] "..player["name"] end
    player["health"] = math.floor(GetPlayerHealth(charid) or 0)
    player["distance"] = math.floor(GetPlayerDistance(charid) or 0)
    player["faction"] = GetPlayerFaction(charid)
    player["istand"] = factionfriendlyness(GetPlayerFactionStanding(1, charid))
    player["sstand"] = factionfriendlyness(GetPlayerFactionStanding(2, charid))
    player["ustand"] = factionfriendlyness(GetPlayerFactionStanding(3, charid))
    player["lstand"] = factionfriendlyness(GetPlayerFactionStanding("sector", charid))
    player["ship"] = GetPrimaryShipNameOfPlayer(charid)
    player["npc"] = "NO"
    player["label"] = nil
    if not (player["name"] and player["health"] and player["faction"] and player["ship"]) then return end

    player.fontcolor = "150 150 150"
    function player:getiup(format)
        if(format == nil) then 
            format = "{<health><name><fill><lstand>}{<distance><ship>}"
        end
        local formattbl = {}
        string.gsub(format,"{(.-)}", function(a) table.insert(formattbl, a) end)
        local i = 1
        while(formattbl[i]) do
            local formatstr = formattbl[i]
            formattbl[i] = {}
            string.gsub(formatstr,"<(.-)>", function(a) table.insert(formattbl[i], a) end)
            i = i + 1
        end

        local iupbox = iup.vbox {}
        i = 1
        while(formattbl[i]) do
            local iuphbox = iup.hbox {}
            local j = 1
            while(formattbl[i][j]) do
                local iuplabel = self:getlabelbytag(formattbl[i][j])
                iup.Append(iuphbox, iuplabel)
                j = j + 1
            end
            iup.Append(iupbox, iuphbox)
            i = i + 1
        end

        return iupbox 
    end

    function player:getlabelbytag(tag)
        local iuplabel = iup.label {title = "", font = targetless.var.font, fgcolor = self.fontcolor }
        if(tag == "fill") then
            iuplabel = iup.fill {}
        elseif(tag == "tab") then
            iuplabel = iup.fill { size="10" }
        elseif(tag == "health") then
            local health = tonumber(self["health"])
            local iupbar = iup.label { title="", size= math.floor(health/3).."x10" }
            if(self["health"] >= 66) then iupbar.fgcolor="0 125 0"
            elseif(self["health"] > 33) then iupbar.fgcolor="150 125 0"
            elseif(self["health"] <= 33) then iupbar.fgcolor="150 0 0" end
            iupbar.image=targetless.var.IMAGE_DIR.."health.png"
            iuplabel.title = tostring(self["health"].."%")
            local iupbox = iup.hbox
            {
                iup.hbox
                {
                    iupbar,
                    size = "36"
                },
                iup.hbox 
                {
                    iuplabel,
                    margin = "-32"
                }
            }
            return iupbox 
        elseif(tag == "name") then
            local name = self["name"]
            local trim = math.floor(gkinterface.GetXResolution()/40)
            if(#name > trim+2) then name = name:sub(1,trim).."..." end

            iuplabel.title = name
            iuplabel.fgcolor=FactionColor_RGB[self["faction"]] 
            if(self["faction"] > 3) then 
                iuplabel.title = iuplabel.title .. "(" .. targetless.var.factions[self["faction"]] .. ")" 
            end
        elseif(tag == "distance") then
            iuplabel.title = " " .. tostring(self["distance"]) .. "m "
            iuplabel.size = "50"
        elseif(tag == "ship") then
            iuplabel.title = self["ship"]
        elseif(tag == "istand") then
            iuplabel.title = targetless.Player.standingstr(self["istand"])
            iuplabel.fgcolor = FactionColor_RGB[1]
            iuplabel.image = targetless.var.IMAGE_DIR .. iuplabel.title
        elseif(tag == "sstand") then
            iuplabel.title = targetless.Player.standingstr(self["sstand"])
            iuplabel.fgcolor = FactionColor_RGB[2]
            iuplabel.image = targetless.var.IMAGE_DIR .. iuplabel.title
        elseif(tag == "ustand") then
            iuplabel.title = targetless.Player.standingstr(self["ustand"])
            iuplabel.fgcolor = FactionColor_RGB[3]
            iuplabel.image = targetless.var.IMAGE_DIR .. iuplabel.title
        elseif(tag == "lstand") then
            if(GetSectorMonitoredStatus() == 1) then 
                iuplabel.title = ""
            else
                if(self["id"] ~= GetCharacterID() and self["npc"] == "NO" and GetSectorAlignment() < 4) then
                        iuplabel.title = ""
                else
                    iuplabel.title = targetless.Player.standingstr(self["lstand"])
                    iuplabel.image = targetless.var.IMAGE_DIR..iuplabel.title
                    iuplabel.fgcolor = FactionColor_RGB[GetSectorAlignment()]
                end
            end
        end
        return iuplabel
    end

    -- Obsolete function??? TODO, remove
    function player:destroy()
        if(self["label"]) then
            iup.Detach(self["label"])
            iup.Destroy(self["label"])
        end
    end
    -- end TODO

    function player:target()
        radar.SetRadarSelection(GetPlayerNodeID(self["id"]), GetPrimaryShipIDOfPlayer(self["id"]))
        targetless.func.refresh()
    end

    return player
end

function targetless.Player.standingstr(stand)
    if stand == "Kill on Sight" then
        return "KOS.png"
    elseif stand == "Hate" then
        return "hate.png"
    elseif stand == "Dislike" then
        return "dislike.png"
    elseif stand == "Neutral" then
        return "neutral.png"
    elseif stand == "Respect" then
        return "respect.png"
    elseif stand == "Admire" then
        return "admire.png"
    elseif stand == "Pillar of Society" then
        return "POS.png"
    else
        return stand
    end
end
