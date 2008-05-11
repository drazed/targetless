-- The ui.ore Dialog
targetless.ui.ore = {}
targetless.ui.ore.sectorname2id = {}

function targetless.ui.ore.savelist(sid)
    if(sid and sid ~= 0) then
        local roids = ""
        local i = 1
        while(targetless.ui.ore.element.rlist[i]) do
            local roid = {}
            string.gsub(targetless.ui.ore.element.rlist[i],"<(.-)>", function(a) table.insert(roid,a) end)
            roids = roids.."<"..roid[1]..">"
            gkini.WriteString("roidls"..sid,""..roid[1],targetless.ui.ore.element.rlist[i])
            i = i + 1
        end
        gkini.WriteString("roidls"..sid,"roids",roids)
    end
end

function targetless.ui.ore.loadlist(sid)
    -- load this sectors list
    if(sid) then
        local i = 1 
        while(targetless.ui.ore.element.rlist[i] ~= nil) do
            targetless.ui.ore.element.rlist[i] = nil
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

        targetless.ui.ore.element.rlist.value = 0
        for i,v in ipairs(sectorroids) do
            targetless.ui.ore.element.rlist[i] = v
            targetless.ui.ore.element.rlist.value = i 
        end
    end
end

targetless.ui.ore.element = {}
targetless.ui.ore.element.slist = iup.list { dropdown="YES",size="300" }
targetless.ui.ore.element.rlist = iup.pdasubsubsublist{value=0,size="400x300",expand="HORIZONTAL"}
targetless.ui.ore.element.upbutton = iup.stationbutton { title = "  up  " }
targetless.ui.ore.element.downbutton = iup.stationbutton { title = "down" }
targetless.ui.ore.element.editbutton = iup.stationbutton { title = "   Edit   " }
targetless.ui.ore.element.removebutton = iup.stationbutton { title = "Remove", fgcolor="255 0 0" }
    
targetless.ui.ore.mainbox = iup.vbox
{
    iup.hbox
    {
        --rlist is populated on open/sector select...
        iup.label { title = "\127ddddddSector: \127o", size="100"},
        targetless.ui.ore.element.slist,
        iup.fill {}
    },
    iup.vbox
    {
        --rlist is populated on open/sector select...
        targetless.ui.ore.element.rlist,
        iup.hbox
        {
            targetless.ui.ore.element.editbutton,
            targetless.ui.ore.element.removebutton,
            iup.fill{},
            targetless.ui.ore.element.downbutton,
            targetless.ui.ore.element.upbutton,
        },
    },
 }

targetless.ui.ore.main = iup.vbox{
	iup.label{title="Scanned Ore", expand="HORIZONTAL", font=Font.H3},
	iup.hbox{
		iup.fill{},
		alignment="ACENTER",
		gap=5,
	},
    targetless.ui.ore.mainbox,
	iup.fill{},
	gap=15,
	margin="2x2",
	tabtitle="Scanned Ore",
	alignment="ACENTER",
	hotkey=iup.K_S,
}

function targetless.ui.ore.main:OnShow() 
    -- generate lists and show
    targetless.ui.ore.element.slist.value = 0
    targetless.ui.ore.sectorname2id = {}
    local sectors = {}
    string.gsub(gkini.ReadString("roidls", "sectors", ""),"<(.-)>", function(a) table.insert(sectors,a) end)
    iup.SetAttribute(targetless.ui.ore.element.slist,1,"none") 
    targetless.ui.ore.sectorname2id["none"] = "0"
    for j,sid in ipairs(sectors) do 
        local i = j + 1
        iup.SetAttribute(targetless.ui.ore.element.slist,i,ShortLocationStr(tonumber(sid))) 
        if(tonumber(sid)==GetCurrentSectorid()) then 
            targetless.ui.ore.element.slist.value = i 
        end
        targetless.ui.ore.sectorname2id[ShortLocationStr(tonumber(sid))] = sid
    end
    targetless.ui.ore.loadlist(GetCurrentSectorid())
end

function targetless.ui.ore.main:OnHide() 
    targetless.ui.ore.savelist(targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[targetless.ui.ore.element.slist.value]])
    targetless.RoidList:clear()
    targetless.RoidList:updatesector(GetCurrentSectorid())
    targetless.Lists:update()
end

function targetless.ui.ore.element.editbutton:action()
    local roidstr = targetless.ui.ore.element.rlist[targetless.ui.ore.element.rlist.value]
    if not roidstr then return end
    local roid =  {}
    string.gsub(roidstr,"<(.-)>", function(a) table.insert(roid, a) end)
    targetless.ui.ore.edit.element.id.title = roid[1]
    targetless.ui.ore.edit.element.id.title = roid[1]
    targetless.ui.ore.edit.element.note.value = roid[2] 
    targetless.ui.ore.edit.element.ore.title = roid[3] 
    targetless.ui.ore.edit.dlg:show()
    iup.Refresh(targetless.ui.ore.edit.dlg)
end

function targetless.ui.ore.element.removebutton:action()
    local i = targetless.ui.ore.element.rlist.value
    while(targetless.ui.ore.element.rlist[i] ~= nil) do
        targetless.ui.ore.element.rlist[i] = targetless.ui.ore.element.rlist[i+1]
        i = i + 1
    end
    if(targetless.ui.ore.element.rlist[targetless.ui.ore.element.rlist.value] == nil) then targetless.ui.ore.element.rlist.value = targetless.ui.ore.element.rlist.value - 1 end
