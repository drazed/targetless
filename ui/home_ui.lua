targetless.ui.home = {}
targetless.ui.home.element = {}
targetless.ui.home.element.desc = iup.label{title=
    "Advanced targetting configuration, options, and tools.\n\n"..
    "Credits:\n\n"..
    "Slime for providing much of the code for this UI\n\n"..
    "BlackNet, Eonis, FireMage, Nautrogus and a bunch of others\n"..
    "in IRC land for their l33t lua coding skills.  If I missed any of\n"..
    "you remind me, I have a terrible memory =9\n\n"..
    "Scuba Steve 9.0 and his Pirates Toolkit for providing me with\n"..
    "wonderful sample code when I was learning lua.\n\n"..
    "The members of Coalition of Itan for helping test the plugin before\n"..
    "I actually got it to work right.\n\n"..
    "The VO devs for making this all possible.\n"..
    "Thanks John, Ray, Andy, and Michael.\n" }

targetless.ui.home.main = iup.vbox{
	iup.label{title="Targetless Tools", expand="HORIZONTAL", font=Font.H3},
	iup.hbox{
		iup.fill{},
		alignment="ACENTER",
		gap=5,
	},
    targetless.ui.home.element.desc,
	iup.fill{},
	gap=15,
	margin="2x2",
	tabtitle="About",
	alignment="ACENTER",
	hotkey=iup.K_a,
}

function targetless.ui.home.main:OnShow() end
function targetless.ui.home.main:OnHide() end
