-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

-- The UIconfig Dialog

targetls.UIconfig = {}
targetls.UIconfig.element = {}
targetls.UIconfig.element.version = iup.label { title = targetls.var.version, fgcolor = "255 255 255" }
targetls.UIconfig.element.place = iup.list { "right", "left", "bottom"; dropdown="YES" }
targetls.UIconfig.element.slist = iup.list { "distance", "health", "faction"; dropdown="YES" }
targetls.UIconfig.element.fontlist = iup.list { "large", "regular", "small"; dropdown="YES" }
targetls.UIconfig.element.showtls = iup.stationtoggle { title = "Show TLS", value = targetls.var.showtls,  fgcolor = "200 200 200" }
targetls.UIconfig.element.showNPCtoggle = iup.stationtoggle { title = "Show NPC's", value = targetls.PlayerList.shownpc,  fgcolor = "200 200 200" }
targetls.UIconfig.element.showselftoggle = iup.stationtoggle { title = "Show Self", value = targetls.var.showself,  fgcolor = "200 200 200" }
targetls.UIconfig.element.lswidth = iup.text { value = "" .. targetls.var.lswidth, size = "50x" }
targetls.UIconfig.element.refreshtext = iup.text { value = "" .. targetls.var.refreshDelay/1000, size = "30x" }
targetls.UIconfig.element.maxlsize = iup.text { value = "" .. targetls.var.listmax, size = "30x" }
targetls.UIconfig.element.bindsbutton = iup.stationbutton { title = "Set Binds" }
targetls.UIconfig.element.okbutton = iup.stationbutton { title = "OK" }
targetls.UIconfig.element.cancelbutton = iup.stationbutton { title = "Cancel" }
    
targetls.UIconfig.mainbox = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffTARGETLS Config:\127o", expand = "HORIZONTAL" },
                iup.fill{},
                targetls.UIconfig.element.version
            },
            iup.fill { size = "20" },
            iup.hbox
            {
                iup.fill { size = "5" },
                -- targetls.UIconfig.element.showtls,
                -- iup.fill {},
                targetls.UIconfig.element.showselftoggle,
                iup.fill {},
                targetls.UIconfig.element.showNPCtoggle,
                iup.fill { size = "5" }
            },
            iup.fill{ size = "10"},
            iup.hbox
            {
                iup.fill { size = "10" },
                iup.label { title = "\127ddddddSort By:\127o", expand = "HORIZONTAL" },
                iup.fill {},
                targetls.UIconfig.element.slist,
                iup.fill { size = "10" }
            },
            iup.fill{ size = "10"},
            iup.hbox
            {
                iup.fill { size = "10" },
                iup.label { title = "\127ddddddFont Size:\127o", expand = "HORIZONTAL" },
                iup.fill {},
                targetls.UIconfig.element.fontlist,
                iup.fill { size = "10" }
            },
            iup.fill{ size = "10"},
            iup.hbox
            {
                iup.fill { size = "10" },
                iup.label { title = "\127ddddddWidth (pixels):\127o", expand = "HORIZONTAL" },
                iup.fill {},
                targetls.UIconfig.element.lswidth,
                iup.fill {size = "10" }
            },
            iup.fill{ size = "10"},
            iup.hbox
            {
                iup.fill { size = "10" },
                iup.label { title = "\127ddddddRefresh Delay (sec):\127o", expand = "HORIZONTAL" },
                iup.fill {},
                targetls.UIconfig.element.refreshtext,
                iup.fill {size = "10" }
            },
            iup.fill{ size = "10"},
            iup.hbox
            {
                iup.fill { size = "10" },
                iup.label { title = "\127ddddddList Max (targets):\127o", expand = "HORIZONTAL" },
                iup.fill {},
                targetls.UIconfig.element.maxlsize,
                iup.fill { size = "10" }
            },
            iup.fill{ size = "10"},
            iup.hbox
            {
                iup.fill { size = "5" },
                iup.label { title = "\127ddddddList Placement:\127o", expand = "HORIZONTAL" },
                iup.fill {},
                targetls.UIconfig.element.place,
                iup.fill { size = "5" }
            },
            iup.fill{ size = "25" },
            iup.hbox
            {
                targetls.UIconfig.element.bindsbutton,
                iup.fill{},
                targetls.UIconfig.element.okbutton,
                targetls.UIconfig.element.cancelbutton
            }
        }
    }
}

