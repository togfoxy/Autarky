ecs = {}


function ecs.init()

    -- Create the World
    WORLD = Concord.world()

    -- define components
    Concord.component("drawable")
    Concord.component("isSelected")
    Concord.component("uid", function(c)
        c.value = Cf.Getuuid()
    end)
    Concord.component("position", function(c, row, col)
        c.row = row or love.math.random(1,NUMBER_OF_ROWS)
        c.col = col or love.math.random(1,NUMBER_OF_COLS)
        c.x, c.y = Fun.getXYfromRowCol(c.row, c.col)
    end)

    Concord.component("isPerson")
    Concord.component("currentAction", function(c, number)
        c.value = number or 0
    end)
    Concord.component("hasTargetTile", function(c, row, col)
        c.row = row
        c.col = col
        c.traveltime = 0
    end)
    Concord.component("maxSpeed", function(c, number)
        c.value = 30
    end)
    Concord.component("age", function(c, number)
        c.value = number or love.math.random(20, 45)
    end)
    Concord.component("maxAge", function(c, number)
        c.value = number or love.math.random(50, 70) -- years
    end)
    Concord.component("occupation", function(c, number)
        c.value = number or 0
    end)
    Concord.component("hasWorkplace", function(c, row, col)
        if row == nil or col == nil then error("hasWorkplace needs a row and a col") end
        c.row = row
        c.col = col
    end)

    Concord.component("isTile", function(c, imagenumber)
        c.imageNumber = imagenumber or love.math.random(1, Enum.terrainNumberOfTypes)
    end)
    Concord.component("hasBuilding", function(c, buildingnumber)
        c.value = buildingnumber
    end)

    -- define Systems
    systemDraw = Concord.system({
        pool = {"position", "drawable"}
    })
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        for _, e in ipairs(self.pool) do
            if e.isTile then
                local img = IMAGES[e.isTile.imageNumber]
                local x, y = e.position.x - (TILE_SIZE / 2), e.position.y - (TILE_SIZE / 2)
                love.graphics.draw(img, x, y, 0, TILE_SIZE / 256)
                if e.isSelected then
                    love.graphics.rectangle("line", x, y, TILE_SIZE, TILE_SIZE - 1)
                end
            end

            if e.isPerson then
                love.graphics.setColor(1,1,1,1)
                if e:has("occupation") then
                    if e.occupation.value == Enum.jobFarmer then
                        love.graphics.setColor(0,1,0,1)
                    end
                end
                local drawwidth = Enum.personDrawWidth
                local x, y = e.position.x, e.position.y
                love.graphics.circle("fill", x, y, drawwidth)
                if e.isSelected then
                    love.graphics.setColor(1,0,0,1)
                    love.graphics.circle("fill", x, y, drawwidth / 2)
                    love.graphics.setColor(1,1,1,1)
                end
            end
        end
    end

    systemDoWork = Concord.system({
        pool = {"occupation"}
    })
    function systemDoWork:update(dt)
        -- ensure a workplace exists
        -- if not at workplace then set targetTile
        -- if at workplace then do work
        for _, e in ipairs(self.pool) do
            if Fun.AtWorkplace(e) then
                -- check if building at workplace
                local r, c = Fun.getRowColfromXY(e.position.row, e.position.col)
                if MAP[r][c]:has("hasBuilding") then
                    Fun.DoWork(e)
                else
                    -- build a building
                end
            end
        end
    end

    systemDecideAction = Concord.system({
        pool = {"isPerson"}
    })
    function systemDecideAction:update(dt)
        for _, e in ipairs(self.pool) do
            if not e:has("currentAction") then
                -- doing nothing. Decide action
                if e:has("occupation") then
                    -- has a job
                    if e:has("hasWorkplace") then
                        -- lets go to work
                        e:ensure("currentAction", Enum.actionMovingToWorkplace)
                        e:ensure("hasTargetTile", e.hasWorkplace.row, e.hasWorkplace.col)
                    else
                        -- has an occupation but no workplace
                        -- build a workplace
                        local r, c = Fun.getBlankTile()
                        e:ensure("hasWorkplace", r, c)
                        e:ensure("currentAction", actionMovingToWorkplace)
                        e:ensure("hasTargetTile", e.hasWorkplace.row, e.hasWorkplace.col)
                        MAP[r][c]:ensure("hasBuilding", Enum.buildingFarm)
                    end
                end
            end
        end
    end

    systemMove = Concord.system({
        pool = {"hasTargetTile"}
    })
    function systemMove:update(dt)
        for k, e in ipairs(self.pool) do
            -- adjust x and y
            Fun.applyMovement(e, e.maxSpeed.value, dt)
            -- remove hasTargetTile if at destination
            if (Cf.round(e.position.row,1) == Cf.round(e.hasTargetTile.row,1)) and Cf.round(e.position.col,1) == Cf.round(e.hasTargetTile.col,1) then
                e:remove("hasTargetTile")
                -- print("Target tile removed " ..  dt)
            end
        end
    end

    systemIsTile = Concord.system({
        pool = {"isTile"},
        --poolB = {"isPerson"}
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col] = entity
        end
        --self.poolB.onEntityAdded = function(_, entity)
        --    table.insert(VILLAGERS, entity)
        --end
    end

    -- Add the Systems
    WORLD:addSystems(systemDraw, systemIsTile, systemDoWork, systemDecideAction, systemMove)

    -- Create entitites

    -- create tiles
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            local TILES = Concord.entity(WORLD)
            :give("drawable")
            :give("position", row, col)
            :give("isTile")
            :give("uid")
        end
    end
    -- add a well
    local wellrow = love.math.random(4,NUMBER_OF_ROWS - 3)
    local wellcol = love.math.random(4,NUMBER_OF_COLS - 3)
    local WELL = Concord.entity(WORLD)
    :give("drawable")
    :give("position", wellrow, wellcol)
    :give("isTile", Enum.terrainWell)
    :give("uid")

    -- add starting villagers
    for i = 1, NUMBER_OF_VILLAGERS do
        local VILLAGER = Concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("maxSpeed")
        :give("uid")
        :give("isPerson")
        table.insert(VILLAGERS, VILLAGER)
    end
end


return ecs
