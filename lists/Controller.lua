--dofile('lists/PinnedList.lua')
dofile('lists/Ship.lua')
dofile('lists/List.lua')
dofile('lists/iupCell.lua')
dofile('lists/CellList.lua')
dofile('lists/RoidList.lua')
dofile('lists/Buffer.lua')
targetless.Controller = {}
targetless.Controller.currentbuffer = targetless.Buffer:new()
targetless.Controller.rebuildbuffer = targetless.Buffer:new()
targetless.Controller.pin = {}
targetless.Controller.currentbuffer.pin = targetless.Controller.pin
targetless.Controller.rebuildbuffer.pin = targetless.Controller.pin
targetless.Controller.mode = "All"
targetless.Controller.fstatus = 0
targetless.Controller.shiplist = nil
targetless.Controller.roid_timer = nil
targetless.Controller.roid_index = 0

-- Independent background timer for roid distance updates.
-- Runs one roid:updatedistance() per tick, spaced out so a full cycle
-- takes approximately roidrefresh ms (default 3000ms).
-- Completely decoupled from the ship buffer cycle to avoid lag.
function targetless.Controller:startRoidRefresh()
    if self.roid_timer then return end  -- already running
    self.roid_timer = Timer()
    self.roid_index = 0
    self:roidRefreshStep()
end

