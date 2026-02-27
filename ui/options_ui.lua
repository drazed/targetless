-- The ui.options Dialog
targetless.ui.options = {}
targetless.ui.options.lists = {}
targetless.ui.options.ships = {}
targetless.ui.options.ore = {}
targetless.ui.options.element = {}

targetless.ui.options.element.showself = iup.stationtoggle{title="Show Self Info Above Lists", value=targetless.var.showself}
targetless.ui.options.element.showselfcenter = iup.stationtoggle{title="Show Self Info in Center HUD", value=targetless.var.showselfcenter}
targetless.ui.options.element.showtargetcenter = iup.stationtoggle{title="Show Target Info in Center HUD", value=targetless.var.showtargetcenter}
targetless.ui.options.element.selfframe = iup.stationtoggle{title="Frame Self Info", value=targetless.var.selfframe}
targetless.ui.options.element.pinframe = iup.stationtoggle{title="Frame Pinned Targets", value=targetless.var.pinframe}
targetless.ui.options.element.listframe = iup.stationtoggle{title="Frame Lists", value=targetless.var.listframe}

targetless.ui.options.element.showpvp = iup.stationtoggle{title="Display PvP list on HUD", value=targetless.var.huddisplay.showpvp}
targetless.ui.options.element.showpve = iup.stationtoggle{title="Display PvE list on HUD", value=targetless.var.huddisplay.showpve}
targetless.ui.options.element.showcaps = iup.stationtoggle{title="Include capship list", value=targetless.var.huddisplay.showcaps}
targetless.ui.options.element.showbomb = iup.stationtoggle{title="Include bomber list", value=targetless.var.huddisplay.showbomb}
targetless.ui.options.element.showships = iup.stationtoggle{title="Include all ships list", value=targetless.var.huddisplay.showships}
targetless.ui.options.element.showore = iup.stationtoggle{title="Display Ore list on HUD", value=targetless.var.huddisplay.showore}

targetless.ui.options.element.slist = iup.list { "distance", "health", "faction"; dropdown="YES" }
targetless.ui.options.element.flist = iup.list { "smile","wheel","bar"; dropdown="YES" }
targetless.ui.options.element.basefontsize = iup.text { value = "" .. targetless.var.basefontsize, size = "100x" }
targetless.ui.options.element.maxlsize = iup.text { value = "" .. targetless.var.listmax, size = "100x" }
targetless.ui.options.element.autopin = {}
targetless.ui.options.element.autopin.damage = iup.stationtoggle{title="auto-pin ships that damage you", value=targetless.var.autopin.damage}
targetless.ui.options.element.reversewheel = iup.stationtoggle{title="Reverse mouse wheel direction", value=targetless.var.reversewheel}

targetless.ui.options.element.scanall = iup.stationtoggle{title="save all scanned ore", value=targetless.var.scanall}
targetless.ui.options.element.maxrsize = iup.text { value = "" .. targetless.var.roidmax, size = "100x" }
targetless.ui.options.element.oresort = iup.list { dropdown="YES"}
targetless.ui.options.element.oresort.value = 0
for i,ore in ipairs(targetless.RoidList.sortorder) do
    iup.SetAttribute(targetless.ui.options.element.oresort,i,ore)
    if(ore == targetless.var.oresort) then
        targetless.ui.options.element.oresort.value = i
    end
end

targetless.ui.options.element.saveore = iup.stationbutton { title = "Backup Ore" }
targetless.ui.options.element.restoreore = iup.stationbutton { title = "Restore Backup" }

function targetless.ui.options.element.saveore:action()
    local current = LoadSystemNotes(targetless.var.noteoffset+1) or ""
    if(current == "") then
        SaveSystemNotes(spickle(targetless.RoidList.allroids),targetless.var.noteoffset+1)
        print("ore backup complete!")
    else
        targetless.ui.options.element.confirmsave.dlg:show()
    end
end

targetless.ui.options.element.confirmsave = {}
targetless.ui.options.element.confirmsave.confirmbutton = iup.stationbutton { title = "Confirm" }
targetless.ui.options.element.confirmsave.cancelbutton = iup.stationbutton { title = "Cancel" }

targetless.ui.options.element.confirmsave.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffThis will overwrite the data currently saved to backup location.\127o\n", expand = "HORIZONTAL" },
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.options.element.confirmsave.confirmbutton,
                targetless.ui.options.element.confirmsave.cancelbutton,
            },
        },
    },
    expand="NO",
}

