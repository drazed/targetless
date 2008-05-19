targetless.ui.controls = {}
targetless.ui.controls.element = {}
targetless.ui.controls.element.pinkey = iup.text { value = "" .. gkini.ReadString("targetless", "pin", "'p'"), size = "50x" }
targetless.ui.controls.element.pagekey = iup.text { value = "" .. gkini.ReadString("targetless", "lspage", "'-'"), size = "50x" }
targetless.ui.controls.element.nextkey = iup.text { value = "" .. gkini.ReadString("targetless", "lsnext", "']'"), size = "50x" }
targetless.ui.controls.element.prevkey = iup.text { value = "" .. gkini.ReadString("targetless", "lsprev", "'['"), size = "50x" }
targetless.ui.controls.element.raddkey = iup.text { value = "" .. gkini.ReadString("targetless", "radd", "'='"), size = "50x" }
targetless.ui.controls.element.numkeybutton = iup.stationbutton { title = "# Keys " }
targetless.ui.controls.element.custombutton = iup.stationbutton { title = "Custom" }
targetless.ui.controls.element.wheelbutton = iup.stationbutton { title = "Wheel " }
targetless.ui.controls.element.helpbutton = iup.stationbutton { title = "Help" }

targetless.ui.controls.confirm = iup.vbox {
    iup.hbox
    {
        targetless.ui.controls.element.numkeybutton,
        targetless.ui.controls.element.wheelbutton,
        targetless.ui.controls.element.custombutton,
    },
    iup.fill{ size = "30" },
    iup.hbox
    {
        iup.fill {},
        iup.vbox
        {
            iup.hbox
            {
                iup.label { title = "cycle lists:", fgcolor = "255 255 255" },
                iup.fill {},
                targetless.ui.controls.element.pagekey
            },
            iup.hbox
            {
                iup.label { title = "add roid:", fgcolor = "255 255 255" },
                iup.fill {},
                targetless.ui.controls.element.raddkey
            },
            iup.hbox
            {
                iup.label { title = "target next:", fgcolor = "255 255 255" },
                iup.fill {},
                targetless.ui.controls.element.nextkey
            },
            iup.hbox
            {
                iup.label { title = "target previous:", fgcolor = "255 255 255" },
                iup.fill {},
                targetless.ui.controls.element.prevkey
            },
            iup.hbox
            {
                iup.label { title = "pin/unpin target:", fgcolor = "255 255 255" },
                iup.fill {},
                targetless.ui.controls.element.pinkey
            },

        },
        iup.fill {}
    },
    iup.fill{},
    targetless.ui.controls.element.helpbutton,
}

targetless.ui.controls.main = iup.vbox{
	iup.label{title="TargetLess Controls", expand="HORIZONTAL", font=Font.H3},
	iup.hbox{
		iup.fill{},
		alignment="ACENTER",
		gap=5,
	},
    targetless.ui.controls.confirm,
	gap=15,
	margin="2x2",
	tabtitle="Controls",
	alignment="ACENTER",
	hotkey=iup.K_c,
}

function targetless.ui.controls.main:OnShow() 
    targetless.ui.controls.element.pinkey.value = "" .. gkini.ReadString("targetless", "pin", "'p'")
    targetless.ui.controls.element.pagekey.value = "" .. gkini.ReadString("targetless", "lspage", "'-'")
    targetless.ui.controls.element.nextkey.value = "" .. gkini.ReadString("targetless", "lsnext", "']'")
    targetless.ui.controls.element.prevkey.value = "" .. gkini.ReadString("targetless", "lsprev", "'['")
    targetless.ui.controls.element.raddkey.value = "" .. gkini.ReadString("targetless", "radd", "'='")
end
function targetless.ui.controls.main:OnHide() end

function targetless.ui.controls.element.custombutton:action()
    targetless.ui.controls.custom.open()
end

function targetless.ui.controls.element.numkeybutton:action()
    targetless.ui.controls.numkey.dlg:show()
end

function targetless.ui.controls.element.wheelbutton:action()
    targetless.ui.controls.wheel.dlg:show()
end

function targetless.ui.controls.element.helpbutton:action()
    targetless.ui.controls.help.dlg:show()
end

-- The "# Key controls" confirmation dialog
targetless.ui.controls.numkey = {}
targetless.ui.controls.numkey.element = {}
targetless.ui.controls.numkey.element.okbutton = iup.stationbutton { title = "OK" }
targetless.ui.controls.numkey.element.cancelbutton = iup.stationbutton { title = "Cancel" }

targetless.ui.controls.numkey.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.label { title = "\127ffffffSET # KEY controls:\127o\n\n\127eeeeeeThe following controls will be installed:\n"..
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
                "\n\127ff5555WARNING:This will overwrite the controls\ncurrently set to these keys.\127o", fgcolor = "255 255 255" },
            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.controls.numkey.element.okbutton,
                targetless.ui.controls.numkey.element.cancelbutton
            }
        }
    }
}

