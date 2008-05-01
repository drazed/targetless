dofile('lists/PinnedList.lua')
dofile('lists/PlayerList.lua')
dofile('lists/RoidList.lua')
targetless.Lists = {}
targetless.Lists.mode = "All"
targetless.Lists.iup = nil
targetless.Lists.pinned = {}
targetless.Lists.pinnednew = {}

function targetless.Lists:switch()
    if(self.mode == "PvP") then self.mode = "Cap"
    elseif(self.mode == "Cap") then  self.mode = "Bomb" 
    elseif(self.mode == "Bomb") then self.mode = "All"
    elseif(self.mode == "All") then self.mode = "Ore"
    elseif(self.mode == "Ore") then  self.mode = "none" 
    else self.mode = "PvP" end
    self:update()
end

function targetless.Lists:pin()
    local ttype,tid = radar.GetRadarSelectionID()
    if(tid and ttype) then
        if(self.pinnednew[tid] == 1) then
            self.pinnednew[tid] = 0 
        else
            self.pinnednew[tid] = 1 
        end
    end
    self:update()
end

function targetless.Lists:getiuptotals()
        local pvplabel = iup.label { title="PvP: "..self.pvpcount, fgcolor="155 155 155",  font=targetless.var.font }
        local pvelabel = iup.label { title="PvE: (", fgcolor="155 155 155", font=targetless.var.font }
        local pveblabel = iup.label { title=")", fgcolor="155 155 155", font=targetless.var.font }
        local caplabel = iup.label { title=""..self.capcount, fgcolor="155 155 155",  font=targetless.var.font }
        local bomblabel = iup.label { title=""..self.bombcount, fgcolor="155 155 155",  font=targetless.var.font }
        local alllabel = iup.label { title=""..self.allcount, fgcolor="155 155 155",  font=targetless.var.font }
        local orelabel = iup.label { title="Ore: "..targetless.RoidList.roidcount, fgcolor="155 155 155", font=targetless.var.font }

        if self.mode ~= "Ore" then 
        else orelabel.fgcolor = "255 255 255" end

        if(self.mode == "PvP") then pvplabel.fgcolor = "255 255 255"
        elseif(self.mode == "Cap" or self.mode == "Bomb" or self.mode == "All") then 
            pvelabel.fgcolor = "255 255 255"
            pveblabel.fgcolor = "255 255 255"
            if(self.mode == "Cap") then caplabel.fgcolor = "255 255 255"
            elseif(self.mode == "Bomb") then bomblabel.fgcolor = "255 255 255"
            elseif(self.mode == "All") then alllabel.fgcolor = "255 255 255" end
        elseif(self.mode == "Ore") then  orelabel.fgcolor = "255 255 255" end

        local iupbox = iup.hbox
        {
            iup.fill {},
            pvplabel,
            iup.fill { size="3" },
            iup.label{title="|",fgcolor="155 155 155", font=targetless.var.font},
            iup.fill { size="3" },
            pvelabel,
            caplabel,
            iup.label{title="|",fgcolor="155 155 155", font=targetless.var.font},
            bomblabel,
            iup.label{title="|",fgcolor="155 155 155", font=targetless.var.font},
            alllabel,
            pveblabel,
            iup.fill { size="3" },
            iup.label{title="|",fgcolor="155 155 155", font=targetless.var.font},
            iup.fill { size="3" },
            orelabel,
        }
        --targetless.var.sectortotals = iupbox
        return iupbox
end

function targetless.Lists:getiuppinnedlist()
    local iuppinnedlist = iup.vbox{}
    for i,v in ipairs(targetless.PinnedList) do
        local iupbox
        local pinnedlabel
        local numlabel = iup.label {title = "" .. i, fgcolor="150 150 150", font = targetless.var.font, size=22, alignment="ACENTER" }
        if v["name"] == HUD.targetname.title then
            v.fontcolor = "255 255 255"
            numlabel.fgcolor = "255 255 255"
            numlabel.font = Font.H1
        end
        if(v["npc"] == "YES") then
            pinnedlabel = v:getiup(targetless.var.layout.npc)
        else
            pinnedlabel = v:getiup(targetless.var.layout.pc)
        end
        iupbox = iup.hbox
        {
            numlabel,
            pinnedlabel
        }
        v["label"] = iupbox
        iup.Append(iuppinnedlist, v["label"])
    end
    return iuppinnedlist
