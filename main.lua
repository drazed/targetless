-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

declare("targetls", {})
targetls.start = {}
targetls.stop = {}
targetls.init = {}
targetls.re_attach = {}
targetls.update = {}
targetls.sectorupdate = {}
targetls.scan = {}

dofile('PlayerList.lua')
dofile('RoidList.lua')
dofile('func.lua')
dofile('var.lua')
dofile('UIroid.lua')
dofile('UIconfig.lua')
dofile('UIcredits.lua')

function targetls.start:OnEvent(eventname, ...)
    targetls.var.state = true
    targetls.func.refresh()
end

function targetls.stop:OnEvent(eventname, ...)
    targetls.var.state = false
end

function targetls.re_attach:OnEvent(eventname, ...)
    -- when VO reloads the HUD it deletes all our lists thinking they're
    -- the selfinfo holder box =(
    targetls.PlayerList.self = nil
    while(targetls.PlayerList[1]) do table.remove(targetls.PlayerList, 1) end
    while(targetls.RoidList[1]) do table.remove(targetls.RoidList, 1) end

    targetls.var.iupspacer1 = iup.label { title="", image=targetls.var.IMAGE_DIR .."health.png", fgcolor = "255 255 255", size= targetls.var.lswidth .."x1"}
    targetls.var.iupspacer2 = iup.label { title="", image=targetls.var.IMAGE_DIR .."health.png", fgcolor = "255 255 255", size= targetls.var.lswidth .."x1"}

    targetls.var.sectortotals = nil
    targetls.var.iupself = iup.vbox {}
    targetls.var.iupplayers = iup.vbox {}
    targetls.var.iuproids = iup.vbox {}
    targetls.var.iuptotals = iup.vbox {}
    targetls.var.PlayerData = iup.zbox
    {
        iup.vbox
        {
            iup.fill {size="3"},
            targetls.var.iupself,
            iup.fill {size="3"},
            targetls.var.iupspacer1,
            iup.fill {size="3"},
            targetls.var.iuptotals,
            iup.fill {size="3"},
            targetls.var.iupspacer2,
            iup.fill {size="3"},
            targetls.var.iupplayers,
            targetls.var.iuproids
        }
    }

    targetls.appendiups()
    if GetStationLocation() == nil then targetls.func.refresh() end
    targetls.RoidList:updatesector(GetCurrentSectorid())
end

function targetls.scan:OnEvent(eventname, data)
    local objecttype,objectid = radar.GetRadarSelectionID()
    if(data ~= nil and data ~= "" and objecttype == 2) then
            local ores = {} 
            string.gsub(data,"(.-)\n", function(a) if(not string.find(a, "Temperature:")) then table.insert(ores, a) end end)
            if(#ores >= 1 and ores[1] ~= "Object too far to scan") then 
                local oreserial = ""
                for i,v in ipairs(ores) do oreserial=oreserial.."'"..v.."'" end
                oreserial = string.gsub(oreserial, "\r", "")
                oreserial = string.gsub(oreserial, "\n", "")
                oreserial = string.gsub(oreserial, "%%", "")
                targetls.UIroid.add.element.id.title = "" .. objectid
                targetls.UIroid.add.element.ore.title = oreserial
            else
                for i,v in ipairs(targetls.RoidList) do
                    if(tonumber(v['id'])==objectid) then
                        local ores = {}
                        string.gsub(v["ore"],"'(.-)'", function(a) table.insert(ores,a) end)
                        local string = ""
                        for i,v in ipairs(ores) do string = string..v.."\n" end
                        HUD.scaninfo.title = HUD.scaninfo.title..string
                    end
                end
            end
    end
end

function targetls.confirmRoid()
    if(targetls.UIroid.add.element.id.title ~= "" and 
       targetls.UIroid.add.element.ore.title ~= "") then
        if(#targetls.RoidList >= 50) then
            print("\127ff77ffList reached max for sector (50), to remove roids type /targetls roids\127o")
            return
        end
        if(targetls.var.listpage ~= "roid") then targetls.func.lsswitch() end
        targetls.UIroid.add.dlg:show()
        iup.Refresh(targetls.UIroid.add.dlg)
    else
        print("\127ff77ffYou need to scan a roid before you can add it!\127o")
    end
end

function targetls.sectorupdate:OnEvent(eventname, ...)
    targetls.RoidList:updatesector(GetCurrentSectorid())
end

function targetls.update:OnEvent(eventname, ...)
    targetls.func.update()
end

function targetls.printinfo()
    print("\127ffffff" .. "Target List " .. targetls.var.version .. " loaded... \nCommands: "..
        "\n\t\127ff77ff/addroid\127o --> add roid to list"..
        "\n\t\127ff77ff/targetls roids\127o --> roid list manager"..
        "\n\t\127ff77ff/targetls config\127o --> program settings"..
        "\n\t\127ff77ff/targetls credits\127o --> program credits" .. "\127o")
end

function targetls.usercmd(cmd)
    if cmd == nil then targetls.printinfo()
    elseif cmd[1] == "config" then targetls.UIconfig.open() 
    elseif cmd[1] == "credits" then targetls.UIcredits.open()
    elseif cmd[1] == "roids" then targetls.UIroid.open()
    else targetls.printinfo() end
end

function targetls.init:OnEvent(eventname, ...)
    targetls.printinfo()
    targetls.RoidList.sector = GetCurrentSectorid()

    targetls.appendiups()
    if GetStationLocation() == nil then targetls.func.refresh() end
    targetls.RoidList:updatesector(GetCurrentSectorid())
    UnregisterEvent(self, "PLAYER_ENTERED_GAME")

    RegisterEvent(targetls.re_attach, "rHUDxscale")
    RegisterEvent(targetls.start, "LEAVING_STATION")
    RegisterEvent(targetls.stop, "ENTERING_STATION")
    RegisterEvent(targetls.scan, "TARGET_SCANNED")
    RegisterEvent(targetls.sectorupdate, "SECTOR_CHANGED")
    RegisterEvent(targetls.update, "TARGET_CHANGED")
end

function targetls.appendiups()
    local hudinfo = iup.GetParent(HUD.selfinfoframe)
    local schat = HUD.secondarychatarea
    local bsinfo = iup.GetParent(HUD.BSinfo.enemylabel)
    targetls.var.PlayerData.expand = "NO"

    if(targetls.var.place == "left") then
        iup.Detach(bsinfo)
        iup.Append(iup.GetParent(iup.GetParent(HUD.locationtext)), bsinfo)
        iup.Append(HUD.secondarychatarea, targetls.var.PlayerData)
    elseif(targetls.var.place == "right") then
        iup.Detach(hudinfo)
        iup.Detach(bsinfo)
        iup.Detach(schat)
        local missionup = iup.vbox { iup.fill { size=20}, schat }
        iup.Append(HUD.alladdonlist, hudinfo)
        iup.Append(iup.GetParent(iup.GetParent(HUD.locationtext)), bsinfo)
        iup.Append(iup.GetParent(HUD.locationtext), missionup)
        iup.Append(HUD.targetless, targetls.var.PlayerData)
    else 
        local listplace = iup.vbox { iup.fill { size=20}, targetls.var.PlayerData }
        iup.Append(iup.GetParent(HUD.locationtext), listplace)
    end
end

RegisterEvent(targetls.init, "PLAYER_ENTERED_GAME")
RegisterUserCommand("targetselect", function(data, args) targetls.func.settarget(args[1]) end) -- set binds using aliases for any target number
RegisterUserCommand("addroid",function() targetls.confirmRoid() end)
RegisterUserCommand("lsswitch",function() targetls.func.lsswitch() end)
RegisterUserCommand("nextLS",function() targetls.func.targetnext() end)
RegisterUserCommand("prevLS",function() targetls.func.targetprev() end)
RegisterUserCommand("selecttarget1",function() targetls.func.settarget(1) end)
RegisterUserCommand("selecttarget2",function() targetls.func.settarget(2) end)
RegisterUserCommand("selecttarget3",function() targetls.func.settarget(3) end)
RegisterUserCommand("selecttarget4",function() targetls.func.settarget(4) end)
RegisterUserCommand("selecttarget5",function() targetls.func.settarget(5) end)
RegisterUserCommand("selecttarget6",function() targetls.func.settarget(6) end)
RegisterUserCommand("selecttarget7",function() targetls.func.settarget(7) end)
RegisterUserCommand("selecttarget8",function() targetls.func.settarget(8) end)
RegisterUserCommand("selecttarget9",function() targetls.func.settarget(9) end)
RegisterUserCommand("selecttarget10",function() targetls.func.settarget(10) end)
RegisterUserCommand("targetls",function(data, args) targetls.usercmd(args) end)
