ecs = {}


function ecs.init()

    -- Create the World
    WORLD = Concord.world()

    -- define components
    Concord.component("drawable")
    Concord.component("isPerson")
    Concord.component("isSelected")
    Concord.component("isTile", function(c, imagenumber)
        c.imageNumber = imagenumber or love.math.random(1, Enum.terrainNumberOfTypes)
    end)
    Concord.component("uid", function(c)
        c.value = Cf.Getuuid()
    end)
    Concord.component("currentAction", function(c, text)
        c.value = text or ""
    end)
    Concord.component("hasTargetTile", function(c, row, col)
        c.row = row
        c.col = col
        c.traveltime = 0
    end)
    Concord.component("position", function(c, row, col)
        c.row = row or love.math.random(1,NUMBER_OF_ROWS)
        c.col = col or love.math.random(1,NUMBER_OF_COLS)
        c.x, c.y = Fun.getXYfromRowCol(c.row, c.col)
    end)
    Concord.component("maxSpeed", function(c, number)
        c.value = 15
    end)
    Concord.component("age", function(c, number)
        c.value = number or love.math.random(20, 45)
    end)
    Concord.component("maxAge", function(c, number)
        c.value = number or love.math.random(50, 70) -- years
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
                    love.graphics.rectangle("line", x, y, TILE_SIZE, TILE_SIZE)

                end
            end

            if e.isPerson then
                local drawwidth = Enum.personDrawWidth
                local x, y = e.position.x, e.position.y
                love.graphics.circle("fill", x, y, drawwidth)
            end
        end
    end

    systemIsTile = Concord.system({
        pool = {"isTile"},
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col] = entity
        end
    end




    -- Add the Systems
    WORLD:addSystems(systemDraw, systemIsTile)

    -- Create entitites

    -- create tiles
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            TILES = Concord.entity(WORLD)
            :give("drawable")
            :give("position", row, col)
            :give("isTile")
            :give("uid")

        end
    end
    -- add a well
    local wellrow = love.math.random(4,NUMBER_OF_ROWS - 3)
    local wellcol = love.math.random(4,NUMBER_OF_COLS - 3)
    WELL = Concord.entity(WORLD)
    :give("drawable")
    :give("position", wellrow, wellcol)
    :give("isTile", Enum.terrainWell)
    :give("uid")

    -- add starting villagers
    for i = 1, NUMBER_OF_VILLAGERS do
        VILLAGER = Concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("uid")
        :give("isPerson")
    end



















end


return ecs