targetls.UIconfig.dlg = iup.dialog 
{
    targetls.UIconfig.mainbox;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetls.UIconfig.element.okbutton:action()
    local maxls = tonumber(targetls.UIconfig.element.maxlsize.value)
    local lswidth = tonumber(targetls.UIconfig.element.lswidth.value)
    local refreshT = tonumber(targetls.UIconfig.element.refreshtext.value)
    targetls.var.showtls = targetls.UIconfig.element.showtls.value 
    targetls.PlayerList.shownpc = targetls.UIconfig.element.showNPCtoggle.value 
    targetls.var.showself = targetls.UIconfig.element.showselftoggle.value 
    if targetls.UIconfig.element.slist.value == "1" then targetls.var.sortBy = "distance"
    elseif targetls.UIconfig.element.slist.value == "2" then targetls.var.sortBy = "health" 
    else targetls.var.sortBy = "faction" end

    local oldplace = targetls.var.place
    if targetls.UIconfig.element.place.value == "1" then targetls.var.place = "right"
    elseif targetls.UIconfig.element.place.value == "2" then targetls.var.place = "left" 
    else targetls.var.place = "bottom" end

    if targetls.UIconfig.element.fontlist.value == "1" then 
        targetls.var.font = targetls.func.getfont("Font.H5")
        gkini.WriteString("targetls", "font", "Font.H5")
    elseif targetls.UIconfig.element.fontlist.value == "2" then 
        targetls.var.font = targetls.func.getfont("Font.H6")
        gkini.WriteString("targetls", "font", "Font.H6")
    else 
        targetls.var.font = targetls.func.getfont("Font.Tiny")
        gkini.WriteString("targetls", "font", "Font.Tiny")
    end
    gkini.WriteString("targetls", "showtls", targetls.var.showtls)
    gkini.WriteString("targetls", "npc", targetls.PlayerList.shownpc)
    gkini.WriteString("targetls", "self", targetls.var.showself)
    gkini.WriteString("targetls", "sort", targetls.var.sortBy)
    gkini.WriteString("targetls", "place", targetls.var.place)
    if maxls ~= nil then 
        if(targetls.var.listmax ~= maxls) then
            -- clear the lists, so we don't have detach problems
            targetls.PlayerList:clear()
            targetls.RoidList:clear()
        end
        targetls.var.listmax = maxls 
        gkini.WriteString("targetls", "listmax", maxls)
    end
    if lswidth ~= nil then
        targetls.var.lswidth = lswidth 
        targetls.var.iupspacer1.size = lswidth.."x1"
        targetls.var.iupspacer2.size = lswidth.."x1"
        gkini.WriteString("targetls", "hudwidth", lswidth)
    end
    if refreshT ~= nil then 
        targetls.var.refreshDelay = refreshT*1000 
        gkini.WriteString("targetls", "refresh", refreshT*1000)
    end
    targetls.UIconfig.bind.dlg:hide()
    targetls.UIconfig.bind.custom.dlg:hide()
    targetls.UIconfig.bind.numkey.dlg:hide()
    targetls.UIconfig.bind.wheel.dlg:hide()

    targetls.func.update() 
    targetls.RoidList:updatesector(GetCurrentSectorid())
    targetls.UIconfig.dlg:hide()
    --scale the hud to change the list placement
    if(oldplace ~= targetls.var.place) then
        gkinterface.GKProcessCommand("hudscale")
        gkinterface.GKProcessCommand("hudscale")
    end
end

function targetls.UIconfig.element.cancelbutton:action()
    targetls.UIconfig.dlg:hide()
    targetls.UIconfig.bind.dlg:hide()
    targetls.UIconfig.bind.custom.dlg:hide()
    targetls.UIconfig.bind.numkey.dlg:hide()
    targetls.UIconfig.bind.wheel.dlg:hide()
end

function targetls.UIconfig.element.bindsbutton:action()
    targetls.UIconfig.bind.dlg:show()
    iup.Refresh(targetls.UIconfig.bind.dlg)
end

function targetls.UIconfig.open()
    local maxtext = "" .. targetls.var.listmax .. ""
    targetls.UIconfig.element.showtls.value = targetls.var.showtls
    targetls.UIconfig.element.showNPCtoggle.value = targetls.PlayerList.shownpc
    targetls.UIconfig.element.showselftoggle.value = targetls.var.showself
    targetls.UIconfig.element.maxlsize.value = "" .. targetls.var.listmax
    targetls.UIconfig.element.lswidth.value = "" .. targetls.var.lswidth
    targetls.UIconfig.element.refreshtext.value = "" .. targetls.var.refreshDelay/1000
    targetls.var.pagekey = gkini.ReadString("targetls", "pagekey", "~")
    if targetls.var.sortBy == "distance" then targetls.UIconfig.element.slist.value = 1
    elseif targetls.var.sortBy == "health" then  targetls.UIconfig.element.slist.value = 2 
    else targetls.UIconfig.element.slist.value = 3 end

    if targetls.var.place == "right" then targetls.UIconfig.element.place.value = 1
    elseif targetls.var.place == "left" then  targetls.UIconfig.element.place.value = 2
    else targetls.UIconfig.element.place.value = 3 end



    if targetls.var.font == Font.H5 then targetls.UIconfig.element.fontlist.value = 1
    elseif targetls.var.font == Font.H6 then targetls.UIconfig.element.fontlist.value = 2
    else targetls.UIconfig.element.fontlist.value = 3 end

    targetls.UIconfig.dlg:show()
    iup.Refresh(targetls.UIconfig.dlg)
end

-- The "Set Binds" confirmation dialog

targetls.UIconfig.bind = {}
targetls.UIconfig.bind.element = {}
targetls.UIconfig.bind.element.pagekey = iup.text { value = "" .. gkini.ReadString("targetls", "lspage", "'-'"), size = "50x" }
targetls.UIconfig.bind.element.nextkey = iup.text { value = "" .. gkini.ReadString("targetls", "lsnext", "']'"), size = "50x" }
targetls.UIconfig.bind.element.prevkey = iup.text { value = "" .. gkini.ReadString("targetls", "lsprev", "'['"), size = "50x" }
targetls.UIconfig.bind.element.raddkey = iup.text { value = "" .. gkini.ReadString("targetls", "radd", "'='"), size = "50x" }
targetls.UIconfig.bind.element.numkeybutton = iup.stationbutton { title = "# Keys " }
targetls.UIconfig.bind.element.custombutton = iup.stationbutton { title = "Custom" }
targetls.UIconfig.bind.element.wheelbutton = iup.stationbutton { title = "Wheel " }
targetls.UIconfig.bind.element.helpbutton = iup.stationbutton { title = "Help" }
targetls.UIconfig.bind.element.exitbutton = iup.stationbutton { title = "Exit" }

targetls.UIconfig.bind.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "\127ffffffSET BINDS:\127o\n\n\127eeeeee\127ff5555WARNING: Setting binds will overwrite what they\nwhere previously set for.  Use with caution.\127o\n\n\n# Keys --> Select targets with keyboard numbers.\nWheel --> Scroll targets list with mouse wheel.\127o", fgcolor = "255 255 255" }
            },
            iup.fill{ size = "25" },
            iup.hbox
            {
                targetls.UIconfig.bind.element.numkeybutton,
                iup.label { title = "--> Select with # keys.", fgcolor = "255 255 255" }
            },
            iup.fill{ size = "10" },
            iup.hbox
            {
                targetls.UIconfig.bind.element.wheelbutton,
                iup.label { title = "--> Select with mouse wheel.", fgcolor = "255 255 255" }
            },
            iup.fill{ size = "10" },
            iup.hbox
            {
                targetls.UIconfig.bind.element.custombutton,
                iup.label { title = "-->", fgcolor = "255 255 255" },
                iup.fill {},
                iup.vbox
                {
                    iup.hbox
                    {
                        iup.label { title = "cycle lists:", fgcolor = "255 255 255" },
                        iup.fill {},
                        targetls.UIconfig.bind.element.pagekey
                    },
                    iup.hbox
                    {
                        iup.label { title = "target next:", fgcolor = "255 255 255" },
                        iup.fill {},
                        targetls.UIconfig.bind.element.nextkey
                    },
                    iup.hbox
                    {
                        iup.label { title = "target previous:", fgcolor = "255 255 255" },
                        iup.fill {},
                        targetls.UIconfig.bind.element.prevkey
                    },
                    iup.hbox
                    {
                        iup.label { title = "add roid:", fgcolor = "255 255 255" },
                        iup.fill {},
                        targetls.UIconfig.bind.element.raddkey
                    }
                },
                iup.fill {}
            },
            iup.fill{ size = "25" },
            iup.hbox
            {
                targetls.UIconfig.bind.element.helpbutton,
                iup.fill{},
                targetls.UIconfig.bind.element.exitbutton
            }
        }
    }
}

