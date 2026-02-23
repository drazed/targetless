targetless.Buffer = {}
function targetless.Buffer:new()
    local buffer = {
        timer = Timer(),
        rush = nil,
        delay = 20,
        ready = false,
        shipidbuffer = {},
        atship = 0,
        atroid = 0,
        -- ships = targetless.List:new(),
        -- pinned = targetless.List:new(),
        count = {
            pvp = 0,
            cap = 0,
            bomb = 0,
            all = 0,
        },
        pin = {},
        mode = "All",
        fstatus = 0,
        iupobj = nil,
    }

    --[[
    --
    --]]
    function buffer:reset(rush)
        self.timer = nil
        self.timer = Timer()
        self.ready = nil 
        self.rush = rush
        self.shipidbuffer = {}
        self.atship = 0
        self.atroid = 0

        self.self = false 
        self.totals = false 
        self.center = false 

        self.count.pvp = 0
        self.count.cap = 0
        self.count.bomb = 0
        self.count.all = 0

        self.ships:clear()
        self.pinned:clear()
        --collectgarbage()
        self:start()
    end

    function buffer:start()
        ForEachPlayer(function (id)
            if id ~= GetCharacterID() then
                -- add ship id to buffer
                table.insert(self.shipidbuffer, id)

                -- re-target
                if(not targetless.api.radarlock and HUD.targetname.title == "(none)") then
                    if(GetPrimaryShipIDOfPlayer(id) == targetless.var.lasttarget) then radar.SetRadarSelection(targetless.var.lasttype, targetless.var.lasttarget) end
                end
                
            end
        end)
        if self.rush == true then 
            self:step()
        else self.timer:SetTimeout(self.delay, function() self:step() end)
        end
    end

    --[[
    --
    --]]
    function buffer:step()
        if targetless.var.state and not self.ready then
            if(#self.shipidbuffer > 0) then
                self:addship(self.shipidbuffer[1])
                table.remove(self.shipidbuffer, 1)
            elseif((self.atship < #self.pinned+#self.ships) and (self.atship <= targetless.var.listmax)) then
                self.atship = self.atship + 1
                if(self.atship > #self.pinned) then
                    if(self.atship-#self.pinned <= #self.ships) then
                        self.ships[self.atship-#self.pinned].label = self.ships[self.atship-#self.pinned]:getiup()
                    end
                else
                    self.pinned[self.atship].label = self.pinned[self.atship]:getiup()
                end
            elseif(self.mode == "Ore" and (self.atroid < #self.pinned+#targetless.RoidList) and (self.atroid <= targetless.var.roidmax)) then
                self.atroid = self.atroid + 1
                -- broken for some reason, laggy TODO
                --targetless.RoidList[self.atroid]:updatedistance()
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
                self.iupobj = self:getiup()
                self.ready = true 
            end
            if self.rush == true then self:step()
            else self.timer:SetTimeout(self.delay, function() self:step() end)
            end
        else
            --ProcessEvent('TLS_BUFFER_READY', self)
            if not self.rush == true then
                targetless.Controller:switchbuffers()
            end
        end
    end

    --[[
    --
    --]]
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

    --[[
    --
    --]]
    function buffer:getiup()
        local iupbox
        if not self.ready and self.mode ~= "none" then
            self.ships.offset = #self.pinned
            local iuppinnedframe
            if(#self.pinned>0) then 
	            local iuppinned = self.pinned:getiup()
                if(targetless.var.pinframe=="ON") then
                    iuppinnedframe = iup.hudrightframe{iuppinned}
                else
                    iuppinnedframe = iup.vbox{iuppinned}
                end
            else
                iuppinnedframe = iup.vbox{}
            end
            local iuplist
            if self.mode == "Ore" then 
                iuplist = targetless.RoidList:getiup(#self.pinned)
            else
                iuplist = self.ships:getiup()
            end

            local iuplistframe
            if(targetless.var.listframe=="ON") then
                iuplistframe = iup.hudrightframe { iup.zbox{ iup.hbox{iup.fill{}}, iuplist, all="YES", }, }
            else
                iuplistframe = iup.vbox { iup.zbox{ iup.hbox{iup.fill{}}, iuplist, all="YES", }, }
            end

            iupbox = iup.vbox{
                iup.vbox {
                    --  targetless.var.iupself,
                    iuppinnedframe,
                    iuplistframe,
                    gap="4",
                },
            }
        end
        if not iupbox then iupbox = iup.vbox{} end
        return iupbox
    end

    --[[
    --
    --]]
    function buffer:updateiup()
    end

    return buffer
end

