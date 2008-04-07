-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

-- The UIroid Dialog

targetls.UIroid = {}
targetls.UIroid.sectorname2id = {}

function targetls.UIroid.savelist(sid)
    if(sid and sid ~= 0) then
        local roids = ""
        local i = 1
        while(targetls.UIroid.element.rlist[i]) do
            local roid = {}
            string.gsub(targetls.UIroid.element.rlist[i],"<(.-)>", function(a) table.insert(roid,a) end)
            roids = roids.."<"..roid[1]..">"
            gkini.WriteString("roidls"..sid,""..roid[1],targetls.UIroid.element.rlist[i])
            i = i + 1
        end
        gkini.WriteString("roidls"..sid,"roids",roids)
    end
end

function targetls.UIroid.loadlist(sid)
    -- merge older version lists... remove this in future version
    targetls.RoidList:mergeold(sid)

    -- load this sectors list
    if(sid and sid ~= 0) then
        local i = 1 
        while(targetls.UIroid.element.rlist[i] ~= nil) do
            targetls.UIroid.element.rlist[i] = nil
            i = i + 1
        end

        local string = gkini.ReadString("roidls"..sid, "roids", "")
        local roids = {}
        local sectorroids = {}
        if string ~= "" then
            string.gsub(string,"<(.-)>", function(a) table.insert(roids,a) end)
            for i,v in ipairs(roids) do
                local roidstr = gkini.ReadString("roidls"..sid, ""..v, "")
                if roidstr ~= "" then
                    table.insert(sectorroids, roidstr)
                end
            end
        end

        for i,v in ipairs(sectorroids) do
            targetls.UIroid.element.rlist[i] = v
            targetls.UIroid.element.rlist.value = i 
        end
    end
end

targetls.UIroid.element = {}
targetls.UIroid.element.slist = iup.list { dropdown="YES" }
targetls.UIroid.element.rlist = iup.pdasubsubsublist{value=0,size="600x200",expand="HORIZONTAL"}
targetls.UIroid.element.upbutton = iup.stationbutton { title = "  up  " }
targetls.UIroid.element.downbutton = iup.stationbutton { title = "down" }
targetls.UIroid.element.editbutton = iup.stationbutton { title = "   Edit   " }
targetls.UIroid.element.removebutton = iup.stationbutton { title = "Remove", fgcolor="255 0 0" }
targetls.UIroid.element.exitbutton = iup.stationbutton { title = "Exit" }
    
targetls.UIroid.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffUIroid:\127o", expand = "HORIZONTAL" },
                iup.fill{}
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill { size = "10" },
                --rlist is populated on open/sector select...
                iup.label { title = "\127ddddddSectorID: \127o" },
                targetls.UIroid.element.slist,
                iup.fill {}
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill { size = "10" },
                --rlist is populated on open/sector select...
                targetls.UIroid.element.rlist,
                iup.fill {},
                iup.vbox
                {
                    targetls.UIroid.element.upbutton,
                    targetls.UIroid.element.downbutton
                },
                iup.fill { size = "10" }
            },
            iup.hbox
            {
                iup.fill { size = "10" },
                targetls.UIroid.element.editbutton,
                targetls.UIroid.element.removebutton
            },
            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIroid.element.exitbutton
            }
        }
    }
}

