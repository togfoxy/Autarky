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
    IMAGES[enum.imagesFarm] = love.graphics.newImage("assets/images/house1.png")

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

local function convertToCollisionMap(map)
    -- takes the game map (not entities) and converts it to a jumper-compatible collision map
    local thismap = {}

    -- initalise thismap
    for row = 1, NUMBER_OF_ROWS do
		thismap[row] = {}
	end
	for col = 1, NUMBER_OF_COLS do
		for row = 1,NUMBER_OF_ROWS do
			thismap[row][col] = {}
        end
    end

    -- copy improvements from MAP to thismap
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if map[row][col].entity.isTile.improvementType ~= nil then
                thismap[row][col] = 1
            else
                thismap[row][col] = 0
            end
        end
    end
    return thismap
end

local function getBlankTile()
    --! need to check that tile is pathfinding to the well

    local row, col
    local tilevalid = true
    local count = 0

    repeat
        count = count + 1
        row = love.math.random(1, NUMBER_OF_ROWS)
        col = love.math.random(1, NUMBER_OF_COLS)

        if MAP[row][col].entity.isTile.improvementType ~= nil then tilevalid = false end

        if row >= WELLS[1].row - 3 and row <= WELLS[1].row + 3 and
            col >= WELLS[1].col - 3 and col <= WELLS[1].col + 3 then
                tilevalid = false
        end

        local cmap = convertToCollisionMap(MAP)
        -- jumper uses x and y which is really col and row
        local startx = WELLS[1].col
        local starty = WELLS[1].row
        local endx = col
        local endy = row

        local path = cf.findPath(cmap, 0, startx, starty, endx, endy, false)        -- startx, starty, endx, endy
        if path == nil then tilevalid = false end
    until tilevalid or count > 1000

    if count > 1000 then
        return nil, nil     --! need to check if nil is returned (no blank tiles available)
    else
        return row, col
    end
end

local function getClosestBuilding(buildingtype, startrow, startcol)
    -- returns the closest building of required type
    local closestvalue = -1
    local closestrow, closestcol

    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if MAP[row][col].entity.isTile.improvementType == buildingtype then
                local cmap = convertToCollisionMap(MAP)
                cmap[row][col] = enum.tileWalkable
                local _, dist = cf.findPath(cmap, enum.tileWalkable, startcol, startrow, col, row, false)
                if closestvalue < 0 then
                    closestvalue = dist
                    closestrow = row
                    closestcol = col
                elseif dist < closestvalue then
                    closestvalue = dist
                    closestrow = row
                    closestcol = col
                end
            end
        end
    end
    return closestrow, closestcol       --! need to manage nils
end

local function addMoveAction(queue, startrow, startcol, stoprow, stopcol)
    -- uses jumper to add as many "move" actions as necessary to get to the waypoint

    -- get path to destination
    local cmap = convertToCollisionMap(MAP)
    -- need to 'blank' out the destination so jumper can find a path.
    cmap[stoprow][stopcol] = enum.tileWalkable

    -- jumper uses x and y which is really col and row
    local startx = startcol
    local starty = startrow
    local endx = stopcol
    local endy = stoprow
    local path = cf.findPath(cmap, enum.tileWalkable, startx, starty, endx, endy, false)        -- startx, starty, endx, endy

    for index, node in ipairs(path) do
        if index > 1 then   -- don't apply the first waypoint as it is too close to the agent
            local action = {}
            action.action = "move"
            action.row = node.y
            action.col = node.x
            action.x, action.y = fun.getXYfromRowCol(action.row, action.col)    -- returns x and y (in that order)
            table.insert(queue, action)
        end
    end
end

