targetless.ui = {}

local bg = {
    [0] = "30 55 78 96",
    [1] = "42 74 96 96",
    [2] = "65 100 127 255",
}
local bg_numbers = {
    [0] = {30, 55, 78, 96},
    [1] = {42, 74, 96, 96},
    [2] = {65, 100, 127, 255},
}

function targetless.ui.matrix(funcs)
    local curselindex
    local sort_key = funcs.defsort or 1
    
    local mat = iup.pdasubsubsubmatrix{
        numcol=#funcs,
        numcol_visible=funcs.numcol_visible or #funcs,
        numlin=0,
        numlin_visible=funcs.numlin_visible or 14,
        expand=funcs.expand or "YES",
        size=funcs.size,
    }
    
    for i, n in ipairs(funcs) do
        mat["0:"..i] = n.name
        mat["ALIGNMENT"..i] = n.alignment or "ALEFT"
    end
    
    local function set_sort_mode(mode)
        sort_key = mode
        for i=1, #funcs do
            mat:setattribute("FGCOLOR", 0, i, mode == i and tabseltextcolor or tabunseltextcolor)
        end
    end
    
    function mat:fgcolor_cb(row, col)
        local colorindex = math.fmod(row,2)
        local c = bg_numbers[colorindex]
        return c[1],c[2],c[3],c[4],iup.DEFAULT
    end
    mat.bgcolor_cb = mat.fgcolor_cb
    
    function mat:leaveitem_cb(row, col)
        local sel = curselindex and curselindex or row
        mat:setattribute("BGCOLOR", sel, -1, bg[math.fmod(sel, 2)])
        curselindex = nil
    end
    
    function mat:enteritem_cb(row, col, str)
        if curselindex then mat:setattribute("BGCOLOR", curselindex, -1, bg[math.fmod(row, 2)]) end
        curselindex = row
        mat:setattribute("BGCOLOR", row, -1, bg[2])
    end
    
    local function reload_matrix(self)
        local numitems = #funcs.table_sort
        mat.numlin = numitems
        for i,v in ipairs(funcs.table_sort) do
            mat:update_itementry(i, v)
        end
        if numitems > 0 and curselindex then
            if curselindex > numitems then
                curselindex = nil
            else
                local curs = curselindex
                mat:leaveitem_cb(curs, 1)
                mat:enteritem_cb(curs, 1)
            end
        end
    end
    mat.reload = reload_matrix
    
    local function update_matrix(self)
        local sort = funcs[sort_key].fn
        if curselindex then
            local oldsel = funcs.table_sort[curselindex]
            local oldindex = curselindex
            mat:leaveitem_cb(curselindex, 1)
            table.sort(funcs.table_sort, sort)
            for i,v in ipairs(funcs.table_sort) do
                if v == oldsel then mat:enteritem_cb(i, 1) break end
            end
        else table.sort(funcs.table_sort, sort)
        end
        set_sort_mode(sort_key)
        reload_matrix()
    end
    mat.update = update_matrix
    
    function mat:click_cb(row, col)
        if row == 0 then
            set_sort_mode(col)
            update_matrix()
        elseif funcs.onsel then
            funcs.onsel(row, col)
        end
    end
    
    function mat:edition_cb(row, col, mode)
        if funcs.onedit then funcs:onedit(row, col, mode) return iup.IGNORE else return iup.IGNORE end
    end
    
    function mat:update_itementry(i, item)
        for n=1, #funcs do
            self:setcell(i, n, " ".. funcs[n].itementry_fn(item))
        end
    end
    
    function mat:populate(func)
        curselindex = nil
        self.dellin = "1--1"
        func()
        update_matrix()
        ShowDialog(targetless.ui.dlg)
    end
    
    return mat
end

function targetless.ui.getdist(a,b)
    local adist = targetless.NavDist[GetSystemID(GetCurrentSectorid())][GetSystemID(a)] or 10000
    local bdist = b and (targetless.NavDist[GetSystemID(GetCurrentSectorid())][GetSystemID(b)] or 10000) or nil
    return adist, bdist
end

dofile("ui/home_ui.lua")
dofile("ui/options_ui.lua")
dofile("ui/controls_ui.lua")
dofile("ui/ui_matrix.lua")
dofile("ui/roid_ui.lua")

targetless.ui.close = iup.stationbutton{title="Click To Close", expand="HORIZONTAL", action=function(self) 
    targetless.ui.options.main:OnHide()
    targetless.ui.ore.main:OnHide()
    HideDialog(targetless.ui.dlg) 
end}
targetless.ui.optionsbutton = iup.stationbutton{title="Options", hotkey=iup.K_o, action=function() 
    ShowDialog(targetless.options.dlg) 
    targetless.options.tabs:OnShow() 
end}

targetless.ui.tabs = iup.roottabtemplate{
    targetless.ui.home.main,
    targetless.ui.controls.main,
    targetless.ui.options.main,
    targetless.ui.ore.main,
    secondary = iup.hbox{
        iup.fill{},
        iup.label{title="Version "..targetless.var.version, alignment="ACENTER", fgcolor=tabseltextcolor},
        iup.fill{},
        margin="5x5"
    },
}

targetless.ui.dlg = iup.dialog{
    iup.vbox{
        iup.fill{},
        iup.hbox{
            iup.fill{},
            iup.pdarootframe{
                iup.vbox{
                    iup.hbox{
                        targetless.ui.close,
                        gap=5,
                    },
                    targetless.ui.tabs,
                    expand="NO",
                    gap=8,
                },
            },
            iup.fill{},
        },
        iup.fill{},
    },
    defaultesc=targetless.ui.close,
    bgcolor="0 0 0 144 *",
    fullscreen="YES",
    border="NO",
    resize="NO",
    maxbox="NO",
    minbox="NO",
    menubox="NO",
    topmost="YES",
}
targetless.ui.dlg:map()

function targetless.ui.show()
    ShowDialog(targetless.ui.dlg)
    targetless.ui.options.main:OnShow()
    targetless.ui.ore.main:OnShow()
    targetless.ui.tabs:OnShow()
end

--local stationbutton = iup.stationbutton{title="TargetLess", action=targetless.ui.show, expand="HORIZONTAL", hotkey=iup.K_exclam}
--local pdabutton = iup.stationbutton{title="TargetLess", action=targetless.ui.show, expand="HORIZONTAL", hotkey=iup.K_exclam}
--local capbutton = iup.stationbutton{title="TargetLess", action=targetless.ui.show, expand="HORIZONTAL", hotkey=iup.K_exclam}
--iup.Append(iup.GetParent(StationLaunchButton), stationbutton)
--iup.Append(iup.GetParent(PDACloseButton), pdabutton)
--iup.Append(iup.GetParent(CapShipLaunchButton), capbutton)
