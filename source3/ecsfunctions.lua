ecsfunctions = {}

function ecsfunctions.init()

    -- create the world
    WORLD = concord.world()

    local compmodule = require 'comp'

    -- define components
    compmodule.init()

    -- declare systems
    systemDraw = concord.system({
        pool = {"position", "drawable"}
    })
    -- define same systems
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        for _, e in ipairs(self.pool) do
            if e.isTile then

                local row, col = e.position.row, e.position.col
                -- draw tile image
                local img
                local imgnumber

                -- NOTE: This is NOT the improvement
                local img = IMAGES[e.isTile.tileType]
                local drawx, drawy = LEFT_MARGIN + e.position.x, TOP_MARGIN + e.position.y
                local imagewidth = img:getWidth()
                local imageheight = img:getHeight()
                local drawscalex = (TILE_SIZE / imagewidth)
                local drawscaley = (TILE_SIZE / imageheight)
                local offsetx = imagewidth / 2
                local offsety = imageheight / 2

				love.graphics.setColor(1,1,1,1)
                love.graphics.draw(img, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)

                -- draw the mud
                local mudalpha = cf.round((e.isTile.mudLevel / 255),3)
                love.graphics.setColor(1,1,1,mudalpha)
                love.graphics.draw(IMAGES[enum.imagesMud], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)

                -- draw contour lines

                -- check if top neighbour is different to current cell
                if row > 1 then
                    if MAP[row-1][col].height ~= MAP[row][col].height then
                        -- draw line
                        local x1, y1 = fun.getXYfromRowCol(row, col)
                        local x2, y2 = x1 + TILE_SIZE, y1
                        local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
                        x1 = x1 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y1 = y1 - (TILE_SIZE / 2) + TOP_MARGIN
                        x2 = x2 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y2 = y2 - (TILE_SIZE / 2) + TOP_MARGIN
                        -- love.graphics.setColor(1,1,1,alpha)
                        -- love.graphics.line(x1, y1, x2, y2)
                    end
                end
                -- left side
                if col > 1 then
                    if MAP[row][col-1].height ~= MAP[row][col].height then
                        -- draw line
                        local x1, y1 = fun.getXYfromRowCol(row, col)
                        local x2 = x1
                        local y2 = y1 + TILE_SIZE
                        local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
                        x1 = x1 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y1 = y1 - (TILE_SIZE / 2) + TOP_MARGIN
                        x2 = x2 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y2 = y2 - (TILE_SIZE / 2) + TOP_MARGIN
                        -- love.graphics.setColor(1,1,1,alpha)
                        -- love.graphics.line(x1, y1, x2, y2)
                    end
                end

                local imptype
                if MAP[row][col].entity.isTile.improvementType ~= nil then imptype = e.isTile.improvementType end

                -- draw the improvement
                local sprite, quad
                if imptype ~= nil then
                    local imagenumber = imptype
                    local imagewidth, imageheight

                    -- draw house or house frame depending on house health
                    if imptype == enum.improvementHouse and MAP[row][col].entity.isTile.tileOwner.residence.health < 80 then
                        imagenumber = enum.imagesHouseFrame

                        -- take this opportunity to draw the health bar
                        local x1, y1, x2, y2
                        x1 = drawx + (TILE_SIZE / 2)
                        y1 = drawy + (TILE_SIZE / 2)
                        x2 = x1
                        y2 = y1 - (MAP[row][col].entity.isTile.tileOwner.residence.health / 100) * TILE_SIZE
                        love.graphics.setColor(0,1,0,1)
                        love.graphics.line(x1,y1,x2,y2)


                    elseif imptype == enum.improvementHouse and MAP[row][col].entity.isTile.tileOwner.residence.health >= 80 then
                        imagenumber = enum.imagesHouse
                    end
                    if imptype == enum.improvementFarm then
                        -- determine which image from spritesheet
                        imagenum = cf.round(e.isTile.stockLevel * 4) + 1
                        if imagenum > 5 then imagenum = 5 end
                        sprite = SPRITES[enum.spriteAppleTree]
                        quad = QUADS[enum.spriteAppleTree][imagenum]
                        imagewidth, imageheight = 37,50     --! need to not hardcode this
                    end
                    if imptype == enum.improvementWoodsman then
                        -- determine which image from spritesheet
                        imagenum = math.floor(e.isTile.stockLevel) + 1
                        if imagenum > 6 then imagenum = 6 end
                        sprite = SPRITES[enum.spriteWoodPile]
                        quad = QUADS[enum.spriteWoodPile][imagenum]
                        imagewidth, imageheight = 50,50     --! need to not hardcode this
                    end

                    if imagewidth == nil then
                        imagewidth = IMAGES[imagenumber]:getWidth()
                        imageheight = IMAGES[imagenumber]:getHeight()
                    end

                    local drawscalex = (TILE_SIZE / imagewidth)
                    local drawscaley = (TILE_SIZE / imageheight)

                    local offsetx = imagewidth / 2
                    local offsety = imageheight / 2

                    love.graphics.setColor(1,1,1,1)

                    if imptype == enum.improvementFarm or imptype == enum.improvementWoodsman then
                        love.graphics.draw(sprite, quad, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                    else
                        love.graphics.draw(IMAGES[imagenumber], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                    end
                    -- draw the health of the improvement as a bar
                end

                -- draw stocklevels for each tile
                if MAP[row][col].entity.isTile.stockLevel > 0 then
                    love.graphics.setColor(0/255,0/255,115/255,1)
                    love.graphics.print(cf.round(MAP[row][col].entity.isTile.stockLevel,1), drawx, drawy, 0, 1, 1, 20, -10)
                end

                -- debugging
                -- draw mud levels for each tile
                -- if MAP[row][col].entity.isTile.mudLevel > 0 then
                --     love.graphics.setColor(1,1,1,1)
                --     love.graphics.print(cf.round(MAP[row][col].entity.isTile.mudLevel,4), drawx, drawy, 0, 1, 1, 20, 20)
                -- end
            end

            if e.isPerson then
                if e.isSelected then
                    love.graphics.setColor(0,1,0,1)
                else
                    love.graphics.setColor(1,1,1,1)
                end

                local drawwidth = PERSON_DRAW_WIDTH
                local drawx, drawy = LEFT_MARGIN + e.position.x, TOP_MARGIN + e.position.y

                -- draw occupation icon
                if e:has("occupation") then
                    local imgnumber = e.occupation.value + 30       -- there is an offset to avoid clashes. See enum.lua
                    love.graphics.draw(IMAGES[imgnumber], drawx, drawy, 0, 0.25, 0.25, 0, 130)
                end

                -- draw if sleeping
                local imgrotation = 0
                if e.isPerson.queue[1] ~= nil then
                    if e.isPerson.queue[1].action == "rest" then
                        imgrotation = math.rad(90)
                    end
                end

                -- draw the villager
                local facing = fun.determineFacing(e)      -- gets the cardinal facing of the entity. Is a string
                local imagenum = fun.getImageNumberFromFacing(facing)
                local imagenumoffset = cf.round(e.position.movementDelta / 0.5)
                imagenum = imagenum + imagenumoffset


                local sprite, quad
                if e.isPerson.gender == enum.genderMale and e:has("occupation") then
                    if e.occupation.value == enum.jobFarmer then
                        sprite = SPRITES[enum.spriteFarmerMan]
                        quad = QUADS[enum.spriteFarmerMan][imagenum]
                    else
                        sprite = SPRITES[enum.spriteBlueMan]
                        quad = QUADS[enum.spriteBlueMan][imagenum]
                    end
                end
                if e.isPerson.gender == enum.genderFemale and e:has("occupation") then
                    sprite = SPRITES[enum.spriteBlueWoman]
                    quad = QUADS[enum.spriteBlueWoman][imagenum]
                end
                if e.isPerson.gender == enum.genderMale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedMan]
                    quad = QUADS[enum.spriteRedMan][imagenum]
                end
                if e.isPerson.gender == enum.genderFemale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedWoman]
                    quad = QUADS[enum.spriteRedWoman][imagenum]
                end
                love.graphics.draw(sprite, quad, drawx, drawy, imgrotation, 1, 1, 10, 25)

                -- display the log
                local maxindex = #e.isPerson.log
                if e:has("isSelected") and VILLAGERS_SELECTED == 1 then
                    img = IMAGES[enum.imagesVillagerLog]
                    local imageheight = img:getHeight()
                    local drawboxy = SCREEN_HEIGHT - imageheight - 100

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.draw(img, 50, drawboxy)
                    local texty = drawboxy + 7

                    for i = maxindex, maxindex - 4, -1 do
                        if i < 1 then break end
                        love.graphics.setColor(47/255,11/255,50/255,1)
                        love.graphics.print(e.isPerson.log[i].text, 57, texty)
                        texty = texty + 12
                    end
                end

                local txt = ""
                if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
                    -- display some debugging information
                    if e.isPerson.queue[1] ~= nil then
                        txt = "action: " .. e.isPerson.queue[1].action .. "\n"
                        if e.isPerson.queue[1].timeleft ~= nil then
                            txt = txt .. "timer: " .. cf.round(e.isPerson.queue[1].timeleft) .. "\n"
                        end
                    end
                    txt = txt .. "health: " .. cf.round(e.isPerson.health) .. "\n"
                    txt = txt .. "stamina: " .. cf.round(e.isPerson.stamina) .. "\n"
                    txt = txt .. "fullness: " .. cf.round(e.isPerson.fullness) .. "\n"
                    txt = txt .. "wealth: " .. cf.round(e.isPerson.wealth,1) .. "\n"
                    txt = txt .. "wood: " .. cf.round(e.isPerson.stockInv[enum.stockWood]) .. "\n"
                    txt = txt .. "tax owed: " .. cf.round(e.isPerson.taxesOwed, 1) .. "\n"

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 60)
                else
                    if e.isPerson.health < 25 then
                        txt = txt .. "health: " .. cf.round(e.isPerson.health) .. "\n"
                    end
                    if e.isPerson.stamina < 25 then
                        txt = txt .. "stamina: " .. cf.round(e.isPerson.stamina) .. "\n"
                    end
                    if e.isPerson.fullness < 25 then
                        txt = txt .. "fullness: " .. cf.round(e.isPerson.fullness) .. "\n"
                    end
                    if e.isPerson.wealth < 1 then
                        txt = txt .. "wealth: " .. cf.round(e.isPerson.wealth,1) .. "\n"
                    end
                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 25)
                end
            end
        end
    end

    systemIsPerson = concord.system({
        pool = {"isPerson"}
    })
    function systemIsPerson:update(dt)
        for _, e in ipairs(self.pool) do
            -- check if queue is empty and if so then get a new action from the behavior tree

            local agentrow = e.position.row
            local agentcol = e.position.col
            -- determine new action for queue (or none)
            if #e.isPerson.queue == 0 then
                local goal
                if e.isPerson.fullness < 30 then
                    -- force agent to eat
                    goal = enum.goalEat
                elseif e.isPerson.health < 30 then
                    goal = enum.goalHeal
                else
                    goal = ft.DetermineAction(TREE, e)
                    -- if e:has("occupation") then print("Occupation: " .. e.occupation.value) end
                    -- if goal ~= nil then print("Goal is number " .. goal) end
                end
                local actionlist = {}
                local actionlist = fun.createActions(goal, e)  -- turns a simple decision from the tree into a complex sequence of actions and adds to queue
            end

            -- add 'idle' action if queue is still empty
            if #e.isPerson.queue < 1 then
                -- add an 'idle' action
                action = {}
                action.action = "idle"      -- idle is same as rest but idle means "nothing else to do" but rest was chosen from btree
                action.timeleft = love.math.random(10, 20)
                table.insert(e.isPerson.queue, action)

                -- add a talking bubble
                local item = {}
                item.imagenumber = enum.imagesEmoteTalking
                item.start = love.math.random(0, 7)
                item.stop = love.math.random(item.start, action.timeleft)
                item.x, item.y = fun.getXYfromRowCol(agentrow, agentcol)
                table.insert(DRAWQUEUE, item)
            end

            -- process head of queue
            local currentaction = {}
            currentaction = e.isPerson.queue[1]      -- a table

            -- ** debugging ** --
            -- if currentaction.action ~= "idle" and currentaction.action ~= "move" and currentaction.action ~= "work" then
            -- if currentaction.action ~= "idle" and currentaction.action ~= "move" then
            --     -- print("Current action: " .. currentaction.action)
            --     local agentrow = e.position.row
            --     local agentcol = e.position.col
            --     -- print(MAP[agentrow][agentcol].entity.isTile.improvementType)
            -- end

            if currentaction.action == "idle" or currentaction.action == "rest" then
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
                    e.isPerson.stamina = e.isPerson.stamina + (2 * dt)
                else
                    e.isPerson.stamina = e.isPerson.stamina + (1.5 * dt)        -- gain 1 per second + recover the 0.5 applied above
                end
                if currentaction.timeleft <= 0 then
                    table.remove(e.isPerson.queue, 1)
                    fun.addLog(e, "Rested")
                end
            end

            if currentaction.action == "move" then
                local destx = currentaction.x
                local desty = currentaction.y
                if e.position.x == destx and e.position.y == desty then
                    -- capture the current position as the previous position
                    e.position.previousx = e.position.x
                    e.position.previousy = e.position.y

                    -- arrived at destination
                    table.remove(e.isPerson.queue, 1)
                    fun.addLog(e, "Moved")
                else
                    -- move towards destination
                    if e.isPerson.stamina > 0 then
                        fun.applyMovement(e, destx, desty, WALKING_SPEED, dt)       -- entity, x, y, speed, dt
                    else
                        fun.applyMovement(e, destx, desty, WALKING_SPEED / 2, dt)       -- entity, x, y, speed, dt
                    end
                end
            end

            if currentaction.action == "work" then
                currentaction.timeleft = currentaction.timeleft - dt

                -- play audio
                if currentaction.timeleft > 3 and love.math.random(1, 5000) == 1 then
                    -- play audio
                    if e.occupation.value == enum.jobFarmer then
                        fun.playAudio(enum.audioRustle, false, true)
                    end
                    if e.occupation.value == enum.jobWoodsman then
                        fun.playAudio(enum.audioSawWood, false, true)
                    end
                end

                -- see if they hurt themselves at work
                if love.math.random(1, INJURY_RATE) == 1 then
                    local dmg = cf.round(love.math.random(1,10) * dt, 4)
                    e.isPerson.health = e.isPerson.health - dmg
                end

                -- update log
                if currentaction.timeleft <= 0 then
                    table.remove(e.isPerson.queue, 1)
                    fun.addLog(e, "Worked")
                end

                -- print("+++")
                -- print(e.occupation.value)
                -- print(e.occupation.stockType)
                -- print("+++")

                -- reap benefits of work

                if e.occupation.stockType ~= nil and e.occupation.value ~= enum.jobCarpenter then
                    -- accumulate stock
                    local row = e.position.row
                    local col = e.position.col
                    if MAP[row][col].stockLevel == nil then MAP[row][col].stockLevel = 0 end

                    local stockgained
                    if e.occupation.stockType == enum.stockFruit then
                        stockgained = (FRUIT_PRODUCTION_RATE * dt)
                    elseif e.occupation.stockType == enum.stockWood then
                        stockgained = (WOOD_PRODUCTION_RATE * dt)
                    elseif e.occupation.stockType == enum.stockHealingHerbs then
                        stockgained = (HERB_PRODUCTION_RATE * dt)
                    end
                    assert(stockgained ~= nil)

                    if e.isPerson.stamina <= 0 then
                        stockgained = stockgained / 2   -- less productive when tired
                    end

                    stockgained = cf.round(stockgained, 4)
                    MAP[row][col].entity.isTile.stockLevel = MAP[row][col].entity.isTile.stockLevel + stockgained
                end

                if e.occupation.value == enum.jobCarpenter then
                    local row = e.position.row
                    local col = e.position.col
                    local owner = MAP[row][col].entity.isTile.tileOwner
                    owner.residence.health = owner.residence.health + (dt * CARPENTER_BUILD_RATE * HEALTH_GAIN_FROM_WOOD)
                    print("House health is now " .. owner.residence.health)
                    local wage = (dt * CARPENTER_WAGE)
                    e.isPerson.wealth = e.isPerson.wealth + wage          -- e = the carpenter
                    owner.isPerson.wealth = owner.isPerson.wealth - wage          -- is okay if goes negative
                end

                if e.occupation.value == enum.jobTaxCollector then
                    -- tax all the villagers on this tile
                    local row = e.position.row
                    local col = e.position.col

                    for k, villager in pairs(VILLAGERS) do
                        if villager.position.row == row and villager.position.col == col and villager.isPerson.taxesOwed >= 1 then
                           local taxamount = cf.round(villager.isPerson.taxesOwed)
                           local collectorwage = cf.round(taxamount * TAXCOLLECTOR_WAGE,4)
                           local villageincome = cf.round(taxamount - collectorwage,4)

                           villager.isPerson.taxesOwed = villager.isPerson.taxesOwed - taxamount
                           VILLAGE_WEALTH = VILLAGE_WEALTH + villageincome
                           e.isPerson.wealth = e.isPerson.wealth + collectorwage
                        end
                    end
                end
            end

            if currentaction.action == "buy" then
                local agentrow = e.position.row
                local agentcol = e.position.col
                print("Buying stock type " .. currentaction.stockType)

                local amtbought = fun.buyStock(e, currentaction.stockType, currentaction.purchaseAmount)
                print("Bought " .. amtbought .. " of stock type " .. currentaction.stockType)
                if currentaction.stockType == enum.stockFruit then
                    e.isPerson.fullness = e.isPerson.fullness + (amtbought * 100)   -- each food restores 100 fullness
                    if amtbought > 0 and love.math.random(1, 1000) == 1 then
                        fun.playAudio(enum.audioEat, false, true)
                    end
                elseif currentaction.stockType == enum.stockHealingHerbs then
                    e.isPerson.health = e.isPerson.health + (amtbought * 10)
                    if amtbought > 0 and love.math.random(1, 1000) == 1 then
                        fun.playAudio(enum.audioBandage, false, true)
                    end
                else
                    e.isPerson.stockInv[currentaction.stockType] = e.isPerson.stockInv[currentaction.stockType] + amtbought
                end

                if amtbought > 0 then
                    -- add a money bubble
                    local item = {}
                    item.imagenumber = enum.imagesEmoteCash
                    item.start = 0
                    item.stop = 3
                    item.x, item.y = fun.getXYfromRowCol(agentrow, agentcol)
                    table.insert(DRAWQUEUE, item)
                end

                table.remove(e.isPerson.queue, 1)
                fun.addLog(e, "Bought something")
            end

            if currentaction.action == "stockhouse" then
                -- transfer wood from agent to house
                local woodamt = e.isPerson.stockInv[enum.stockWood]
                e.isPerson.stockInv[enum.stockWood] = 0

                local houserow = e.residence.row
                local housecol = e.residence.col
                MAP[houserow][housecol].entity.isTile.stockLevel = MAP[houserow][housecol].entity.isTile.stockLevel + woodamt
                table.remove(e.isPerson.queue, 1)
                fun.addLog(e, "Stocked house")
            end

            -- ******************* --
            -- do things that don't depend on an action
            -- ******************* --
            local row = e.position.row
            local col = e.position.col

            -- add mud
            if MAP[row][col].entity.isTile.improvementType == nil then
                MAP[row][col].entity.isTile.mudLevel = MAP[row][col].entity.isTile.mudLevel + (dt * 1.5)
            end
            if MAP[row][col].entity.isTile.mudLevel > 255 then MAP[row][col].entity.isTile.mudLevel = 255 end

            -- reduce stamina
            e.isPerson.stamina = e.isPerson.stamina - (0.5 * dt)
            if e.isPerson.stamina < 0 then e.isPerson.stamina = 0 end

            -- reduce fullness
            e.isPerson.fullness = e.isPerson.fullness - (0.33 * dt)

            -- apply wear to house if they have one
            if e:has("residence") then
                e.residence.health = e.residence.health - (dt * HOUSE_WEAR)
                if e.residence.health < 0 then e.residence.health = 0 end
            end

            -- do this last as it may nullify the entity
            if e.isPerson.fullness < 0 or e.isPerson.health <= 0 then
                -- destroy any improvement belonging to starving agent
                if e:has("workplace") then
                    -- destroy workplace
                    local wprow = e.workplace.row
                    local wpcol = e.workplace.col
                    MAP[wprow][wpcol].entity.isTile.improvementType = nil
                    MAP[wprow][wpcol].entity.isTile.stockType = nil
                    MAP[wprow][wpcol].entity.isTile.tileOwner = nil
                    MAP[wprow][wpcol].entity.isTile.stockLevel = 0
                end
                if e:has("residence") then
                    -- destroy house
                    local wprow = e.residence.row
                    local wpcol = e.residence.col
                    MAP[wprow][wpcol].entity.isTile.improvementType = nil
                    MAP[wprow][wpcol].entity.isTile.stockType = nil
                    MAP[wprow][wpcol].entity.isTile.tileOwner = nil
                    MAP[wprow][wpcol].entity.isTile.stockLevel = 0
                end

                fun.killAgent(e.uid.value)  -- removes the agent from the VILLAGERS table
                e:destroy()                 -- destroys the entity from the world
                --! add a graveyard somewhere
            end
        end
    end

    systemIsTile = concord.system({
        pool = {"isTile"}
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col].entity = entity
        end
    end

    systemIsTileUpdate = concord.system({
        pool = {"isTile"}
    })
    function systemIsTileUpdate:update(dt)
        for _, e in ipairs(self.pool) do

            -- decrease mud so that grass grows
            e.isTile.mudLevel = cf.round(e.isTile.mudLevel - (dt / 3), 4)
            if e.isTile.mudLevel < 0 then e.isTile.mudLevel = 0 end
        end
    end

    -- add the systems to the world
    -- ## ensure all systems are added to the world
    WORLD:addSystems(systemDraw, systemIsTile, systemIsTileUpdate, systemIsPerson)

    -- create entities

    -- capture the tile that has the well firs of all
	WELLS = {}
	WELLS[1] = {}
	WELLS[1].row = love.math.random(3, NUMBER_OF_ROWS - 4)  -- The 3 and -2 keeps the well off the screen edge
	WELLS[1].col = love.math.random(3, NUMBER_OF_COLS - 2)

    -- debugging
    -- WELLS[1].row = 4
	-- WELLS[1].col = 4


    -- create tiles
    local terrainheightperlinseed
    local terraintypeperlinseed = love.math.random(0,20) / 20
    repeat
        terrainheightperlinseed = love.math.random(0,20) / 20
    until terrainheightperlinseed ~= terraintypeperlinseed

    -- create tile entities
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            local rowvalue = row / NUMBER_OF_ROWS
            local colvalue = col / NUMBER_OF_COLS
            -- the noise function only works with numbers between 0 and 1
            MAP[row][col].height = cf.round(love.math.noise(rowvalue, colvalue, terrainheightperlinseed) * UPPER_TERRAIN_HEIGHT)
            MAP[row][col].tileType = cf.round(love.math.noise(rowvalue, colvalue, terraintypeperlinseed) * 4)
            local tiles = concord.entity(WORLD)
            :give("drawable")
            :give("position", row, col)
            :give("uid")
            if row == WELLS[1].row and col == WELLS[1].col then
                -- this tile has a well
                tiles:give("isTile", MAP[row][col].tileType, MAP[row][col].height, enum.improvementWell)
            else
                tiles:give("isTile", MAP[row][col].tileType, MAP[row][col].height)
            end
        end
    end

    -- add starting villagers
    for i = 1, NUMBER_OF_VILLAGERS do
        local villager = concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("uid")
        :give("isPerson")
        table.insert(VILLAGERS, villager)
    end

end

return ecsfunctions