local function buyStock(agent, stocktype, qty)

    local agentrow = agent.position.row
    local agentcol = agent.position.col
    local imptype = MAP[agentrow][agentcol].entity.isTile.improvementType
    -- check if agent is at the right shop
    if imptype ~= nil then
        if imptype == stocktype then
            -- determine how much stock the agent can afford to buy
            local sellprice = MAP[agentrow][agentcol].entity.isTile.stockSellPrice
            local stockavail = MAP[agentrow][agentcol].entity.isTile.stockLevel
            local canafford = math.floor(agent.isPerson.wealth / sellprice)     -- rounds down
            local purchaseamt = math.min(stockavail, canafford)
            local funds = purchaseamt * sellprice

            MAP[agentrow][agentcol].entity.isTile.stockLevel = MAP[agentrow][agentcol].entity.isTile.stockLevel - purchaseamt
            agent.isPerson.fullness = agent.isPerson.fullness + purchaseamt

            MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.wealth = MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.wealth + funds
            agent.isPerson.wealth = agent.isPerson.wealth - funds
        end
    end
end

function functions.createActions(goal, agent)
    -- takes the goal provided by the behavior tree and returns a complex set of actions to achieve that goal
    -- returns a table of actions
    local queue = agent.isPerson.queue
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
        action.x, action.y = fun.getXYfromRowCol(destrow, destcol)      -- returns x and y (in that order)
        action.x = action.x + love.math.random(-20, 20)
        action.y = action.y + love.math.random(-20, 20)
        table.insert(queue, action)

        -- add an 'idle' action
        action = {}
        action.action = "idle"
        action.timeleft = love.math.random(10, 30)
        table.insert(queue, action)
    end
    if goal == enum.goalWork then
        -- time to earn a paycheck

        -- add a 'move to' action
        -- add a 'work' action
        if not agent:has("workplace") then
            -- create a workplace
            local workplacerow, workplacecol = getBlankTile()
            agent:give("workplace", workplacerow, workplacecol)
            -- MAP[workplacerow][workplacecol].improvementType = agent.occupation.value
            -- MAP[workplacerow][workplacecol].stocktype = agent.occupation.stocktype

            MAP[workplacerow][workplacecol].entity.isTile.improvementType = agent.occupation.value
            MAP[workplacerow][workplacecol].entity.isTile.stockType = agent.occupation.stocktype
            MAP[workplacerow][workplacecol].entity.isTile.tileOwner = agent

        end
        if agent:has("workplace") then
            -- move to workplace
            local workplacerow = agent.workplace.row
            local workplacecol = agent.workplace.col

            -- get path to workplace
            local cmap = convertToCollisionMap(MAP)
            -- need to 'blank' out the workplace so jumper can find a path.
            cmap[workplacerow][workplacecol] = enum.tileWalkable

            -- jumper uses x and y which is really col and row
            local startx = agent.position.col
            local starty = agent.position.row
            local endx = workplacecol
            local endy = workplacerow
            local path = cf.findPath(cmap, enum.tileWalkable, startx, starty, endx, endy, false)        -- startx, starty, endx, endy

            for index, node in ipairs(path) do
                if index > 1 then   -- don't apply the first waypoint as it is too close to the agent
                    local action = {}
                    action.action = "move"
                    action.row = node.y
                    action.col = node.x
                    action.x, action.y = fun.getXYfromRowCol(action.row, action.col)    -- returns x and y (in that order)
                    table.insert(queue, action)
                end
            end
            -- do work
            local action = {}
            action.action = "work"
            action.timeleft = love.math.random(10, 30)
            table.insert(queue, action)
        else
            error()     -- should never happen
        end
    end
    if goal == enum.goalEat then
        -- scan for a farmer
        local agentrow = agent.position.row
        local agentcol = agent.position.col
        local shoprow, shopcol = getClosestBuilding(enum.improvementFarm, agentrow, agentcol)
        if shoprow ~= nil then  --! need to properly deal with nils
           addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
           -- buy food
           buyStock(agent, enum.stockFruit, 10)

           -- eat food

        end
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

    e.position.row = cf.round(currenty / TILE_SIZE)
    e.position.col = cf.round(currentx / TILE_SIZE)
    if e.position.row < 1 then e.position.row = 1 end
    if e.position.col < 1 then e.position.col = 1 end
    if e.position.row > NUMBER_OF_ROWS then e.position.row = NUMBER_OF_ROWS end
    if e.position.col > NUMBER_OF_COLS then e.position.col = NUMBER_OF_COLS end
end

return functions
