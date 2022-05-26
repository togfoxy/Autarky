actionmove = {}

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
            fun.applyMovement(e, destx, desty, WALKING_SPEED, dt)       -- entity, x, y, speed, dt
        else
            fun.applyMovement(e, destx, desty, WALKING_SPEED / 2, dt)       -- entity, x, y, speed, dt
        end
    end
end

return actionmove