targetless.ui.controls.numkey.dlg = iup.dialog
{
    targetless.ui.controls.numkey.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetless.ui.controls.numkey.element.okbutton:action()
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
    targetless.ui.controls.numkey.dlg:hide()
end

function targetless.ui.controls.numkey.element.cancelbutton:action()
    targetless.ui.controls.numkey.dlg:hide()
end

-- The "Mouse-Wheel controls" confirmation dialog
targetless.ui.controls.wheel = {}
targetless.ui.controls.wheel.element = {}
targetless.ui.controls.wheel.element.okbutton = iup.stationbutton { title = "OK" }
targetless.ui.controls.wheel.element.cancelbutton = iup.stationbutton { title = "Cancel" }

targetless.ui.controls.wheel.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.label { title = "\127ffffffSET # KEY controls:\127o\n\n\127eeeeeeThe following controls will be installed:\n"..
                "\t/bind MWHEELUP nextLS\n"..
                "\t/bind MWHEELDOWN prevLS\n"..
                "\t/bind MMBUTTON lsswitch\n"..
                "\n\127ff5555WARNING:This will overwrite the controls\ncurrently set to these keys.\127o", fgcolor = "255 255 255" },
            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.controls.wheel.element.okbutton,
                targetless.ui.controls.wheel.element.cancelbutton
            }
        }
    }
}

targetless.ui.controls.wheel.dlg = iup.dialog
{
    targetless.ui.controls.wheel.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetless.ui.controls.wheel.element.okbutton:action()
    gkinterface.GKProcessCommand("bind 'MWHEELUP' prevLS")
    gkinterface.GKProcessCommand("bind 'MWHEELDOWN' nextLS")
    gkinterface.GKProcessCommand("bind 'MMBUTTON' lsswitch")
    targetless.ui.controls.wheel.dlg:hide()
end

function targetless.ui.controls.wheel.element.cancelbutton:action()
    targetless.ui.controls.wheel.dlg:hide()
end


-- The "Custom controls" confirmation dialog
targetless.ui.controls.custom = {}
targetless.ui.controls.custom.element = {}
targetless.ui.controls.custom.element.title = iup.label { title="", fgcolor = "255 255 255" }
targetless.ui.controls.custom.element.okbutton = iup.stationbutton { title = "OK" }
targetless.ui.controls.custom.element.cancelbutton = iup.stationbutton { title = "Cancel" }

targetless.ui.controls.custom.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            targetless.ui.controls.custom.element.title,

            iup.fill{ size = "25" },
            iup.hbox
            {
                iup.fill{},
                targetless.ui.controls.custom.element.okbutton,
                targetless.ui.controls.custom.element.cancelbutton
            }
        }
    }
}

targetless.ui.controls.custom.dlg = iup.dialog
{
    targetless.ui.controls.custom.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetless.ui.controls.custom.open()
    local title = "\127ffffffSET # KEY controls:\127o\n\n\127eeeeeeThe following controls will be installed:\n"
    if(targetless.ui.controls.element.pinkey.value ~= "") then
        title = title.."\t/bind "..targetless.ui.controls.element.pinkey.value.." pin\n"
    end
    if(targetless.ui.controls.element.pagekey.value ~= "") then
        title = title.."\t/bind "..targetless.ui.controls.element.pagekey.value.." lsswitch\n"
    end
    if(targetless.ui.controls.element.nextkey.value ~= "") then
        title = title.."\t/bind "..targetless.ui.controls.element.nextkey.value.." nextLS\n"
    end
    if(targetless.ui.controls.element.prevkey.value ~= "") then
        title = title.."\t/bind "..targetless.ui.controls.element.prevkey.value.." prevLS\n"
    end
    if(targetless.ui.controls.element.raddkey.value ~= "") then
        title = title.."\t/bind "..targetless.ui.controls.element.raddkey.value.." addroid\n"
    end
    title = title.."\n\127ff5555WARNING:This will overwrite the controls\ncurrently set to these keys.\127o"
    targetless.ui.controls.custom.element.title.title = title
    targetless.ui.controls.custom.dlg:show()
end

function targetless.ui.controls.custom.element.okbutton:action()
    if(targetless.ui.controls.element.pinkey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetless.ui.controls.element.pinkey.value.." pin")
    end
    if(targetless.ui.controls.element.nextkey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetless.ui.controls.element.nextkey.value.." nextLS")
    end
    if(targetless.ui.controls.element.prevkey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetless.ui.controls.element.prevkey.value.." prevLS")
    end
    if(targetless.ui.controls.element.pagekey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetless.ui.controls.element.pagekey.value.." lsswitch")
    end
    if(targetless.ui.controls.element.raddkey ~= "") then
        gkinterface.GKProcessCommand("bind "..targetless.ui.controls.element.raddkey.value.." addroid")
    end
    targetless.ui.controls.custom.dlg:hide()
end

function targetless.ui.controls.custom.element.cancelbutton:action()
    targetless.ui.controls.custom.dlg:hide()
end


-- The "controls Help dialog
targetless.ui.controls.help = {}
targetless.ui.controls.help.element = {}
targetless.ui.controls.help.element.exitbutton = iup.stationbutton { title = "exit" }

targetless.ui.controls.help.confirm = iup.pdarootframe
{
    iup.pdasubframebg
    {
        iup.vbox
        {
            iup.label { title = "\127ffffffcontrols HELP:\127o\n\n\127eeeeee"..
                "You can use the quickset buttons ('# Keys' and 'Wheel')\n"..
                "to quickly setup your targetless quickselect keys.\n\n"..
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
                targetless.ui.controls.help.element.exitbutton
            }
        }
    }
}

targetless.ui.controls.help.dlg = iup.dialog
{
    targetless.ui.controls.help.confirm;
    BORDER="NO",
    topmost = "YES",
    RESIZE="NO",
    MAXBOX="NO",
    MINBOX="NO",
    MENUBOX="NO",
    MODAL="YES"
}

function targetless.ui.controls.help.element.exitbutton:action()
    targetless.ui.controls.help.dlg:hide()
end

