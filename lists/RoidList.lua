dofile('lists/Roid.lua')
targetless.RoidList = {}
targetless.RoidList.sector = 0
targetless.RoidList.roidcount = 0

function targetless.RoidList:add(id, note, ore)
    local scanned = targetless.Roid:new()
    local objecttype,objectid = radar.GetRadarSelectionID()
    scanned["id"] = id 
    scanned["ore"] = ore
    scanned["note"] = note 
    scanned["fontcolor"] = "155 155 155"
    for i,v in ipairs(self) do
        if(self[i]["id"] == scanned["id"]) then return end
    end
    table.insert(self, scanned)
    return scanned
end

function targetless.RoidList:refresh()
    -- regenerate iups 
    for i,v in ipairs(self) do 
        v:destroy()
    end
    for i,v in ipairs(self) do 
        if(i>targetless.var.listmax) then return end
        local numlabel = iup.label {title = "" .. i, size=30,alignment="ACENTER" }
        local objecttype,objectid = radar.GetRadarSelectionID()
        if(objectid and v["id"] == ""..objectid) then 
            numlabel.fgcolor="255 255 255"
            numlabel.font = Font.H1 
            v.fontcolor = "255 255 255"
        else 
            numlabel.fgcolor="155 155 155" 
            numlabel.font = targetless.var.font 
            v.fontcolor = "155 155 155"
        end
        local roidlabel = v:getiup() 

        local iupbox = iup.hbox
        {
            numlabel,
            roidlabel
        }
        v["label"] = iupbox
        iup.Append(targetless.var.iuproids, v["label"])
        iup.Map(v["label"])
    end
end

function targetless.RoidList:updatesector(sectorid)
    if(sectorid) then
        -- save list, clear, and load new sector list
        local seriallist = self:savesector(self.sector)
        if seriallist then 
            -- get a list of saved sectors, add this sector where it belongs
            local sectorload = gkini.ReadString("roidls", "sectors", "")
            local sectors = {}
            string.gsub(sectorload,"<(.-)>", function(a) sectors[""..a]=true end)
            if(not sectors[""..self.sector]) then 
                gkini.WriteString("roidls", "sectors", sectorload.."<"..self.sector..">")
            end
            -- and save the roids and sector
            gkini.WriteString("roidls", ""..self.sector, seriallist)
        end
        self:clear()
        self.sector = sectorid
        -- load list
        self:loadsector(self.sector)

        -- updates
--        if(targetless.var.listpage == "roid") then
--            self:refresh()
--        end
        self.roidcount = #self
    end
end

function targetless.RoidList:clear()
    while(self[1]) do
--        self[1]:destroy()
        table.remove(self,1)
    end
end

function targetless.RoidList:savesector(sectorID)
    local roids = ""
    for i,v in ipairs(self) do 
        roids = roids.."<"..v['id']..">"
        gkini.WriteString("roidls"..sectorID,""..v['id'],v:serialize())
    end
    if roids == "" then return false end -- nothing was added
    gkini.WriteString("roidls"..sectorID,"roids",roids)
    return true
end

function targetless.RoidList:loadsector(sectorID)
    local string = gkini.ReadString("roidls"..sectorID, "roids", "")
    local roids = {}
    if string ~= "" then
        string.gsub(string,"<(.-)>", function(a) table.insert(roids,a) end)
        for i,v in ipairs(roids) do
            local roidstr = gkini.ReadString("roidls"..sectorID, ""..v, "")
            if roidstr ~= "" then
                local roid = {}
                string.gsub(roidstr,"<(.-)>", 
                    function(a) table.insert(roid, a) end)
                self:add(roid[1], roid[2], roid[3])
            end
        end
    end
end

