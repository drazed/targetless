--dofile('lists/PinnedList.lua')
dofile('lists/Ship.lua')
dofile('lists/List.lua')
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
    self.totals.pveblabel.fgcolor ="155 155 155"
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
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.cap.fgcolor = activestatuscolor
    elseif(self.mode == "Bomb") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.bomb.fgcolor = activestatuscolor
    elseif(self.mode == "All") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.all.fgcolor = activestatuscolor
    elseif(self.mode == "Ore") then
        self.totals.orelabel.fgcolor = "255 255 255"
        self.totals.roids.fgcolor = activestatuscolor
    end
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
                self.mode = "Bombships"
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
    self.totals.pveblabel.fgcolor ="155 155 155"
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
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.cap.fgcolor = activestatuscolor
    elseif(self.mode == "Bomb") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.bomb.fgcolor = activestatuscolor
    elseif(self.mode == "All") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.all.fgcolor = activestatuscolor
    elseif(self.mode == "Ore") then
        self.totals.orelabel.fgcolor = "255 255 255"
        self.totals.roids.fgcolor = activestatuscolor
    end
    self.currentbuffer.mode = self.mode
    self.rebuildbuffer.mode = self.mode
    self:update()
end

-- this does not save the sort order, only temporarily cycles it.
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
                targetless.RoidList:load(GetCurrentSectorid())
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

    local statuscolor = "155 155 155"
    if(self.fstatus == 2) then statuscolor = "155 32 32"
    elseif(self.fstatus == 1) then statuscolor = "32 155 32"
    end
    local activestatuscolor = "255 255 255"
    if(self.fstatus == 2) then activestatuscolor = "255 64 64"
    elseif(self.fstatus == 1) then activestatuscolor = "64 255 64"
    end

    if(self.mode == "PvP") then
        self.totals.pvplabel.fgcolor = "255 255 255"
        self.totals.pvp.fgcolor = activestatuscolor
    elseif(self.mode == "Cap" or self.mode == "Bomb" or self.mode == "All") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor ="255 255 255"
        if(self.mode == "Cap") then self.totals.cap.fgcolor = activestatuscolor
        elseif(self.mode == "Bomb") then self.totals.bomb.fgcolor = activestatuscolor
        elseif(self.mode == "All") then self.totals.all.fgcolor = activestatuscolor
        end
    elseif(self.mode == "Ore") then  self.totals.roids.fgcolor = "255 255 255" end

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
    iup.Map(iup.GetDialog(self.selfinfo))
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
    iup.Map(iup.GetDialog(self.centerHUD))
    iup.Refresh(targetless.var.centerHUD)
end


function targetless.Controller:pinfunc()
    -- only allow this function if targetless state is enabled/started
    if not targetless.var.state then return end

    local id = RequestTargetStats()
    if(id) then
        if(self.pin[id] == 1) then
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

    -- update totals colors
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
    self.totals.pveblabel.fgcolor ="155 155 155"
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
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.cap.fgcolor = activestatuscolor
    elseif(self.mode == "Bomb") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.bomb.fgcolor = activestatuscolor
    elseif(self.mode == "All") then
        self.totals.pvelabel.fgcolor = "255 255 255"
        self.totals.pveblabel.fgcolor ="255 255 255"
        self.totals.all.fgcolor = activestatuscolor
    elseif(self.mode == "Ore") then
        self.totals.orelabel.fgcolor = "255 255 255"
        self.totals.roids.fgcolor = activestatuscolor
    end
    self:update()
end

function targetless.Controller:targetprev()
    local buffer = self.currentbuffer
    if targetless.var.targetnum <= 1 then
        -- if at first target own a targetable capship wrap to that, otherwise wrap to last element
        if targetless.var.targetnum == 1 then
            for k,v in pairs(targetless.var.mycaps) do
                if v.ship ~= nil then
                    targetless.var.targetnum = 0
                    self:settarget(targetless.var.targetnum)
                    return -- return immediatly to prevent re-wrapping below 
                end
            end
        end

        if buffer.mode ~= "Ore" and buffer.mode ~= "none" then
            targetless.var.targetnum = #buffer.pinned+#buffer.ships
            if targetless.var.targetnum >= targetless.var.listmax then
                targetless.var.targetnum = targetless.var.listmax
            end

        elseif buffer.mode == "Ore" then
            targetless.var.targetnum = #buffer.pinned+#targetless.RoidList
            if targetless.var.targetnum >= targetless.var.roidmax then
                targetless.var.targetnum = targetless.var.roidmax
            end
        end
    else targetless.var.targetnum = targetless.var.targetnum - 1 end

    self:settarget(targetless.var.targetnum)
end

function targetless.Controller:targetnext()
    local buffer = self.currentbuffer
    if (buffer.mode == "Ore" and
       (targetless.var.targetnum >= targetless.var.roidmax or
       targetless.var.targetnum >= #buffer.pinned+#targetless.RoidList)) or
       (buffer.mode ~= "Ore" and buffer.mode ~= "none" and
       (targetless.var.targetnum >= targetless.var.listmax or 
       targetless.var.targetnum >= #buffer.pinned+#buffer.ships))
    then 
        -- if your capship is targettable wrap to that, otherwise wrap back to 1st
        targetless.var.targetnum = 1
        for k,v in pairs(targetless.var.mycaps) do
            if v.ship ~= nil then
                targetless.var.targetnum = 0
                break
            end
        end
    else targetless.var.targetnum = targetless.var.targetnum + 1 end

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

    local buffer = self.currentbuffer
    if(#buffer.pinned >= number) then
        if buffer.pinned[tonumber(number)] ~= nil then
            buffer.pinned[tonumber(number)]:target()
        end
    else
        if buffer.mode ~= "Ore" and buffer.mode ~= "none" then
            if buffer.ships[tonumber(number)-#buffer.pinned] ~= nil then
                buffer.ships[tonumber(number)-#buffer.pinned]:target()
            end
        else
            if targetless.RoidList[tonumber(number)-#buffer.pinned] ~= nil then
                targetless.RoidList[tonumber(number)-#buffer.pinned]:target()
            end
        end
    end

    -- store this target number in the rollover list
    targetless.var.targetnum = number
end

function targetless.Controller:switchbuffers()
    if targetless.var.state then
        local tmpbuffer = self.currentbuffer
        self.currentbuffer = self.rebuildbuffer
        self.rebuildbuffer = tmpbuffer
        if self.rebuildbuffer.iupobj ~= nil then
            iup.Detach(self.rebuildbuffer.iupobj)
            iup.Destroy(self.rebuildbuffer.iupobj)
            self.rebuildbuffer.iupobj = nil
        end
        if self.currentbuffer.iupobj ~= nil then
            iup.Append(targetless.var.iuplists, self.currentbuffer.iupobj)
            iup.Map(iup.GetDialog(self.currentbuffer.iupobj))
            iup.Refresh(targetless.var.PlayerData)
        end
        self.rebuildbuffer:reset()
    end
end

function targetless.Controller:update()
    if not targetless.var.lock then
        targetless.var.lock = true
        if HUD.hud_toggled_off then return end
        self.rebuildbuffer:reset(true)
        self:switchbuffers()
        targetless.var.lock = nil
   end
end
