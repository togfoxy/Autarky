actionidle = {}

function actionidle.idle(e, currentaction, dt)

    currentaction.timeleft = currentaction.timeleft - dt

    -- capture the current position as the previous position
    e.position.previousx = e.position.x
    e.position.previousy = e.position.y
    e.position.movementDelta = 0

    if currentaction.timeleft > 3 and love.math.random(1, 20000) == 1 then
        -- play audio
        fun.playAudio(enum.audioYawn, false, true)
    end

    -- e.isPerson.stamina = e.isPerson.stamina + (STAMINA_RECOVERY_RATE * TIME_SCALE * dt)        -- gain 1 per second + recover the 0.5 applied above
    -- if e.isPerson.stamina > 300 then e.isPerson.stamina = 300 end

    if currentaction.timeleft <= 0 then
        table.remove(e.isPerson.queue, 1)
        fun.addLog(e, currentaction.log)
    end


end








return actionidle
