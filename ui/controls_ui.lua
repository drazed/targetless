targetless.ui.controls = {}
targetless.ui.controls.element = {}
targetless.ui.controls.element.nextkey = iup.text { value = "" .. gkini.ReadString("targetless", "lsnext", "]"), size = "200x" }
targetless.ui.controls.element.prevkey = iup.text { value = "" .. gkini.ReadString("targetless", "lsprev", "["), size = "200x" }
targetless.ui.controls.element.targetnone = iup.text { value = "" .. gkini.ReadString("targetless", "targetnone", "U"), size = "200x" }
targetless.ui.controls.element.targetmycap = iup.text { value = "" .. gkini.ReadString("targetless", "targetmycap", "0"), size = "200x" }
targetless.ui.controls.element.pinkey = iup.text { value = "" .. gkini.ReadString("targetless", "pin", "p"), size = "200x" }
targetless.ui.controls.element.pagekey = iup.text { value = "" .. gkini.ReadString("targetless", "lspage", "-"), size = "200x" }
targetless.ui.controls.element.cyclekey = iup.text { value = "" .. gkini.ReadString("targetless", "cyclestatus", "_"), size = "200x" }
targetless.ui.controls.element.lssort = iup.text { value = "" .. gkini.ReadString("targetless", "lssort", "o"), size = "200x" }
targetless.ui.controls.element.raddkey = iup.text { value = "" .. gkini.ReadString("targetless", "radd", "="), size = "200x" }
targetless.ui.controls.element.reditkey = iup.text { value = "" .. gkini.ReadString("targetless", "redit", "+"), size = "200x" }
targetless.ui.controls.element.unroidkey = iup.text { value = "" .. gkini.ReadString("targetless", "unroid", "|"), size = "200x" }

targetless.ui.controls.numkeys = {}
targetless.ui.controls.numkeys.apply = iup.stationbutton { title = "Set #Keys" }
targetless.ui.controls.numkeys.tab = iup.vbox{
    iup.label { title = "\127ffffffSET # KEY controls:\127o\n\n\127eeeeeeThe following controls will be set:\n"..
        "\t/bind '1' selecttarget1\n"..
        "\t/bind '2' selecttarget2\n"..
        "\t/bind '3' selecttarget3\n"..
        "\t/.......\n"..
        "\t/bind '0' targetmycap\n"..
        "\t/bind 'p' pin\n"..
        "\t/bind '-' lsswitch\n"..
        "\t/bind '_' cyclestatus\n"..
        "\t/bind '=' addroid\n"..
        "\t/bind '+' editroid\n"..
        "\t\n", 
        fgcolor = "255 255 255" },
    iup.fill{},
    iup.hbox
    {
        iup.label { title = "\n\127ff5555This will overwrite the controls set to these keys.\127o", fgcolor = "255 255 255" },
        iup.fill{},
        targetless.ui.controls.numkeys.apply,
    },
    margin="10x10",
	tabtitle="#Keys",
	hotkey=iup.K_k,
}
function targetless.ui.controls.numkeys.apply:action()
    gkinterface.GKProcessCommand("bind '1' selectTarget1")
    gkinterface.GKProcessCommand("bind '2' selectTarget2")
    gkinterface.GKProcessCommand("bind '3' selectTarget3")
    gkinterface.GKProcessCommand("bind '4' selectTarget4")
    gkinterface.GKProcessCommand("bind '5' selectTarget5")
    gkinterface.GKProcessCommand("bind '6' selectTarget6")
    gkinterface.GKProcessCommand("bind '7' selectTarget7")
    gkinterface.GKProcessCommand("bind '8' selectTarget8")
    gkinterface.GKProcessCommand("bind '9' selectTarget9")
    gkinterface.GKProcessCommand("bind '0' targetmycap")
    gkinterface.GKProcessCommand("bind '-' lsswitch")
    gkinterface.GKProcessCommand("bind '_' cyclestatus")
    gkinterface.GKProcessCommand("bind '=' addroid")
    gkinterface.GKProcessCommand("bind '+' editroid")
end

