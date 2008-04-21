targetless.ui.modes = {}
targetless.ui.modes.element = {}
targetless.ui.modes.element.desc = iup.label{title="Configure your targetting modes here."}

targetless.ui.modes.main = iup.vbox{
	iup.label{title="TargetLess Modes", expand="HORIZONTAL", font=Font.H3},
	iup.hbox{
		iup.fill{},
		alignment="ACENTER",
		gap=5,
	},
    targetless.ui.modes.element.desc,
	iup.fill{},
	gap=15,
	margin="2x2",
	tabtitle="Target Modes",
	alignment="ACENTER",
	hotkey=iup.K_m,
}

function targetless.ui.modes.main:OnShow() end
function targetless.ui.modes.main:OnHide() end
