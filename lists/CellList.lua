-- Pre-allocated list of Cells for the pinned/ship display.
-- Uses targetless.CellList (not targetless.List) to avoid name collision.
--
-- Pinned cells live in a separate vbox wrapped in hudrightframe (matching
-- the legacy pinned frame look).  Non-pinned cells live in a plain vbox.
-- Cells are moved between the two containers via Detach/Append only when
-- the pin count changes.
--
-- celllist:populate(items, offset, pincount)  update cells, clear remainder
-- celllist:clear()                            clear (hide) all cells
-- celllist:rebuild(new_size)                  recreate all cells (settings change)

targetless.CellList = {}

function targetless.CellList:new(size)
    local list = {
        size          = size or 10,
        cells         = {},
        pinvbox       = iup.vbox{},   -- pinned cells go here
        shipvbox      = iup.vbox{},   -- non-pinned cells go here
        pincontainer  = nil,          -- hudrightframe or pinvbox; toggled visible when pins > 0
        last_pincount = 0,
        iup           = nil,          -- top-level mount point
    }

    -- Wrap pinned section in hudrightframe if the pinframe setting is on.
    if targetless.var.pinframe == "ON" then
        list.pincontainer = iup.hudrightframe{ list.pinvbox }
    else
        list.pincontainer = list.pinvbox
    end
    list.pincontainer.visible = "NO"   -- hidden until pins exist
    list.iup = iup.vbox{ list.pincontainer, list.shipvbox }

    -- Pre-allocate cells; all start in shipvbox (no pins initially).
    for i = 1, list.size do
        local cell = targetless.Cell:new()
        cell:create(i)
        cell:clear()
        table.insert(list.cells, cell)
        iup.Append(list.shipvbox, cell.root)
    end

    -- Update cells from items array, clear remainder.
    -- offset: added to i to produce the display index.
    -- pincount: items[1..pincount] are pinned (shown in framed container).
    function list:populate(items, offset, pincount)
        local count = items and #items or 0
        pincount = pincount or 0

        -- Re-parent cells between pinvbox and shipvbox when pin count changes.
        if pincount ~= self.last_pincount then
            for i = 1, self.size do
                iup.Detach(self.cells[i].root)
            end
            for i = 1, self.size do
                if i <= pincount then
                    iup.Append(self.pinvbox, self.cells[i].root)
                else
                    iup.Append(self.shipvbox, self.cells[i].root)
                end
            end
            self.pincontainer.visible = (pincount > 0) and "YES" or "NO"
            self.last_pincount = pincount
        end

        for i = 1, self.size do
            if i <= count then
                self.cells[i]:update(items[i], (offset or 0) + i, i <= pincount)
            else
                self.cells[i]:clear()
            end
        end
    end

    -- Clear (hide) all cells.
    function list:clear()
        for _, cell in ipairs(self.cells) do
            cell:clear()
        end
    end

    -- Recreate all cells into the existing containers.
    -- Call this when display settings change: font, faction mode, or listmax.
    function list:rebuild(new_size)
        for _, cell in ipairs(self.cells) do
            if cell.root then
                iup.Detach(cell.root)
                iup.Destroy(cell.root)
            end
        end
        self.cells = {}
        self.last_pincount = 0
        if new_size then self.size = new_size end
        for i = 1, self.size do
            local cell = targetless.Cell:new()
            cell:create(i)
            cell:clear()
            table.insert(self.cells, cell)
            iup.Append(self.shipvbox, cell.root)
        end
    end

    return list
end
