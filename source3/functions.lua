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
    local x = LEFT_MARGIN + (col * TILE_SIZE) - TILE_SIZE
    local y = TOP_MARGIN + (row * TILE_SIZE) - TILE_SIZE
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

    local row, col

    local count = 0

    repeat
        count = count + 1
        local tilevalid = true
        row = love.math.random(1, NUMBER_OF_ROWS)
        col = love.math.random(1, NUMBER_OF_COLS)

        if MAP[row][col].entity.isTile.improvementType ~= nil then
            tilevalid = false
            print("Selected tile is already improved." .. count)
        end

        if row >= WELLS[1].row - 3 and row <= WELLS[1].row + 3 and
            col >= WELLS[1].col - 3 and col <= WELLS[1].col + 3 then
                tilevalid = false
                print("New improvement inside town square. Trying to find a new tile. " .. count, row, col)
        end

        local cmap = convertToCollisionMap(MAP)
        -- jumper uses x and y which is really col and row
        local startx = WELLS[1].col
        local starty = WELLS[1].row
        local endx = col
        local endy = row

        local path = cf.findPath(cmap, 0, startx, starty, endx, endy, false)        -- startx, starty, endx, endy
        if path == nil then
            tilevalid = false
            print("Can't find path to new tile. Trying to find a new tile. " .. count)
        end
    until tilevalid or count > 10000

    if count > 10000 then
        print("Can't find a blank tile. Giving up after 1000 tries." .. count)
        return nil, nil     --! need to check if nil is returned (no blank tiles available)
    else
        return row, col
    end
end

local function getClosestBuilding(buildingtype, requiredstocklevel, startrow, startcol)
    -- returns the closest building of required type
    local closestvalue = -1
    local closestrow, closestcol

    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if MAP[row][col].entity.isTile.improvementType == buildingtype and MAP[row][col].entity.isTile.stockLevel >= requiredstocklevel then
                local cmap = convertToCollisionMap(MAP)
                cmap[row][col] = enum.tileWalkable
                local _, dist = cf.findPath(cmap, enum.tileWalkable, startcol, startrow, col, row, false)
                if closestvalue < 0 or dist < closestvalue then
                    closestvalue = dist
                    closestrow = row
                    closestcol = col
                end
            end
        end
    end
    if closestrow == nil then
        -- print("Can't find building of type " .. buildingtype .. " with stocklevel of at least " .. requiredstocklevel)
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

    assert(path ~= nil) --! not sure how this is possible

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

function functions.buyStock(agent, stocktype, maxqty)
    -- returns the amount of stock purchased
    -- assumes agent is in the correct location
    local agentrow = agent.position.row
    local agentcol = agent.position.col
    local sellprice
    local purchaseamt
    local stockavail = math.floor(MAP[agentrow][agentcol].entity.isTile.stockLevel)

    if MAP[agentrow][agentcol].entity.isTile.tileOwner == agent then
        -- agent is buying from own shop. Waive the purchase price
        -- doing this allows farms with 0 wealth to still buy and survive
        purchaseamt = math.min(maxqty, stockavail)
        MAP[agentrow][agentcol].entity.isTile.stockLevel = MAP[agentrow][agentcol].entity.isTile.stockLevel - purchaseamt
    else
        -- normal purchase transaction
        sellprice = MAP[agentrow][agentcol].entity.isTile.stockSellPrice
        local canafford = math.floor(agent.isPerson.wealth / sellprice)     -- rounds down
        purchaseamt = math.min(stockavail, canafford)
        purchaseamt = math.min(purchaseamt, maxqty)       -- limit purchase to the requested amount
        purchaseamt = math.floor(purchaseamt)
        local funds = purchaseamt * sellprice

        MAP[agentrow][agentcol].entity.isTile.stockLevel = MAP[agentrow][agentcol].entity.isTile.stockLevel - purchaseamt
        MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.wealth = MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.wealth + funds
        agent.isPerson.wealth = agent.isPerson.wealth - funds
    end
    return purchaseamt
end

function functions.createActions(goal, agent)
    -- takes the goal provided by the behavior tree and returns a complex set of actions to achieve that goal
    -- returns a table of actions
    local queue = agent.isPerson.queue
    local agentrow = agent.position.row
    local agentcol = agent.position.col
    local workplacerow
    local workplacecol
    if agent:has("workplace") then
        workplacerow = agent.workplace.row
        workplacecol = agent.workplace.col
    end

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
        addMoveAction(queue, agentrow, agentcol, destrow, destcol)   -- will add as many 'move' actions as necessary

        -- add an 'idle' action
        action = {}
        action.action = "idle"
        action.timeleft = ((100 - agent.isPerson.stamina) / 2) + love.math.random(5, 30)      -- some random formula. Please tweak!
        table.insert(queue, action)
    end
    if goal == enum.goalWork then
        -- time to earn a paycheck
        if not agent:has("workplace") then
            -- create a workplace
            workplacerow, workplacecol = getBlankTile()
            assert(workplacerow ~= nil)
            agent:give("workplace", workplacerow, workplacecol)
            MAP[workplacerow][workplacecol].entity.isTile.improvementType = agent.occupation.value
            MAP[workplacerow][workplacecol].entity.isTile.stockType = agent.occupation.stocktype
            MAP[workplacerow][workplacecol].entity.isTile.tileOwner = agent
            -- print("Onwer assigned to " .. workplacerow, workplacecol)
        end
        if agent:has("workplace") then
            -- move to workplace
            -- add a 'move' action
            addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
            -- do work
            local action = {}
            action.action = "work"
            action.timeleft = love.math.random(30, 60)
            table.insert(queue, action)
        else
            error()     -- should never happen
        end
    end
    if goal == enum.goalEat then
        local qtyneeded = 1
        local ownsFruitshop = false
        if agent:has("workplace") and agent.isPerson.wealth <= 1.5 then
            if MAP[workplacerow][workplacecol].entity.isTile.stockLevel >= qtyneeded and
                MAP[workplacerow][workplacecol].entity.isTile.stockType == enum.stockFruit then
                    ownsFruitshop = true
            end
        end
        if ownsFruitshop then
            addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
        else
            -- not a farmer or rich or own farm has no stock
            local shoprow, shopcol = getClosestBuilding(enum.improvementFarm, qtyneeded, agentrow, agentcol)
            if shoprow ~= nil then
                addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
            end
        end
        -- buy food
        action = {}
        action.action = "buy"
        action.stockType = enum.stockFruit
        action.purchaseAmount = qtyneeded
        -- print("Added 'buy' goal")
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

    e.position.row = cf.round(currenty / TILE_SIZE)
    e.position.col = cf.round(currentx / TILE_SIZE)
    if e.position.row < 1 then e.position.row = 1 end
    if e.position.col < 1 then e.position.col = 1 end
    if e.position.row > NUMBER_OF_ROWS then e.position.row = NUMBER_OF_ROWS end
    if e.position.col > NUMBER_OF_COLS then e.position.col = NUMBER_OF_COLS end
end

function functions.killAgent(uniqueid)
    local deadID
    for k, v in ipairs(VILLAGERS) do
        -- print(uniqueid, v.uid.value)
        if v.uid.value == uniqueid then
            print("Found dead guy. " .. k)
            deadID = k
            break
        end
    end
    print("deadid: " .. deadID)
    assert(deadID ~= nil)
    table.remove(VILLAGERS, deadID)
    print("There are now " .. #VILLAGERS .. " villagers.")
end

return functions