targetls.UIconfig.bind.dlg = iup.dialog
{
    targetls.UIconfig.bind.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetls.UIconfig.bind.element.custombutton:action()
    targetls.UIconfig.bind.custom.open()
end

function targetls.UIconfig.bind.element.numkeybutton:action()
    targetls.UIconfig.bind.numkey.dlg:show()
end

function targetls.UIconfig.bind.element.wheelbutton:action()
    targetls.UIconfig.bind.wheel.dlg:show()
end

function targetls.UIconfig.bind.element.helpbutton:action()
    targetls.UIconfig.bind.help.dlg:show()
end

function targetls.UIconfig.bind.element.exitbutton:action()
    targetls.UIconfig.bind.dlg:hide()
    targetls.UIconfig.bind.custom.dlg:hide()
    targetls.UIconfig.bind.numkey.dlg:hide()
    targetls.UIconfig.bind.wheel.dlg:hide()
end




-- The "# Key Binds" confirmation dialog
targetls.UIconfig.bind.numkey = {}
targetls.UIconfig.bind.numkey.element = {}
targetls.UIconfig.bind.numkey.element.okbutton = iup.stationbutton { title = "OK" }
targetls.UIconfig.bind.numkey.element.cancelbutton = iup.stationbutton { title = "Cancel" }

targetls.UIconfig.bind.numkey.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.label { title = "\127ffffffSET # KEY BINDS:\127o\n\n\127eeeeeeThe following binds will be installed:\n"..
                "\t/bind '1' selecttarget1\n"..
                "\t/bind '2' selecttarget2\n"..
                "\t/bind '3' selecttarget3\n"..
                "\t/bind '4' selecttarget4\n"..
                "\t/bind '5' selecttarget5\n"..
                "\t/bind '6' selecttarget6\n"..
                "\t/bind '7' selecttarget7\n"..
                "\t/bind '8' selecttarget8\n"..
                "\t/bind '9' selecttarget9\n"..
                "\t/bind '0' selecttarget0\n"..
                "\t/bind '-' lsswitch\n"..
                "\t/bind '=' addroid\n"..
                "\n\127ff5555WARNING:This will overwrite the binds\ncurrently set to these keys.\127o", fgcolor = "255 255 255" },
            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIconfig.bind.numkey.element.okbutton,
                targetls.UIconfig.bind.numkey.element.cancelbutton
            }
        }
    }
}