function targetless.ui.options.element.confirmsave.confirmbutton:action()
    SaveSystemNotes(spickle(targetless.RoidList.allroids),targetless.var.noteoffset+1)
    print("ore backup complete!")
    targetless.ui.options.element.confirmsave.dlg:hide()
end

function targetless.ui.options.element.confirmsave.cancelbutton:action()
    targetless.ui.options.element.confirmsave.dlg:hide()
end

targetless.ui.options.element.confirmsave.dlg = iup.dialog
{
    iup.vbox{
        iup.fill{},
        iup.hbox{
            iup.fill{},
            targetless.ui.options.element.confirmsave.mainbox,
            iup.fill{},
        },
        iup.fill{},
    },
    defaultesc=targetless.ui.options.element.confirmsave.cancelbutton,
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

function targetless.ui.options.element.restoreore:action()
    local current = LoadSystemNotes(targetless.var.noteoffset) or ""
    if(current == "") then
        current = LoadSystemNotes(targetless.var.noteoffset+1) or ""
        SaveSystemNotes(current,targetless.var.noteoffset)
        targetless.RoidList.allroids = unspickle(LoadSystemNotes(targetless.var.noteoffset) or "") or {}
        targetless.RoidList:load(GetCurrentSectorid())
        targetless.Controller:update()
        print("ore restore complete!")
    else
        targetless.ui.options.element.confirmrestore.dlg:show()
    end

end

targetless.ui.options.element.confirmrestore = {}
targetless.ui.options.element.confirmrestore.confirmbutton = iup.stationbutton { title = "Confirm" }
targetless.ui.options.element.confirmrestore.cancelbutton = iup.stationbutton { title = "Cancel" }

targetless.ui.options.element.confirmrestore.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffThis will overwrite any ore currently saved to the local list.\127o\n", expand = "HORIZONTAL" },
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.options.element.confirmrestore.confirmbutton,
                targetless.ui.options.element.confirmrestore.cancelbutton,
            },
        },
    },
    expand="NO",
}

function targetless.ui.options.element.confirmrestore.confirmbutton:action()
    local current = LoadSystemNotes(targetless.var.noteoffset+1) or ""
    SaveSystemNotes(current,targetless.var.noteoffset)
    targetless.RoidList.allroids = unspickle(LoadSystemNotes(targetless.var.noteoffset) or "") or {}
    targetless.RoidList:load(GetCurrentSectorid())
    targetless.Controller:update()
    print("ore restore complete!")
    targetless.ui.options.element.confirmrestore.dlg:hide()
end

function targetless.ui.options.element.confirmrestore.cancelbutton:action()
    targetless.ui.options.element.confirmrestore.dlg:hide()
end

