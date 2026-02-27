--[[
#The modreg section is required for all LME-compatible plugins. This is forward-registered into Neoloader.
[modreg]
#this is Neoloader's library API; loader ignores if mismatched
API=3
#this is your mod's internal ID.
id=targetless
#This is your mod's version number
version=2.0.0 -EX
#This is your mod's public, user-facing name
name=Targetless
#Optionally, this is your name as the mod creator
author=Drazed

#All of the below is optional (and not even used in the current version of Neoloader).
#Metadata here defines this specific file, not the mod package. Intended for use in a possible in-game distribution platform
[metadata]
description=This is Targetless's main file
version=1.0.0
owner=targetless|2.0.0 -EX
type=lua
created=2026-2-23
]]--
if (type(lib) == "table") and (lib[0] == "LME") then

    --LME API 3.12.x allows lib.get_path to attempt to find the current file's location by sniffing a pcall'd error.
    --LME plugins can use this path to be location-fluid
    --we use it here to mainly get a reference directory to our INI data above
    local my_path = lib.get_path() or "plugins/targetless/"

    --test if the file 'main.lua' exists where we expect.
    if not gksys.IsExist(my_path .. "main.lua") then
        --file doesn't exist, abort LME functionality and registration
        --user is running pre-3.12.x LME provider (Neoloader 6.3.0) AND has put targetless in a directory other than /targetless/
    else

        --most LME functions can use INI data path instead of ID/Version pairs. we use this below:

        --check if our plugin has been registered. if no, add to registry
        if not lib.is_exist(my_path .. "main.lua") then
            lib.register(my_path .. "main.lua")
        end

        --check if the user has enabled our plugin in-game.
        --first time registration: plugin doesn't get run immediately; lets user inspect new plugins before executing them
        --        post-first-registration: plugins may default to enabled or disabled, set by user configuration
        if lib.get_state(my_path .. "main.lua").load == "NO" then
            --plugin is set as disabled by user, abort main.lua
            return
        end

        --an LME plugin's class is its public-facing data. Other plugins can obtain this through Neoloader.
        local class = {
            CCD1 = false, --your plugin doesn't have forward-declared configuration
            description = "Targetless provides a HUD display for your sector list, among other utilities.", --displayed 'about' text in neomgr
        }

        --store the table reference in Neoloader
        lib.set_class(my_path .. "main.lua", nil, class)

    end
end

-- Begin Targetless initialization
declare("targetless", {})
targetless.start = {}
targetless.stop = {}
targetless.retarget = {}
targetless.logout = {}
targetless.init = {}
targetless.re_attach = {}
targetless.update = {}
targetless.targetchange = {}
targetless.sectorupdate = {}
targetless.gothit = {}
targetless.scanevent = {}
targetless.scanevent.lock = false 
targetless.scan = {}
targetless.addroid = {}
targetless.oretbl = {}
targetless.notelabel = nil 
targetless.orelabel = nil

dofile('var.lua')
dofile('api.lua')
dofile('lists/Controller.lua')
dofile('ui/ui.lua')

targetless.playercaps = {
    ["Trident Type M"] = true,
    ["Goliath"] = true,
    ["Capella"] = true,
}

function targetless.scancaps()
    targetless.var.mycaps = {}
    local _, name, shiptype, containerid
    for itemid, _ in PlayerInventoryPairs() do
        _, name, _, _, shiptype, _, _, containerid, _, _ = GetInventoryItemInfo(itemid)
        if targetless.playercaps[shiptype] and containerid > 0 then -- found a capship!
            local stationid = GetInventoryItemLocation(itemid)
            local sectorid = GetSectorIDOfStation(stationid)
            local mycap = {
                itemid=itemid,
                containerid=containerid,
                stationid=stationid,
                sectorid=sectorid,
                name=name,
                shiptype=shiptype,
                ship=nil,
            }
            targetless.var.mycaps[name] = mycap
        end
    end
end

function targetless.start:OnEvent(eventname, ...)
    -- scan for your capships
    targetless.scancaps()
    targetless.var.state = true
    targetless.Controller:update()
    targetless.Controller:startRoidRefresh()
end