targetls.UIconfig.bind.numkey.dlg = iup.dialog
{
    targetls.UIconfig.bind.numkey.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetls.UIconfig.bind.numkey.element.okbutton:action()
    gkinterface.GKProcessCommand("bind '1' selectTarget1")
    gkinterface.GKProcessCommand("bind '2' selectTarget2")
    gkinterface.GKProcessCommand("bind '3' selectTarget3")
    gkinterface.GKProcessCommand("bind '4' selectTarget4")
    gkinterface.GKProcessCommand("bind '5' selectTarget5")
    gkinterface.GKProcessCommand("bind '6' selectTarget6")
    gkinterface.GKProcessCommand("bind '7' selectTarget7")
    gkinterface.GKProcessCommand("bind '8' selectTarget8")
    gkinterface.GKProcessCommand("bind '9' selectTarget9")
    gkinterface.GKProcessCommand("bind '0' selectTarget10")
    gkinterface.GKProcessCommand("bind '-' lsswitch")
    gkinterface.GKProcessCommand("bind '=' addroid")
    targetls.UIconfig.bind.numkey.dlg:hide()
end

function targetls.UIconfig.bind.numkey.element.cancelbutton:action()
    targetls.UIconfig.bind.numkey.dlg:hide()
end

-- The "Mouse-Wheel Binds" confirmation dialog
targetls.UIconfig.bind.wheel = {}
targetls.UIconfig.bind.wheel.element = {}
targetls.UIconfig.bind.wheel.element.okbutton = iup.stationbutton { title = "OK" }
targetls.UIconfig.bind.wheel.element.cancelbutton = iup.stationbutton { title = "Cancel" }

targetls.UIconfig.bind.wheel.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.label { title = "\127ffffffSET # KEY BINDS:\127o\n\n\127eeeeeeThe following binds will be installed:\n"..
                "\t/bind MWHEELUP nextLS\n"..
                "\t/bind MWHEELDOWN prevLS\n"..
                "\t/bind MMBUTTON lsswitch\n"..
                "\n\127ff5555WARNING:This will overwrite the binds\ncurrently set to these keys.\127o", fgcolor = "255 255 255" },
            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIconfig.bind.wheel.element.okbutton,
                targetls.UIconfig.bind.wheel.element.cancelbutton
            }
        }
    }
}

