-- The ui.options Dialog
targetless.ui.options = {}
targetless.ui.options.element = {}
targetless.ui.options.element.slist = iup.list { "distance", "health", "faction"; dropdown="YES" }
targetless.ui.options.element.fontlist = iup.list { "regular", "small"; dropdown="YES" }
targetless.ui.options.element.refreshtext = iup.text { value = "" .. targetless.var.refreshDelay/1000, size = "30x" }
targetless.ui.options.element.maxlsize = iup.text { value = "" .. targetless.var.listmax, size = "30x" }
targetless.ui.options.element.pinframe = iup.stationtoggle{title="Frame Pinned Targets", value=targetless.var.pinframe}
targetless.ui.options.element.listframe = iup.stationtoggle{title="Frame Lists", value=targetless.var.listframe}

targetless.ui.options.element.applybutton = iup.stationbutton { title = "Apply" }
targetless.ui.options.element.cancelbutton = iup.stationbutton { title = "Reset" }
targetless.ui.options.mainbox = iup.vbox
{
    iup.hbox
    {
        iup.fill { size = "10" },
        iup.label { title = "\127ddddddSort By:\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.slist,
        iup.fill { size = "10" }
    },
    iup.fill{ size = "10"},
    iup.hbox
    {
        iup.fill { size = "10" },
        iup.label { title = "\127ddddddFont Size:\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.fontlist,
        iup.fill { size = "10" }
    },
    iup.fill{ size = "10"},
    iup.hbox
    {
        iup.fill { size = "10" },
        iup.label { title = "\127ddddddRefresh Delay (sec):\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.refreshtext,
        iup.fill {size = "10" }
    },
    iup.fill{ size = "10"},
    iup.hbox
    {
        iup.fill { size = "10" },
        iup.label { title = "\127ddddddList Max (targets):\127o", expand = "HORIZONTAL" },
        iup.fill {},
        targetless.ui.options.element.maxlsize,
        iup.fill { size = "10" }
    },
    iup.fill{ size = "10"},
    iup.hbox
    {
        iup.fill { size = "10" },
        targetless.ui.options.element.pinframe,
        iup.fill { size = "10" }
    },
    iup.fill{ size = "10"},
    iup.hbox
    {
        iup.fill { size = "10" },
        targetless.ui.options.element.listframe,
        iup.fill { size = "10" }
    },
    iup.fill{},
    iup.hbox
    {
        iup.fill{},
        targetless.ui.options.element.applybutton,
        targetless.ui.options.element.cancelbutton
    }
}

targetless.ui.options.main = iup.vbox{
	iup.label{title="TargetLess Options", expand="HORIZONTAL", font=Font.H3},
	iup.hbox{
		iup.fill{},
		alignment="ACENTER",
		gap=5,
	},
    targetless.ui.options.mainbox,
	gap=15,
	margin="2x2",
	tabtitle="Options",
	alignment="ACENTER",
	hotkey=iup.K_o,
}

function targetless.ui.options.main:OnShow() 
    local maxtext = "" .. targetless.var.listmax .. ""
    targetless.ui.options.element.maxlsize.value = "" .. targetless.var.listmax
    targetless.ui.options.element.refreshtext.value = "" .. targetless.var.refreshDelay/1000
    targetless.var.pagekey = gkini.ReadString("targetless", "pagekey", "-")
    if targetless.var.sortBy == "distance" then targetless.ui.options.element.slist.value = 1
    elseif targetless.var.sortBy == "health" then  targetless.ui.options.element.slist.value = 2 
    else targetless.ui.options.element.slist.value = 3 end

--    if targetless.var.font == Font.H5 then targetless.ui.options.element.fontlist.value = 1
    if targetless.var.font == Font.H6 then targetless.ui.options.element.fontlist.value = 1
    else targetless.ui.options.element.fontlist.value = 2 end
end

function targetless.ui.options.main:OnHide() end

function targetless.ui.options.element.applybutton:action()
    local maxls = tonumber(targetless.ui.options.element.maxlsize.value)
    local refreshT = tonumber(targetless.ui.options.element.refreshtext.value)
    if targetless.ui.options.element.slist.value == "1" then targetless.var.sortBy = "distance"
    elseif targetless.ui.options.element.slist.value == "2" then targetless.var.sortBy = "health" 
    else targetless.var.sortBy = "faction" end

    if targetless.ui.options.element.fontlist.value == "1" then 
        targetless.var.font = targetless.var.getfont("Font.H6")
        gkini.WriteString("targetless", "font", "Font.H6")
    else 
        targetless.var.font = targetless.var.getfont("Font.Tiny")
        gkini.WriteString("targetless", "font", "Font.Tiny")
    end
    gkini.WriteString("targetless", "sort", targetless.var.sortBy)
    if maxls ~= nil then 
        if(targetless.var.listmax ~= maxls) then
            -- clear the lists, so we don't have detach problems
            targetless.PlayerList:clear()
            targetless.RoidList:clear()
        end
        targetless.var.listmax = maxls 
        gkini.WriteString("targetless", "listmax", maxls)
    end
    if refreshT ~= nil then 
        targetless.var.refreshDelay = refreshT*1000 
        gkini.WriteString("targetless", "refresh", refreshT*1000)
    end
    targetless.var.pinframe = targetless.ui.options.element.pinframe.value
    targetless.var.listframe = targetless.ui.options.element.listframe.value
    gkini.WriteString("targetless", "pinframe", ""..targetless.var.pinframe)
    gkini.WriteString("targetless", "listframe", ""..targetless.var.listframe)
    targetless.Lists:update()
    targetless.RoidList:updatesector(GetCurrentSectorid())
end

