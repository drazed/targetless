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
dofile('var.lua')
dofile('ui/ui.lua')

function targetless.start:OnEvent(eventname, ...)
    targetless.var.state = true
    targetless.Lists:refresh()
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
    targetless.Lists.iup = nil
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
                targetless.ui.ore.add.element.id.title = "" .. objectid
                targetless.ui.ore.add.element.ore.title = oreserial
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
    if(targetless.ui.ore.add.element.id.title ~= "" and 
       targetless.ui.ore.add.element.ore.title ~= "") then
        if(#targetless.RoidList >= 50) then
            print("\127ff77ffList reached max for sector (50), to remove roids type /targetless roids\127o")
            return
        end
        if(targetless.Lists.mode ~= "Ore") then 
            targetless.Lists.mode="Ore" 
            targetless.Lists:update()
        end
        targetless.ui.ore.add.dlg:show()
        iup.Refresh(targetless.ui.ore.add.dlg)
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
    print("\127ffffff" .. "Target List " .. targetless.var.version .. " loaded...")
end

function targetless.usercmd(cmd)
    targetless.printinfo() 
    targetless.ui.show()
end

function targetless.init:OnEvent(eventname, ...)
    targetless.printinfo()
    targetless.RoidList.sector = GetCurrentSectorid()

    targetless.appendiups()
    if GetStationLocation() == nil then targetless.Lists:refresh() end
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

    targetless.var.sectortotals = nil
    targetless.var.iuplists = iup.vbox {}

    local hudinfo = iup.GetParent(HUD.selfinfoframe)
    local addons = iup.GetParent(HUD.addonframe)
    local schat = iup.GetParent(HUD.secondarychatarea)
    iup.Detach(hudinfo)
    iup.Detach(addons)
    iup.Detach(schat)

    targetless.var.PlayerData = iup.hbox
    {
        iup.vbox{
            iup.hbox{iup.fill{size="THREEQUARTER",},},
            iup.fill{size="%21",},
            iup.hbox{
                iup.fill{size="5"},
                hudinfo,
                addons,
                schat,
                iup.fill{},
                gap="4",
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
            expand="VERTICAL",
            margin="4x4",
            gap="4",
        },
    }

    local bsinfo = iup.GetParent(HUD.BSinfo.enemylabel)
    targetless.var.PlayerData.expand = "NO"
    iup.Detach(bsinfo)
    iup.Append(iup.GetParent(iup.GetParent(HUD.locationtext)), bsinfo)
    iup.Append(HUD.pluginlayer, targetless.var.PlayerData)
end

RegisterEvent(targetless.init, "PLAYER_ENTERED_GAME")
RegisterUserCommand("targetselect", function(data, args) targetless.Lists:settarget(args[1]) end) -- set binds using aliases for any target number
RegisterUserCommand("addroid",function() targetless.confirmRoid() end)
RegisterUserCommand("lsswitch",function() targetless.Lists:switch() end)
RegisterUserCommand("nextLS",function() targetless.Lists:targetnext() end)
RegisterUserCommand("prevLS",function() targetless.Lists:targetprev() end)
RegisterUserCommand("pin",function() targetless.Lists:pin() end)
RegisterUserCommand("selecttarget1",function() targetless.Lists:settarget(1) end)
RegisterUserCommand("selecttarget2",function() targetless.Lists:settarget(2) end)
RegisterUserCommand("selecttarget3",function() targetless.Lists:settarget(3) end)
RegisterUserCommand("selecttarget4",function() targetless.Lists:settarget(4) end)
RegisterUserCommand("selecttarget5",function() targetless.Lists:settarget(5) end)
RegisterUserCommand("selecttarget6",function() targetless.Lists:settarget(6) end)
RegisterUserCommand("selecttarget7",function() targetless.Lists:settarget(7) end)
RegisterUserCommand("selecttarget8",function() targetless.Lists:settarget(8) end)
RegisterUserCommand("selecttarget9",function() targetless.Lists:settarget(9) end)
RegisterUserCommand("selecttarget10",function() targetless.Lists:settarget(10) end)
RegisterUserCommand("targetless",function(data, args) targetless.usercmd(args) end)
