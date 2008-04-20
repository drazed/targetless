dofile('lists/Player.lua')
targetless.PlayerList = {}
targetless.PlayerList.self = nil
targetless.PlayerList.showpc = gkini.ReadString("targetless", "pc", "ON") 
targetless.PlayerList.shownpc = gkini.ReadString("targetless", "npc", "ON")

function targetless.PlayerList:add(charid)
    local player = targetless.Player:new(charid)
    if player and player["distance"] ~= 0 then
        if(string.sub(player["name"], 1, string.len("*")) == "*") then
            player["npc"] = "YES"
        end
        if player["name"] == "(reading transponder " .. charid .. ")" then
            player["name"] = "(reading transponder)"
        end
        local i = 1 
        while(self[i] and self[i][targetless.var.sortBy] < player[targetless.var.sortBy]) do
            i = i + 1
        end
        if(i <= targetless.var.listmax) then
            table.insert(self, i, player)
        end
    end
    return player
end

function targetless.PlayerList:clear()
    while(self[1]) do
        table.remove(self, 1)
    end
end