targetless.ui.controls.mouse = {}
targetless.ui.controls.mouse.apply = iup.stationbutton { title = "Set Mouse" }
targetless.ui.controls.mouse.tab = iup.vbox{
    iup.label { title = "\127ffffffSET Mouse controls:\127o\n\n\127eeeeeeThe following controls will be set:\n"..
        "\t/bind MWHEELUP nextLS\n"..
        "\t/bind MWHEELDOWN prevLS\n"..
        "\t/bind MMBUTTON lsswitch\n"..
        "\t/bind '_' cyclestatus\n"..
        "\t/bind '=' addroid\n"..
        "\t/bind '+' editroid\n"..
        "\t/bind '0' targetmycap\n"..
        "\t\n", 
        fgcolor = "255 255 255" },
    iup.fill{},
    iup.hbox
    {
        iup.label { title = "\n\127ff5555This will overwrite the controls set to these keys.\127o", fgcolor = "255 255 255" },
        iup.fill{},
        targetless.ui.controls.mouse.apply,
    },
    margin="10x10",
	tabtitle="Mouse",
	hotkey=iup.K_m,
}
function targetless.ui.controls.mouse.apply:action()
    gkinterface.GKProcessCommand("bind 'MWHEELUP' prevLS")
    gkinterface.GKProcessCommand("bind 'MWHEELDOWN' nextLS")
    gkinterface.GKProcessCommand("bind 'MMBUTTON' lsswitch")
    gkinterface.GKProcessCommand("bind '_' cyclestatus")
    gkinterface.GKProcessCommand("bind '=' addroid")
    gkinterface.GKProcessCommand("bind '+' editroid")
    gkinterface.GKProcessCommand("bind '0' targetmycap")
end

