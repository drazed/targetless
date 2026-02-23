-- The ui.ore Dialog
targetless.ui.ore = {}
targetless.ui.ore.sectorname2id = {}

function targetless.ui.ore.importconfig()
    local allroids = {}
    local sectors = {}
    string.gsub(gkini.ReadString("roidls", "sectors", ""),"<(.-)>", function(a) table.insert(sectors,a) end)
    for i,sid in ipairs(sectors) do
        sid = tonumber(sid)

        local sectorstr = gkini.ReadString("roidls"..sid, "roids", "")
        local sectorroids = {}
        if(targetless.RoidList.allroids[tonumber(sid)]) then
            sectorroids = unspickle(targetless.RoidList.allroids[tonumber(sid)] or "") or {}
        end
        if string ~= "" then
            local roids = {}
            string.gsub(sectorstr,"<(.-)>", function(a) table.insert(roids,a) end)
            for i,v in ipairs(roids) do
                local roid = {}
                local roidstr = gkini.ReadString("roidls"..sid, ""..v, "")
                string.gsub(roidstr,"<(.-)>", function(a) table.insert(roid,a) end)
                if roidstr ~= "" then
                    local id, note, ores
                    id = roid[1]
                    note = roid[2]
                    ores = {}
                    string.gsub(roid[3],"'(.-)'", function(a)
                        a = string.gsub(a, "\r", "")
                        a = string.gsub(a, "\n", "")
                        a = string.gsub(a, "%%", "")
                        a = string.gsub(a, " Ore", "")
                        if a then
                            local ore = targetless.strsplit(": ",a)
                            ores[ore[1]] = ore[2]
                        end
                    end)
                    local newroid = {
                        id=tonumber(id),
                        note=note,
                        ore=ores,
                    }
                    sectorroids[tonumber(id)] = newroid
                end
            end
        end
        targetless.RoidList.allroids[tonumber(sid)] = spickle(sectorroids)
    end
    SaveSystemNotes(spickle(targetless.RoidList.allroids),targetless.var.noteoffset)
    targetless.RoidList:load(GetCurrentSectorid())
end

function targetless.ui.ore.loadlist(sid)
    -- load this sectors list
    if(sid) then
        local roids = unspickle(targetless.RoidList.allroids[sid] or "") or {}
        targetless.ui.ore.element.rmat:populate(function()
            targetless.ui.ore.element.rmatrix.table_sort = {}
            for i,v in pairs(roids) do
                local roid = {
                    ["id"] = (v.id or ""),
                    ["note"] = (v.note or ""),
                    ["He"] = tonumber(v.ore["Heliocene"] or 0),
                    ["Pe"] = tonumber(v.ore["Pentric"] or 0),
                    ["Ap"] = tonumber(v.ore["Apicene"] or 0),
                    ["Py"] = tonumber(v.ore["Pyronic"] or 0),
                    ["De"] = tonumber(v.ore["Denic"] or 0),
                    ["La"] = tonumber(v.ore["Lanthanic"] or 0),
                    ["Xi"] = tonumber(v.ore["Xithricite"] or 0),
                    ["Va"] = tonumber(v.ore["VanAzek"] or 0),
                    ["Is"] = tonumber(v.ore["Ishik"] or 0),
                    ["Fe"] = tonumber(v.ore["Ferric"] or 0),
                    ["Ca"] = tonumber(v.ore["Carbonic"] or 0),
                    ["Si"] = tonumber(v.ore["Silicate"] or 0),
                    ["Aq"] = tonumber(v.ore["Aquean"] or 0),
                }
                table.insert(targetless.ui.ore.element.rmatrix.table_sort, roid)
            end
            iup.SetFocus(targetless.ui.ore.element.rmat)
        end)
    end
end

targetless.ui.ore.element = {}
targetless.ui.ore.element.slist = iup.list { dropdown="YES",expand="HORIZONTAL",visible_items=10 }
targetless.ui.ore.element.rlist = iup.pdasubsubsublist{value=0,size="x500",expand="HORIZONTAL"}
targetless.ui.ore.element.clearbutton = iup.stationbutton { title = "Clear Sector" }

