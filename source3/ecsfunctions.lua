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
                        love.graphics.setColor(1,1,1,alpha)
                        love.graphics.line(x1, y1, x2, y2)
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


                        love.graphics.setColor(1,1,1,alpha)
                        love.graphics.line(x1, y1, x2, y2)
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

                -- draw the occupation
                if e:has("occupation") then
                    love.graphics.draw(SPRITES[enum.spriteBlueMan], QUADS[enum.spriteBlueMan][1], drawx, drawy, 0, 1, 1, 10, 25)
                    love.graphics.setColor(0,0,1,1)
                else
                    love.graphics.draw(SPRITES[enum.spriteRedMan], QUADS[enum.spriteRedMan][1], drawx, drawy, 0, 1, 1, 10, 25)
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
                    txt = txt .. "stamina: " .. cf.round(e.isPerson.stamina) .. "\n"
                    txt = txt .. "fullness: " .. cf.round(e.isPerson.fullness) .. "\n"
                    txt = txt .. "wealth: " .. cf.round(e.isPerson.wealth,1) .. "\n"
                    txt = txt .. "wood: " .. cf.round(e.isPerson.stockInv[enum.stockWood]) .. "\n"

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 25)
                else
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

            -- determine new action for queue (or none)
            if #e.isPerson.queue == 0 then
                -- if DEBUG then print("***") end
                local goal = ft.DetermineAction(TREE, e)
                -- if DEBUG then print("***") end
                local actionlist = {}
                --local actionlist = fun.createActions(goal, e.isPerson.queue)  -- turns a simple decision from the tree into a complex sequence of actions
                local actionlist = fun.createActions(goal, e)  -- turns a simple decision from the tree into a complex sequence of actions and adds to queue
            end

            -- add 'idle' action if queue is still empty
            if #e.isPerson.queue < 1 then
                -- add an 'idle' action
                action = {}
                action.action = "idle"
                action.timeleft = love.math.random(10, 30)
                table.insert(e.isPerson.queue, action)
            end

            -- process head of queue
            local currentaction = {}
            currentaction = e.isPerson.queue[1]      -- a table

            if currentaction.action ~= "idle" and currentaction.action ~= "move" and currentaction.action ~= "work" then
                print("Current action: " .. currentaction.action)
            end

            if currentaction.action == "idle" then
                currentaction.timeleft = currentaction.timeleft - dt
                if currentaction.timeleft > 3 and love.math.random(1, 10000) == 1 then
                    -- play audio
                    AUDIO[enum.audioYawn]:play()
                end

                e.isPerson.stamina = e.isPerson.stamina + (1.5 * dt)        -- gain 1 per second + recover the 0.5 applied above
                -- if e.isPerson.stamina > 100 then e.isPerson.stamina = 100 end
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
                    AUDIO[enum.audioWork]:play()
                    print("Play 'work'")
                end
                if currentaction.timeleft <= 0 then
                    table.remove(e.isPerson.queue, 1)
                end
                if e.occupation.stocktype ~= nil then
                    -- accumulate stock
                    local row = e.position.row
                    local col = e.position.col
                    if MAP[row][col].stockLevel == nil then MAP[row][col].stockLevel = 0 end        --! this is probably redundant
                    local stockgained
                    if e.occupation.stocktype == enum.stockFruit then
                        if e.isPerson.stamina > 0 then
                            stockgained = (0.0267 * dt)
                        else
                            stockgained = (0.0267 * dt) / 2        -- less productive when tired
                        end
                    elseif e.occupation.stocktype == enum.stockWood then
                        if e.isPerson.stamina > 0 then
                            stockgained = (0.0089 * dt)
                        else
                            stockgained = (0.0089 * dt) / 2        -- less productive when tired
                        end
                    end
                    stockgained = cf.round(stockgained, 4)
                    MAP[row][col].entity.isTile.stockLevel = MAP[row][col].entity.isTile.stockLevel + stockgained
                end
            end
            if currentaction.action == "buy" then
                local agentrow = e.position.row
                local agentcol = e.position.col
                local imptype = MAP[agentrow][agentcol].entity.isTile.improvementType
                print("Buying stock type " .. imptype)
                -- check if agent is at the right shop
                if imptype ~= nil then
                    if imptype == action.stockType then
                        local amtbought = fun.buyStock(e, action.stockType, action.purchaseAmount)
                        print("Bought " .. amtbought .. " of stock type " .. action.stockType)
                        if action.stockType == enum.stockFruit then
                            e.isPerson.fullness = e.isPerson.fullness + (amtbought * 100)   -- each food restores 100 fullness
                            if amtbought > 0 and love.math.random(1, 2000) == 1 then
                                    AUDIO[enum.audioEat]:play()
                                    print("Play 'eat'")
                            end
                        else
                            e.isPerson.stockInv[action.stockType] = e.isPerson.stockInv[action.stockType] + amtbought
                        end
                    end
                end
                table.remove(e.isPerson.queue, 1)
            end

            -- ******************* --
            -- do things that don't depend on an action
            -- ******************* --
            local row = e.position.row  --! try to refact this so all the good stuff is only at the top
            local col = e.position.col

            -- add mud
            MAP[row][col].entity.isTile.mudLevel = MAP[row][col].entity.isTile.mudLevel + (dt * 3)
            if MAP[row][col].entity.isTile.mudLevel > 255 then MAP[row][col].entity.isTile.mudLevel = 255 end

            e.isPerson.stamina = e.isPerson.stamina - (0.5 * dt)
            if e.isPerson.stamina < 0 then e.isPerson.stamina = 0 end

            -- do this last as it may nullify the entity
            e.isPerson.fullness = e.isPerson.fullness - (0.33 * dt)
            -- if e.isPerson.fullness < 0 then e.isPerson.fullness = 0 end
            if e.isPerson.fullness < 0 then
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