targetless.ui.controls.custom = {}
targetless.ui.controls.custom.apply = iup.stationbutton { title = "Set Custom" }
targetless.ui.controls.custom.tab = iup.vbox{
    iup.hbox
    {
        iup.fill{size="500"},
    },
    iup.hbox
    {
        iup.label { title = "target next:", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.nextkey,
    },
    iup.hbox
    {
        iup.label { title = "target previous:", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.prevkey,
    },
    iup.hbox
    {
        iup.label { title = "targetnone (replaces RadarNone):", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.targetnone,
    },
    iup.hbox
    {
        iup.label { title = "target/route-to your capship:", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.targetmycap,
    },
    iup.hbox
    {
        iup.label { title = "pin/unpin (ship):", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.pinkey,
    },
    iup.hbox
    {
        iup.label { title = "cycle (list type):", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.pagekey,
    },
    iup.hbox
    {
        iup.label { title = "cycle (friendly/hostile):", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.cyclekey,
    },
    iup.hbox
    {
        iup.label { title = "cycle sort:", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.lssort,
    },
    iup.hbox
    {
        iup.label { title = "addroid (manually):", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.raddkey,
    },
    iup.hbox
    {
        iup.label { title = "editroid (already scanned):", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.reditkey,
    },
    iup.hbox
    {
        iup.label { title = "unroid (target nearest unscanned):", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.element.unroidkey,
    },
    iup.fill {},
    iup.hbox
    {
        iup.label { title = "\n\127ff5555This will overwrite the controls set to these keys.\127o", fgcolor = "255 255 255" },
        iup.fill {},
        targetless.ui.controls.custom.apply,
    },
    margin="10x10",
	tabtitle="Custom",
	hotkey=iup.K_u,
}
function targetless.ui.controls.custom.apply:action()
    if(targetless.ui.controls.element.nextkey ~= "") then
        local nextkey = targetless.ui.controls.element.nextkey.value
        gkini.WriteString("targetless", "lsnext", nextkey)
        if(#nextkey == 1) then nextkey = "'"..nextkey.."'" end
        gkinterface.GKProcessCommand("bind "..nextkey.." nextLS")
    end
    if(targetless.ui.controls.element.prevkey ~= "") then
        local prevkey = targetless.ui.controls.element.prevkey.value
        gkini.WriteString("targetless", "lsprev", prevkey)
        if(#prevkey == 1) then prevkey = "'"..prevkey.."'" end
        gkinterface.GKProcessCommand("bind "..prevkey.." prevLS")
    end
    if(targetless.ui.controls.element.targetnone ~= "") then
        local targetnone = targetless.ui.controls.element.targetnone.value
        gkini.WriteString("targetless", "targetnone", targetnone)
        if(#targetnone == 1) then targetnone = "'"..targetnone.."'" end
        gkinterface.GKProcessCommand("bind "..targetnone.." targetnone")
    end
    if(targetless.ui.controls.element.targetmycap ~= "") then
        local targetmycap = targetless.ui.controls.element.targetmycap.value
        gkini.WriteString("targetless", "targetmycap", targetmycap)
        if(#targetmycap == 1) then targetmycap = "'"..targetmycap.."'" end
        gkinterface.GKProcessCommand("bind "..targetmycap.." targetmycap")
    end

    if(targetless.ui.controls.element.pinkey ~= "") then
        local pinkey = targetless.ui.controls.element.pinkey.value
        gkini.WriteString("targetless", "pin", pinkey)
        if(#pinkey == 1) then pinkey = "'"..pinkey.."'" end
        gkinterface.GKProcessCommand("bind "..pinkey.." pin")
    end
    if(targetless.ui.controls.element.pagekey ~= "") then
        local pagekey = targetless.ui.controls.element.pagekey.value
        gkini.WriteString("targetless", "lspage", pagekey)
        if(#pagekey == 1) then pagekey = "'"..pagekey.."'" end
        gkinterface.GKProcessCommand("bind "..pagekey.." lsswitch")
    end
    if(targetless.ui.controls.element.cyclekey ~= "") then
        local cyclekey = targetless.ui.controls.element.cyclekey.value
        gkini.WriteString("targetless", "cyclestatus", cyclekey)
        if(#cyclekey == 1) then cyclekey = "'"..cyclekey.."'" end
        gkinterface.GKProcessCommand("bind "..cyclekey.." cyclestatus")
    end
    if(targetless.ui.controls.element.lssort ~= "") then
        local lssort = targetless.ui.controls.element.lssort.value
        gkini.WriteString("targetless", "lssort", lssort)
        if(#lssort == 1) then lssort = "'"..lssort.."'" end
        gkinterface.GKProcessCommand("bind "..lssort.." lssort")
    end
    if(targetless.ui.controls.element.raddkey ~= "") then
        local raddkey = targetless.ui.controls.element.raddkey.value
        gkini.WriteString("targetless", "radd", raddkey)
        if(#raddkey == 1) then raddkey = "'"..raddkey.."'" end
        gkinterface.GKProcessCommand("bind "..raddkey.." addroid")
    end
    if(targetless.ui.controls.element.reditkey ~= "") then
        local reditkey = targetless.ui.controls.element.reditkey.value
        gkini.WriteString("targetless", "redit", reditkey)
        if(#reditkey == 1) then reditkey = "'"..reditkey.."'" end
        gkinterface.GKProcessCommand("bind "..reditkey.." editroid")
    end

    if(targetless.ui.controls.element.unroidkey ~= "") then
        local unroidkey = targetless.ui.controls.element.unroidkey.value
        gkini.WriteString("targetless", "unroid", unroidkey)
        if(#unroidkey == 1) then unroidkey = "'"..unroidkey.."'" end
        gkinterface.GKProcessCommand("bind "..unroidkey.." unroid")
    end


    if(targetless.ui.controls.element.cyclekey ~= "") then
        local cyclekey = targetless.ui.controls.element.cyclekey.value
        gkini.WriteString("targetless", "cyclestatus", cyclekey)
        if(#cyclekey == 1) then cyclekey = "'"..cyclekey.."'" end
        gkinterface.GKProcessCommand("bind "..cyclekey.." cyclestatus")
    end
end

targetless.ui.controls.main = iup.subsubtabtemplate{
    targetless.ui.controls.custom.tab,
    targetless.ui.controls.numkeys.tab,
    targetless.ui.controls.mouse.tab,
}
targetless.ui.controls.main.tabtitle="Controls"
targetless.ui.controls.main.hotkey=iup.K_c
iup.Detach(targetless.ui.controls.main[1][1][1][2])

function targetless.ui.controls.main:OnShow() 
    targetless.ui.controls.element.nextkey.value = ""..gkini.ReadString("targetless", "lsnext", "]")
    targetless.ui.controls.element.prevkey.value = ""..gkini.ReadString("targetless", "lsprev", "[")
    targetless.ui.controls.element.targetnone.value = ""..gkini.ReadString("targetless", "targetnone", "U")
    targetless.ui.controls.element.targetmycap.value = ""..gkini.ReadString("targetless", "targetmycap", "0")
    targetless.ui.controls.element.pinkey.value = ""..gkini.ReadString("targetless", "pin", "p")
    targetless.ui.controls.element.pagekey.value = ""..gkini.ReadString("targetless", "lspage", "-")
    targetless.ui.controls.element.cyclekey.value = ""..gkini.ReadString("targetless", "cyclestatus", "_")
    targetless.ui.controls.element.raddkey.value = ""..gkini.ReadString("targetless", "radd", "=")
    targetless.ui.controls.element.reditkey.value = ""..gkini.ReadString("targetless", "redit", "+")
    targetless.ui.controls.element.unroidkey.value = ""..gkini.ReadString("targetless", "unroid", "|")
end

function targetless.ui.controls.main:OnHide() end