function targetless.ui.ore.element.clearbutton:action()
    targetless.ui.ore.element.clear.dlg:show()
end

targetless.ui.ore.element.clear = {}
targetless.ui.ore.element.clear.confirmbutton = iup.stationbutton { title = "Confirm" }
targetless.ui.ore.element.clear.cancelbutton = iup.stationbutton { title = "Cancel" }

targetless.ui.ore.element.clear.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffThis will clear all saved ore in currently selected sector.\127o\n", expand = "HORIZONTAL" },
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.ore.element.clear.confirmbutton,
                targetless.ui.ore.element.clear.cancelbutton,
            },
        },
    },
    expand="NO",
}

function targetless.ui.ore.element.clear.confirmbutton:action()
    targetless.RoidList.allroids[tonumber(targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[targetless.ui.ore.element.slist.value]])] = spickle({})
    SaveSystemNotes(spickle(targetless.RoidList.allroids),targetless.var.noteoffset)
    -- same as main:OnShow(), may want to refactor lots of this
    local i = 1
    while(targetless.ui.ore.element.slist[i]) do
       targetless.ui.ore.element.slist[i] = nil
       i = i + 1
    end
    targetless.ui.ore.element.slist.value = 0
    targetless.ui.ore.sectorname2id = {}
    iup.SetAttribute(targetless.ui.ore.element.slist,1,"none") 
    targetless.ui.ore.element.slist.value = 1
    targetless.ui.ore.sectorname2id["none"] = 0
    local j = 2
    local allsectors = {}
    for i,v in pairs(targetless.RoidList.allroids) do 
        table.insert(allsectors, i)
    end
    table.sort(allsectors)
    for i,v in pairs(allsectors) do 
        if(targetless.RoidList.allroids[v] and (#targetless.RoidList.allroids[v] > 0)) then
            iup.SetAttribute(targetless.ui.ore.element.slist,j,ShortLocationStr(tonumber(v))) 
            if(tonumber(v)==GetCurrentSectorid()) then 
                targetless.ui.ore.element.slist.value = j 
            end
            targetless.ui.ore.sectorname2id[ShortLocationStr(tonumber(v))] = v 
            j = j + 1
        end
    end
    targetless.ui.ore.loadlist(targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[targetless.ui.ore.element.slist.value]])
   -- END

    targetless.RoidList:load(targetless.RoidList.sector)
    targetless.Controller:update()
    print("sector ore cleared!")
    targetless.ui.ore.element.clear.dlg:hide()
end

function targetless.ui.ore.element.clear.cancelbutton:action()
    targetless.ui.ore.element.clear.dlg:hide()
end

targetless.ui.ore.element.clear.dlg = iup.dialog
{
    iup.vbox{
        iup.fill{},
        iup.hbox{
            iup.fill{},
            targetless.ui.ore.element.clear.mainbox,
            iup.fill{},
        },
        iup.fill{},
    },
    defaultesc=targetless.ui.ore.element.clear.cancelbutton,
    bgcolor="0 0 0 128 *",
    fullscreen="YES",
    topmost = "YES",
    BORDER="NO",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}

targetless.ui.ore.element.rmatrix = {
    [1] = {
    name = "note",
    fn=function(a,b)
        if a.name ~= b.name then
            return gkmisc.strnatcasecmp(a.note,b.note) < 0
        else
            return gkmisc.strnatcasecmp(a.note,b.note) > 0
        end
    end,
    itementry_fn = function(roid) return roid.note end,
    },
    [2] = {name="He",size=40},
    [3] = {name="Pe",size=40},
    [4] = {name="Ap",size=40},
    [5] = {name="Py",size=40},
    [6] = {name="De",size=40},
    [7] = {name="La",size=40},
    [8] = {name="Xi",size=40},
    [9] = {name="Va",size=40},
    [10] = {name="Is",size=40},
    [11] = {name="Fe",size=40},
    [12] = {name="Ca",size=40},
    [13] = {name="Si",size=40},
    [14] = {name="Aq",size=40},
    table_sort = {},
    defsort=2,
    numcol_visible=5,
    onedit=function(self, row, col, mode)
        if mode == 1 and self.table_sort[row] then
            targetless.ui.ore.edit.element.sector = targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[targetless.ui.ore.element.slist.value]]
            targetless.ui.ore.edit.element.id = self.table_sort[row].id
            targetless.ui.ore.edit.element.note.value = self.table_sort[row].note
            local ore = ""
            local i = 2
            while(i < 15) do
                if(self.table_sort[row][self[i].name] ~= 0) then
                    ore = ore..targetless.Roid.colorore(self[i].name)..":"..self.table_sort[row][self[i].name].."%  "
                end
                i = i + 1
            end
            targetless.ui.ore.edit.element.ore.title = ore
            targetless.ui.ore.edit.dlg:show()
            iup.Refresh(targetless.ui.ore.edit.dlg)
        end
    end,
}
for i,v in ipairs(targetless.ui.ore.element.rmatrix) do
    if i~=1 then
        v.fn = function(a,b) 
            return gkmisc.strnatcasecmp(a[v.name],b[v.name]) > 0
        end
        v.itementry_fn = function(roid) return roid[v.name] and ""..roid[v.name] or "" end
    end
