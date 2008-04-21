-- Vendetta Online TargetList Plugin
-- 
-- Author: Adrian (drazed) Zakrzewski
-- contact: drazed@gmail.com

targetless.func = {}

function targetless.func.settarget(number)
    if(#targetless.PinnedList >= number) then
        if targetless.PinnedList[tonumber(number)] ~= nil then
            targetless.PinnedList[tonumber(number)]:target()
        end
    else
        if targetless.Lists.mode ~= ("Ore" or "none") then
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

function targetless.func.targetnext()
    if targetless.Lists.mode ~= ("Ore" or "none") then
        if targetless.var.targetnum >= #(targetless.PlayerList) or targetless.var.targetnum >= targetless.var.listmax then
            targetless.var.targetnum = 1 
        else targetless.var.targetnum = targetless.var.targetnum + 1 end
        local player = targetless.PlayerList[targetless.var.targetnum]
        if player then 
            player:target() 
        end
    else
        if targetless.var.targetnum >= #(targetless.RoidList) or targetless.var.targetnum >= targetless.var.listmax then
            targetless.var.targetnum = 1 
        else targetless.var.targetnum = targetless.var.targetnum + 1 end
        local roid = targetless.RoidList[targetless.var.targetnum]
        if roid then
            roid:target()
        end
    end
end

function targetless.func.targetprev()
    if targetless.Lists.mode ~= ("Ore" or "none") then
        if targetless.var.targetnum <= 1 then
            if #(targetless.PlayerList) <= targetless.var.listmax then
                targetless.var.targetnum = #(targetless.PlayerList)
            else
                targetless.var.targetnum = targetless.var.listmax 
            end
        else targetless.var.targetnum = targetless.var.targetnum - 1 end
        local player = targetless.PlayerList[targetless.var.targetnum]
        if player then 
            player:target()
        end
    else
        if targetless.var.targetnum <= 1 then
            if #(targetless.RoidList) <= targetless.var.listmax then
                targetless.var.targetnum = #(targetless.RoidList)
            else
                targetless.var.targetnum = targetless.var.listmax 
            end
        else targetless.var.targetnum = targetless.var.targetnum - 1 end
        local roid = targetless.RoidList[targetless.var.targetnum]
        if roid then
            roid:target()
        end
    end
end

function targetless.func.getfont(fontstr)
    if fontstr == "Font.H5" then
        return Font.H5
    elseif fontstr == "Font.H6" then
        return Font.H6
    else
        return Font.Tiny
    end
end

function targetless.func.refresh()
    if targetless.var.state == true then 
        --targetless.func.update()
        targetless.Lists:update()
        targetless.var.timer:SetTimeout(targetless.var.refreshDelay, function() targetless.func.refresh() end)
    end
end

