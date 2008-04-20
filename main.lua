-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

declare("targetless", {})
targetless.start = {}
targetless.stop = {}
targetless.init = {}
targetless.re_attach = {}
targetless.update = {}
targetless.sectorupdate = {}
targetless.scan = {}

dofile('lists/Lists.lua')
dofile('func.lua')
dofile('var.lua')
dofile('ui/ui.lua')

function targetless.start:OnEvent(eventname, ...)
    targetless.var.state = true
    targetless.func.refresh()
end

function targetless.stop:OnEvent(eventname, ...)
    targetless.var.state = false
end

function targetless.re_attach:OnEvent(eventname, ...)
    -- when VO reloads the HUD it deletes all our lists thinking they're
    -- the selfinfo holder box =(
    targetless.PlayerList.self = nil
    while(targetless.PlayerList[1]) do table.remove(targetless.PlayerList, 1) end
    while(targetless.RoidList[1]) do table.remove(targetless.RoidList, 1) end

    targetless.appendiups()
    if GetStationLocation() == nil then targetless.Lists:update() end
    targetless.RoidList:updatesector(GetCurrentSectorid())
end

function targetless.scan:OnEvent(eventname, data)
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
                targetless.UIroid.add.element.id.title = "" .. objectid
                targetless.UIroid.add.element.ore.title = oreserial
            else
                for i,v in ipairs(targetless.RoidList) do
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

function targetless.confirmRoid()
    if(targetless.UIroid.add.element.id.title ~= "" and 
       targetless.UIroid.add.element.ore.title ~= "") then
        if(#targetless.RoidList >= 50) then
            print("\127ff77ffList reached max for sector (50), to remove roids type /targetless roids\127o")
            return
        end
        if(targetless.Lists.mode ~= "Ore") then 
            targetless.Lists.mode="Ore" 
            targetless.Lists:update()
        end
        targetless.UIroid.add.dlg:show()
        iup.Refresh(targetless.UIroid.add.dlg)
    else
        print("\127ff77ffYou need to scan a roid before you can add it!\127o")
    end
end

function targetless.sectorupdate:OnEvent(eventname, ...)
    targetless.RoidList:updatesector(GetCurrentSectorid())
end

function targetless.update:OnEvent(eventname, ...)
    targetless.Lists:update()
end

function targetless.printinfo()
    print("\127ffffff" .. "Target List " .. targetless.var.version .. " loaded... \nCommands: "..
        "\n\t\127ff77ff/addroid\127o --> add roid to list"..
        "\n\t\127ff77ff/targetless roids\127o --> roid list manager"..
        "\n\t\127ff77ff/targetless config\127o --> program settings"..
        "\n\t\127ff77ff/targetless credits\127o --> program credits" .. "\127o")
end

function targetless.usercmd(cmd)
    if cmd == nil then targetless.printinfo()
    elseif cmd[1] == "config" then targetless.UIconfig.open() 
    elseif cmd[1] == "credits" then targetless.UIcredits.open()
    elseif cmd[1] == "roids" then targetless.UIroid.open()
    else targetless.printinfo() end
end

function targetless.init:OnEvent(eventname, ...)
    targetless.printinfo()
    targetless.RoidList.sector = GetCurrentSectorid()

    targetless.appendiups()
    if GetStationLocation() == nil then targetless.func.refresh() end
    targetless.RoidList:updatesector(GetCurrentSectorid())
    UnregisterEvent(self, "PLAYER_ENTERED_GAME")

    RegisterEvent(targetless.re_attach, "rHUDxscale")
    RegisterEvent(targetless.start, "LEAVING_STATION")
    RegisterEvent(targetless.stop, "ENTERING_STATION")
    RegisterEvent(targetless.scan, "TARGET_SCANNED")
    RegisterEvent(targetless.sectorupdate, "SECTOR_CHANGED")
    RegisterEvent(targetless.update, "TARGET_CHANGED")
end

function targetless.appendiups()
    iup.Append(iup.GetParent(HUD.targetframe), iup.hbox{iup.fill{size="QUARTER"}})
    iup.Detach(HUD.targetframe)
    iup.Detach(HUD.licensewatchframe)
    iup.Detach(HUD.missiontimerframe)

--    targetless.var.iupself = iup.vbox {}
    targetless.var.sectortotals = nil
--    targetless.var.iuptotals = iup.vbox {}
--    targetless.var.iupplayers = iup.vbox {}
--    targetless.var.iuproids = iup.vbox {}
    targetless.var.iuplists = iup.vbox {}

    local hudinfo = iup.GetParent(HUD.selfinfoframe)
    iup.Detach(hudinfo)
    --iup.Append(HUD.alladdonlist, hudinfo)

    targetless.var.PlayerData = iup.hbox
    {
        iup.vbox{
            iup.hbox{iup.fill{size="THREEQUARTER",},},
            iup.fill{size="%40",},
            iup.hbox{
                iup.fill{size="10"},
                hudinfo,
                iup.fill{},
            },
        },
        iup.vbox
        {
            iup.zbox{
                HUD.licensewatchframe,
                HUD.missiontimerframe,
            },
            HUD.targetframe,
            targetless.var.iuplists,
            --[[
            iup.vbox {
                --  targetless.var.iupself,
                iup.hudrightframe {
                    targetless.var.iuptotals,
                },
                iup.hudrightframe {
                    iup.zbox{
                        targetless.var.iupplayers,
                        targetless.var.iuproids,
                        all="YES",
                    },
                },
                gap="4",
            },
            ]]--
            expand="VERTICAL",
            margin="4x4",
            gap="4",
        },
    }

    local schat = HUD.secondarychatarea
    local bsinfo = iup.GetParent(HUD.BSinfo.enemylabel)
    targetless.var.PlayerData.expand = "NO"
--[[
    if(targetless.var.place == "left") then
        iup.Detach(bsinfo)
        iup.Append(iup.GetParent(iup.GetParent(HUD.locationtext)), bsinfo)
        iup.Append(HUD.secondarychatarea, targetless.var.PlayerData)
    elseif(targetless.var.place == "right") then
]]--
        iup.Detach(bsinfo)
        iup.Detach(schat)
        local missionup = iup.vbox { iup.fill { size=20}, schat }
        iup.Append(iup.GetParent(iup.GetParent(HUD.locationtext)), bsinfo)
        iup.Append(iup.GetParent(HUD.locationtext), missionup)
        --iup.Append(HUD.targetless, targetless.var.PlayerData)
        iup.Append(HUD.plugins, targetless.var.PlayerData)
--[[
    else 
        local listplace = iup.vbox { iup.fill { size=20}, targetless.var.PlayerData }
        iup.Append(iup.GetParent(HUD.locationtext), listplace)
    end
]]--
end

RegisterEvent(targetless.init, "PLAYER_ENTERED_GAME")
RegisterUserCommand("targetselect", function(data, args) targetless.func.settarget(args[1]) end) -- set binds using aliases for any target number
RegisterUserCommand("addroid",function() targetless.confirmRoid() end)
RegisterUserCommand("lsswitch",function() targetless.Lists:switch() end)
RegisterUserCommand("nextLS",function() targetless.func.targetnext() end)
RegisterUserCommand("prevLS",function() targetless.func.targetprev() end)
RegisterUserCommand("selecttarget1",function() targetless.func.settarget(1) end)
RegisterUserCommand("selecttarget2",function() targetless.func.settarget(2) end)
RegisterUserCommand("selecttarget3",function() targetless.func.settarget(3) end)
RegisterUserCommand("selecttarget4",function() targetless.func.settarget(4) end)
RegisterUserCommand("selecttarget5",function() targetless.func.settarget(5) end)
RegisterUserCommand("selecttarget6",function() targetless.func.settarget(6) end)
RegisterUserCommand("selecttarget7",function() targetless.func.settarget(7) end)
RegisterUserCommand("selecttarget8",function() targetless.func.settarget(8) end)
RegisterUserCommand("selecttarget9",function() targetless.func.settarget(9) end)
RegisterUserCommand("selecttarget10",function() targetless.func.settarget(10) end)
RegisterUserCommand("targetless",function(data, args) targetless.usercmd(args) end)
