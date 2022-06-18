ecsfunctions = {}

function ecsfunctions.init()

    -- create the world
    WORLD = concord.world()

    local compmodule = require 'comp'

    -- define components
    compmodule.init()

    -- declare systems
    ecsDraw.draw()
    ecsUpdate.isPerson()

    systemIsTile = concord.system({
        pool = {"isTile"}
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col].entity = entity       -- this assigns isTile amongst other things
        end
    end
    ecsUpdate.isTile()

    -- add the systems to the world
    -- ## ensure all systems are added to the world
    WORLD:addSystems(systemDraw, systemIsTile, systemIsTileUpdate, systemIsPerson)

    -- create entities

    -- capture the tile that has the well first of all
	WELLS = {}
	WELLS[1] = {}
	WELLS[1].row = love.math.random(4, NUMBER_OF_ROWS - 4)  -- The 3 and -2 keeps the well off the screen edge
	WELLS[1].col = love.math.random(4, NUMBER_OF_COLS - 4)

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
            local tiles = concord.entity(WORLD)     -- this calls tile:init() which then loads the entity into MAP
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
