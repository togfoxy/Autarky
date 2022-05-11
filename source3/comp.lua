comp = {}

function comp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)
    concord.component("drawable")   -- will be drawn during love.draw()

    concord.component("isSelected") -- clicked by the mouse

    concord.component("isPerson", function(c)
        c.queue = {}
        c.stamina = 100         -- fully rested
        c.wealth = 3            -- starting amount. 3 days worth of food.
        c.fullness = 125        -- hunger. Start a little topped up so they have a chance to establish themselves.
        c.stockInv = {}         -- track how much of each stock is owned
        for i = 1, 99 do
            c.stockInv[i] = 0
        end
    end)

    concord.component("occupation", function(c, number, stocktype)
        c.value = number or 0       -- see enum.job
        c.stocktype = stocktype or nil             -- see enum.stocktype
    end)

    concord.component("workplace", function(c,row,col)
        c.row = row
        c.col = col
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
    end)

    concord.component("position", function(c, row, col)         -- exists on the map/grid
        c.row = row or love.math.random(1, NUMBER_OF_ROWS)  -- this is updated in "applyMovement"
        c.col = col or love.math.random(1, NUMBER_OF_COLS)
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
    end)


    concord.component("isTile", function(c, tiletype, tileheight, improvementtype)
        -- c.imageNumber = imagenumber or love.math.random(1, Enum.terrainNumberOfTypes)
        c.tileType = tiletype
        c.tileHeight = tileheight
        c.tileOwner = {}
        c.improvementType = improvementtype or nil     -- an improvement = a building or structure
        c.stockType = nil
        c.stockLevel = 0
        c.stockSellPrice = 0
        c.mudLevel = 0              -- holds the alpha value for the mud (0 -> 255)
    end)


end




return comp
