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
targetless.RoidList.refreshmultiple = 0
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
    while(self[1]) do
        table.remove(self,1)
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
    for i,v in pairs(roids) do
        self:add(v.id, v.note, v.ore)
    end
    self.roidcount = #self
end

function targetless.RoidList:ids()
    local roidids = {}
    for i,v in ipairs(self) do 
        roidids[v.id] = true
    end
    return roidids
end

function targetless.RoidList:getiup(offset)
    self.refreshmultiple = self.refreshmultiple + 1
    if self.refreshmultiple > math.ceil(targetless.var.roidrefresh/targetless.var.refreshDelay) then
        self.refreshmultiple = 0
    end
    local iuproidlist = iup.vbox{}
    targetless.api.radarlock = true
    for i,v in ipairs(targetless.RoidList) do
        if(offset+i > targetless.var.roidmax) then 
            targetless.api.radarlock = false
            return iuproidlist 
        end
        local numlabel = iup.label {title = "" .. offset+i, size=30,alignment="ACENTER" }
        local objecttype,objectid = radar.GetRadarSelectionID()
        if(objectid and tonumber(v.id) == objectid) then
            numlabel.fgcolor="255 255 255"
            numlabel.font = Font.H1
            v.fontcolor = "255 255 255"
        else
            numlabel.fgcolor="155 155 155"
            numlabel.font = targetless.var.font
            v.fontcolor = "155 155 155"
        end
        if self.refreshmultiple == 1 then v:updatedistance() end
        local roidlabel = v:getiup()

        local iupbox = iup.vbox{
            iup.hbox
            {
                numlabel,
                roidlabel,
                alignment="ACENTER",
            },
        }
        v.label = iupbox
        iup.Append(iuproidlist, v.label)
    end
    targetless.api.radarlock = false
    return iuproidlist
end
