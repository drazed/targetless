-- Pre-allocated cell for ship list entries.
-- cell:create(index)      builds IUP widget tree once, stores mutable refs
-- cell:update(ship, i)    mutates stored widget refs in-place (no new widgets)
-- cell:clear()            hides the cell row (root.visible = "NO")

targetless.Cell = {}

function targetless.Cell:new()
    local cell = {
        root           = nil,
        numlabel       = nil,
        shieldbar      = nil,
        healthbar      = nil,
        healthpct      = nil,
        name           = nil,
        shiptype       = nil,
        distance       = nil,
        pcstands       = nil,
        istand         = nil, sstand = nil, ustand = nil,
        istand_factbar = nil, sstand_factbar = nil, ustand_factbar = nil,
        lstand         = nil, lstand_factbar = nil,
    }

    -- Build a bar-mode standing widget.
    -- Returns: container_box, standbar_ref, factbar_ref
    local function make_standbar(faction_id)
        local fcolor  = FactionColor_RGB[faction_id] or "155 155 155"
        local standbar = iup.stationprogressbar{
            visible="YES", active="NO", size="16x4", title=""}
        standbar.minvalue  = -100
        standbar.maxvalue  = 65535
        standbar.uppercolor = "64 64 64 64 *"
        standbar.lowercolor = "255 255 255 128 *"
        standbar.value     = 0
        local factbar = iup.stationprogressbar{
            visible="YES", active="NO", size="16x3", title=""}
        factbar.minvalue  = 0
        factbar.maxvalue  = 100
        factbar.uppercolor = fcolor
        factbar.lowercolor = fcolor
        factbar.value     = 0
        local box = iup.vbox{ iup.fill{size=4}, factbar, standbar }
        return box, standbar, factbar
    end

    -- Build an image-mode standing label.
    local function make_imagelabel()
        return iup.label{title="", font=targetless.var.font}
    end

    -- Build the full widget tree. Must be called before update() or clear().
    -- Layout is a single info row beneath thin health/shield bars:
    --   [#N] [===health/shield===]
    --        [hp%] Name ShipType ... 1234m [standings]
    function cell:create(index)
        local font = targetless.var.font
        local fc   = "150 150 150"

        -- Number label (#N)
        self.numlabel = iup.label{
            title     = index and ("#"..index) or "",
            font      = font,
            fgcolor   = "32 155 32",
            size      = "40",
            alignment = "ACENTER",
        }

        -- Shield bar (hidden when shield == 0)
        self.shieldbar = iup.stationprogressbar{
            visible="NO", active="NO", size="x3", expand="HORIZONTAL", title=""}
        self.shieldbar.minvalue   = 0
        self.shieldbar.maxvalue   = 100
        self.shieldbar.uppercolor = "0 0 0 0 *"
        self.shieldbar.lowercolor = "0 0 255 155 *"

        -- Health bar
        self.healthbar = iup.stationprogressbar{
            visible="YES", active="NO", size="x6", expand="HORIZONTAL", title=""}
        self.healthbar.minvalue   = 0
        self.healthbar.maxvalue   = 100
        self.healthbar.uppercolor = "0 0 0 0 *"
        self.healthbar.lowercolor = "64 255 64 64 *"

        -- Health text with brackets
        self.healthpct = iup.label{title="   0%", font=font, fgcolor="255 255 255"}
        local healthtext = iup.hbox{
            iup.label{title=" [", font=font, fgcolor="255 255 255 156 *"},
            self.healthpct,
            iup.label{title="]",  font=font, fgcolor="255 255 255 156 *"},
        }

        -- Name label (player name for PC, ship name for NPC/cap)
        self.name = iup.label{title="", font=font, fgcolor=fc}

        -- Ship type label (shown alongside name for PCs, empty for NPC/cap)
        self.shiptype = iup.label{title="", font=font, fgcolor=fc}

        -- Distance
        self.distance = iup.label{title="", font=font, fgcolor=fc, size="60"}

        -- Standing widgets
        local use_images = (targetless.var.faction == "smile" or targetless.var.faction == "wheel")
        local istand_box, sstand_box, ustand_box, lstand_box
        if use_images then
            self.istand = make_imagelabel()
            self.sstand = make_imagelabel()
            self.ustand = make_imagelabel()
            self.lstand = make_imagelabel()
            istand_box  = self.istand
            sstand_box  = self.sstand
            ustand_box  = self.ustand
            lstand_box  = self.lstand
        else
            istand_box, self.istand, self.istand_factbar = make_standbar(1)
            sstand_box, self.sstand, self.sstand_factbar = make_standbar(2)
            ustand_box, self.ustand, self.ustand_factbar = make_standbar(3)
            lstand_box, self.lstand, self.lstand_factbar = make_standbar(GetSectorAlignment() or 1)
        end

        -- PC standings container (hidden for NPC/cap)
        self.pcstands = iup.hbox{ istand_box, sstand_box, ustand_box }

        -- Single info row: hp% + name + shiptype + fill + distance + standings
        local inforow = iup.hbox{
            healthtext, self.name, self.shiptype,
            iup.fill{},
            self.distance, lstand_box, self.pcstands,
        }

        -- Assemble root: number label + bars + info row
        self.root = iup.hbox{
            self.numlabel,
            iup.vbox{ self.shieldbar, self.healthbar, inforow },
            alignment="ACENTER",
        }
    end

    -- Mutate all widget properties from a Ship data object.
    -- index is the display number shown in numlabel and used for target selection.
    -- is_pinned: true if this entry is a pinned target (shown with gold highlight).
    function cell:update(ship, index, is_pinned)
        self.root.visible = "YES"

        -- Target highlight (color only, no font scaling to avoid stretching rows)
        local is_target = (ship.name == HUD.targetname.title
            or "Turret ("..ship.name..")" == HUD.targetname.title)
        if is_target then
            targetless.var.targetnum  = index
            self.numlabel.fgcolor    = ship.hostile and "255 64 64" or "64 255 64"
        else
            self.numlabel.fgcolor    = ship.hostile and "155 32 32" or "32 155 32"
        end
        self.numlabel.title = "#" .. index

        -- Health bars
        local health = ship.health or 0
        local shield = ship.shield or 0
        self.shieldbar.visible = (shield > 0) and "YES" or "NO"
        if shield > 0 then self.shieldbar.value = shield end

        local halpha = is_target and 128 or 64
        self.healthbar.lowercolor = calc_health_color(health / 100, halpha)
        self.healthbar.value      = health
        self.healthbar.visible    = (health >= 0) and "YES" or "NO"

        -- Health text
        local hpstr = tostring(health)
        if #hpstr < 2 then hpstr = "    " .. hpstr
        elseif #hpstr < 3 then hpstr = "  " .. hpstr end
        if #hpstr < 3 then hpstr = hpstr .. " " end
        self.healthpct.title  = hpstr .. "%"
        self.healthpct.fgcolor = calc_health_color(health / 100, 156)

        -- Distance
        self.distance.title = " " .. tostring(ship.distance) .. "m "

        -- Name, ship type, and standings depend on ship category
        local namecolor = is_target and "255 255 255" or FactionColor_RGB[ship.faction]
        local trim = targetless.var.trim

        if ship.cap then
            self.pcstands.visible = "NO"
            self.shiptype.title = ""
            local capname = (ship.ship or "") .. " " .. ship.name
            if #capname > trim + 2 then capname = capname:sub(1, trim) .. ".." end
            self.name.title   = capname
            self.name.fgcolor = namecolor

        elseif ship.npc then
            self.pcstands.visible = "NO"
            self.shiptype.title = ""
            local npcname = ship.ship or ship.name
            if npcname == "Robot" then npcname = ship.name end
            local faction = (ship.faction and ship.faction > 3)
                and (targetless.var.factions[ship.faction] or "") or ""
            local strim = trim - #faction - 8
            if strim < 1 then strim = 1 end
            if #npcname + 4 > strim then npcname = npcname:sub(1, strim) .. ".." end
            self.name.title   = npcname
            self.name.fgcolor = namecolor
            if ship.faction and ship.faction > 3 then
                self.name.title = self.name.title .. "(" .. faction .. ")"
            end

        else
            -- PC: name in faction color, ship type in grey
            self.pcstands.visible = "YES"
            local fname = (ship.faction and ship.faction > 3)
                and (targetless.var.factions[ship.faction] or "") or ""
            local pctrim = trim - 6
            if #fname > 0 then pctrim = pctrim - #fname end
            local pcname = ship.name
            if #pcname > pctrim + 2 then pcname = pcname:sub(1, pctrim) .. ".." end
            self.name.title   = pcname
            self.name.fgcolor = namecolor
            if #fname > 0 then
                self.name.title = self.name.title .. "(" .. fname .. ")"
            end

            local pcship = ship.ship or ""
            if #pcship + 4 > trim then pcship = pcship:sub(1, trim - 6) .. "..." end
            self.shiptype.title   = " " .. pcship
            self.shiptype.fgcolor = "150 150 150"

            self:update_standings(ship)
        end

        self:update_lstand(ship)
    end

    -- Update istand/sstand/ustand for a PC ship row.
    function cell:update_standings(ship)
        local monitored  = (GetSectorMonitoredStatus() == 1)
        local use_images = (targetless.var.faction == "smile" or targetless.var.faction == "wheel")

        if monitored then
            if use_images then
                self.istand.title = ""
                self.sstand.title = ""
                self.ustand.title = ""
            else
                self.istand.value = 0
                self.sstand.value = 0
                self.ustand.value = 0
            end
            return
        end

        if use_images then
            self.istand.title  = self:standing_image_name(ship.istand)
            self.sstand.title  = self:standing_image_name(ship.sstand)
            self.ustand.title  = self:standing_image_name(ship.ustand)
            self.istand.fgcolor = FactionColor_RGB[1] or "255 255 255"
            self.sstand.fgcolor = FactionColor_RGB[2] or "255 255 255"
            self.ustand.fgcolor = FactionColor_RGB[3] or "255 255 255"
            self.istand.image  = targetless.var.IMAGE_DIR .. self.istand.title
            self.sstand.image  = targetless.var.IMAGE_DIR .. self.sstand.title
            self.ustand.image  = targetless.var.IMAGE_DIR .. self.ustand.title
        else
            self.istand.value = ship.istand or 0
            self.sstand.value = ship.sstand or 0
            self.ustand.value = ship.ustand or 0
        end
    end

    -- Update lstand based on sector rules (all ship types).
    -- lstand is shown only when: not monitored AND (npc OR sector alignment >= 4).
    function cell:update_lstand(ship)
        local monitored  = (GetSectorMonitoredStatus() == 1)
        local alignment  = GetSectorAlignment() or 1
        local use_images = (targetless.var.faction == "smile" or targetless.var.faction == "wheel")
        local show       = (not monitored) and (ship.npc or alignment >= 4)

        if not show then
            if use_images then
                self.lstand.title = ""
                if self.lstand.image ~= nil then self.lstand.image = "" end
            else
                self.lstand.value = 0
            end
            return
        end

        if use_images then
            local imgname = self:standing_image_name(ship.lstand)
            self.lstand.title  = imgname
            self.lstand.fgcolor = FactionColor_RGB[alignment] or "155 155 155"
            self.lstand.image  = targetless.var.IMAGE_DIR .. imgname
        else
            self.lstand.value = ship.lstand or 0
            if self.lstand_factbar then
                local color = FactionColor_RGB[alignment] or "155 155 155"
                self.lstand_factbar.uppercolor = color
                self.lstand_factbar.lowercolor = color
            end
        end
    end

    -- Map a standing value to an image filename relative to IMAGE_DIR.
    function cell:standing_image_name(stand)
        local s = factionfriendlyness(stand)
        local f = targetless.var.faction
        if     s == "Kill on Sight"     then return f .. "/KOS.png"
        elseif s == "Hate"              then return f .. "/hate.png"
        elseif s == "Dislike"           then return f .. "/dislike.png"
        elseif s == "Neutral"           then return f .. "/neutral.png"
        elseif s == "Respect"           then return f .. "/respect.png"
        elseif s == "Admire"            then return f .. "/admire.png"
        elseif s == "Pillar of Society" then return f .. "/POS.png"
        else                                 return f .. "/neutral.png"
        end
    end

    -- Hide this cell (no-op if root not yet created).
    function cell:clear()
        if self.root then self.root.visible = "NO" end
    end

    return cell
end
