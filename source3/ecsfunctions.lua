ecsfunctions = {}

function ecsfunctions.init()

    -- create the world
    WORLD = concord.world()

    local compmodule = require 'comp'

    -- define components
    compmodule.init()

    -- ## declare systems
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
				love.graphics.setColor(1,1,1,1)
                love.graphics.draw(img, drawx, drawy, 0, drawscalex, drawscaley)
            end
            if e.isPerson then
                love.graphics.setColor(1,1,1,1)
                local drawwidth = PERSON_DRAW_WIDTH
                local drawx, drawy = e.position.x, e.position.y
                local offsetx, offsety = TILE_SIZE / 2, TILE_SIZE / 2
                drawx = drawx + offsetx
                drawy = drawy + offsety
                love.graphics.circle("fill", drawx, drawy, drawwidth)
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
            MAP[row][col] = entity
        end
        --self.poolB.onEntityAdded = function(_, entity)
        --    table.insert(VILLAGERS, entity)
        --end
    end

    -- ## define more systems here

    -- add the systems to the world
    -- ## ensure all systems are added to the world
    WORLD:addSystems(systemDraw, systemIsTile)

    -- create entities
    -- create tiles
    local terrainheightperlinseed
    local terraintypeperlinseed = love.math.random(0,20) / 20
    repeat
        terrainheightperlinseed = love.math.random(0,20) / 20
    until terrainheightperlinseed ~= terraintypeperlinseed

    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            local rowvalue = row / NUMBER_OF_ROWS
            local colvalue = col / NUMBER_OF_COLS
            -- the noise function only works with numbers between 0 and 1
            MAP[row][col].height = cf.round(love.math.noise(rowvalue, colvalue, terrainheightperlinseed) * UPPER_TERRAIN_HEIGHT)
            MAP[row][col].tileType = cf.round(love.math.noise(rowvalue, colvalue, terraintypeperlinseed) * 4)

            local TILES = concord.entity(WORLD)
            :give("drawable")
            :give("position", row, col)
            :give("isTile", MAP[row][col].tileType, MAP[row][col].height)
            :give("uid")
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
