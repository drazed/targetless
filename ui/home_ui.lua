targetless.ui.home = {}


targetless.ui.home.logo = {}
targetless.ui.home.logo.logo = iup.label{title = "logo.png",image=targetless.var.IMAGE_DIR.."logo.png"}
targetless.ui.home.logo.tab = iup.vbox{
    targetless.ui.home.logo.logo,
    iup.label{title="Created by Adrian (drazed@gmail.com) Zakrzewski\nhttp://targetless.com/"},
	margin="2x2",
	tabtitle="Author",
	hotkey=iup.K_u,
}

targetless.ui.home.controls = {}
targetless.ui.home.controls.desc = iup.label{title=
--[[   OLD controls help, put this somewhere!?!
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
]]--

    "\nTargetless contains the following binds:\n\n"..
    "nextLS -> target next in list\n" ..
    "prevLS -> target previous in list\n" ..
    "pin -> pin or unpin a target above the list\n"..
    "clearpin -> clear the entire pin list\n"..
    "lsswitch -> cycle list type\n" ..
    "lssort -> cycle list sort (dependant on active list)\n" ..
    "cyclestatus -> cycle friendly/hostile/all\n" ..
    "targetmycap -> target/nav-route-to your capships\n" ..
    "addroid -> save a scanned roid (when scanall disabled)\n" ..
    "editroid -> edit/remove a saved roid\n" ..
    "unroid -> target nearest unscanned roid (if in range)\n" }

targetless.ui.home.controls.tab = iup.vbox{
    iup.hbox{
        targetless.ui.home.controls.desc,
        iup.fill{}
    },
	margin="2x2",
	tabtitle="Binds",
	hotkey=iup.K_b,
}

targetless.ui.home.credit = {}
targetless.ui.home.credit.desc = iup.label{title=
    "\nThe VO devs. Thanks John, Ray, Andy, and Michael.\n\n"..
    "Slime for providing much of the code for this UI\n\n"..
    "Spidey for making my logo.\n\n"..
    "Draugath for droid touch code.\n\n"..
    "Chocoleteer for help debugging and bug fixing.\n\n"..
    "BlackNet, Eonis, FireMage, Nautrogus and a bunch of others\n"..
    "in IRC land for their l33t lua coding skills.  If I missed any of\n"..
    "you remind me, I have a terrible memory =9\n\n"..
    "Scuba Steve 9.0 and his Pirates Toolkit for providing me with\n"..
    "wonderful sample code when I was learning lua.\n\n"..
    "The members of Coalition of Itan for helping test.\n\n"}

targetless.ui.home.credit.tab = iup.vbox{
    iup.hbox{
        targetless.ui.home.credit.desc,
        iup.fill{}
    },
	margin="2x2",
	tabtitle="Special Thanks",
	hotkey=iup.K_T,
}

targetless.ui.home.main = iup.subsubtabtemplate{
    targetless.ui.home.logo.tab,
    targetless.ui.home.controls.tab,
    targetless.ui.home.credit.tab,
}
targetless.ui.home.main.tabtitle="About"
targetless.ui.home.main.hotkey=iup.K_a
iup.Detach(targetless.ui.home.main[1][1][1][2])


function targetless.ui.home.main:OnShow() end
function targetless.ui.home.main:OnHide() end
