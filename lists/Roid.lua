targetless.Roid = {}

function targetless.Roid:new()
    local roid = {}
    roid["id"] = 0
    roid["note"] = ""
    roid["ore"] = "" 
    roid["label"] = nil
    roid.fontcolor = "255 255 255"
    function roid:getiup(format)
        if(format == nil) then 
            format = "{<tab><ore><fill>}"
        end
        local formattbl = {}
        string.gsub(format,"{(.-)}", function(a) table.insert(formattbl, a) end)
        local i = 1
        while(formattbl[i]) do
            local formatstr = formattbl[i]
            formattbl[i] = {}
            string.gsub(formatstr,"<(.-)>", function(a) table.insert(formattbl[i], a) end)
            i = i + 1
        end

        local iupbox = iup.vbox {}
        i = 1
        while(formattbl[i]) do
            local iuphbox = iup.hbox {}
            local j = 1
            while(formattbl[i][j]) do
                local iuplabel = self:getlabelbytag(formattbl[i][j])
                iup.Append(iuphbox, iuplabel)
                j = j + 1
            end
            iup.Append(iupbox, iuphbox)
            i = i + 1
        end

        return iupbox 
    end

    function roid:getlabelbytag(tag)
        local iuplabel = iup.label {title = "", font = targetless.var.font, fgcolor = self.fontcolor }
        if(tag == "fill") then
            iuplabel = iup.fill {}
        elseif(tag == "tab") then
            iuplabel = iup.fill { size="10" }
        elseif(tag == "id") then
            iuplabel.title = tostring("id: "..self["id"])
            iuplabel.size = "40"
        elseif(tag == "note") then
            iuplabel.title = self["note"]
        elseif(tag == "ore") then
            local ores = {}
            string.gsub(self["ore"],"'(.-)'", function(a) table.insert(ores,a) end)
            local iupbox = iup.hbox { }
            for i,v in ipairs(ores) do
                local oreframe = iup.hbox {
                    iup.label {
                        title=""..targetless.Roid.colorore(v), 
                        fgcolor=self.fontcolor, 
                        font=targetless.var.font
                    },
                    size="55",
                }
                iup.Append(iupbox, oreframe)
            end
            return iupbox
        end
        return iuplabel
    end

    function roid:target()
        gkinterface.GKProcessCommand("RadarNone")
        local nonetype,noneid = radar.GetRadarSelectionID()
        local objecttype = 2;
        radar.SetRadarSelection(objecttype, self["id"])
        local scantype,scanid = radar.GetRadarSelectionID()
        if(scanid == noneid and scantype == nonetype) then
            HUD:PrintSecondaryMsg("\127ffffffTarget out of range!\127o")
        end
    end

    function roid:serialize()
        return "<"..self["id"].."><"..self["note"]..">".."<"..self["ore"]..">"
    end

    function roid:destroy()
        if(self["label"]) then
            iup.Detach(self["label"])
            iup.Destroy(self["label"])
        end
    end

    return roid 
end

function targetless.Roid.colorore(ore)
    ore = string.gsub(ore, " Ore:", ":")
    for i,v in pairs(targetless.var.orecolor) do
        ore = string.gsub(ore, i, v)    
    end
    return ore
end
