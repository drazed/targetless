dofile('lists/Roid.lua')
targetless.RoidList = {}
targetless.RoidList.sortorder = {
    "Heliocene",
    "Pentric",
    "Apicene",
    "Pyronic",
    "Denic",
    "Lanthanic",
    "Xithricite",
    "VanAzek",
    "Ishik",
    "Ferric",
    "Carbonic",
    "Silicate",
    "Aquean",
}
targetless.RoidList.scannum = 1
targetless.RoidList.sector = 0
targetless.RoidList.roidcount = 0
targetless.RoidList.allroids = {}

function targetless.RoidList:add(id, note, ore)
    local scanned = targetless.Roid:new()
    local objecttype,objectid = radar.GetRadarSelectionID()
    scanned.id = id 
    scanned.ore = ore
    scanned.note = note 
    scanned.fontcolor = "155 155 155"

    -- check for duplicate
    for j,roid in ipairs(self) do
        if(scanned.id == roid.id) then return false end
    end

    -- Always order by user selected ore type first
    local i = 1
    while(self[i] and self[i].ore[targetless.var.oresort] and (tonumber(scanned.ore[targetless.var.oresort] or 0) < tonumber(self[i].ore[targetless.var.oresort] or 0))) do
        i = i + 1
    end
    -- if this rock had no user selected ore sor by best (arbitrary)
    -- Order is Helio, Pentric, Apicene, Pyronic, Denic, Lanth, Xith, VanAzek, Ishik, Ferric, Carbonic, Silicate, Aquean
    if not scanned.ore[targetless.var.oresort] then
        local offset
        for j,oretype in ipairs(self.sortorder) do
            offset = j
            if not scanned.ore[oretype] then
                while(self[i] and self[i].ore[oretype] and not (tonumber(self[i].ore[oretype] or 0) == 0)) do
                    i = i + 1
                end
            else
                break
            end
        end
        while(self[i] and self[i].ore[self.sortorder[offset]] and (tonumber(scanned.ore[self.sortorder[offset]] or 0) < tonumber(self[i].ore[self.sortorder[offset]] or 0))) do
            i = i + 1
        end
    end
    -- and we're ready to insert
    table.insert(self, i, scanned)
    return scanned
end

function targetless.RoidList:clear()
    for i = #self, 1, -1 do
        self[i] = nil
    end
end

function targetless.RoidList:save()
    local roids = {}
    for i,v in ipairs(self) do 
        roids[v.id] = {
            id=v.id,
            note=v.note,
            ore=v.ore,
        }
    end
    self.allroids[tonumber(self.sector)] = spickle(roids)
    SaveSystemNotes(spickle(self.allroids),targetless.var.noteoffset)
    return true
end

function targetless.RoidList:load(sectorID)
    self:clear()
    self.sector = sectorID
    local roids = unspickle(self.allroids[sectorID] or "") or {}
    -- Bulk insert then sort once (O(n log n) vs O(n²) from repeated add())
    for i,v in pairs(roids) do
        local roid = targetless.Roid:new()
        roid.id = v.id
        roid.ore = v.ore
        roid.note = v.note
        roid.fontcolor = "155 155 155"
        table.insert(self, roid)
    end
    local sortore = targetless.var.oresort
    local sortorder = self.sortorder
    table.sort(self, function(a, b)
        -- Primary: sort by user-selected ore type descending
        local aval = tonumber(a.ore[sortore] or 0)
        local bval = tonumber(b.ore[sortore] or 0)
        if aval ~= bval then return aval > bval end
        -- Secondary: sort by first ore in sortorder that either has
        for _, oretype in ipairs(sortorder) do
            local ao = tonumber(a.ore[oretype] or 0)
            local bo = tonumber(b.ore[oretype] or 0)
            if ao ~= bo then return ao > bo end
        end
        return false
    end)
    self.roidcount = #self
end

function targetless.RoidList:ids()
    local roidids = {}
    for i,v in ipairs(self) do 
        roidids[v.id] = true
    end
    return roidids
end

