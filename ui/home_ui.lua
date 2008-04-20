targetless.ui.home = {}
targetless.ui.home.element = {}
targetless.ui.home.element.desc = iup.label{title="Advanced targetting configuration, options, and tools."}

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
