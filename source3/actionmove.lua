actionmove = {}

local function applyMovement(e, targetx, targety, velocity, dt)
    -- assumes an entity has a position and a target.
    -- updates the x,y for the entity (e)

    -- print("Target is " .. targetx, targety)

    local distancemovedthisstep = velocity * dt * TIME_SCALE
    -- print(distancemovedthisstep, velocity, velocity * dt)
    --if e.isPerson.stamina < 1 then print("Hi") end

    -- map row/col to x/y
    local currentx = (e.position.x)
    local currenty = (e.position.y)

    -- capture the current position as the previous position
    e.position.previousx = currentx
    e.position.previousy = currenty
    e.position.movementDelta = e.position.movementDelta + dt    -- track time between animation frames
    if e.position.movementDelta > 2 then
        -- reset the animation timer back to zero
        e.position.movementDelta = 0
    end

    -- get the vector that moves the entity closer to the destination
    local xvector = targetx - currentx  -- tiles
    local yvector = targety - currenty  -- tiles

    -- print(distancemovedthisstep, currentx,currenty,targetx,targety,xvector,yvector)

    local xscale = math.abs(xvector / distancemovedthisstep)
    local yscale = math.abs(yvector / distancemovedthisstep)
    local scale = math.max(xscale, yscale)

    --print(cf.round(scale), cf.round(xscale),cf.round(yscale))

    if scale > 1 then
        xvector = xvector / scale
        yvector = yvector / scale
    end

    --print(xvector, yvector)

    -- currentx = cf.round(currentx + xvector, 0)
    -- currenty = cf.round(currenty + yvector, 0)
    currentx = (currentx + xvector)
    currenty = (currenty + yvector)

    e.position.x = currentx
    e.position.y = currenty

    e.position.row = cf.round((currenty + TOP_MARGIN) / TILE_SIZE)
    e.position.col = cf.round((currentx + LEFT_MARGIN) / TILE_SIZE)
    if e.position.row < 1 then e.position.row = 1 end
    if e.position.col < 1 then e.position.col = 1 end
    if e.position.row > NUMBER_OF_ROWS then e.position.row = NUMBER_OF_ROWS end
    if e.position.col > NUMBER_OF_COLS then e.position.col = NUMBER_OF_COLS end
end

function actionmove.move(e, currentaction, dt)
    local destx = currentaction.x
    local desty = currentaction.y
    if e.position.x == destx and e.position.y == desty then
        -- capture the current position as the previous position
        e.position.previousx = e.position.x
        e.position.previousy = e.position.y

        -- arrived at destination
        table.remove(e.isPerson.queue, 1)
        fun.addLog(e, currentaction.log)
    else
        -- move towards destination
        if e.isPerson.stamina > 0 then
            applyMovement(e, destx, desty, WALKING_SPEED, dt)       -- entity, x, y, speed, dt
        else
            applyMovement(e, destx, desty, WALKING_SPEED / 2, dt)       -- entity, x, y, speed, dt
        end
    end
end

return actionmove
