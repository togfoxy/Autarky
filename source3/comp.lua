comp = {}

function comp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)
    concord.component("drawable")
    concord.component("isPerson")

    concord.component("position", function(c, row, col)
        c.row = row or love.math.random(1, NUMBER_OF_ROWS)
        c.col = col or love.math.random(1, NUMBER_OF_COLS)
        c.x, c.y = fun.getXYfromRowCol(c.row, c.col)
    end)

    concord.component("isTile", function(c, tiletype, tileheight)
        -- c.imageNumber = imagenumber or love.math.random(1, Enum.terrainNumberOfTypes)
        c.tileType = tiletype
        c.tileHeight = tileheight
    end)


end




return comp
