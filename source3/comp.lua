comp = {}

function comp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)
    concord.component("drawable")   -- will be drawn during love.draw()

    concord.component("isSelected") -- clicked by the mouse

    concord.component("isPerson", function(c)
        c.gender = love.math.random(2)
        c.health = 100
        c.queue = {}
        c.stamina = 100         -- fully rested
        c.fullness = 125        -- hunger. Start a little topped up so they have a chance to establish themselves.
        c.stockInv = {}         -- track how much of each stock is owned
        c.stockBelief = {}
        for i = 1, 30 do
            c.stockInv[i] = 0
            c.stockBelief[i] = {}
            c.stockBelief[i][1] = 0       -- lowest belief for stock item 'i'
            c.stockBelief[i][2] = 0       -- highest belief
            c.stockBelief[i][3] = 0       -- total financial amount transacted    -- finanical amount / count = average for item 'i'
            c.stockBelief[i][4] = 0       -- total count transacted
        end

        c.stockBelief[enum.stockFruit][1] = FRUIT_SELL_PRICE - 1
        c.stockBelief[enum.stockFruit][2] = FRUIT_SELL_PRICE + 1
        if c.stockBelief[enum.stockFruit][1] < 0 then c.stockBelief[enum.stockFruit][1] = 0.5 end

        c.stockBelief[enum.stockWood][1] = WOOD_SELL_PRICE - 1
        c.stockBelief[enum.stockWood][2] = WOOD_SELL_PRICE + 1
        if c.stockBelief[enum.stockWood][1] < 0 then c.stockBelief[enum.stockWood][1] = 0.5 end

        c.stockBelief[enum.stockHealingHerbs][1] = HERB_SELL_PRICE - 1
        c.stockBelief[enum.stockHealingHerbs][2] = HERB_SELL_PRICE + 1
        if c.stockBelief[enum.stockHealingHerbs][1] < 0 then c.stockBelief[enum.stockHealingHerbs][1] = 0.5 end

        c.wealth = 3          -- starting amount. 3 days worth of food.
        c.stockInv[enum.stockWood] = 0
        c.log = {}
        c.taxesOwed = 0
    end)

    concord.component("occupation", function(c, jobtype, stocktype, bolProducer, bolService, bolConverter)
        c.value = jobtype or 0       -- see enum.job
        c.stockType = stocktype or nil             -- see enum.stockType
        c.isProducer = bolProducer
        c.isService = bolService
        c.isConverter = bolConverter                -- converts one item into another
    end)

    concord.component("workplace", function(c,row,col)
        c.row = row
        c.col = col
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
    end)

    concord.component("residence", function(c,row,col)
        c.row = row
        c.col = col
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
        c.health = 0        -- starts off at zero
    end)

    concord.component("position", function(c, row, col)         -- exists on the map/grid
        c.row = row or love.math.random(1, NUMBER_OF_ROWS)  -- this is updated in "applyMovement"
        c.col = col or love.math.random(1, NUMBER_OF_COLS)
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
        c.previousx = c.x
        c.previousy = c.y
        c.movementDelta = 0     -- track movement for animation purposes
    end)

    concord.component("isTile", function(c, tiletype, tileheight, improvementtype)
        -- c.imageNumber = imagenumber or love.math.random(1, Enum.terrainNumberOfTypes)
        c.tileType = tiletype
        c.tileHeight = tileheight
        c.tileOwner = {}
        c.improvementType = improvementtype or nil     -- an improvement = a building or structure
        c.stockType = nil
        c.stockLevel = 0            -- must never be nil
        c.stockSellPrice = 0
        c.mudLevel = 0              -- holds the alpha value for the mud (0 -> 255)
        c.timeToBuild = nil        -- how long to build this tile
    end)


end




return comp
