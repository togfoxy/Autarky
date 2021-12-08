comp = {}

function comp.init()
    -- establish all the components

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
        c.value = 90 -- 30
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
        c.buildingNumber = buildingnumber	-- this determines the image
		c.isConstructed = false		-- has the building been built
    end)
end

return comp
