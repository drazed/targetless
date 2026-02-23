targetless.List = {}

function targetless.List:new()
    -- iup contains our dynamic/changing iup, cells contains each element within
    -- iup along with modifiable variables
    local list = {
        iup = vbox{},
        cells = {},
    }

    -- cells are empty by default, and can be modified as needed
    function list:add()
        local cell = targetless.Cell:new{}
        cell.iup = cell:getiup(targetless.var.layout.ship)
        table.insert(cells, #cells+1, cell)
        iup.Append(self.iup, cell.iup)
    end

    -- clear the cell contents, but leave the cells
    -- only clear from 'at' to end, default 'at' = 1
    function list:clear(at)
        if(not at) then at = 1 end
        while(cells[at] <= #cells) do
            cells[at].clear()
            at = at+1
        end
    end

    return list
end