end

targetless.ui.ore.element.rmat = targetless.matrix(targetless.ui.ore.element.rmatrix)
    
targetless.ui.ore.mainbox = iup.vbox
{
    iup.hbox {iup.fill{size="660"}},
    iup.hbox
    {
        --rlist is populated on open
        iup.label { title = "\127ddddddSector: \127o", size="100"},
        targetless.ui.ore.element.slist,
        targetless.ui.ore.element.clearbutton,
        iup.fill {}
    },
    iup.vbox
    {
        --rlist is populated on open/sector select...
        targetless.ui.ore.element.rmat,
    },
 }

targetless.ui.ore.main = iup.vbox{
    targetless.ui.ore.mainbox,
	iup.fill{},
	gap=15,
	margin="2x2",
	tabtitle="Scanned Ore",
	hotkey=iup.K_s,
}

function targetless.ui.ore.main:OnShow() 
    -- generate lists and show
    local i = 1
    while(targetless.ui.ore.element.slist[i]) do
       targetless.ui.ore.element.slist[i] = nil
       i = i + 1
    end
    targetless.ui.ore.element.slist.value = 0
    targetless.ui.ore.sectorname2id = {}
    iup.SetAttribute(targetless.ui.ore.element.slist,1,"none") 
    targetless.ui.ore.element.slist.value = 1
    targetless.ui.ore.sectorname2id["none"] = 0
    local j = 2
    local allsectors = {}
    for i,v in pairs(targetless.RoidList.allroids) do 
        table.insert(allsectors, i)
    end
    table.sort(allsectors)
    for i,v in pairs(allsectors) do 
        if(targetless.RoidList.allroids[v] and (#targetless.RoidList.allroids[v] > 0)) then
            iup.SetAttribute(targetless.ui.ore.element.slist,j,ShortLocationStr(tonumber(v))) 
            if(tonumber(v)==GetCurrentSectorid()) then 
                targetless.ui.ore.element.slist.value = j 
            end
            targetless.ui.ore.sectorname2id[ShortLocationStr(tonumber(v))] = v 
            j = j + 1
        end
    end
    targetless.ui.ore.loadlist(targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[targetless.ui.ore.element.slist.value]])
end

function targetless.ui.ore.main:OnHide() 
    targetless.RoidList:load(targetless.RoidList.sector)
    targetless.Controller:update()
end

function targetless.ui.ore.element.slist:action(t,i,v)
    -- t is sector name, i is location in list, v is action state
    if(v == 0) then 
        -- this is the off callback
        return
    elseif(v == 1) then 
        -- this is the on callback
        targetless.ui.ore.loadlist(targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[i]])
    end
end

