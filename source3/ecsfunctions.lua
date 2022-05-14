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

                -- draw tile image
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
                local row, col = e.position.row, e.position.col
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
                if imptype ~= nil then
                    local imagenumber = imptype
                    local imagewidth = IMAGES[imagenumber]:getWidth()
                    local imageheight = IMAGES[imagenumber]:getHeight()

                    local drawscalex = (TILE_SIZE / imagewidth)
                    local drawscaley = (TILE_SIZE / imageheight)

                    local offsetx = imagewidth / 2
                    local offsety = imageheight / 2

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.draw(IMAGES[imagenumber], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
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

                local imgrotation = 0
                if e.isPerson.queue[1] ~= nil then
                    if e.isPerson.queue[1].action == "rest" then
                        imgrotation = math.rad(90)
                    end
                end



                local sprite, quad
                if e.isPerson.gender == enum.genderMale and e:has("occupation") then
                    sprite = SPRITES[enum.spriteBlueMan]
                    quad = QUADS[enum.spriteBlueMan][1]
                end
                if e.isPerson.gender == enum.genderFemale and e:has("occupation") then
                    sprite = SPRITES[enum.spriteBlueWoman]
                    quad = QUADS[enum.spriteBlueWoman][1]
                end
                if e.isPerson.gender == enum.genderMale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedMan]
                    quad = QUADS[enum.spriteRedMan][1]
                end
                if e.isPerson.gender == enum.genderFemale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedWoman]
                    quad = QUADS[enum.spriteRedWoman][1]
                end
                love.graphics.draw(sprite, quad, drawx, drawy, imgrotation, 1, 1, 10, 25)

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
                    --! if agent has no wealth then this may not be the best option
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
                if currentaction.timeleft > 3 and love.math.random(1, 10000) == 1 then
                    -- play audio
                    AUDIO[enum.audioYawn]:play()
                end

                if currentaction.action == "rest" and e:has("residence") then
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
                end
            end

            if currentaction.action == "move" then
                local destx = currentaction.x
                local desty = currentaction.y
                if e.position.x == destx and e.position.y == desty then
                    -- arrived at destination
                    table.remove(e.isPerson.queue, 1)
                else
                    -- move towards destination
                    if e.isPerson.stamina > 0 then
                        local newx, newy = fun.applyMovement(e, destx, desty, WALKING_SPEED, dt)       -- entity, x, y, speed, dt
                    else
                        local newx, newy = fun.applyMovement(e, destx, desty, WALKING_SPEED / 2, dt)       -- entity, x, y, speed, dt
                    end

                end
            end

            if currentaction.action == "work" then
                currentaction.timeleft = currentaction.timeleft - dt
                if currentaction.timeleft > 3 and love.math.random(1, 5000) == 1 then
                    -- play audio
                    if e.occupation.value == enum.jobFarmer then
                        AUDIO[enum.audioRustle]:play()
                    end
                    if e.occupation.value == enum.jobWoodsman then
                        AUDIO[enum.audioSawWood]:play()
                    end
                end
                -- see if they hurt themselves at work
                if love.math.random(1, 100) == 1 then
                    local dmg = cf.round(love.math.random(1,10) * dt, 4)
                    e.isPerson.health = e.isPerson.health - dmg
                end

                if currentaction.timeleft <= 0 then
                    table.remove(e.isPerson.queue, 1)
                end

                -- print("+++")
                -- print(e.occupation.value)
                -- print(e.occupation.stockType)
                -- print("+++")
                if e.occupation.stockType ~= nil and e.occupation.value ~= enum.jobCarpenter then
                    -- accumulate stock
                    local row = e.position.row
                    local col = e.position.col
                    if MAP[row][col].stockLevel == nil then MAP[row][col].stockLevel = 0 end        --! this is probably redundant

                    local stockgained
                    if e.occupation.stockType == enum.stockFruit then
                        stockgained = (0.0267 * dt)     --! make these constants
                    elseif e.occupation.stockType == enum.stockWood then
                        stockgained = (0.0089 * dt)
                    elseif e.occupation.stockType == enum.stockHealingHerbs then
                        stockgained = (0.0267 * dt)
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
                    if MAP[row][col].entity.isTile.timeToBuild == nil then
                        -- house is already built. So sad. Nothing to do
                        table.remove(e.isPerson.queue, 1)
                    else
                        if MAP[row][col].entity.isTile.timeToBuild > 0  then
                            -- keep building the structure
                            MAP[row][col].entity.isTile.timeToBuild = MAP[row][col].entity.isTile.timeToBuild - dt
                            e.isPerson.wealth = e.isPerson.wealth + dt * 0.13
                        else
                            -- complete the house
                            local row = e.position.row
                            local col = e.position.col
                            MAP[row][col].entity.isTile.improvementType = enum.improvementHouse
                            MAP[row][col].entity.isTile.stockType = nil
                            MAP[row][col].entity.isTile.stockLevel = 0      -- stockLevel must never be nil
                            MAP[row][col].entity.isTile.timeToBuild = nil
                            local houseOwner = MAP[row][col].entity.isTile.tileOwner

                            houseOwner:remove("residenceFrame")
                            houseOwner:ensure("residence", row, col)

                            table.remove(e.isPerson.queue, 1)
                        end
                    end
                end
            end
            if currentaction.action == "buy" then
                local agentrow = e.position.row
                local agentcol = e.position.col
                print("Buying stock type " .. currentaction.stockType)     --! should the line above be 'stockType'?

                local amtbought = fun.buyStock(e, currentaction.stockType, currentaction.purchaseAmount)
                print("Bought " .. amtbought .. " of stock type " .. currentaction.stockType)
                if currentaction.stockType == enum.stockFruit then
                    e.isPerson.fullness = e.isPerson.fullness + (amtbought * 100)   -- each food restores 100 fullness
                    if amtbought > 0 and love.math.random(1, 1000) == 1 then
                            AUDIO[enum.audioEat]:play()
                            print("Play 'eat'")
                    end
                elseif currentaction.stockType == enum.stockHealingHerbs then
                    e.isPerson.health = e.isPerson.health + (amtbought * 10)
                    if amtbought > 0 and love.math.random(1, 1000) == 1 then
                            AUDIO[enum.audioBandage]:play()
                            print("Play 'heal'")
                    end
                else
                    e.isPerson.stockInv[currentaction.stockType] = e.isPerson.stockInv[currentaction.stockType] + amtbought
                end
                table.remove(e.isPerson.queue, 1)
            end

            -- ******************* --
            -- do things that don't depend on an action
            -- ******************* --
            local row = e.position.row  --! try to refact this so all the good stuff is only at the top
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
                if e:has("residenceFrame") then
                    -- destroy house
                    local wprow = e.residenceFrame.row
                    local wpcol = e.residenceFrame.col
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
