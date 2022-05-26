actionrest = {}

function actionrest.rest(e, currentaction, dt)

    currentaction.timeleft = currentaction.timeleft - dt

    -- capture the current position as the previous position
    e.position.previousx = e.position.x
    e.position.previousy = e.position.y
    e.position.movementDelta = 0

    if currentaction.timeleft > 3 and love.math.random(1, 20000) == 1 then
        -- play audio
        fun.playAudio(enum.audioYawn, false, true)
    end

    if currentaction.action == "rest" and e:has("residence") and e.residence.health >= 80 then  --! make the 80 value a constant
        if currentaction.timeleft > 5 then
            -- draw sleep bubble
            local item = {}
            item.imagenumber = enum.imagesEmoteSleeping
            item.start = 0
            item.stop = math.min(5, currentaction.timeleft)
            item.x, item.y = fun.getXYfromRowCol(agentrow, agentcol)
            table.insert(DRAWQUEUE, item)
        end
        -- recover stamina faster
        e.isPerson.stamina = e.isPerson.stamina + (1.5 * STAMINA_RECOVERY_RATE * TIME_SCALE * dt)      --! make constants
    else
        e.isPerson.stamina = e.isPerson.stamina + (STAMINA_RECOVERY_RATE * TIME_SCALE * dt)        -- gain 1 per second + recover the 0.5 applied above
    end
    if currentaction.timeleft <= 0 then
        table.remove(e.isPerson.queue, 1)
        fun.addLog(e, currentaction.log)
    end

end



return actionrest
