targetless.Roid = {}

function targetless.Roid:new()
    local roid = {
        id = 0,
        note = "",
        ore = "",
        distance = -1,
        label = nil,
        fontcolor = "255 255 255",
    }
   
    function roid:getiup(format)
        if(format == nil) then 
            format = targetless.var.layout.roid
        end
        local layers = format
        local iupzbox = iup.zbox { iup.vbox{},all="YES" }
        for i,layerz in ipairs(layers) do
            local iupvbox = iup.vbox {}
            for j,layery in ipairs(layerz) do
                local iuphbox = iup.hbox {}
                for k,layerx in ipairs(layery) do
                    local iuplabel = self:getlabelbytag(layerx)
                    iup.Append(iuphbox, iuplabel)
                end
                iup.Append(iupvbox, iuphbox)
            end
            iup.Append(iupzbox, iupvbox)
        end
        return iupzbox
    end

    function roid:updatedistance()
        -- TODO this is hacky, since we have to change targets make sure a new update doesn't get forced
        local oldlockvalue = targetless.var.lock
        targetless.var.lock = true

        local distance = ""
        local endtype,endid = radar.GetRadarSelectionID()
        if(self:target(1)) then
            distance = ""..HUD.targetdistance.title
            distance = string.gsub(distance, ",", "")
            distance = string.gsub(distance, "m", "")
            distance = string.gsub(distance, " ", "")
            self.distance = tonumber(distance)
        else
            self.distance = -1
        end
        radar.SetRadarSelection(endtype, endid)
        targetless.var.lock = oldlockvalue
        -- end TODO
    end

    function roid:getlabelbytag(tag)
        local iuplabel
        if(tag == "<fill>") then
            iuplabel = iup.fill {}
        elseif(tag == "<tab>") then
            iuplabel = iup.fill { size="10" }
        elseif(tag == "<id>") then
			iuplabel = iup.label {title = "", font = targetless.var.font, fgcolor = self.fontcolor }
            iuplabel.title = tostring("id: "..self.id)
            iuplabel.size = "40"
        elseif(tag == "<note>") then
			iuplabel = iup.label {title = "", font = targetless.var.font, fgcolor = self.fontcolor }
            iuplabel.title = self.note
        elseif(tag == "<ore>") then
            local ores = self.ore --{}
            --string.gsub(self.ore,"'(.-)'", function(a) table.insert(ores,a) end)
            local iupbox = iup.hbox { }
            local i = 1
            for k,v in pairs(ores) do
                if(i < targetless.var.trimore) then
                    local oreframe = iup.hbox {
                        iup.label {
                            title=""..targetless.Roid.colorore(k)..": "..v.."%",
                            fgcolor=self.fontcolor,
                            font=targetless.var.font,
                        },
                        size="55",
                    }
                    iup.Append(iupbox, oreframe)
                else
                    iup.Append(iupbox, iup.label{title=".."})
                end
                i = i + 1
            end
            return iupbox
        elseif(tag == "<distance>") then
			iuplabel = iup.label {title = "", font = targetless.var.font, fgcolor = self.fontcolor }
            local distance = ""
            local endtype,endid = radar.GetRadarSelectionID()
            if not (self.distance == -1) then
                distance = self.distance.."m"
            end
            radar.SetRadarSelection(endtype, endid)
            iuplabel.title = distance
        end
        if not iuplabel then iuplabel = iup.label {title = "", font = targetless.var.font, fgcolor = self.fontcolor } end
        return iuplabel
    end

    function roid:target(silent)
        gkinterface.GKProcessCommand("RadarNone")
        local nonetype,noneid = radar.GetRadarSelectionID()
        local objecttype = 2;
        radar.SetRadarSelection(objecttype, self.id)
        local scantype,scanid = radar.GetRadarSelectionID()
        if(scanid == noneid and scantype == nonetype) then
            if not silent then
                HUD:PrintSecondaryMsg("\127ffffffTarget out of range!\127o")

                -- requested by chocolateer
                ProcessEvent("ROID_OUT_OF_RANGE", self.id)
            end
            return false
        end
        return true
    end

    function roid:destroy()
        if(self.label) then
            iup.Detach(self.label)
            iup.Destroy(self.label)
        end
    end
    return roid
end

function targetless.Roid.colorore(ore)
    ore = string.sub(ore, 1, 2)
    for i,v in pairs(targetless.var.orecolor) do
        ore = string.gsub(ore, i, v)    
    end
    return ore
end