targetless.ui.options.element.confirmrestore.dlg = iup.dialog
{
    iup.vbox{
        iup.fill{},
        iup.hbox{
            iup.fill{},
            targetless.ui.options.element.confirmrestore.mainbox,
            iup.fill{},
        },
        iup.fill{},
    },
    defaultesc=targetless.ui.options.element.confirmrestore.cancelbutton,
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

targetless.ui.options.element.fontslider = iup.canvas{
    scrollbar="HORIZONTAL", size="300x", border="YES",
    expand="NO",
    xmin = 50, xmax=150, dx=10, posx=0,
    scroll_cb=statechangefunc,
    active="YES",
}

targetless.ui.options.lists.tab = iup.vbox{
    iup.hbox
    {
        iup.label{title="\127ddddddScale:\127o",expand="HORIZONTAL"},
        iup.fill {},
        targetless.ui.options.element.fontslider,
    },
    iup.fill{size="30"},
    iup.hbox
    {
        iup.label { title = "\127ddddddBase font size:\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.basefontsize,
    },
    iup.fill{size="30"},
    iup.hbox
    {
        targetless.ui.options.element.showself,
    },
    iup.hbox
    {
        targetless.ui.options.element.showselfcenter,
    },
    iup.hbox
    {
        targetless.ui.options.element.showtargetcenter,
    },
    iup.fill{size="30"},
    iup.hbox
    {
        targetless.ui.options.element.selfframe,
        iup.fill{size="50"},
        targetless.ui.options.element.pinframe,
        iup.fill{size="50"},
        targetless.ui.options.element.listframe,
    },
    targetless.ui.options.element.autopin.damage,
    targetless.ui.options.element.reversewheel,
    iup.fill{size="30"},
    iup.vbox{
        targetless.ui.options.element.showpvp,
        targetless.ui.options.element.showpve,
        iup.vbox{
            targetless.ui.options.element.showcaps,
            targetless.ui.options.element.showbomb,
            targetless.ui.options.element.showships,
            margin="20x0",
        },
        targetless.ui.options.element.showore,
    },
    margin="10x10",
	tabtitle="Lists",
	hotkey=iup.K_l,
}

targetless.ui.options.ships.tab = iup.vbox{
    iup.hbox
    {
        iup.label { title = "\127ddddddDefault Sort By:\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.slist,
    },
    iup.fill{ size = "10"},
    iup.hbox
    {
        iup.label { title = "\127ddddddDisplay faction by:\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.flist,
    },
    iup.fill{ size = "10"},
    iup.hbox
    {
        iup.label { title = "\127ddddddList Max (targets):\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.maxlsize,
    },
    margin="10x10",
    iup.fill{ size = "10"},
	tabtitle="Ships",
	hotkey=iup.K_h,
}

targetless.ui.options.ore.tab = iup.vbox{
    targetless.ui.options.element.scanall,
    iup.hbox {
        iup.label { title = "\127ddddddDefault Sort First:\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.oresort,
    },
    iup.fill{ size = "10"},
    iup.hbox {
        iup.label { title = "\127ddddddMax List: (roids):\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.maxrsize,
    },
    iup.fill{},
    iup.hbox {
        iup.fill {},
        targetless.ui.options.element.saveore,
        targetless.ui.options.element.restoreore,
    },
    margin="10x10",
	tabtitle="Ore",
	hotkey=iup.K_r,
}

targetless.ui.options.main = iup.subsubtabtemplate{
    targetless.ui.options.lists.tab,
    targetless.ui.options.ships.tab,
    targetless.ui.options.ore.tab,
}
targetless.ui.options.main.tabtitle="Options"
targetless.ui.options.main.hotkey=iup.K_o
iup.Detach(targetless.ui.options.main[1][1][1][2])

function targetless.ui.options.main:OnShow()
    local maxtext = "" .. targetless.var.listmax .. ""
    targetless.ui.options.element.maxlsize.value = "" .. targetless.var.listmax
    if targetless.var.sortBy == "distance" then targetless.ui.options.element.slist.value = 1
    elseif targetless.var.sortBy == "health" then  targetless.ui.options.element.slist.value = 2 
    else targetless.ui.options.element.slist.value = 3 end

    if targetless.var.basefontsize == 0 then
        if gkinterface.IsTouchModeEnabled() then
            targetless.var.basefontsize = 20
        else
            targetless.var.basefontsize = 11
        end
    end
    targetless.ui.options.element.basefontsize.value = ""..targetless.var.basefontsize

    if(targetless.var.faction == "smile") then
        targetless.ui.options.element.flist.value = 1
    elseif(targetless.var.faction == "wheel") then
        targetless.ui.options.element.flist.value = 2
    else
        targetless.ui.options.element.flist.value = 3
    end

    targetless.ui.options.element.fontslider.posx = (targetless.var.fontscale or 1)*100
end

function targetless.ui.options.main:OnHide() 
    local maxls = tonumber(targetless.ui.options.element.maxlsize.value)
    local maxrs = tonumber(targetless.ui.options.element.maxrsize.value)
    if targetless.ui.options.element.slist.value == "1" then targetless.var.sortBy = "distance"
    elseif targetless.ui.options.element.slist.value == "2" then targetless.var.sortBy = "health" 
    else targetless.var.sortBy = "faction" end

    gkini.WriteString("targetless", "sort", targetless.var.sortBy)
    if maxls ~= nil then 
        if(targetless.var.listmax ~= maxls) then
            -- clear the lists, so we don't have detach problems
            targetless.Controller.currentbuffer:reset()
            targetless.RoidList:clear()
        end
        targetless.var.listmax = maxls 
        gkini.WriteString("targetless", "listmax", maxls)
    end
    if maxrs ~= nil then 
        if(targetless.Controller.mode == "Ore") then
            if(targetless.var.roidmax ~= maxrs) then
                -- clear the lists, so we don't have detach problems
                targetless.Controller.currentbuffer:reset()
                targetless.RoidList:clear()
            end
        end
        targetless.var.roidmax = maxrs 
        gkini.WriteString("targetless", "roidmax", maxrs)
    end
    targetless.var.fontscale = tonumber(targetless.ui.options.element.fontslider.posx)/100
    gkini.WriteInt("targetless", "fontscale", targetless.var.fontscale*100)

    targetless.var.basefontsize = tonumber(targetless.ui.options.element.basefontsize.value)
    gkini.WriteInt("targetless", "basefontsize", targetless.var.basefontsize)

    -- need to recalculate the font and trim data
    targetless.var.fontcalc()
    targetless.var.trimcalc()

    targetless.var.showself = targetless.ui.options.element.showself.value
    targetless.var.showselfcenter = targetless.ui.options.element.showselfcenter.value
    targetless.var.showtargetcenter = targetless.ui.options.element.showtargetcenter.value
    targetless.var.selfframe = targetless.ui.options.element.selfframe.value
    targetless.var.pinframe = targetless.ui.options.element.pinframe.value
    targetless.var.listframe = targetless.ui.options.element.listframe.value
    targetless.var.scanall = targetless.ui.options.element.scanall.value
    targetless.var.autopin.damage = targetless.ui.options.element.autopin.damage.value
    targetless.var.reversewheel = targetless.ui.options.element.reversewheel.value
    targetless.var.faction = targetless.ui.options.element.flist[targetless.ui.options.element.flist.value]
    targetless.var.oresort = targetless.ui.options.element.oresort[targetless.ui.options.element.oresort.value] or targetless.var.oresort
    gkini.WriteString("targetless", "pindamage", ""..targetless.var.autopin.damage)
    gkini.WriteString("targetless", "reversewheel", ""..targetless.var.reversewheel)
    gkini.WriteString("targetless", "showself", ""..targetless.var.showself)
    gkini.WriteString("targetless", "showselfcenter", ""..targetless.var.showselfcenter)
    gkini.WriteString("targetless", "showtargetcenter", ""..targetless.var.showtargetcenter)
    gkini.WriteString("targetless", "selfframe", ""..targetless.var.selfframe)
    gkini.WriteString("targetless", "pinframe", ""..targetless.var.pinframe)
    gkini.WriteString("targetless", "listframe", ""..targetless.var.listframe)
    gkini.WriteString("targetless", "scanall", ""..targetless.var.scanall)
    gkini.WriteString("targetless", "factiontype", ""..targetless.var.faction)
    gkini.WriteString("targetless", "oresort", ""..targetless.var.oresort)

    targetless.var.huddisplay.showpvp = targetless.ui.options.element.showpvp.value
    targetless.var.huddisplay.showpve = targetless.ui.options.element.showpve.value
    targetless.var.huddisplay.showcaps = targetless.ui.options.element.showcaps.value
    targetless.var.huddisplay.showbomb = targetless.ui.options.element.showbomb.value
    targetless.var.huddisplay.showships = targetless.ui.options.element.showships.value
    targetless.var.huddisplay.showore = targetless.ui.options.element.showore.value
    gkini.WriteString("targetless", "showpvp", ""..targetless.var.huddisplay.showpvp)
    gkini.WriteString("targetless", "showpve", ""..targetless.var.huddisplay.showpve)
    gkini.WriteString("targetless", "showcaps", ""..targetless.var.huddisplay.showcaps)
    gkini.WriteString("targetless", "showbomb", ""..targetless.var.huddisplay.showbomb)
    gkini.WriteString("targetless", "showships", ""..targetless.var.huddisplay.showships)
    gkini.WriteString("targetless", "showore", ""..targetless.var.huddisplay.showore)
    targetless.RoidList:load(GetCurrentSectorid())
    targetless.Controller:generatetotals()
    targetless.appendiups()
    targetless.Controller:update()

    -- cycle list if the current one has been disabled
    if 
        (targetless.Controller.mode == "PvP" and targetless.var.huddisplay.showpvp == "OFF") or
        (targetless.Controller.mode == "Cap" and (targetless.var.huddisplay.showcaps == "OFF" or targetless.var.huddisplay.showpve == "OFF")) or
        (targetless.Controller.mode == "Bomb" and (targetless.var.huddisplay.showbomb == "OFF" or targetless.var.huddisplay.showpve == "OFF")) or
        (targetless.Controller.mode == "All" and (targetless.var.huddisplay.showships == "OFF" or targetless.var.huddisplay.showpve == "OFF")) or
        (targetless.Controller.mode == "Ore" and targetless.var.huddisplay.showore == "OFF")
    then
        targetless.Controller:switch()
    end
end
