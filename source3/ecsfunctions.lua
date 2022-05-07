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
                local img = IMAGES[e.isTile.tileType]
                local drawx, drawy = e.position.x, e.position.y
                local imagewidth = img:getWidth()
                local imageheight = img:getHeight()
                local drawscalex = (TILE_SIZE / imagewidth)
                local drawscaley = (TILE_SIZE / imageheight)
                local offsetx = imagewidth / 2
                local offsety = imageheight / 2

				love.graphics.setColor(1,1,1,1)
                love.graphics.draw(img, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)

                -- debugging
                -- love.graphics.circle("line", drawx, drawy, 3)
                -- love.graphics.print(e.isTile.tileType, drawx, drawy)
                -- love.graphics.print(e.isTile.tileHeight, drawx, drawy)

                -- draw contour lines
                local row, col = e.position.row, e.position.col
                -- check if top neighbour is different to current cell
                if row > 1 then
                    if MAP[row-1][col].height ~= MAP[row][col].height then
                        -- draw line
                        local x1, y1 = fun.getXYfromRowCol(row, col)
                        local x2, y2 = x1 + TILE_SIZE, y1
                        local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
                        x1 = x1 - (TILE_SIZE / 2)
                        y1 = y1 - (TILE_SIZE / 2)
                        x2 = x2 - (TILE_SIZE / 2)
                        y2 = y2 - (TILE_SIZE / 2)
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
                        x1 = x1 - (TILE_SIZE / 2)
                        y1 = y1 - (TILE_SIZE / 2)
                        x2 = x2 - (TILE_SIZE / 2)
                        y2 = y2 - (TILE_SIZE / 2)


                        love.graphics.setColor(1,1,1,alpha)
                        love.graphics.line(x1, y1, x2, y2)
                    end
                end

                if e.isTile.improvementType ~= nil then
                    -- draw the improvement
                    local imagenumber = e.isTile.improvementType
                    local drawx, drawy = e.position.x, e.position.y
                    local imagewidth = IMAGES[imagenumber]:getWidth()
                    local imageheight = IMAGES[imagenumber]:getHeight()

                    local drawscalex = (TILE_SIZE / imagewidth)
                    local drawscaley = (TILE_SIZE / imageheight)

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.draw(IMAGES[imagenumber], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                end
            end

            if e.isPerson then
                if e.isSelected then
                    love.graphics.setColor(0,1,0,1)
                else
                    love.graphics.setColor(1,1,1,1)
                end
                local drawwidth = PERSON_DRAW_WIDTH
                local drawx, drawy = e.position.x, e.position.y
                love.graphics.circle("fill", drawx, drawy, drawwidth)

                -- draw the occupation
                if e:has("occupation") then
                    love.graphics.setColor(0,0,1,1)
                    local offsetx = 5
                    local offsety = 8
                    local occupation = e.occupation.value
                    if occupation == enum.jobFarmer then
                        love.graphics.print("F", drawx, drawy, 0, 1, 1, offsetx, offsety)
                    end
                end

                -- display some debugging information
                if e.isPerson.queue[1] ~= nil then
                    local txt = e.isPerson.queue[1].action .. "\n"
                    if e.isPerson.queue[1].timeleft ~= nil then
                        txt = txt .. cf.round(e.isPerson.queue[1].timeleft)
                    end

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 10)
                end


            end
        end
    end

    systemIsTile = concord.system({
        pool = {"isTile"}
        --poolB = {"isPerson"}
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            -- MAP[row][col] = entity
        end
        --self.poolB.onEntityAdded = function(_, entity)
        --    table.insert(VILLAGERS, entity)
        --end
    end

    systemIsPerson = concord.system({
        pool = {"isPerson"}
    })
    function systemIsPerson:update(dt)
        for _, e in ipairs(self.pool) do
            -- check if queue is empty and if so then get a new action from the behavior tree

    -- print("alpha " .. #e.isPerson.queue)
            if #e.isPerson.queue == 0 then
                local goal = ft.DetermineAction(TREE, e)
                local actionlist = {}
                --local actionlist = fun.createActions(goal, e.isPerson.queue)  -- turns a simple decision from the tree into a complex sequence of actions
                local actionlist = fun.createActions(goal, e)  -- turns a simple decision from the tree into a complex sequence of actions and adds to queue
    print("alpha " .. #e.isPerson.queue)
    print(inspect(actionlist))
            end

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

            if currentaction.action == "idle" then
                currentaction.timeleft = currentaction.timeleft - dt
                e.isPerson.stamina = e.isPerson.stamina + (dt * 2)
                if e.isPerson.stamina > 100 then e.isPerson.stamina = 100 end
                if currentaction.timeleft <= 0 then
    print("beta " .. #e.isPerson.queue)
                    table.remove(e.isPerson.queue, 1)
    print("charlie " .. #e.isPerson.queue)
    print("~~~~")
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
                    e.isPerson.stamina = e.isPerson.stamina - dt
                    if e.isPerson.stamina < 0 then e.isPerson.stamina = 0 end
                end
            end
        end
    end

    -- add the systems to the world
    -- ## ensure all systems are added to the world
    WORLD:addSystems(systemDraw, systemIsTile, systemIsPerson)

    -- create entities

    -- capture the tile that has the well firs of all
	WELLS = {}
	WELLS[1] = {}
	WELLS[1].row = love.math.random(3, NUMBER_OF_ROWS - 4)  -- The 3 and -2 keeps the well off the screen edge
	WELLS[1].col = love.math.random(3, NUMBER_OF_COLS - 2)

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
        local VILLAGER = concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("uid")
        :give("isPerson")
        table.insert(VILLAGERS, VILLAGER)
    end

end

return ecsfunctions