end

function targetless.ui.ore.element.upbutton:action()
    local i = targetless.ui.ore.element.rlist.value
    if(tonumber(i) > 1) then
        local tmproid = targetless.ui.ore.element.rlist[i]
        targetless.ui.ore.element.rlist[i] = targetless.ui.ore.element.rlist[i-1]
        targetless.ui.ore.element.rlist[i-1] = tmproid
        targetless.ui.ore.element.rlist.value = i - 1
    end
end

function targetless.ui.ore.element.downbutton:action()
    local i = targetless.ui.ore.element.rlist.value
    if(targetless.ui.ore.element.rlist[i+1] ~= nil) then
        local tmproid = targetless.ui.ore.element.rlist[i]
        targetless.ui.ore.element.rlist[i] = targetless.ui.ore.element.rlist[i+1]
        targetless.ui.ore.element.rlist[i+1] = tmproid
        targetless.ui.ore.element.rlist.value = i + 1
    end
end

function targetless.ui.ore.element.slist:action(t,i,v)
    -- t is sector name, i is location in list, v is action state
    if(v == 0) then 
        -- this is the off callback for slist[i]
        targetless.ui.ore.savelist(targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[i]])
    elseif(v == 1) then 
        -- this is the on callback for slist[i]
        targetless.ui.ore.loadlist(targetless.ui.ore.sectorname2id[targetless.ui.ore.element.slist[i]])
    end
end

-- Edit dialog
targetless.ui.ore.edit = {}
targetless.ui.ore.edit.element = {}
targetless.ui.ore.edit.element.id = iup.label { title="" }
targetless.ui.ore.edit.element.ore = iup.label { title="" }
targetless.ui.ore.edit.element.note = iup.text { value="", size="200px" }
targetless.ui.ore.edit.element.okbutton = iup.stationbutton { title = "OK" }
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
                iup.fill {}
            },
            iup.fill { size = "10"},
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "ID:  " },
                targetless.ui.ore.edit.element.id,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Ore:  " },
                targetless.ui.ore.edit.element.ore,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Note:" },
                targetless.ui.ore.edit.element.note,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.ore.edit.element.okbutton,
                targetless.ui.ore.edit.element.cancelbutton
            }
        }
    }
}

function targetless.ui.ore.edit.element.okbutton:action()
    targetless.ui.ore.element.rlist[targetless.ui.ore.element.rlist.value] = "<"..
        targetless.ui.ore.edit.element.id.title.."><"..
        targetless.ui.ore.edit.element.note.value.."><"..
        targetless.ui.ore.edit.element.ore.title..">"
    targetless.ui.ore.edit.element.id.title = ""
    targetless.ui.ore.edit.element.ore.title = ""
    targetless.ui.ore.edit.element.note.value = ""
    targetless.ui.ore.edit.dlg:hide()
end

function targetless.ui.ore.edit.element.cancelbutton:action()
    targetless.ui.ore.edit.element.id.title = ""
    targetless.ui.ore.edit.element.ore.title = ""
    targetless.ui.ore.edit.element.note.value = ""
    targetless.ui.ore.edit.dlg:hide()
end

targetless.ui.ore.edit.dlg = iup.dialog 
{
    targetless.ui.ore.edit.mainbox;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}

-- Add dialog
targetless.ui.ore.add = {}
targetless.ui.ore.add.element = {}
targetless.ui.ore.add.element.id = iup.label { title="" }
targetless.ui.ore.add.element.ore = iup.label { title="" }
targetless.ui.ore.add.element.note = iup.text { value="", size="200px" }
targetless.ui.ore.add.element.okbutton = iup.stationbutton { title = "OK" }
targetless.ui.ore.add.element.cancelbutton = iup.stationbutton { title = "Cancel" }
    
targetless.ui.ore.add.mainbox = iup.pdarootframe
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
                targetless.ui.ore.add.element.id,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Ore:  " },
                targetless.ui.ore.add.element.ore,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.hbox
            {
                iup.fill { size = "20"},
                iup.label { title = "Note:" },
                targetless.ui.ore.add.element.note,
                iup.fill {},
                iup.fill { size = "20"}
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.ore.add.element.okbutton,
                targetless.ui.ore.add.element.cancelbutton
            }
        }
    }
}

function targetless.ui.ore.add.element.okbutton:action()
    targetless.RoidList:add(targetless.ui.ore.add.element.id.title,
                          targetless.ui.ore.add.element.note.value,
                          targetless.ui.ore.add.element.ore.title)
    targetless.ui.ore.add.element.id.title = ""
    targetless.ui.ore.add.element.ore.title = ""
    targetless.ui.ore.add.element.note.value = ""
    targetless.RoidList:updatesector(GetCurrentSectorid())
    targetless.Lists:update()
    targetless.ui.ore.add.dlg:hide()
end

function targetless.ui.ore.add.element.cancelbutton:action()
    targetless.ui.ore.add.element.id.title = ""
    targetless.ui.ore.add.element.ore.title = ""
    targetless.ui.ore.add.element.note.value = ""
    targetless.ui.ore.add.dlg:hide()
end

targetless.ui.ore.add.dlg = iup.dialog 
{
    targetless.ui.ore.add.mainbox;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES",
}

