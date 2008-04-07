dofile('Player.lua')
targetls.PlayerList = {}
targetls.PlayerList.self = nil
targetls.PlayerList.showpc = gkini.ReadString("targetls", "pc", "ON") 
targetls.PlayerList.shownpc = gkini.ReadString("targetls", "npc", "ON")

function targetls.PlayerList:add(charid)
    local player = targetls.Player:new()
    player["id"] = charid
    if GetGuildTag(charid) ~= "" then player["name"] = "[" .. GetGuildTag(charid) .. "] " end
    player["name"] = player["name"] .. GetPlayerName(charid)
    player["distance"] = math.floor(GetPlayerDistance(charid) or 0)
    player["health"] = math.floor(GetPlayerHealth(charid) or 0)
    player["faction"] = GetPlayerFaction(charid)
    player["istand"] = factionfriendlyness(GetPlayerFactionStanding(1, charid))
    player["sstand"] = factionfriendlyness(GetPlayerFactionStanding(2, charid))
    player["ustand"] = factionfriendlyness(GetPlayerFactionStanding(3, charid))
    player["lstand"] = factionfriendlyness(GetPlayerFactionStanding("sector", charid))
    player["ship"] = GetPrimaryShipNameOfPlayer(charid)
    if player["name"] and player["health"] and player["faction"] and player["ship"] then
        if charid and charid ~= 0 and player["distance"] ~= 0 then
            if(string.sub(player["name"], 1, string.len("*")) == "*") then
                if self.shownpc == "OFF" then return end
                player["npc"] = "YES"
            else
                if targetls.var.showpc == "OFF" then return end
            end
            if player["name"] == "(reading transponder " .. charid .. ")" then
                player["name"] = "(reading transponder)"
            end
            local i = 1 
            while(self[i] and self[i][targetls.var.sortBy] < player[targetls.var.sortBy]) do
                i = i + 1
            end
            if(i <= targetls.var.listmax) then
                table.insert(self, i, player)
            end
        elseif player["id"] == GetCharacterID()  then
            if(targetls.var.showself == "ON") then
                player.fontcolor = "255 255 255"
                self.self = player
            else
                self.self = nil
            end
        end
    end
    return player
end

function targetls.PlayerList:clear()
    while(self[1]) do
        self[1]:destroy()
        table.remove(self, 1)
    end
end

function targetls.PlayerList:refresh(tlist)
    if(self.self ~= nil) then self.self:destroy() end
    self:clear()

    ForEachPlayer(function (id) 
        self:add(id) 
    end)

    if(self.self ~= nil) then
        self.self["label"] = self.self:getiup(targetls.var.layout.self)
        iup.Append(targetls.var.iupself, self.self["label"])
        iup.Map(self.self["label"])
    end

    for i,v in ipairs(self) do
        if(i <= targetls.var.listmax) then
            local iupbox
            local playerlabel
            local numlabel = iup.label {title = "" .. i, fgcolor="150 150 150", font = targetls.var.font, size=30, alignment="ACENTER" }
            if v["name"] == HUD.targetname.title then
                v.fontcolor = "255 255 255"
                numlabel.fgcolor = "255 255 255"
                numlabel.font = Font.H1 
            end
            if(v["npc"] == "YES") then
                playerlabel = v:getiup(targetls.var.layout.npc)
            else
                playerlabel = v:getiup(targetls.var.layout.pc)
            end
            iupbox = iup.hbox
            {
                numlabel,
                playerlabel
            }
            v["label"] = iupbox
            iup.Append(targetls.var.iupplayers, v["label"])
            iup.Map(v["label"])
            i = i + 1
        end
    end
end