function targetless.Controller:roidRefreshStep()
    if not targetless.var.state then
        self.roid_timer = nil
        return
    end

    -- Only update distances for visible roids:
    -- Ore mode: all roids are visible, update them all.
    -- Other modes: only pinned roids are visible.
    if #targetless.RoidList > 0 then
        self.roid_index = self.roid_index + 1
        if self.roid_index > #targetless.RoidList then
            self.roid_index = 1
        end
        local roid = targetless.RoidList[self.roid_index]
        local mode = self.currentbuffer.mode or self.mode
        if mode == "Ore" or self.pin["roid:" .. roid.id] == 1 then
            roid:updatedistance()
        end
    end

    -- Space updates so one full cycle through all roids takes ~roidrefresh ms.
    -- Minimum 100ms per update to stay gentle on CPU.
    local count = math.max(#targetless.RoidList, 1)
    local interval = math.max(math.floor(targetless.var.roidrefresh / count), 100)
    self.roid_timer:SetTimeout(interval, function()
        self:roidRefreshStep()
    end)
end

function targetless.Controller:stopRoidRefresh()
    self.roid_timer = nil
    self.roid_index = 0
end

function targetless.Controller:switch()
    -- only allow this function if targetless state is enabled/started
    if not targetless.var.state then return end

    if(self.mode == "PvP") then 
        if(targetless.var.huddisplay.showpve == "ON") then
            if(targetless.var.huddisplay.showcaps == "ON") then
                self.mode = "Cap"
            elseif(targetless.var.huddisplay.showbomb == "ON") then
                self.mode = "Bomb"
            elseif(targetless.var.huddisplay.showships == "ON") then
                self.mode = "All"
            elseif(targetless.var.huddisplay.showore == "ON") then
                self.mode = "Ore"
            else self.mode = "none"
            end
        elseif(targetless.var.huddisplay.showore == "ON") then
            self.mode = "Ore"
        else self.mode = "none"
        end
    elseif(self.mode == "Cap") then  
        if(targetless.var.huddisplay.showbomb == "ON") then
            self.mode = "Bomb" 
        elseif(targetless.var.huddisplay.showships == "ON") then
            self.mode = "All"
        elseif(targetless.var.huddisplay.showore == "ON") then
            self.mode = "Ore"
        else self.mode = "none"
        end
    elseif(self.mode == "Bomb") then 
        if(targetless.var.huddisplay.showships == "ON") then
            self.mode = "All"
        elseif(targetless.var.huddisplay.showore == "ON") then
            self.mode = "Ore"
        else self.mode = "none"
        end
    elseif(self.mode == "All") then 
        if(targetless.var.huddisplay.showore == "ON") then
            self.mode = "Ore"
        else self.mode = "none"
        end
    elseif(self.mode == "Ore") then  self.mode = "none" 
    else 
        if(targetless.var.huddisplay.showpvp == "ON") then
            self.mode = "PvP"
        elseif(targetless.var.huddisplay.showpve == "ON") then
            if(targetless.var.huddisplay.showcaps == "ON") then
                self.mode = "Cap"
            elseif(targetless.var.huddisplay.showbomb == "ON") then
                self.mode = "Bomb"
            elseif(targetless.var.huddisplay.showships == "ON") then
                self.mode = "All"
            elseif(targetless.var.huddisplay.showore == "ON") then
                self.mode = "Ore"
            else self.mode = "none"
            end
        elseif(targetless.var.huddisplay.showore == "ON") then
            self.mode = "Ore"
        else self.mode = "none"
        end
    end
    self:updatetotalcolors()
    self.currentbuffer.mode = self.mode
    self.rebuildbuffer.mode = self.mode
    self:update()
end

function targetless.Controller:switchback()
    -- only allow this function if targetless state is enabled/started
    if not targetless.var.state then return end

    if(self.mode == "Ore") then 
        if(targetless.var.huddisplay.showpve == "ON") then
            if(targetless.var.huddisplay.showships == "ON") then
                self.mode = "All"
            elseif(targetless.var.huddisplay.showbomb == "ON") then
                self.mode = "Bomb"
            elseif(targetless.var.huddisplay.showcaps == "ON") then
                self.mode = "Cap"
            elseif(targetless.var.huddisplay.showpvp == "ON") then
                self.mode = "PvP"
            else self.mode = "none"
            end
        elseif(targetless.var.huddisplay.showpvp == "ON") then
            self.mode = "PvP"
        else self.mode = "none"
        end
    elseif(self.mode == "All") then  
        if(targetless.var.huddisplay.showbomb == "ON") then
            self.mode = "Bomb" 
        elseif(targetless.var.huddisplay.showcaps == "ON") then
            self.mode = "Cap"
        elseif(targetless.var.huddisplay.showpvp == "ON") then
            self.mode = "PvP"
        else self.mode = "none"
        end
    elseif(self.mode == "Bomb") then 
        if(targetless.var.huddisplay.showcaps == "ON") then
            self.mode = "Cap"
        elseif(targetless.var.huddisplay.showpvp == "ON") then
            self.mode = "PvP"
        else self.mode = "none"
        end
    elseif(self.mode == "Cap") then 
        if(targetless.var.huddisplay.showpvp == "ON") then
            self.mode = "PvP"
        else self.mode = "none"
        end
    elseif(self.mode == "PvP") then  self.mode = "none" 
    else 
        if(targetless.var.huddisplay.showore == "ON") then
            self.mode = "Ore"
        elseif(targetless.var.huddisplay.showpve == "ON") then
            if(targetless.var.huddisplay.showships == "ON") then
                self.mode = "All"
            elseif(targetless.var.huddisplay.showbomb == "ON") then
                self.mode = "Bomb"
            elseif(targetless.var.huddisplay.showcaps == "ON") then
                self.mode = "Cap"
            elseif(targetless.var.huddisplay.showpvp == "ON") then
                self.mode = "PvP"
            else self.mode = "none"
            end
        elseif(targetless.var.huddisplay.showpvp == "ON") then
            self.mode = "PvP"
        else self.mode = "none"
        end
    end

    self:updatetotalcolors()
    self.currentbuffer.mode = self.mode
    self.rebuildbuffer.mode = self.mode
    self:update()
end

-- this does not save the sort order, only temporarily cycles it.
-- Destroys and recreates all cells to guarantee a clean slate, then
-- re-populates with current data using the new sort key.
function targetless.Controller:sort()
    if(self.mode == "none") then return
    elseif(self.mode == "Ore") then
        for i,ore in ipairs(targetless.RoidList.sortorder) do
            if(ore == targetless.var.oresort) then
                if(i < #targetless.RoidList.sortorder) then
                    targetless.var.oresort = targetless.RoidList.sortorder[i+1]
                else
                    targetless.var.oresort = targetless.RoidList.sortorder[1]
                end
                self:update()
                HUD:PrintSecondaryMsg("\127ffffffOre sorted by "..targetless.var.oresort.."\127o")
                return
            end
        end
    else
        -- options are "distance", "health", "faction"
        if(targetless.var.sortBy == "distance") then
            targetless.var.sortBy = "health"
        elseif(targetless.var.sortBy == "health") then
            targetless.var.sortBy = "faction"
        else
            targetless.var.sortBy = "distance"
        end
        self:update()
        HUD:PrintSecondaryMsg("\127ffffffShips sorted by "..targetless.var.sortBy.."\127o")
    end
end

targetless.Controller.totals = {}
targetless.Controller.totals.iup = nil

-- Update the fgcolor of all totals bar labels to reflect current mode and fstatus.
-- Call this any time mode or fstatus changes.
function targetless.Controller:updatetotalcolors()
    local statuscolor = "155 155 155"
    if(self.fstatus == 2) then statuscolor = "155 32 32"
    elseif(self.fstatus == 1) then statuscolor = "32 155 32"
    end
    local activestatuscolor = "255 255 255"
    if(self.fstatus == 2) then activestatuscolor = "255 64 64"
    elseif(self.fstatus == 1) then activestatuscolor = "64 255 64"
    end
    self.totals.pvplabel.fgcolor = "155 155 155"
    self.totals.pvelabel.fgcolor = "155 155 155"
    self.totals.pveblabel.fgcolor = "155 155 155"
    self.totals.orelabel.fgcolor = "155 155 155"
    self.totals.pvp.fgcolor = statuscolor
    self.totals.cap.fgcolor = statuscolor
    self.totals.bomb.fgcolor = statuscolor
    self.totals.all.fgcolor = statuscolor
    self.totals.roids.fgcolor = statuscolor
    if(self.mode == "PvP") then
        self.totals.pvplabel.fgcolor = "255 255 255"
        self.totals.pvp.fgcolor = activestatuscolor
    elseif(self.mode == "Cap") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor = "255 255 255"
        self.totals.cap.fgcolor = activestatuscolor
    elseif(self.mode == "Bomb") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor = "255 255 255"
        self.totals.bomb.fgcolor = activestatuscolor
    elseif(self.mode == "All") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor = "255 255 255"
        self.totals.all.fgcolor = activestatuscolor
    elseif(self.mode == "Ore") then
        self.totals.orelabel.fgcolor = "255 255 255"
        self.totals.roids.fgcolor = activestatuscolor
    end
end

function targetless.Controller:generatetotals()
    if self.totals.iup ~= nil then
        iup.Detach(self.totals.iup)
        iup.Destroy(self.totals.iup)
        self.totals.iup = nil
    end
    targetless.Controller.totals.pvp = iup.label { title="0", fgcolor="155 155 155", font=targetless.var.font }
    targetless.Controller.totals.cap = iup.label { title="0", fgcolor="155 155 155", font=targetless.var.font }
    targetless.Controller.totals.bomb = iup.label { title="0", fgcolor="155 155 155", font=targetless.var.font }
    targetless.Controller.totals.all = iup.label { title="0", fgcolor="155 155 155", font=targetless.var.font }
    targetless.Controller.totals.roids = iup.label { title="0", fgcolor="155 155 155", font=targetless.var.font }

    targetless.Controller.totals.pvplabel = iup.label { title="PvP:", fgcolor="155 155 155", font=targetless.var.font }
    targetless.Controller.totals.pvelabel = iup.label { title="PvE: (", fgcolor="155 155 155", font=targetless.var.font }
    targetless.Controller.totals.pveblabel = iup.label { title=")", fgcolor="155 155 155", font=targetless.var.font }
    targetless.Controller.totals.orelabel = iup.label { title="Ore:", fgcolor="155 155 155", font=targetless.var.font }

    self:updatetotalcolors()

    local iupbox = iup.hbox {}
    iup.Append(iupbox,iup.fill{})
    if(targetless.var.huddisplay.showpvp == "ON") then
        iup.Append(iupbox,self.totals.pvplabel)
        iup.Append(iupbox,self.totals.pvp)
        iup.Append(iupbox,iup.fill { size="3" })
    end
    if(targetless.var.huddisplay.showpve == "ON") then
        if(targetless.var.huddisplay.showpvp == "ON") then
            iup.Append(iupbox,iup.label{title="|",fgcolor="155 155 155",font=targetless.var.font})
            iup.Append(iupbox,iup.fill { size="3" })
        end
        iup.Append(iupbox,self.totals.pvelabel)
        if(targetless.var.huddisplay.showcaps == "ON") then
            iup.Append(iupbox,self.totals.cap)
        end
        if(targetless.var.huddisplay.showbomb == "ON") then
            if(targetless.var.huddisplay.showcaps == "ON") then
                iup.Append(iupbox,iup.label{title="|",fgcolor="155 155 155",font=targetless.var.font})
            end
            iup.Append(iupbox,self.totals.bomb)
        end
        if(targetless.var.huddisplay.showships == "ON") then
            if((targetless.var.huddisplay.showbomb == "ON") or (targetless.var.huddisplay.showcaps == "ON")) then
                iup.Append(iupbox,iup.label{title="|",fgcolor="155 155 155",font=targetless.var.font})
            end
            iup.Append(iupbox,self.totals.all)
        end
        iup.Append(iupbox,self.totals.pveblabel)
        iup.Append(iupbox,iup.fill { size="3" })
    end
    if(targetless.var.huddisplay.showore == "ON") then
        if((targetless.var.huddisplay.showpve == "ON") or (targetless.var.huddisplay.showpvp == "ON")) then
            iup.Append(iupbox,iup.label{title="|",fgcolor="155 155 155",font=targetless.var.font})
            iup.Append(iupbox,iup.fill { size="3" })
        end
        iup.Append(iupbox,self.totals.orelabel)
        iup.Append(iupbox,self.totals.roids)
    end
    self.totals.iup = iup.hudrightframe { iupbox }
end

function targetless.Controller:updatetotals()
    self.totals.pvp.title = ""..self.currentbuffer.count.pvp
    self.totals.cap.title = ""..self.currentbuffer.count.cap
    self.totals.bomb.title = ""..self.currentbuffer.count.bomb
    self.totals.all.title = ""..self.currentbuffer.count.all
    self.totals.roids.title = ""..targetless.RoidList.roidcount
end

-- Build a formatted ore string for a roid using \127 color codes.
local function roid_ore_string(roid)
    local parts = {}
    local i = 0
    for k, v in pairs(roid.ore) do
        if i >= targetless.var.trimore then
            parts[#parts + 1] = ".."
            break
        end
        parts[#parts + 1] = targetless.Roid.colorore(k) .. ":" .. v .. "%"
        i = i + 1
    end
    return table.concat(parts, " ")
end

-- Wrap a Roid data object into a cell-compatible item table.
local function make_roid_item(roid)
    return {
        roid     = true,
        id       = roid.id,
        ore      = roid.ore,
        distance = roid.distance or -1,
        health   = -1,
        shield   = 0,
        hostile  = false,
        npc      = false,
        cap      = false,
        ship     = nil,
        faction  = 0,
        name     = roid_ore_string(roid),
        target   = function(self) roid:target() end,
    }
end

-- Sort comparator using the configured sortBy key ("distance", "health", "faction").
-- Roids only have distance, so health/faction fall back to 0 (sort to top).
local function sort_by_key(a, b)
    local key = targetless.var.sortBy
    local av = tonumber(a[key] or 0) or 0
    local bv = tonumber(b[key] or 0) or 0
    return av < bv
end

-- Sort comparator for ore mode: primary by oresort percentage (descending),
-- secondary by distance (ascending).
local function sort_by_ore(a, b)
    local ore_key = targetless.var.oresort
    local ao = tonumber(a.ore and a.ore[ore_key] or 0) or 0
    local bo = tonumber(b.ore and b.ore[ore_key] or 0) or 0
    if ao ~= bo then return ao > bo end
    local ad = tonumber(a.distance or 0) or 0
    local bd = tonumber(b.distance or 0) or 0
    return ad < bd
end

-- Populate the pre-allocated cell list from the completed buffer.
-- Builds a unified display list: [pinned items (sorted)] + [mode items (sorted)].
-- Cross-mode pinning: pinned roids show on ship lists, pinned ships show on roid list.
function targetless.Controller:populatecells(buffer)
    if not targetless.var.state then return end
    if not self.shiplist then return end

    -- 1. Collect all pinned items (ships + roids), sort together by sortBy
    local pinned = {}
    local ship_pincount = buffer.pinned and #buffer.pinned or 0
    for i = 1, ship_pincount do
        pinned[#pinned + 1] = buffer.pinned[i]
    end
    for _, roid in ipairs(targetless.RoidList) do
        if self.pin["roid:" .. roid.id] == 1 then
            pinned[#pinned + 1] = make_roid_item(roid)
        end
    end
    table.sort(pinned, sort_by_key)

    local items = {}
    local pincount = #pinned
    for i = 1, pincount do
        items[#items + 1] = pinned[i]
    end

    -- 2. Mode-specific non-pinned items
    if buffer.mode == "Ore" then
        -- Ore mode: sort by oresort percentage (descending), then distance (ascending)
        local roids = {}
        for _, roid in ipairs(targetless.RoidList) do
            if self.pin["roid:" .. roid.id] ~= 1 then
                roids[#roids + 1] = make_roid_item(roid)
            end
        end
        table.sort(roids, sort_by_ore)
        for _, item in ipairs(roids) do
            if #items >= targetless.var.listmax then break end
            items[#items + 1] = item
        end
    elseif buffer.mode ~= "none" then
        -- Ship modes: sort dynamically so sort-key changes take effect
        -- without requiring a full rush rebuild.
        local ships = {}
        local shipcount = buffer.ships and #buffer.ships or 0
        for i = 1, shipcount do
            ships[#ships + 1] = buffer.ships[i]
        end
        table.sort(ships, sort_by_key)
        for i = 1, #ships do
            if #items >= targetless.var.listmax then break end
            items[#items + 1] = ships[i]
        end
    end

    buffer.items = items
    local layout_changed = self.shiplist:populate(items, 0, pincount)
    -- Only refresh layout when structural changes occurred (cell count or
    -- pincount changed).  Content-only updates (sort reorder, property
    -- mutations) don't need a Refresh and triggering one can cause IUP
    -- layout artefacts.  Scope to the cell container, not the full panel.
    if layout_changed and self.shiplist.iup then
        iup.Refresh(self.shiplist.iup)
    end
end

function targetless.Controller:updateself()
    -- only run this function if showself is enabled, otherwise memory leaks
    if targetless.var.showself ~= "ON" then return end

    if self.selfinfo ~= nil then
        iup.Detach(self.selfinfo)
        iup.Destroy(self.selfinfo)
        self.selfinfo = nil
    end
    self.selfinfo = iup.vbox {}
    local selfinfo = iup.vbox {}

    -- ALWAYS add your own ship
    self.selfship = targetless.Ship:new(GetCharacterID())
    if not self.selfship or not self.selfship.ship then return end
    local selfiup = self.selfship:getiup(targetless.var.layout.self)
    iup.Append(selfinfo, selfiup)

    -- add any your-capships
    -- capships are scanned in on EVENTS and stored in targetless.var.mycaps
    if next(targetless.var.mycaps) ~= nil then
        for k,v in pairs(targetless.var.mycaps) do
            local selfcapiup = nil
            if v.ship ~= nil and v.ship.ship ~= nil then
                selfcapiup = v.ship:getiup(targetless.var.layout.mycap)
            elseif v.sectorid ~= nil and v.sectorid > 0 then
                local iupname = iup.label {title = "", font = targetless.var.font }
                local name = v.shiptype.." "..v.name
                local trim = targetless.var.trim
                if(#name > trim+2) then name = name:sub(1,trim)..".." end
                iupname.title = name

                -- use your own faction as the ships is unavailable but the same
                iupname.fgcolor=FactionColor_RGB[self.selfship.faction]

                local location = AbbrLocationStr(targetless.var.mycaps[v.name].sectorid)
                local iuploc = iup.label {title = "", font = targetless.var.font }
                iuploc.title = " "..location
                iuploc.size = ""..(88 + ((targetless.var.fontscale*100)) - 40)

                -- ship is not located in this sector, lets build a custom iup for it
                selfcapiup = iup.zbox{ iup.vbox{
                    iup.hbox {
                        -- this covers <tab><healthtext> which are both unavailable here
                        iup.label {title="    ",font=targetless.var.font},
                        iup.label {title="      ",font=targetless.var.font},
                        iupname,
                        iup.fill{},
                        iuploc,
                    }
                },all="YES"}
            else
                selfcapiup = iup.zbox{iup.vbox{}}
            end
            iup.Append(selfinfo, selfcapiup)
        end
    end

    if(targetless.var.selfframe=="ON") then
        self.selfinfo = iup.hudrightframe { iup.zbox{ iup.hbox{iup.fill{}}, selfinfo, all="YES", }, }
    else
        self.selfinfo = iup.vbox { iup.zbox{ iup.hbox{iup.fill{}}, selfinfo, all="YES", }, }
    end

    iup.Append(targetless.var.selfship, self.selfinfo)
    iup.Map(self.selfinfo)
    iup.Refresh(targetless.var.selfship)
end

function targetless.Controller:updatecenter()
    if self.centerHUD ~= nil then
        iup.Detach(self.centerHUD)
        iup.Destroy(self.centerHUD)
        self.centerHUD = nil
    end
    local targetnode,targetid = radar.GetRadarSelectionID()
    local centeriup
    if GetCharacterID(targetnode) == GetCharacterID() or targetless.var.showtargetcenter ~= "ON" then
        centeriup = iup.vbox{iup.fill{size=20}}
    else
        local targetship = targetless.Ship:new(GetCharacterID(targetnode))
        if not targetship or not targetship.ship then 
            centeriup = iup.vbox{iup.fill{size=20}}
        else
            targetship.font = targetless.var.font
            centeriup = targetship:getiup()
        end
    end

    local selfship = targetless.Ship:new(GetCharacterID())
    if not selfship or not selfship.ship then return end

    local selfiup
    if targetless.var.showselfcenter ~= "ON" then
        selfiup = iup.vbox{iup.fill{size=20}}
    else
        selfship.font = targetless.var.font
        selfiup = selfship:getiup(targetless.var.layout.selfcenter)
    end

    local xres = gkinterface.GetXResolution()*HUD_SCALE
    local yres = gkinterface.GetYResolution()*HUD_SCALE
    self.centerHUD = iup.vbox { 
        iup.fill{size=yres*0.18},
        iup.zbox{ 
            iup.hbox{iup.fill{size=xres*0.22}}, 
            selfiup, 
            all="YES", 
        },
        iup.fill{size=25},
        iup.zbox{ 
            iup.hbox{iup.fill{size=xres*0.22}}, 
            centeriup, 
            all="YES", 
        },

    }
    iup.Append(targetless.var.centerHUD, self.centerHUD)
    iup.Map(self.centerHUD)
    iup.Refresh(targetless.var.centerHUD)
end


function targetless.Controller:pinfunc()
    -- only allow this function if targetless state is enabled/started
    if not targetless.var.state then return end

    -- Detect whether target is a roid (objecttype 2) or a ship.
    local objecttype, objectid = radar.GetRadarSelectionID()
    local id
    if objecttype == 2 then
        id = "roid:" .. objectid
    else
        id = RequestTargetStats()
    end
    if id then
        if self.pin[id] == 1 then
            self.pin[id] = 0
        else
            self.pin[id] = 1
        end
    end
    self:update()
end

function targetless.Controller:cyclestatus()
    if self.fstatus == 2 then 
        self.fstatus = 0
    else
        self.fstatus = self.fstatus + 1
    end
    self.currentbuffer.fstatus = self.fstatus
    self.rebuildbuffer.fstatus = self.fstatus

    self:updatetotalcolors()
    self:update()
end

function targetless.Controller:targetprev()
    local buffer = self.currentbuffer
    local item_count = buffer.items and #buffer.items or 0
    if item_count > targetless.var.listmax then item_count = targetless.var.listmax end

    if targetless.var.targetnum <= 1 then
        -- if at first target and own a targetable capship, wrap to that
        if targetless.var.targetnum == 1 then
            for k,v in pairs(targetless.var.mycaps) do
                if v.ship ~= nil then
                    targetless.var.targetnum = 0
                    self:settarget(targetless.var.targetnum)
                    return
                end
            end
        end
        targetless.var.targetnum = item_count
    else
        targetless.var.targetnum = targetless.var.targetnum - 1
    end

    self:settarget(targetless.var.targetnum)
end

function targetless.Controller:targetnext()
    local buffer = self.currentbuffer
    local item_count = buffer.items and #buffer.items or 0
    if item_count > targetless.var.listmax then item_count = targetless.var.listmax end

    if targetless.var.targetnum >= item_count then
        -- wrap: try capship first, otherwise back to 1
        targetless.var.targetnum = 1
        for k,v in pairs(targetless.var.mycaps) do
            if v.ship ~= nil then
                targetless.var.targetnum = 0
                break
            end
        end
    else
        targetless.var.targetnum = targetless.var.targetnum + 1
    end

    self:settarget(targetless.var.targetnum)
end

function targetless.Controller:settarget(number)
    -- target your own capship if it's in the same sector or plot route to your capship if not
    if tonumber(number) == 0 then
        -- TODO make this multi-cap aware and cycle to next mycap
        -- for now just select the first valid mycap entry or return if none
        for k,v in pairs(targetless.var.mycaps) do
            if v.ship ~= nil then
                v.ship:target()
                return
            end
        end

        -- if we got here no capship was in range, set course to first valid one
        for k,v in pairs(targetless.var.mycaps) do
            if v.sectorid ~= nil and v.sectorid > 0 then
                NavRoute.SetFinalDestination(v.sectorid)
                return
            end
        end
    end

    -- Use unified items list from last populatecells call
    local buffer = self.currentbuffer
    local item = buffer.items and buffer.items[tonumber(number)]
    if item then
        item:target()
    end

    targetless.var.targetnum = number
end

function targetless.Controller:switchbuffers()
    if targetless.var.state then
        local tmpbuffer = self.currentbuffer
        self.currentbuffer = self.rebuildbuffer
        self.rebuildbuffer = tmpbuffer
        self.rebuildbuffer:reset()
    end
end

function targetless.Controller:update()
    if not targetless.var.lock then
        targetless.var.lock = true
        if HUD.hud_toggled_off then return end
        self.rebuildbuffer:reset(true)
        self:switchbuffers()
        targetless.var.lock = false
   end
end