targetls.UIroid.dlg = iup.dialog 
{
    targetls.UIroid.mainbox;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetls.UIroid.element.exitbutton:action()
    targetls.UIroid.savelist(targetls.UIroid.sectorname2id[targetls.UIroid.element.slist[targetls.UIroid.element.slist.value]])
    targetls.RoidList:clear()
    targetls.RoidList:updatesector(GetCurrentSectorid())
    targetls.func.update()
    targetls.UIroid.edit.dlg:hide()
    targetls.UIroid.dlg:hide()
end

function targetls.UIroid.element.editbutton:action()
    local roidstr = targetls.UIroid.element.rlist[targetls.UIroid.element.rlist.value]
    local roid =  {}
    string.gsub(roidstr,"<(.-)>", function(a) table.insert(roid, a) end)
    targetls.UIroid.edit.element.id.title = roid[1]
    targetls.UIroid.edit.element.id.title = roid[1]
    targetls.UIroid.edit.element.note.value = roid[2] 
    targetls.UIroid.edit.element.ore.title = roid[3] 
    targetls.UIroid.edit.dlg:show()
    iup.Refresh(targetls.UIroid.edit.dlg)
end

function targetls.UIroid.element.removebutton:action()
    local i = targetls.UIroid.element.rlist.value
    while(targetls.UIroid.element.rlist[i] ~= nil) do
        targetls.UIroid.element.rlist[i] = targetls.UIroid.element.rlist[i+1]
        i = i + 1
    end
    if(targetls.UIroid.element.rlist[targetls.UIroid.element.rlist.value] == nil) then targetls.UIroid.element.rlist.value = targetls.UIroid.element.rlist.value - 1 end
end

function targetls.UIroid.element.upbutton:action()
    local i = targetls.UIroid.element.rlist.value
    if(tonumber(i) > 1) then
        local tmproid = targetls.UIroid.element.rlist[i]
        targetls.UIroid.element.rlist[i] = targetls.UIroid.element.rlist[i-1]
        targetls.UIroid.element.rlist[i-1] = tmproid
        targetls.UIroid.element.rlist.value = i - 1
    end
end

function targetls.UIroid.element.downbutton:action()
    local i = targetls.UIroid.element.rlist.value
    if(targetls.UIroid.element.rlist[i+1] ~= nil) then
        local tmproid = targetls.UIroid.element.rlist[i]
        targetls.UIroid.element.rlist[i] = targetls.UIroid.element.rlist[i+1]
        targetls.UIroid.element.rlist[i+1] = tmproid
        targetls.UIroid.element.rlist.value = i + 1
    end
end

function targetls.UIroid.element.slist:action(t,i,v)
    -- t is sector name, i is location in list, v is action state
    if(v == 0) then 
        -- this is the off callback for slist[i]
        targetls.UIroid.savelist(targetls.UIroid.sectorname2id[targetls.UIroid.element.slist[i]])
    elseif(v == 1) then 
        -- this is the on callback for slist[i]
        targetls.UIroid.loadlist(targetls.UIroid.sectorname2id[targetls.UIroid.element.slist[i]])
    end
    iup.Refresh(targetls.UIroid.dlg)
end

function targetls.UIroid.open()
    -- generate lists and show
    targetls.UIroid.element.slist.value = 0
    targetls.UIroid.sectorname2id = {}
    local sectors = {}
    string.gsub(gkini.ReadString("roidls", "sectors", ""),"<(.-)>", function(a) table.insert(sectors,a) end)
    for i,sid in ipairs(sectors) do 
        iup.SetAttribute(targetls.UIroid.element.slist,i,ShortLocationStr(tonumber(sid))) 
        if(tonumber(sid)==GetCurrentSectorid()) then 
            targetls.UIroid.element.slist.value = i 
        end
        targetls.UIroid.sectorname2id[ShortLocationStr(tonumber(sid))] = sid
    end

    targetls.UIroid.loadlist(GetCurrentSectorid())
    targetls.UIroid.dlg:show()
    iup.Refresh(targetls.UIroid.dlg)
end

-- Edit dialog
targetls.UIroid.edit = {}
targetls.UIroid.edit.element = {}
targetls.UIroid.edit.element.id = iup.label { title="" }
targetls.UIroid.edit.element.ore = iup.label { title="" }
targetls.UIroid.edit.element.note = iup.text { value="", size="200px" }
targetls.UIroid.edit.element.okbutton = iup.stationbutton { title = "OK" }
targetls.UIroid.edit.element.cancelbutton = iup.stationbutton { title = "Cancel" }
    
targetls.UIroid.edit.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffEdit Roid:\127o\n", expand = "HORIZONTAL" },
                iup.fill {}
            },
            iup.fill { size = "10"},
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "ID:  " },
                targetls.UIroid.edit.element.id,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Ore:  " },
                targetls.UIroid.edit.element.ore,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Note:" },
                targetls.UIroid.edit.element.note,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIroid.edit.element.okbutton,
                targetls.UIroid.edit.element.cancelbutton
            }
        }
    }
}

function targetls.UIroid.edit.element.okbutton:action()
    targetls.UIroid.element.rlist[targetls.UIroid.element.rlist.value] = "<"..
        targetls.UIroid.edit.element.id.title.."><"..
        targetls.UIroid.edit.element.note.value.."><"..
        targetls.UIroid.edit.element.ore.title..">"
    targetls.UIroid.edit.element.id.title = ""
    targetls.UIroid.edit.element.ore.title = ""
    targetls.UIroid.edit.element.note.value = ""
    targetls.UIroid.edit.dlg:hide()
end

function targetls.UIroid.edit.element.cancelbutton:action()
    targetls.UIroid.edit.element.id.title = ""
    targetls.UIroid.edit.element.ore.title = ""
    targetls.UIroid.edit.element.note.value = ""
    targetls.UIroid.edit.dlg:hide()
end

targetls.UIroid.edit.dlg = iup.dialog 
{
    targetls.UIroid.edit.mainbox;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}

-- Add dialog
targetls.UIroid.add = {}
targetls.UIroid.add.element = {}
targetls.UIroid.add.element.id = iup.label { title="" }
targetls.UIroid.add.element.ore = iup.label { title="" }
targetls.UIroid.add.element.note = iup.text { value="", size="200px" }
targetls.UIroid.add.element.okbutton = iup.stationbutton { title = "OK" }
targetls.UIroid.add.element.cancelbutton = iup.stationbutton { title = "Cancel" }
    
targetls.UIroid.add.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffAdd Roid:\127o\n", expand = "HORIZONTAL" },
                iup.fill {}
            },
            iup.fill { size = "10"},
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "ID:  " },
                targetls.UIroid.add.element.id,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Ore:  " },
                targetls.UIroid.add.element.ore,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Note:" },
                targetls.UIroid.add.element.note,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIroid.add.element.okbutton,
                targetls.UIroid.add.element.cancelbutton
            }
        }
    }
}

function targetls.UIroid.add.element.okbutton:action()
    targetls.RoidList:add(targetls.UIroid.add.element.id.title,
                          targetls.UIroid.add.element.note.value,
                          targetls.UIroid.add.element.ore.title)
    targetls.UIroid.add.element.id.title = ""
    targetls.UIroid.add.element.ore.title = ""
    targetls.UIroid.add.element.note.value = ""
    targetls.RoidList:updatesector(GetCurrentSectorid())
    targetls.func.update()
    targetls.UIroid.add.dlg:hide()
end

function targetls.UIroid.add.element.cancelbutton:action()
    targetls.UIroid.add.element.id.title = ""
    targetls.UIroid.add.element.ore.title = ""
    targetls.UIroid.add.element.note.value = ""
    targetls.UIroid.add.dlg:hide()
end

targetls.UIroid.add.dlg = iup.dialog 
{
    targetls.UIroid.add.mainbox;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}

