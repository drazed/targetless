targetless.Buffer = {}
function targetless.Buffer:new()
    local buffer = {
        timer = Timer(),
        delay = 10,
        ready = false,
        shipidbuffer = {},
        ships = targetless.List:new(),
        pinned = targetless.List:new(),
        items = {},    -- unified display list set by populatecells
        count = {
            pvp = 0,
            cap = 0,
            bomb = 0,
            all = 0,
        },
        pin = {},
        mode = "All",
        fstatus = 0,
    }

    function buffer:reset()
        self.timer = nil
        self.timer = Timer()
        self.ready = nil
        self.shipidbuffer = {}

        self.self = false
        self.totals = false
        self.center = false

        self.count.pvp = 0
        self.count.cap = 0
        self.count.bomb = 0
        self.count.all = 0

        self.ships:clear()
        self.pinned:clear()
        self.items = {}
        self:start()
    end

    function buffer:start()
        ForEachPlayer(function (id)
            if id ~= GetCharacterID() then
                table.insert(self.shipidbuffer, id)
            end
        end)
        self.targetrecovered = false
        self.timer:SetTimeout(self.delay, function() self:step() end)
    end

    function buffer:step()
        if targetless.var.state and not self.ready then
            if(#self.shipidbuffer > 0) then
                -- recover lost target: check one player per tick instead of all at once
                if not self.targetrecovered and not targetless.api.radarlock and HUD.targetname.title == "(none)" then
                    if GetPrimaryShipIDOfPlayer(self.shipidbuffer[1]) == targetless.var.lasttarget then
                        radar.SetRadarSelection(targetless.var.lasttype, targetless.var.lasttarget)
                        self.targetrecovered = true
                    end
                end
                self:addship(self.shipidbuffer[1])
                table.remove(self.shipidbuffer, 1)
            elseif not self.self then
                targetless.Controller:updateself()
                self.self = true
            elseif not self.center then
                targetless.Controller:updatecenter()
                self.center = true
            elseif not self.totals then
                targetless.Controller:updatetotals()
                self.totals = true
            else
                targetless.Controller:populatecells(self)
                self.ready = true
            end
            self.timer:SetTimeout(self.delay, function() self:step() end)
        else
            targetless.Controller:switchbuffers()
        end
    end

    function buffer:addship(id)
        local ship = targetless.Ship:new(id)
        if not ship then return end
        if not(self.fstatus == 0) then
            if self.fstatus == 1 then
                if ship.hostile then return end
            else
                if not ship.hostile then return end
            end
        end

        -- check if this ship is in mycaps, ship.name contains leading "*  "
        -- do this BEFORE counts as won't be displayed in list-data so shouldn't
        -- be counted there
        local capname = string.sub(ship.name, 3, string.len(ship.name))
        if targetless.var.mycaps[capname] ~= nil then
            targetless.var.mycaps[capname].ship = ship
            return
        end

        if not ship.ship then
            if not ship.npc then self.count.pvp = self.count.pvp + 1 end
            self.count.all = self.count.all + 1
            return
        end
        if not ship.npc then
            self.count.pvp = self.count.pvp + 1
        end
        local bomb = false
        if(string.sub(ship.ship, 1, string.len("Ragnarok")) == "Ragnarok") then
            bomb = true
        end
        if ship.cap then self.count.cap = self.count.cap + 1 end
        if bomb then self.count.bomb = self.count.bomb + 1 end
        self.count.all = self.count.all + 1

        -- beyond here only show ships within radar range
        if ship.distance == 0 then return end
        if(self.pin[id]==1 ) then
            self.pinned:add(ship)
            return
        end
        if(self.mode == "Ore" or self.mode == "none") then return
        elseif(self.mode == "PvP") then
            if ship.npc then return end
        elseif(self.mode == "Cap") then
            if not ship.cap then return end
        elseif(self.mode == "Bomb") then
            if not bomb then return end
        end
        self.ships:add(ship)
    end

    return buffer
end
