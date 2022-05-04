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

-- print(row, col, MAP[row][col].height)

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
