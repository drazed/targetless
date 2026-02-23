-- this file only loads if touch enabled
declare("touchless",{})

local xres = gkinterface.GetXResolution()
local yres = gkinterface.GetYResolution()

local rcreate = gkinterface.CreateTouchRegion
local rdestroy = gkinterface.DestroyTouchRegion

touchless.region = nil

function touchless.destroy_touch_region()
    rdestroy(touchless.region)
    touchless.regions = nil
end

function touchless.create_touch_region()
    touchless.destroy_touch_region()

    -- this is the targetless touch region, more-or-less overlapping targets
    touchless.region = rcreate(nil, nil, nil, false, false, false, false, false, false, 0.75*xres, 0.20*yres, (xres - 1), (0.6*yres - 1))
end

local pressX = 0
local pressY = 0
function touchless:on_touch_pressed(id, screenX, screenY)
    if(id == touchless.region) then
        -- store the x/y values for compare on release
        pressX = screenX
        pressY = screenY
    end
end

function touchless:on_touch_released(id, screenX, screenY)
    if(id == touchless.region) then
        local diffX = screenX - pressX
        local diffY = screenY - pressY

        -- recent changes make touch release return the fraction of total touch area moved rather then actual pixels, since pixels are superior lets convert this fraction back to pixels and keep our original logic in tact :)
        -- we user 0.25 of the available xres and 0.4 of the available yres
        diffX = diffX*xres*0.25
        diffY = diffY*yres*0.40

        -- defualt pin/unip
        local command = "pin"
        if(math.abs(diffX) > math.abs(diffY)) then
            -- swip left/right
            -- check min 5 pixel
            if(diffX > 5) then
                command = "lsswitch"
            elseif(diffX < -5) then
                command = "lsback"
            end
        else
            -- swip up/down
            -- check min 5 pixel
            if(diffY > 5) then
                command = "nextLS"
            elseif(diffY < -5) then
                command = "prevLS"
            end
        end

        gkinterface.GKProcessCommand(command)
    end
end

function touchless:OnEvent(event, ...)
    if     (event == 'HUD_SHOW') then
        self:create_touch_region()

    elseif (event == 'HUD_HIDE') then
        self:destroy_touch_region()

    elseif (event == 'TOUCH_PRESSED') then
        self:on_touch_pressed(...)

    elseif (event == 'TOUCH_RELEASED') then
        self:on_touch_released(...)
    end
end

RegisterEvent(touchless, 'HUD_SHOW')
RegisterEvent(touchless, 'HUD_HIDE')
RegisterEvent(touchless, 'TOUCH_PRESSED')
RegisterEvent(touchless, 'TOUCH_RELEASED')