-- Edit dialog
targetless.ui.ore.edit = {}
targetless.ui.ore.edit.element = {}
targetless.ui.ore.edit.element.sector = 0
targetless.ui.ore.edit.element.id = 0
targetless.ui.ore.edit.element.ore = iup.label { title="", font=targetless.var.font }
targetless.ui.ore.edit.element.note = iup.text { value="", size="200px" }
targetless.ui.ore.edit.element.savebutton = iup.stationbutton { title = "Save" }
targetless.ui.ore.edit.element.removebutton = iup.stationbutton { title = "Remove", fgcolor="255 0 0" }
targetless.ui.ore.edit.element.cancelbutton = iup.stationbutton { title = "Cancel" }
    
targetless.ui.ore.edit.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffEdit Roid:\127o\n", expand = "HORIZONTAL" },
            },
            iup.fill { size = "10"},
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Ore:  " },
                targetless.ui.ore.edit.element.ore,
            },
            iup.fill { size = "10"},
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Note:" },
                targetless.ui.ore.edit.element.note,
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.ore.edit.element.savebutton,
                targetless.ui.ore.edit.element.removebutton,
                targetless.ui.ore.edit.element.cancelbutton,
            },
        },
    },
    expand="NO",
}

function targetless.ui.ore.edit.element.savebutton:action()
    local roids = unspickle(targetless.RoidList.allroids[targetless.ui.ore.edit.element.sector] or "") or {}
    roids[targetless.ui.ore.edit.element.id].note = targetless.ui.ore.edit.element.note.value
    targetless.RoidList.allroids[tonumber(targetless.ui.ore.edit.element.sector)] = spickle(roids)
    SaveSystemNotes(spickle(targetless.RoidList.allroids),targetless.var.noteoffset)
    targetless.ui.ore.loadlist(targetless.ui.ore.edit.element.sector)
    targetless.ui.ore.edit.element.sector = 0
    targetless.ui.ore.edit.element.id = 0 
    targetless.ui.ore.edit.element.ore.title = ""
    targetless.ui.ore.edit.element.note.value = ""
    targetless.ui.ore.edit.dlg:hide()
    targetless.RoidList:load(targetless.RoidList.sector)
    targetless.Controller:update()
end

function targetless.ui.ore.edit.element.removebutton:action()
    local roids = unspickle(targetless.RoidList.allroids[targetless.ui.ore.edit.element.sector] or "") or {}
    local newroids = {}
    for k,v in pairs(roids) do
        if not (k == targetless.ui.ore.edit.element.id) then
            newroids[k] = v
        end
    end
    targetless.RoidList.allroids[tonumber(targetless.ui.ore.edit.element.sector)] = spickle(newroids)
    SaveSystemNotes(spickle(targetless.RoidList.allroids),targetless.var.noteoffset)
    targetless.ui.ore.loadlist(targetless.ui.ore.edit.element.sector)
    targetless.ui.ore.edit.element.sector = 0
    targetless.ui.ore.edit.element.id = 0 
    targetless.ui.ore.edit.element.ore.title = ""
    targetless.ui.ore.edit.element.note.value = ""
    targetless.ui.ore.edit.dlg:hide()
    targetless.RoidList:load(targetless.RoidList.sector)
    targetless.Controller:update()
end

function targetless.ui.ore.edit.element.cancelbutton:action()
    targetless.ui.ore.edit.element.sector = 0
    targetless.ui.ore.edit.element.id = 0
    targetless.ui.ore.edit.element.ore.title = ""
    targetless.ui.ore.edit.element.note.value = ""
    targetless.ui.ore.edit.dlg:hide()
end

targetless.ui.ore.edit.dlg = iup.dialog 
{
    iup.vbox{
        iup.fill{},
        iup.hbox{
            iup.fill{},
            targetless.ui.ore.edit.mainbox,
            iup.fill{},
        },
        iup.fill{},
    },
    defaultesc=targetless.ui.ore.edit.element.cancelbutton,
    bgcolor="0 0 0 128 *",
    fullscreen="YES",
    topmost = "YES",
    BORDER="NO",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}
