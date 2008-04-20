targetless.options = {}

targetless.options.close = iup.stationbutton{title="Close", expand="HORIZONTAL", action=function(self)
	targetless.options.tabs:OnHide()
	HideDialog(targetless.options.dlg)
end}

targetless.options.tabs = iup.subsubsubtabtemplate{
	targetless.UIconfig.options,
	targetless.ui.ore.options,
}

targetless.options.dlg = iup.dialog{
	iup.vbox{
		iup.fill{},
		iup.hbox{
			iup.fill{},
			iup.pdarootframe{
				iup.vbox{
					targetless.options.tabs,
					targetless.options.close,
					gap=8,
					expand="NO",
				},
			},
			iup.fill{},
		},
		iup.fill{},
	};
	defaultesc=targetless.options.close,
	bgcolor="0 0 0 128 *",
	fullscreen="YES",
	border="NO",
	resize="NO",
    maxbox="NO",
    minbox="NO",
    menubox="NO",
    topmost="YES",
}
targetless.options.dlg:map()
