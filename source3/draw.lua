draw = {}

local function getTaxesOwed()
    local taxesowed
    for k, v in pairs(VILLAGERS) do
       taxesowed = taxesowed + v.taxesOwed
    end
    return taxesowed
end

local function drawGraph()

    local dotsize = 3       -- radius
    local topx = 200
    local topy = 50
    local graphheight = 75
    local bottomy = topy + graphheight
    local bottomx = topx
    local bluex = topx
    local bluey = bottomy - (graphheight / 2)

    local memorylength = 100    -- how many dots
    local graphlength = memorylength * dotsize

    love.graphics.setColor(1,1,1,1)
    love.graphics.line(topx,topy,bottomx,bottomy,bottomx + graphlength, bottomy)

    love.graphics.setColor(0,0,1,1)
    love.graphics.line(bluex, bluey, bluex + graphlength, bluey)

    local maxindex = math.min(memorylength, #STOCK_HISTORY[enum.stockFruit])
    for i = 1, maxindex do
        local drawx = topx + (i * dotsize)
        -- scale the graph by making the transaction a % of the max expected range
        local percent = STOCK_HISTORY[enum.stockFruit][i] / 2       -- this is assuming the blue bar is half way. See bluey up above.
        significance = percent * graphheight
        drawy = bottomy - significance

        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("fill", drawx, drawy, dotsize)
    end
end

local function addDrawItem(drawTable, label, value, red)
    local item = {}
    item.label = label
    item.value = value
    item.red = red      -- true/false value
    table.insert(drawTable, item)
end

local function drawInstructions()
    local count = 0
    local totalfullness, avgfullness = 0,0
    local totalwealth, avgwealth = 0,0
    local totalstamina, avgstamina = 0,0
    local HUDText = {}

    addDrawItem(HUDText, "Treasury: ", cf.round(VILLAGE_WEALTH))
    addDrawItem(HUDText, "GST: ", cf.round(GST_RATE, 2))
    addDrawItem(HUDText, "Taxes owed: ", cf.round(getTaxesOwed(), 2))
    addDrawItem(HUDText, "---", nil)
    addDrawItem(HUDText, "Population: ", #VILLAGERS)
    addDrawItem(HUDText, "#Farmers: ", fun.getJobCount(enum.jobFarmer))
    addDrawItem(HUDText, "#Lumberjacks: ", fun.getJobCount(enum.jobWoodsman))
    addDrawItem(HUDText, "#Healers: ", fun.getJobCount(enum.jobHealer))
    addDrawItem(HUDText, "#Builders: ", fun.getJobCount(enum.jobCarpenter))
    addDrawItem(HUDText, "#Tax collectors: ", fun.getJobCount(enum.jobTaxCollector))
    addDrawItem(HUDText, "#Welfare officers: ", fun.getJobCount(enum.jobWelfareOfficer))
    addDrawItem(HUDText, "#Unemployed: ", fun.getUnemployed())
    addDrawItem(HUDText, "---", nil)

    for k, v in pairs(VILLAGERS) do
        count = count + 1
        totalwealth = totalwealth + v.isPerson.wealth
        totalfullness = totalfullness + v.isPerson.fullness
        totalstamina = totalstamina + v.isPerson.stamina
    end
    if count > 0 then
        avgwealth = cf.round(totalwealth/count, 1)
        if avgwealth >= 2 then
            addDrawItem(HUDText, "Avg wealth: ", avgwealth)
        else
            addDrawItem(HUDText, "Avg wealth: ", avgwealth, true)
        end

        avgfullness = cf.round(totalfullness/count)
        if avgfullness >= 30 then
            addDrawItem(HUDText, "Avg fullness: ", avgfullness)
        else
            addDrawItem(HUDText, "Avg fullness: ", avgfullness, true)
        end

        avgstamina = cf.round(totalstamina/count)
        if avgstamina >= 30 then
            -- addDrawItem(HUDText, "Avg stamina: ", avgwealth)
        else
            addDrawItem(HUDText, "Avg stamina: ", avgstamina, true)
        end
    end

    -- determine average stocklevels for food
    local count = 0
    local totalstocklevel, avgstocklevel = 0, 0
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if MAP[row][col].entity.isTile.stockLevel > 0 and MAP[row][col].entity.isTile.stockType == enum.stockFruit then
                count = count + 1
                totalstocklevel = totalstocklevel + MAP[row][col].entity.isTile.stockLevel
            end
        end
    end
    if count > 0 then
        avgstocklevel = cf.round(totalstocklevel / #VILLAGERS, 1)
        if avgstocklevel >= 1 then
            addDrawItem(HUDText, "Avg food: ", avgstocklevel)
        else
            addDrawItem(HUDText, "Avg food: ", avgstocklevel, true)
        end
    end

    -- determine average stocklevels for wood
    local count = 0
    local totalstocklevel, avgstocklevel = 0, 0
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if MAP[row][col].entity.isTile.stockLevel > 0 and MAP[row][col].entity.isTile.stockType == enum.stockWood then
                count = count + 1
                totalstocklevel = totalstocklevel + MAP[row][col].entity.isTile.stockLevel
            end
        end
    end
    if count > 0 then
        avgstocklevel = cf.round(totalstocklevel / count, 1)
        if avgstocklevel >= 1 then
            addDrawItem(HUDText, "Avg wood: ", avgstocklevel)
        else
            addDrawItem(HUDText, "Avg wood: ", avgstocklevel, red)
        end
    end

    addDrawItem(HUDText, "---", nil)
    addDrawItem(HUDText, "Key commands:", nil)
    addDrawItem(HUDText, "(select red person first)", nil)
    if VILLAGERS_SELECTED > 0 then
        addDrawItem(HUDText, "\n", nil)
        addDrawItem(HUDText, "f = farmer", nil)
        addDrawItem(HUDText, "l = lumberjack", nil)
        addDrawItem(HUDText, "b = builder", nil)
        addDrawItem(HUDText, "h = healer", nil)
        addDrawItem(HUDText, "t = tax collector", nil)
        addDrawItem(HUDText, "w = welfare officer", nil)
    end

    addDrawItem(HUDText, "Change GST = < and >", nil)

    addDrawItem(HUDText, "---", nil)
    addDrawItem(HUDText, "Camera:", nil)
    addDrawItem(HUDText, "mouse wheel = zoom", nil)
    addDrawItem(HUDText, "middle mouse button = pan", nil)
    addDrawItem(HUDText, "arrow keys = pan", nil)
    addDrawItem(HUDText, "keypad 5 = reset camera", nil)
    addDrawItem(HUDText, "---", nil)

    if MUSIC_TOGGLE then
        addDrawItem(HUDText, "'M'usic is on'", nil)
    else
        addDrawItem(HUDText, "'M'usic is off", nil)
    end

    if SOUND_TOGGLE then
        addDrawItem(HUDText, "'E'fects are on", nil)
    else
        addDrawItem(HUDText, "'E'fects are off", nil)
    end

    addDrawItem(HUDText, "---", nil)
    addDrawItem(HUDText, "'c'ontinue game (load)'", nil)
    addDrawItem(HUDText, "'s'ave game'", nil)

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

end

local function drawGameLog()

    local drawx = GAME_LOG_DRAWX
    if #GAME_LOG > 20 then
        j = #GAME_LOG - 20
    else
        j = 1
    end
    local drawy = 30
    for i = j, #GAME_LOG do
        love.graphics.print(GAME_LOG[i], drawx, drawy)
        drawy = drawy + 20
    end

end

function draw.HUD()

    if DISPLAY_GRAPH then
        drawGraph()
    end

    if DISPLAY_INSTRUCTIONS or VILLAGERS_SELECTED >= 1 then
        drawInstructions()
    end

    if DISPLAY_GAME_LOG then
        drawGameLog()
    end
end

function draw.Animations()
    for k, imgitem in pairs(DRAWQUEUE) do
        if imgitem.start <= 0 and imgitem.stop > 0 then
            -- draw item
            love.graphics.draw(IMAGES[imgitem.imagenumber], imgitem.x, imgitem.y)
        end
    end
end


return draw