function targetless.stop:OnEvent(eventname, ...)
    if(GetCurrentStationType() ~= 1) then
        targetless.var.state = false
        targetless.Controller:stopRoidRefresh()
    end
end

function targetless.logout:OnEvent(eventname, ...)
    targetless.var.state = false
    targetless.Controller:stopRoidRefresh()
    ReloadInterface()
end

function targetless.retarget:OnEvent(eventname, ...)
    -- TODO we should probably be checking if the actual player change
    -- turret event rather then a turret-guest
    -- END TODO

    -- re-aquire target after short delay, so missles can lock
    -- we de-target first, so target actually gets required
    local timer = Timer()
        timer:SetTimeout(1000, function()
        local objecttype,objectid = radar.GetRadarSelectionID()
        gkinterface.GKProcessCommand("RadarNone")
        radar.SetRadarSelection(objecttype, objectid)
    end)
end

function targetless.re_attach()
    -- when VO reloads the HUD it deletes all our lists thinking they're
    -- the selfinfo holder box =(
    targetless.Controller.currentbuffer:reset()
    targetless.Controller.rebuildbuffer:reset()

    while(targetless.RoidList[1]) do table.remove(targetless.RoidList, 1) end
    targetless.Controller.selfinfo = nil
    targetless.Controller.centerHUD = nil
    targetless.Controller.totals.iup = nil
    -- VO already destroyed the widget trees on HUD_RELOADED, so nil out
    -- references to prevent appendiups() from Detach/Destroy on dead widgets.
    targetless.var.PlayerData = nil
    targetless.var.centerHUDinfo = nil
    targetless.var.celllists = nil
    targetless.Controller.shiplist = nil
    targetless.appendiups()
    if GetStationLocation() == nil then targetless.Controller:update() end
    targetless.RoidList:load(GetCurrentSectorid())
    targetless.Controller:stopRoidRefresh()
    targetless.Controller:startRoidRefresh()
end

function targetless.strsplit(pattern,text)
    local result = {}
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find(text,pattern,theStart)
    while theSplitStart do
        table.insert(result,string.sub(text,theStart,theSplitStart-1))
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find(text,pattern,theStart)
    end
    table.insert(result, string.sub(text,theStart))
    return result 
end

function targetless.scanevent:OnEvent(eventname, data)
    if self.lock then return end
    targetless.scanevent.objectid = targetless.scan(data)
    if (targetless.var.scanall == "ON") then targetless.addroid() end
end

function targetless.scan(data)
    local objecttype,objectid = radar.GetRadarSelectionID()
    if(data ~= nil and data ~= "" and objecttype == 2) then
        local ores = {} 
        string.gsub(data,"(.-)\n", function(a) if(not string.find(a, "Temperature:")) then table.insert(ores, a) end end)
        if(#ores >= 1 and ores[1] ~= "Object too far to scan") then 
            for i,v in ipairs(ores) do 
                if v then
                    v = string.gsub(v, "\r", "")
                    v = string.gsub(v, "\n", "")
                    v = string.gsub(v, "%%", "")
                    v = string.gsub(v, " Ore", "")
                    local ore = targetless.strsplit(": ",v)
                    targetless.oretbl[ore[1]] = ore[2]
                end
            end
            if (not iup.GetNextChild(targetless.orelabel)) then
                local roid = targetless.Roid:new()
                roid.ore = targetless.oretbl
                targetless.notelabel = iup.label{title="(Not saved)", font=targetless.var.font}
                targetless.orelabel = roid:getlabelbytag("<ore>")
                iup.Append(iup.GetParent(HUD.targethealth), targetless.notelabel)
                iup.Append(iup.GetParent(HUD.targetshiptype), targetless.orelabel)
            end
            targetless.scanevent.lock = true
        end
    end

    return objectid
end

function targetless.addroid()
    if(targetless.scanevent.lock) then
        if targetless.RoidList:add(targetless.scanevent.objectid,"",targetless.oretbl) then
            targetless.RoidList:save()
            targetless.RoidList:load(GetCurrentSectorid())
            HUD:PrintSecondaryMsg("\127ffffffOre Saved!\127o")
            targetless.Controller:update()
            iup.Detach(targetless.notelabel)
            iup.Destroy(targetless.notelabel)
            targetless.notelabel = iup.hbox{}
            iup.Append(iup.GetParent(HUD.targetname), targetless.notelabel)
        end
    end
end

function targetless.unroid()
    -- unroid freezes up really bad if the ore-list is open during operation
    -- if current list is roidlist do an lsswitch before running unroid
    if targetless.Controller.mode == "Ore" then targetless.Controller:switch() end

    local roids = targetless.RoidList:ids()
    local objecttype = 2;
    local max = 0
    local numroids = 0
    for i,v in pairs(roids) do
        numroids = numroids+1 -- #roids is not sequential doesn't have size
        if(tonumber(i) > max) then max = tonumber(i) end
    end
    local estimate = "No new roids in range.  "..numroids.." of at least "..max.." scanned!"
    if(numroids == max) then estimate = "Estimate sector scanning completed!!" end
    if(numroids == 0) then estimate = "No scanned/new roids in range!" end
    local name = ""
    local nearestdistance = 5000
    local nearestid = 0
    targetless.api.radarlock = true
    gkinterface.GKProcessCommand("RadarNone")
    targetless.var.lock = true
    local endtype,endid = radar.GetRadarSelectionID()
    local ttype,tid = radar.GetRadarSelectionID()
    local endid = tid
    repeat
        if(tid) then
            name = HUD.targetname.title
            if(name == "Asteroid" or name == "Ice Crystal") then
                if(roids[tonumber(tid)] ~= true) then
                    local distance = HUD.targetdistance.title
                    distance = distance:gsub(",","")
                    distance = distance:gsub("m","")
                    distance = tonumber(distance)
                    if(distance <= nearestdistance) then
                        nearestdistance = distance
                        nearestid = tid
                    end
                end
            end
        end
        gkinterface.GKProcessCommand("RadarNext")
        ttype,tid = radar.GetRadarSelectionID()
    until(tid == endid)
    targetless.var.lock = false
    targetless.api.radarlock = false

    if(nearestdistance < 5000) then
        radar.SetRadarSelection(objecttype, nearestid)
        HUD:PrintSecondaryMsg("\127ffffffRoid found "..nearestdistance.."m away!  "..numroids.." of at least "..max.." scanned!" .."\127o")
    else
        -- no unscanned found
        HUD:PrintSecondaryMsg("\127ffffff"..estimate.."\127o")

        radar.SetRadarSelection(GetPlayerNodeID(GetCharacterID()), GetPrimaryShipIDOfPlayer(GetCharacterID()))
    end
end


function targetless.sectorupdate:OnEvent(eventname, ...)
    -- refresh mycaps
    targetless.scancaps()

    targetless.Controller:stopRoidRefresh()
    targetless.RoidList:save()
    targetless.RoidList:load(GetCurrentSectorid())
    targetless.Controller:startRoidRefresh()

    -- re-aquire target after short delay, so missles can lock
    local timer = Timer()
        timer:SetTimeout(1000, function()
        local objecttype,objectid = radar.GetRadarSelectionID()
        radar.SetRadarSelection(objecttype, objectid)
    end)
end

function targetless.update:OnEvent(eventname, ...)
    local scaninfo = HUD.scaninfo.title
    targetless.targetchange()
    HUD:OnEvent(eventname, ...)
    if targetless.api.radarlock then
        HUD.scaninfo.title = scaninfo
    end
    targetless.Controller:update()
end

function targetless.gothit:OnEvent(eventname,myid,id) 
    if targetless.var.autopin.damage == "ON" then
        targetless.Controller.pin[id] = 1
    end
end

function targetless.targetchange()
    -- don't run if radar is locked
    if targetless.api.radarlock then return end

    targetless.scanevent.lock = false
    targetless.oretbl = {}
    targetless.scanevent.objectid = nil

    local objecttype,objectid = radar.GetRadarSelectionID()
    if objecttype and objectid then
        targetless.var.lasttarget = objectid
        targetless.var.lasttype = objecttype 
    end
    if(targetless.notelabel) then
        iup.Detach(targetless.notelabel)
        iup.Destroy(targetless.notelabel)
        targetless.notelabel = nil -- iup.hbox{}
    end
    if(targetless.orelabel) then
        iup.Detach(targetless.orelabel)
        iup.Destroy(targetless.orelabel)
        targetless.orelabel = nil -- iup.hbox{}
    end
    if(tonumber(objecttype) == 2) then 
        for i,v in ipairs(targetless.RoidList) do
            if(tonumber(v.id)==objectid) then
                targetless.notelabel = iup.label{title=v.note, font=targetless.var.font}
                targetless.orelabel = v:getlabelbytag("<ore>")
            end
        end
    end
    if not targetless.notelabel then targetless.notelabel = iup.hbox{} end
    if not targetless.orelabel then targetless.orelabel = iup.hbox{} end
    iup.Append(iup.GetParent(HUD.targetname), targetless.notelabel)
    iup.Append(iup.GetParent(HUD.targetshiptype), targetless.orelabel)
end

function targetless.printinfo()
    print("\127ffffff" .. "Target List " .. targetless.var.version .. " loaded...\n\t\127ff77ff/targetless\127o  ->  display options")
end

function targetless.usercmd(cmd)
    targetless.ui.show()
end

function targetless.init:OnEvent(eventname, ...)
    targetless.RoidList.allroids = unspickle(LoadSystemNotes(targetless.var.noteoffset) or "") or {}
    targetless.RoidList.sector = GetCurrentSectorid()
    targetless.appendiups()
    targetless.RoidList:load(GetCurrentSectorid())
    if GetStationLocation() == nil then
        -- scan for your capships
        targetless.scancaps()
        targetless.var.state = true
        targetless.Controller:update()
        targetless.Controller:startRoidRefresh()
    end
    UnregisterEvent(self, "PLAYER_ENTERED_GAME")
    UnregisterEvent(HUD, "TARGET_CHANGED")

    RegisterEvent(targetless.re_attach, "HUD_RELOADED")
    RegisterEvent(targetless.retarget, "TURRET_OCCUPIED")
    RegisterEvent(targetless.retarget, "TURRET_EMPTY")
    RegisterEvent(targetless.start, "LEAVING_STATION")
    RegisterEvent(targetless.stop, "ENTERING_STATION")
    RegisterEvent(targetless.logout, "PLAYER_LOGGED_OUT")
    RegisterEvent(targetless.scanevent, "TARGET_SCANNED")
    RegisterEvent(targetless.sectorupdate, "SECTOR_CHANGED")
    RegisterEvent(targetless.update, "TARGET_CHANGED")
    RegisterEvent(targetless.gothit, "PLAYER_GOT_HIT")
    RegisterEvent(targetless.hudtoggle, "HUD_TOGGLE")

    -- ideally this would be triggered off SHIP_CHANGED event, but something is up with that one
    -- that causes complete loss of control if called on initial load while in an undocked ship
    RegisterEvent(targetless.scancaps, "SHIP_SPAWN_CINEMATIC_FINISHED")
end

function targetless.appendiups()
    -- Clean up old widget trees to prevent duplicates when called from OnHide.
    -- We only Detach (not Destroy) the top-level containers because they hold
    -- borrowed HUD elements (targetframe, selfinfoframe, etc.) that VO still
    -- references.  Destroying would kill those shared handles.
    -- Hide old cells before detaching so their native widgets stop rendering.
    if targetless.Controller.shiplist then
        for _, cell in ipairs(targetless.Controller.shiplist.cells) do
            cell:clear()
        end
        targetless.Controller.shiplist.pincontainer.visible = "NO"
    end
    if targetless.var.PlayerData then
        targetless.var.PlayerData.visible = "NO"
        iup.Detach(targetless.var.PlayerData)
        targetless.var.PlayerData = nil
    end
    if targetless.var.centerHUDinfo then
        targetless.var.centerHUDinfo.visible = "NO"
        iup.Detach(targetless.var.centerHUDinfo)
        targetless.var.centerHUDinfo = nil
    end

    iup.Append(iup.GetParent(HUD.targetframe), iup.hbox{iup.fill{size="QUARTER"}})

    -- Release old cell list reference; the widgets are inside the already-detached
    -- PlayerData tree and will be collected by Lua GC.
    targetless.Controller.shiplist = nil

    targetless.Controller:generatetotals()
    targetless.var.selfship = iup.vbox {}

    -- Pre-allocate cell widgets that are mutated in-place each refresh.
    -- Pinned targets go at the top in a framed container.
    targetless.var.celllists = iup.vbox{}
    targetless.Controller.shiplist = targetless.CellList:new(targetless.var.listmax)
    iup.Append(targetless.var.celllists, targetless.Controller.shiplist.iup)

    local licensewatchframe 
    if(HUD.visibility.license=="YES" or HUD.visibility.missiontimers=="YES") then
        iup.Detach(HUD.licensewatchframe)
        iup.Detach(HUD.missiontimerframe)
        licensewatchframe = iup.zbox{
            HUD.licensewatchframe,
            HUD.missiontimerframe,
        }
    else
        licensewatchframe = iup.hbox{}
    end

    local targetinfoframe 
    if(HUD.visibility.targetinfo=="YES") then
        iup.Detach(HUD.targetframe)
        targetinfoframe = iup.zbox{
            HUD.targetframe,
        }
    else
        targetinfoframe = iup.hbox{iup.fill{size="QUARTER"}}
    end

    local hudinfo = iup.GetParent(HUD.selfinfoframe)
    local addons = iup.GetParent(HUD.addonframe)
    local schat = iup.GetParent(HUD.secondarychatarea)
    iup.Detach(hudinfo)
    iup.Detach(addons)
    iup.Detach(schat)
    iup.Detach(HUD.restcargoframe)

    local padding = 0
    local xres = gkinterface.GetXResolution()
    local yres = gkinterface.GetYResolution()
    local threequarter = xres*0.75
    local quarter = xres*0.25
    if HUD.Centered then
        local usex = yres*(4/3)
        if usex < xres then
            padding = (xres - usex)
            threequarter = usex*0.75
            quarter = usex*0.25
        end
    end

    targetless.var.PlayerData = iup.hbox
    {
        iup.hbox{
            iup.hbox{iup.fill{size=padding/2,},},
            iup.vbox{
                iup.hbox{iup.fill{size=threequarter,},},
                iup.fill{size="%22",},
                iup.hbox{
                    iup.fill{size=10},
                    hudinfo,
                    addons,
                    schat,
                    iup.fill{},
                    gap="4",
                },
                iup.hbox{
                    iup.fill{size=10},
                    HUD.restcargoframe,
                },
            },
            iup.vbox
            {
                iup.hbox {
                    iup.vbox{
                        iup.zbox{
                            licensewatchframe,
                        },
                        iup.zbox{
                            targetinfoframe,
                        },
                    },
                },
                targetless.var.selfship,
                targetless.Controller.totals.iup,
                targetless.var.celllists,
                iup.hbox{iup.fill{size=quarter,},},
                expand="VERTICAL",
                margin="4x4",
                gap="4",
            },
        },
    }

    local yres = gkinterface.GetYResolution()*HUD_SCALE
    targetless.var.centerHUD = iup.vbox{}
    targetless.var.centerHUDinfo = iup.hbox
    {
        iup.fill{},
        iup.vbox{
            iup.fill{size="HALF"},
            targetless.var.centerHUD,
            iup.fill{},
            alignment="ACENTER",
        },
        iup.fill{},
        alignment="ACENTER",
    }
    iup.Append(HUD.pluginlayer, targetless.var.centerHUDinfo)

    local bsinfo = iup.GetParent(HUD.BSinfo.enemylabel)
    targetless.var.PlayerData.expand = "NO"
    targetless.var.centerHUD.expand = "NO"
    iup.Detach(bsinfo)
    iup.Append(iup.GetParent(iup.GetParent(HUD.locationtext)), bsinfo)
    iup.Append(HUD.pluginlayer, targetless.var.PlayerData)

    if(targetless.notelabel) then
        iup.Detach(targetless.notelabel)
        iup.Destroy(targetless.notelabel)
        targetless.notelabel = nil
    end
    if(targetless.orelabel) then
        iup.Detach(targetless.orelabel)
        iup.Destroy(targetless.orelabel)
        targetless.orelabel = nil
    end
    targetless.notelabel = iup.hbox{}
    targetless.orelabel = iup.hbox{}
    iup.Append(iup.GetParent(HUD.targetname), targetless.notelabel)
    iup.Append(iup.GetParent(HUD.targetshiptype), targetless.orelabel)

    -- fix for ticket #45 and mission-update crashing
    -- debugged/fixed by Chocoleteer
    HUD.dlg:map()
end

function targetless.hudtoggle()
    targetless.var.lock = not targetless.var.lock
    targetless.var.state = not targetless.var.state
    targetless.Controller:update()
end

RegisterEvent(targetless.init, "PLAYER_ENTERED_GAME")
RegisterUserCommand("targetselect", function(data, args) targetless.Controller:settarget(args[1]) end) -- set binds using aliases for any target number
RegisterUserCommand("targetmycap",function()
    targetless.var.targetnum = 0
    targetless.Controller:settarget(0)
end)
RegisterUserCommand("lsswitch",function() targetless.Controller:switch() end)
RegisterUserCommand("lsback",function() targetless.Controller:switchback() end)
RegisterUserCommand("lssort",function() targetless.Controller:sort() end)
RegisterUserCommand("nextLS",function() targetless.Controller:targetnext() end)
RegisterUserCommand("prevLS",function() targetless.Controller:targetprev() end)
RegisterUserCommand("pin",function() targetless.Controller:pinfunc() end)
RegisterUserCommand("clearpin",function() 
    targetless.Controller.pin = {} 
    targetless.Controller.currentbuffer.pin = targetless.Controller.pin
    targetless.Controller.rebuildbuffer.pin = targetless.Controller.pin
    targetless.Controller:update()
end)
RegisterUserCommand("cyclestatus",function() targetless.Controller:cyclestatus() end)
RegisterUserCommand("addroid",targetless.addroid)
RegisterUserCommand("editroid",function() 
    local objecttype,objectid = radar.GetRadarSelectionID()
    local note = false
    local ore = "" 
    if(tonumber(objecttype) == 2) then 
        for i,v in ipairs(targetless.RoidList) do
            if(tonumber(v.id)==objectid) then
                note = v.note
                for k,v in pairs(v.ore) do
                    ore = ore..targetless.Roid.colorore(k)..":"..v.."%  "
                end
            end
        end
    end
    if note then
        targetless.ui.ore.edit.element.sector = GetCurrentSectorid() 
        targetless.ui.ore.edit.element.id = objectid
        targetless.ui.ore.edit.element.ore.title = ore 
        targetless.ui.ore.edit.element.note.value = note 
        targetless.ui.ore.edit.dlg:show() 
    else
        HUD:PrintSecondaryMsg("\127ffffffYou need to scan it first!\127o")
    end
end)


RegisterUserCommand("unroid",targetless.unroid)
RegisterUserCommand("importconfigroids",function() targetless.ui.ore.importconfig() end)
RegisterUserCommand("selecttarget1",function() targetless.Controller:settarget(1) end)
RegisterUserCommand("selecttarget2",function() targetless.Controller:settarget(2) end)
RegisterUserCommand("selecttarget3",function() targetless.Controller:settarget(3) end)
RegisterUserCommand("selecttarget4",function() targetless.Controller:settarget(4) end)
RegisterUserCommand("selecttarget5",function() targetless.Controller:settarget(5) end)
RegisterUserCommand("selecttarget6",function() targetless.Controller:settarget(6) end)
RegisterUserCommand("selecttarget7",function() targetless.Controller:settarget(7) end)
RegisterUserCommand("selecttarget8",function() targetless.Controller:settarget(8) end)
RegisterUserCommand("selecttarget9",function() targetless.Controller:settarget(9) end)
RegisterUserCommand("selecttarget10",function() targetless.Controller:settarget(10) end)
RegisterUserCommand("targetnone",function() 
    targetless.var.lasttype = nil
    targetless.var.lasttarget = nil
    gkinterface.GKProcessCommand("RadarNone")
end)
RegisterUserCommand("targetless",function(data, args) targetless.usercmd(args) end)

-- load android stuff last, only if on android
if gkinterface.IsTouchModeEnabled() then
    dofile('touchless.lua')
end