end

function targetless.Lists:getiupplayerlist()
    local iupplayerlist = iup.vbox{}
    for i,v in ipairs(targetless.PlayerList) do
        if(#targetless.PinnedList+i > targetless.var.listmax) then return iupplayerlist end
        local iupbox
        local playerlabel
        local numlabel = iup.label {title = "" .. #targetless.PinnedList+i, fgcolor="150 150 150", font = targetless.var.font, size=22, alignment="ACENTER" }
        if v["name"] == HUD.targetname.title then
            v.fontcolor = "255 255 255"
            numlabel.fgcolor = "255 255 255"
            numlabel.font = Font.H1
        end
        if(v["npc"] == "YES") then
            playerlabel = v:getiup(targetless.var.layout.npc)
        else
            playerlabel = v:getiup(targetless.var.layout.pc)
        end
        iupbox = iup.hbox
        {
            numlabel,
            playerlabel,
        }
        v["label"] = iupbox
        iup.Append(iupplayerlist, v["label"])
    end
    return iupplayerlist
end

function targetless.Lists:getiuproidlist()
    -- regenerate iups 
    local iuproidlist = iup.vbox{}
    for i,v in ipairs(targetless.RoidList) do
        if(#targetless.PinnedList+i > targetless.var.listmax) then return iuproidlist end
        local numlabel = iup.label {title = "" .. #targetless.PinnedList+i, size=22,alignment="ACENTER" }
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
        iup.Append(iuproidlist, v["label"])
    end
    return iuproidlist
end

-- Add ship with id to the appropriate list
function targetless.Lists:addship(id)
    local name = ""..GetPlayerName(id)
    local ship = GetPrimaryShipNameOfPlayer(id)
    if not (id and name and ship) then return end
    if(id == GetCharacterID()) then return end

    local npc = (string.sub(name, 1, string.len("*")) == "*") 
    if not npc then
        self.pvpcount = self.pvpcount + 1
    end

    local bomb = false
    if(string.sub(ship, 1, string.len("Ragnarok")) == "Ragnarok") then
        bomb = true
    end
    local cap = false
    if(string.sub(name, 1, string.len("*Hive Queen")) == "*Hive Queen") then
        cap = true
    elseif(ship == "Heavy Assault Cruiser") then cap = true
    elseif(ship == "TPG Teradon Frigate") then cap = true
    elseif(ship == "Trident Light Frigate") then cap = true
    elseif(ship == "TPG Constellation Heavy Transport") then cap = true
    end
    if cap then self.capcount = self.capcount + 1 end
    if bomb then self.bombcount = self.bombcount + 1 end
    self.allcount = self.allcount + 1
    local pinid = GetPrimaryShipIDOfPlayer(id) 
    if(self.pinned[pinid]==1 ) then
        targetless.PinnedList:add(id)
        self.pinnednew[pinid] = 1 
        return
    end


    if(self.mode == ("Ore" or "none")) then return
    elseif(self.mode == "PvP") then 
        if npc then return end
    elseif(self.mode == "Cap") then 
        if not cap then return end
    elseif(self.mode == "Bomb") then
        if not bomb then return end
    end



    targetless.PlayerList:add(id)
end

function targetless.Lists:targetprev()
    if targetless.var.targetnum <= 1 then
        if self.mode ~= ("Ore" or "none") then
            targetless.var.targetnum = #targetless.PinnedList+#targetless.PlayerList
        elseif self.mode == "Ore" then
            targetless.var.targetnum = #targetless.PinnedList+#targetless.RoidList
        end
        if targetless.var.targetnum >= targetless.var.listmax then
            targetless.var.targetnum = targetless.var.listmax
        end
    else targetless.var.targetnum = targetless.var.targetnum - 1 end

    if(#targetless.PinnedList >= targetless.var.targetnum) then
        local player = targetless.PinnedList[targetless.var.targetnum]
        if player then
            player:target()
        end
    else
        if self.mode ~= ("Ore" or "none") then
            local player = targetless.PlayerList[targetless.var.targetnum-#targetless.PinnedList]
            if player then
                player:target()
            end
        else
            local roid = targetless.RoidList[targetless.var.targetnum-#targetless.PinnedList]
            if roid then
                roid:target()
            end
        end
    end
end
function targetless.Lists:targetnext()
    if targetless.var.targetnum >= targetless.var.listmax or
       (self.mode == "Ore" and targetless.var.targetnum >= #targetless.PinnedList+#targetless.RoidList) or
       (self.mode ~= ("Ore" or "none") and targetless.var.targetnum >= #targetless.PinnedList+#targetless.PlayerList)
    then targetless.var.targetnum = 1
    else targetless.var.targetnum = targetless.var.targetnum + 1 end

    if(#targetless.PinnedList >= targetless.var.targetnum) then
        local player = targetless.PinnedList[targetless.var.targetnum]
        if player then
            player:target()
        end
    else
        if self.mode ~= ("Ore" or "none") then
            local player = targetless.PlayerList[targetless.var.targetnum-#targetless.PinnedList]
            if player then
                player:target()
            end
        elseif self.mode == "Ore" then
            local roid = targetless.RoidList[targetless.var.targetnum-#targetless.PinnedList]
            if roid then
                roid:target()
            end
        end
    end
end
function targetless.Lists:settarget(number)
    if(#targetless.PinnedList >= number) then
        if targetless.PinnedList[tonumber(number)] ~= nil then
            targetless.PinnedList[tonumber(number)]:target()
        end
    else
        if self.mode ~= ("Ore" or "none") then
            if targetless.PlayerList[tonumber(number)-#targetless.PinnedList] ~= nil then
                targetless.PlayerList[tonumber(number)-#targetless.PinnedList]:target()
            end
        else
            if targetless.RoidList[tonumber(number)-#targetless.PinnedList] ~= nil then
                targetless.RoidList[tonumber(number)-#targetless.PinnedList]:target()
            end
        end
    end
end

function targetless.Lists:refresh()
    if targetless.var.state == true then
        self:update()
        targetless.var.timer:SetTimeout(targetless.var.refreshDelay, function() self:refresh() end)
    end
end


function targetless.Lists:update()
    if HUD.hud_toggled_off then return end
    if targetless.var.updatelock == false then
        targetless.var.updatelock = true

        if(self.iup ~= nil) then
            iup.Detach(self.iup)
            iup.Destroy(self.iup)
            self.iup = nil
        end

        targetless.PinnedList:clear()
        targetless.PlayerList:clear()
        self.pvpcount = 0
        self.capcount = 0
        self.bombcount = 0
        self.allcount = 0
        self.pinned = self.pinnednew
        self.pinnednew = {}
        ForEachPlayer(function (id)
            self:addship(id)
        end)
        local iuptotals = self:getiuptotals()
        local iuppinned = self:getiuppinnedlist()
        local iuppinnedframe
        if(#targetless.PinnedList>0) then 
            iuppinnedframe = iup.hudrightframe{iuppinned}
        else
            iuppinnedframe = iup.vbox{}
        end
        local iuplist
        if self.mode == "Ore" then 
            iuplist = self:getiuproidlist()
        elseif self.mode == "none" then 
            iuplist = iup.vbox{}
        else
            iuplist = self:getiupplayerlist()
        end

        self.iup = iup.vbox{
            iup.vbox {
                --  targetless.var.iupself,
                iup.hudrightframe {
                    iuptotals,
                },
                iuppinnedframe,
                iup.hudrightframe {
                    iup.zbox{
                        iup.hbox{iup.fill{}},
                        iuplist,
                        all="YES",
                    },
                },
                gap="4",
            },
        }

        iup.Append(targetless.var.iuplists, self.iup)
        iup.Map(iup.GetDialog(self.iup))
        iup.Refresh(targetless.var.PlayerData)
        targetless.var.updatelock = false
    end
end

