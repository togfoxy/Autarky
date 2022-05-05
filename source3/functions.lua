functions = {}

function functions.initialiseMap()
    -- local terrainheightperlinseed
    -- local terraintypeperlinseed = love.math.random(0,20) / 20
    -- repeat
    --     terrainheightperlinseed = love.math.random(0,20) / 20
    -- until terrainheightperlinseed ~= terraintypeperlinseed

    for row = 1, NUMBER_OF_ROWS do
		MAP[row] = {}
	end
	for col = 1, NUMBER_OF_COLS do
		for row = 1,NUMBER_OF_ROWS do
			MAP[row][col] = {}
            MAP[row][col].row = row
            MAP[row][col].col = col

            -- local rowvalue = row / NUMBER_OF_ROWS
            -- local colvalue = col / NUMBER_OF_COLS
            -- -- the noise function only works with numbers between 0 and 1
            -- MAP[row][col].height = cf.round(love.math.noise(rowvalue, colvalue, terrainheightperlinseed) * UPPER_TERRAIN_HEIGHT)
            -- MAP[row][col].tiletype = cf.round(love.math.noise(rowvalue, colvalue, terraintypeperlinseed) * 4)
		end
	end
end

function functions.loadImages()
	-- terrain tiles
	IMAGES[enum.imagesGrassDry] = love.graphics.newImage("assets/images/grass_dry_block_256x.png")
	IMAGES[enum.imagesGrassGreen] = love.graphics.newImage("assets/images/grass_green_block_256x.png")
	IMAGES[enum.imagesGrassTeal] = love.graphics.newImage("assets/images/grass_teal_block_256x.png")
    IMAGES[enum.imagesWell] = love.graphics.newImage("assets/images/well_256.png")

	-- buildings
	-- IMAGES[enum.buildingFarm] = love.graphics.newImage("assets/images/house1.png")
end

function functions.getXYfromRowCol(row, col)
    -- determine the drawing x based on column
    -- input row and col
    -- returns x, y (reverse order)
    local x = (col * TILE_SIZE) - TILE_SIZE + BORDER_SIZE
    local y = (row * TILE_SIZE) - TILE_SIZE + BORDER_SIZE
    return x, y
end

function functions.createActions(goal, queue)
    -- takes the goal provided by the behavior tree and returns a complex set of actions to achieve that goal
    -- returns a table of actions
    local actionlist = {}
    if goal == enum.goalRest then
        -- get a destination to rest
        -- add a 'move' action to that location
        -- add an 'idle' action at that location

        -- choose a random location near the well
        local random1 = love.math.random(-3, 3)
        local random2 = love.math.random(-3, 3)
        local destrow = WELLS[1].row + random1
        local destcol = WELLS[1].col + random2
        if destrow < 1 then destrow = 1 end
        if destrow > NUMBER_OF_ROWS then destrow = NUMBER_OF_ROWS end
        if destcol < 1 then destcol = 1 end
        if destcol > NUMBER_OF_COLS then destcol = NUMBER_OF_COLS end

        -- add a 'move' action
        local action = {}
        action.action = "move"
        action.row = destrow
        action.col = destcol
        -- adjust the x/y to be a little bit off centre for asthetics
        action.x, action.y = fun.getXYfromRowCol(destrow, destcol)
        action.x = action.x + love.math.random(-20, 20)
        action.y = action.y + love.math.random(-20, 20)
        table.insert(queue, action)

        -- add an 'idle' action
        action = {}
        action.action = "idle"
        action.timeleft = love.math.random(10, 30)
        table.insert(queue, action)
    end
    return queue
end

function functions.applyMovement(e, targetx, targety, velocity, dt)
    -- assumes an entity has a position and a target.
    -- return a new row/col that progresses towards that target

    local distancemovedthisstep = velocity * dt
    -- map row/col to x/y
    local currentx = (e.position.x)
    local currenty = (e.position.y)

    -- get the vector that moves the entity closer to the destination
    local xvector = targetx - currentx  -- tiles
    local yvector = targety - currenty  -- tiles

    -- print(distancemovedthisstep, currentx,currenty,targetx,targety,xvector,yvector)

    local xscale = math.abs(xvector / distancemovedthisstep)
    local yscale = math.abs(yvector / distancemovedthisstep)
    local scale = math.max(xscale, yscale)

    if scale > 1 then
        xvector = xvector / scale
        yvector = yvector / scale
    end

    currentx = cf.round(currentx + xvector, 1)
    currenty = cf.round(currenty + yvector, 1)

    e.position.x = currentx
    e.position.y = currenty

  -- print(currentx, currenty, xvector  , yvector  )

    e.position.row = (currenty / TILE_SIZE)
    e.position.col = (currentx / TILE_SIZE)
    if e.position.row < 1 then e.position.row = 1 end
    if e.position.col < 1 then e.position.col = 1 end
    if e.position.row > NUMBER_OF_ROWS then e.position.row = NUMBER_OF_ROWS end
    if e.position.col > NUMBER_OF_COLS then e.position.col = NUMBER_OF_COLS end
end

return functions