targetls.UIconfig.bind.wheel.dlg = iup.dialog
{
    targetls.UIconfig.bind.wheel.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetls.UIconfig.bind.wheel.element.okbutton:action()
    gkinterface.GKProcessCommand("bind 'MWHEELUP' prevLS")
    gkinterface.GKProcessCommand("bind 'MWHEELDOWN' nextLS")
    gkinterface.GKProcessCommand("bind 'MMBUTTON' lsswitch")
    targetls.UIconfig.bind.wheel.dlg:hide()
end

function targetls.UIconfig.bind.wheel.element.cancelbutton:action()
    targetls.UIconfig.bind.wheel.dlg:hide()
end


-- The "Custom Binds" confirmation dialog
targetls.UIconfig.bind.custom = {}
targetls.UIconfig.bind.custom.element = {}
targetls.UIconfig.bind.custom.element.title = iup.label { title="", fgcolor = "255 255 255" }
targetls.UIconfig.bind.custom.element.okbutton = iup.stationbutton { title = "OK" }
targetls.UIconfig.bind.custom.element.cancelbutton = iup.stationbutton { title = "Cancel" }

targetls.UIconfig.bind.custom.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            targetls.UIconfig.bind.custom.element.title,

            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIconfig.bind.custom.element.okbutton,
                targetls.UIconfig.bind.custom.element.cancelbutton
            }
        }
    }
}

targetls.UIconfig.bind.custom.dlg = iup.dialog
{
    targetls.UIconfig.bind.custom.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetls.UIconfig.bind.custom.open()
    local title = "\127ffffffSET # KEY BINDS:\127o\n\n\127eeeeeeThe following binds will be installed:\n"
    if(targetls.UIconfig.bind.element.pagekey.value ~= "") then
        title = title.."\t/bind "..targetls.UIconfig.bind.element.pagekey.value.." lswitch\n"
    end
    if(targetls.UIconfig.bind.element.nextkey.value ~= "") then
        title = title.."\t/bind "..targetls.UIconfig.bind.element.nextkey.value.." nextLS\n"
    end
    if(targetls.UIconfig.bind.element.prevkey.value ~= "") then
        title = title.."\t/bind "..targetls.UIconfig.bind.element.prevkey.value.." prevLS\n"
    end
    if(targetls.UIconfig.bind.element.raddkey.value ~= "") then
        title = title.."\t/bind "..targetls.UIconfig.bind.element.raddkey.value.." addroid\n"
    end
    title = title.."\n\127ff5555WARNING:This will overwrite the binds\ncurrently set to these keys.\127o"
    targetls.UIconfig.bind.custom.element.title.title = title
    targetls.UIconfig.bind.custom.dlg:show()
end

function targetls.UIconfig.bind.custom.element.okbutton:action()
    if(targetls.UIconfig.bind.element.nextkey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetls.UIconfig.bind.element.nextkey.value.." nextLS")
    end
    if(targetls.UIconfig.bind.element.prevkey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetls.UIconfig.bind.element.prevkey.value.." prevLS")
    end
    if(targetls.UIconfig.bind.element.pagekey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetls.UIconfig.bind.element.pagekey.value.." lsswitch")
    end
    if(targetls.UIconfig.bind.element.raddkey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetls.UIconfig.bind.element.raddkey.value.." addroid")
    end
    targetls.UIconfig.bind.custom.dlg:hide()
end

function targetls.UIconfig.bind.custom.element.cancelbutton:action()
    targetls.UIconfig.bind.custom.dlg:hide()
end


-- The "Binds Help dialog
targetls.UIconfig.bind.help = {}
targetls.UIconfig.bind.help.element = {}
targetls.UIconfig.bind.help.element.exitbutton = iup.stationbutton { title = "exit" }

targetls.UIconfig.bind.help.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.label { title = "\127ffffffBINDS HELP:\127o\n\n\127eeeeee"..
                "You can use the quickset buttons ('# Keys' and 'Wheel')\n"..
                "to quickly setup your targetLS quickselect keys.\n\n"..
                "'# Keys' will bind the first 10 objects in your targetting\n"..
                "list to the # buttons on your keyboard, '-' to cycle list\n"..
                "types, and '=' to add an asteroid to the local list.\n\n"..
                "'Wheel' will bind the mouse-wheel to cycle targets from\n"..
                "the list, and the middle mouse button to cycle list types.\n\n"..
                "'Custom' will bind the values defined in the text fields\n"..
                "to the appropriate actions.  Empty fields will be ignored.\n"..
                "The field must contain a valid VO bind symbol, enclose\n"..
                "keyboard keys with single quotes (eg, 'a'), joystick\n"..
                "and mouse keys are defined without quotes.\127o",
                fgcolor = "255 255 255" },
            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetls.UIconfig.bind.help.element.exitbutton
            }
        }
    }
}

targetls.UIconfig.bind.help.dlg = iup.dialog
{
    targetls.UIconfig.bind.help.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetls.UIconfig.bind.help.element.exitbutton:action()
    targetls.UIconfig.bind.help.dlg:hide()
end

