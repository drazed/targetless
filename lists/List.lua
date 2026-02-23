targetless.List = {}

function targetless.List:new()
    local list = {}

    function list:add(item)
        local i = 1
        while(self[i] and item[targetless.var.sortBy] and self[i][targetless.var.sortBy] < item[targetless.var.sortBy]) do
            i = i + 1
        end
        if(i <= targetless.var.listmax) then
            table.insert(self, i, item)
        end
    end

    function list:clear()
        while(self[1]) do
            table.remove(self, 1)
        end
    end

    return list
end
