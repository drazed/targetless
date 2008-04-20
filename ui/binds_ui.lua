targetless.ui.binds = {}
targetless.ui.binds.element = {}
targetless.ui.binds.element.desc = iup.label{title="Configure your targetting binds here."}

targetless.ui.binds.main = iup.vbox{
	iup.label{title="Target Binds", expand="HORIZONTAL", font=Font.H3},
	iup.hbox{
		iup.fill{},
		alignment="ACENTER",
		gap=5,
	},
    targetless.ui.binds.element.desc,
	iup.fill{},
	gap=15,
	margin="2x2",
	tabtitle="Target Binds",
	alignment="ACENTER",
	hotkey=iup.K_b,
}

function targetless.ui.binds.main:OnShow() end
function targetless.ui.binds.main:OnHide() end
