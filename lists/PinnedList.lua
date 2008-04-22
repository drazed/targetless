dofile('lists/Player.lua')
targetless.PinnedList = {}
targetless.PinnedList.self = nil
targetless.PinnedList.showpc = gkini.ReadString("targetless", "pc", "ON") 
targetless.PinnedList.shownpc = gkini.ReadString("targetless", "npc", "ON")

function targetless.PinnedList:add(charid)
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

function targetless.PinnedList:clear()
    while(self[1]) do
        table.remove(self, 1)
    end
end

