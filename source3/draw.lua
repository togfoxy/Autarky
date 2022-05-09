draw = {}

function draw.HUD()

    local count = 0
    local totalfullness, avgfullness = 0,0
    local totalwealth, avgwealth = 0,0
    local totalstamina, avgstamina = 0,0

    -- determine average stamina
    -- determine average fullness
    -- determine average wealth
    for k, v in pairs(VILLAGERS) do
        count = count + 1

        totalwealth = totalwealth + v.isPerson.wealth
        totalfullness = totalfullness + v.isPerson.fullness
        totalstamina = totalstamina + v.isPerson.stamina

    end
    if count > 0 then
        avgwealth = cf.round(totalwealth/count, 1)
        avgfullness = cf.round(totalfullness/count)
        avgstamina = cf.round(totalstamina/count)
    end

    -- determine average stocklevels
    local count = 0
    local totalstocklevel, avgstocklevel = 0, 0
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if MAP[row][col].entity.isTile.stockLevel > 0 then
                count = count + 1
                totalstocklevel = totalstocklevel + MAP[row][col].entity.isTile.stockLevel
            end
        end
    end
    if count > 0 then
        avgstocklevel = cf.round(totalstocklevel / count, 1)
    end



    local txt = ""
    txt = txt .. "Fullness: " .. avgfullness .. "\n"
    txt = txt .. "Wealth: " .. avgwealth .. "\n"
    txt = txt .. "Stamina: " .. avgstamina .. "\n"
    txt = txt .. "---" .. "\n"
    txt = txt .. "Stock: " .. avgstocklevel .. "\n"

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(txt, 30, 35)


end










return draw
