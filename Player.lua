targetls.Player = {}

function targetls.Player:new()
    local player = {}
    player["id"] = 0
    player["name"] = ""
    player["health"] = 0
    player["distance"] = 0
    player["faction"] = 0
    player["istand"] = ""
    player["sstand"] = ""
    player["ustand"] = ""
    player["lstand"] = ""
    player["ship"] = ""
    player["npc"] = "NO"
    player["label"] = nil
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
        local iuplabel = iup.label {title = "", font = targetls.var.font, fgcolor = self.fontcolor }
        if(tag == "fill") then
            iuplabel = iup.fill {}
        elseif(tag == "tab") then
            iuplabel = iup.fill { size="10" }
        elseif(tag == "health") then
            local health = tonumber(self["health"])
            local iupbar = iup.label { title="", size= math.floor(health/2.5).."x10" }
            if(self["health"] >= 66) then iupbar.fgcolor="0 125 0"
            elseif(self["health"] > 33) then iupbar.fgcolor="150 125 0"
            elseif(self["health"] <= 33) then iupbar.fgcolor="150 0 0" end
            iupbar.image=targetls.var.IMAGE_DIR .. "health.png"
            iuplabel.title = tostring(self["health"] .. "%")
            local iupbox = iup.hbox
            {
                iup.hbox
                {
                    iupbar,
                    size = "44"
                },
                iup.hbox 
                {
                    iuplabel,
                    margin = "-37"
                }
            }
            return iupbox 
        elseif(tag == "name") then
            local name = self["name"]
            if(#name > 25) then name = name:sub(1,25) end
            iuplabel.title = name
            iuplabel.fgcolor=FactionColor_RGB[self["faction"]] 
            if(self["faction"] > 3) then 
                iuplabel.title = iuplabel.title .. "(" .. targetls.var.factions[self["faction"]] .. ")" 
            end
        elseif(tag == "distance") then
            iuplabel.title = "  " .. tostring(self["distance"]) .. "m "
            iuplabel.size = "50"
        elseif(tag == "ship") then
            iuplabel.title = self["ship"]
        elseif(tag == "istand") then
            iuplabel.title = targetls.Player.standingstr(self["istand"])
            iuplabel.fgcolor = FactionColor_RGB[1]
            iuplabel.image = targetls.var.IMAGE_DIR .. iuplabel.title
        elseif(tag == "sstand") then
            iuplabel.title = targetls.Player.standingstr(self["sstand"])
            iuplabel.fgcolor = FactionColor_RGB[2]
            iuplabel.image = targetls.var.IMAGE_DIR .. iuplabel.title
        elseif(tag == "ustand") then
            iuplabel.title = targetls.Player.standingstr(self["ustand"])
            iuplabel.fgcolor = FactionColor_RGB[3]
            iuplabel.image = targetls.var.IMAGE_DIR .. iuplabel.title
        elseif(tag == "lstand") then
            if(GetSectorMonitoredStatus() == 1) then 
                iuplabel.title = ""
            else
                if(self["id"] ~= GetCharacterID() and self["npc"] == "NO" and GetSectorAlignment() < 4) then
                        iuplabel.title = ""
                else
                    iuplabel.title = targetls.Player.standingstr(self["lstand"])
                    iuplabel.image = targetls.var.IMAGE_DIR..iuplabel.title
                    iuplabel.fgcolor = FactionColor_RGB[GetSectorAlignment()]
                end
            end
        end
        return iuplabel
    end

    function player:destroy()
        if(self["label"]) then
            iup.Detach(self["label"])
            iup.Destroy(self["label"])
        end
    end

    function player:target()
        radar.SetRadarSelection(GetPlayerNodeID(self["id"]), GetPrimaryShipIDOfPlayer(self["id"]))
        targetls.func.update()
    end

    return player
end

function targetls.Player.standingstr(stand)
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
