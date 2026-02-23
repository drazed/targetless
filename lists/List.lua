targetless.List = {}

function targetless.List:new()
    local list = {
        -- iup = vbox{},
        -- cells = {},
        offset = 0,
    }

    --[[
    function list:addcell()
        local cell = targetless.Cell:new{}
        cell.iup = cell:getiup(targetless.var.layout.ship)
        table.insert(cells, #cells+1, cell)
        iup.Append(self.iup, cell.iup)
    end
    --]]

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
            self[1].numlabel = nil
            self[1].label = nil
            table.remove(self, 1)
        end
    end

    function list:getiup()
        local iuplist = iup.vbox{}
        for i,v in ipairs(self) do
            if(self.offset+i > targetless.var.listmax) then return iuplist end
            local itemlabel
            local numlabel = iup.label {title = "" .. self.offset+i, fgcolor="150 150 150", font = targetless.var.font, size=40, alignment="ACENTER" }
            if(v.hostile) then
                numlabel.fgcolor = "155 32 32"
            else
                numlabel.fgcolor = "32 155 32"
            end
            if (v.name == HUD.targetname.title or "Turret ("..v.name..")" == HUD.targetname.title) then
                targetless.var.targetnum = self.offset+i
                v.fontcolor = "255 255 255"
                numlabel.fgcolor = "255 255 255"
                numlabel.font = Font.H1
                if(v.hostile) then
                    numlabel.fgcolor = "255 64 64"
                else
                    numlabel.fgcolor = "64 255 64"
                end
            end
            v.numlabel = numlabel 
            local iupbox = iup.vbox{
                iup.hbox
                {
                    v.numlabel,
                    v.label,
                    alignment="ACENTER",
                },
            }
            iup.Append(iuplist, iupbox)
        end
        return iuplist
    end
    return list
end
