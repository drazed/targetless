-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

targetls.func = {}

function targetls.func.lsswitch()
    if targetls.var.listpage == "target" then
--        targetls.var.listpage = "player"
--        targetls.PlayerList.shownpc = "OFF"
--    elseif targetls.var.listpage == "player" then
--        targetls.var.listpage = "npc"
--        targetls.PlayerList.showpc = "OFF"
--        targetls.PlayerList.shownpc = "ON"
--    elseif targetls.var.listpage == "npc" then
        targetls.var.listpage = "roid"
        targetls.PlayerList:clear()
        targetls.RoidList:updatesector(GetCurrentSectorid())
    else
        targetls.var.listpage = "target"
        targetls.RoidList:clear()
--        targetls.PlayerList.showpc = "ON"
--        targetls.PlayerList.shownpc = "ON"
    end
    targetls.func.update()
end

function targetls.func.settarget(number)
    if targetls.var.listpage == "target" then
        if targetls.PlayerList[tonumber(number)] ~= nil then
            targetls.PlayerList[tonumber(number)]:target()
        end
    else
        if targetls.RoidList[tonumber(number)] ~= nil then
            targetls.RoidList[tonumber(number)]:target()
        end
    end
end

function targetls.func.targetnext()
    if targetls.var.listpage == "target" then
        if targetls.var.targetnum >= #(targetls.PlayerList) or targetls.var.targetnum >= targetls.var.listmax then
            targetls.var.targetnum = 1 
        else targetls.var.targetnum = targetls.var.targetnum + 1 end
        local player = targetls.PlayerList[targetls.var.targetnum]
        if player then 
            player:target() 
        end
    else
        if targetls.var.targetnum >= #(targetls.RoidList) or targetls.var.targetnum >= targetls.var.listmax then
            targetls.var.targetnum = 1 
        else targetls.var.targetnum = targetls.var.targetnum + 1 end
        local roid = targetls.RoidList[targetls.var.targetnum]
        if roid then
            roid:target()
        end
    end
end

function targetls.func.targetprev()
    if targetls.var.listpage == "target" then
        if targetls.var.targetnum <= 1 then
            if #(targetls.PlayerList) <= targetls.var.listmax then
                targetls.var.targetnum = #(targetls.PlayerList)
            else
                targetls.var.targetnum = targetls.var.listmax 
            end
        else targetls.var.targetnum = targetls.var.targetnum - 1 end
        local player = targetls.PlayerList[targetls.var.targetnum]
        if player then 
            player:target()
        end
    else
        if targetls.var.targetnum <= 1 then
            if #(targetls.RoidList) <= targetls.var.listmax then
                targetls.var.targetnum = #(targetls.RoidList)
            else
                targetls.var.targetnum = targetls.var.listmax 
            end
        else targetls.var.targetnum = targetls.var.targetnum - 1 end
        local roid = targetls.RoidList[targetls.var.targetnum]
        if roid then
            roid:target()
        end
    end
end

function targetls.func.getfont(fontstr)
    if fontstr == "Font.H5" then
        return Font.H5
    elseif fontstr == "Font.H6" then
        return Font.H6
    else
        return Font.Tiny
    end
end

function targetls.func.refresh()
    if targetls.var.state == true then 
        targetls.func.update()
        targetls.var.timer:SetTimeout(targetls.var.refreshDelay, function() targetls.func.refresh() end)
    end
end

function targetls.func.update()
    if HUD.hud_toggled_off then return end
    if targetls.var.updatelock == false then
        targetls.var.updatelock = true

        if(targetls.var.sectortotals ~= nil) then
            iup.Detach(targetls.var.sectortotals)
            iup.Destroy(targetls.var.sectortotals)
            targetls.var.sectortotals = nil
        end

        targetls.PlayerList.all = 0
        ForEachPlayer(function (id)
            targetls.PlayerList.all = targetls.PlayerList.all + 1
        end)

        local targettitle = "Ships:"
        if targetls.var.listpage ~= "roid" then targetls.PlayerList:refresh()
        else targetls.RoidList:refresh() end

        local targettotallabel = iup.label { title=targettitle..targetls.PlayerList.all-2, fgcolor="155 155 155",  font=targetls.var.font }
        local roidtotallabel = iup.label { title="Scanned Roids: "..targetls.RoidList.roidcount, fgcolor="155 155 155", font=targetls.var.font }

        if targetls.var.listpage ~= "roid" then targettotallabel.fgcolor = "255 255 255"
        else roidtotallabel.fgcolor = "255 255 255" end
        local iupbox = iup.hbox
        {
            iup.fill {},
            targettotallabel,
            iup.fill { size="15" },
            roidtotallabel
        }
        targetls.var.sectortotals = iupbox
        iup.Append(targetls.var.iuptotals, targetls.var.sectortotals)
        iup.Map(iup.GetDialog(targetls.var.sectortotals))
        iup.Refresh(targetls.var.PlayerData)
        targetls.var.updatelock = false
    end
end
