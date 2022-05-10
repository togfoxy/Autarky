draw = {}

function draw.HUD()

    local count = 0
    local totalfullness, avgfullness = 0,0
    local totalwealth, avgwealth = 0,0
    local totalstamina, avgstamina = 0,0
    local HUDText = {}

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
        txt = {}
        txt.label = "Wealth: "
        txt.value = avgwealth
        if avgwealth <= 2 then txt.red = true else txt.red = false end
        table.insert(HUDText, txt)

        avgfullness = cf.round(totalfullness/count)
        txt = {}
        txt.label = "Fullness: "
        txt.value = avgfullness
        if avgfullness <= 30 then txt.red = true else txt.red = false end
        table.insert(HUDText, txt)

        avgstamina = cf.round(totalstamina/count)
        txt = {}
        txt.label = "Stamina: "
        txt.value = avgstamina
        if avgstamina <= 30 then txt.red = true else txt.red = false end
        table.insert(HUDText, txt)
    end

    txt = {}
    txt.label = "---"
    txt.value = nil
    table.insert(HUDText, txt)

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
        txt = {}
        txt.label = "Stock: "
        txt.value = avgstocklevel
        if avgstocklevel < 1 then txt.red = true else txt.red = false end
        table.insert(HUDText, txt)
    end

    -- print to screen
    local yvalue = 35
    for _, str in ipairs(HUDText) do
        if str.value ~= nil then
            if str.red then
                love.graphics.setColor(1,0,0,1)
            else
                love.graphics.setColor(1,1,1,1)
            end
            love.graphics.print(str.label .. str.value, 30, yvalue)
        else
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(str.label, 30, yvalue)
        end
        yvalue = yvalue + 20
    end



    -- local txt = ""
    -- txt = txt .. "Fullness: " .. avgfullness .. "\n"
    -- txt = txt .. "Wealth: " .. avgwealth .. "\n"
    -- txt = txt .. "Stamina: " .. avgstamina .. "\n"
    -- txt = txt .. "---" .. "\n"
    -- txt = txt .. "Stock: " .. avgstocklevel .. "\n"
    --
    -- love.graphics.setColor(1,1,1,1)
    -- love.graphics.print(txt, 30, 35)


end










return draw
