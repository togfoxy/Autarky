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
    end)

    concord.component("occupation", function(c, number)
        c.value = number or 0       -- see enum.job
    end)

    concord.component("workplace", function(c,row,col)
        c.row = row
        c.col = col
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
    end)

    concord.component("position", function(c, row, col)         -- exists on the map/grid
        c.row = row or love.math.random(1, NUMBER_OF_ROWS)
        c.col = col or love.math.random(1, NUMBER_OF_COLS)
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
    end)


    concord.component("isTile", function(c, tiletype, tileheight, improvementtype)
        -- c.imageNumber = imagenumber or love.math.random(1, Enum.terrainNumberOfTypes)
        c.tileType = tiletype
        c.tileHeight = tileheight
        c.improvementType = improvementtype or nil     -- an improvement = a building or structure
    end)


end




return comp
