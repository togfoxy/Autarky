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
    --IMAGES[enum.imagesWell] = love.graphics.newImage("assets/images/well_256.png")
    IMAGES[enum.imagesWell] = love.graphics.newImage("assets/images/well_alpha.png")
    IMAGES[enum.imagesFarm] = love.graphics.newImage("assets/images/appletree_37x50.png")
    IMAGES[enum.imagesMud] = love.graphics.newImage("assets/images/mud.png")
    IMAGES[enum.imagesWoodsman] = love.graphics.newImage("assets/images/woodsman.png")
    IMAGES[enum.imagesHouseFrame] = love.graphics.newImage("assets/images/house4frame.png")
    IMAGES[enum.imagesHouse] = love.graphics.newImage("assets/images/house4.png")


    -- quads
    SPRITES[enum.spriteBlueMan] = love.graphics.newImage("assets/images/Civilian Male Walk Blue.png")
    QUADS[enum.spriteBlueMan] = cf.fromImageToQuads(SPRITES[enum.spriteBlueMan], 15, 32)

    SPRITES[enum.spriteRedMan] = love.graphics.newImage("assets/images/Civilian Male Walk Red.png")
    QUADS[enum.spriteRedMan] = cf.fromImageToQuads(SPRITES[enum.spriteRedMan], 15, 32)
end

function functions.loadAudio()

    AUDIO[enum.musicCityofMagic] = love.audio.newSource("assets/audio/City of magic.wav", "stream")
	AUDIO[enum.musicOvertheHills] = love.audio.newSource("assets/audio/Over the hills.wav", "stream")
	AUDIO[enum.musicSpring] = love.audio.newSource("assets/audio/Spring.wav", "stream")
    AUDIO[enum.musicMedievalFiesta] = love.audio.newSource("assets/audio/Medieval fiesta.wav", "stream")
    AUDIO[enum.musicFuji] = love.audio.newSource("assets/audio/Fuji.mp3", "stream")
    AUDIO[enum.musicHiddenPond] = love.audio.newSource("assets/audio/Hidden-Pond.mp3", "stream")
    AUDIO[enum.musicDistantMountains] = love.audio.newSource("assets/audio/Distant-Mountains.mp3", "stream")

    AUDIO[enum.musicBirdsinForest] = love.audio.newSource("assets/audio/430917__ihitokage__birds-in-forest-5.ogg", "stream")
    AUDIO[enum.musicBirds] = love.audio.newSource("assets/audio/532148__patchytherat__birds-1.wav", "stream")

    AUDIO[enum.audioYawn] = love.audio.newSource("assets/audio/272030__aldenroth2__male-yawn.wav", "static")
    AUDIO[enum.audioWork] = love.audio.newSource("assets/audio/working.wav", "static")
    AUDIO[enum.audioEat] = love.audio.newSource("assets/audio/543386__chomp.wav", "static")
    AUDIO[enum.audioNewVillager] = love.audio.newSource("assets/audio/387232__steaq__badge-coin-win.wav", "static")


    AUDIO[enum.audioWork]:setVolume(0.2)
    AUDIO[enum.musicMedievalFiesta]:setVolume(0.2)
    AUDIO[enum.musicOvertheHills]:setVolume(0.2)
    AUDIO[enum.audioNewVillager]:setVolume(0.2)
    AUDIO[enum.musicCityofMagic]:setVolume(0.2)
    AUDIO[enum.musicSpring]:setVolume(0.1)
    AUDIO[enum.audioEat]:setVolume(0.2)
    AUDIO[enum.musicBirdsinForest]:setVolume(1)

end

function functions.PlayAmbientMusic()
	local intCount = love.audio.getActiveSourceCount()
	if intCount == 0 then
		if love.math.random(1,2000) == 1 then		-- allow for some silence between ambient music
			if love.math.random(1,2) == 1 then
                -- music
                local random = love.math.random(11, 17)
                AUDIO[random]:play()
    print("Playing music #" .. random)
			else

                local random = love.math.random(21, 22)
    print("Playing ambient " .. random)
    			AUDIO[random]:play()
			end
		end
	end
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

    -- print(inspect(cmap))

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
            -- action.x, action.y = fun.getXYfromRowCol(action.row, action.col)    -- returns x and y (in that order)
            local x, y = fun.getXYfromRowCol(action.row, action.col)    -- returns x and y (in that order)
            x = x + love.math.random(-10, 10) -- add some randomness to movement
            y = y + love.math.random(-10, 10)
            action.x, action.y = x, y
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

        -- print("alpha:" .. tostring(agent.occupation.isConverter))
        if agent.occupation.isProducer then
            if not agent:has("workplace") then

                print("beta")
                -- create a workplace
                workplacerow, workplacecol = getBlankTile()
                assert(workplacerow ~= nil)
                agent:give("workplace", workplacerow, workplacecol)
                MAP[workplacerow][workplacecol].entity.isTile.improvementType = agent.occupation.value
                MAP[workplacerow][workplacecol].entity.isTile.stockType = agent.occupation.stocktype
                MAP[workplacerow][workplacecol].entity.isTile.tileOwner = agent

                if agent.occupation.stocktype == enum.stockFruit then
                    MAP[workplacerow][workplacecol].entity.isTile.stockSellPrice = 1
                elseif agent.occupation.stocktype == enum.stockWood then
                    MAP[workplacerow][workplacecol].entity.isTile.stockSellPrice = 3
                end
                print("Owner assigned to " .. workplacerow, workplacecol)
            end
            if agent:has("workplace") then

                print("charlie")
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
        if agent.occupation.isConverter then
            -- print("Delta")
            -- time to convert things
            if agent.occupation.value == enum.jobCarpenter then
                -- print("echo")
                -- look for a house frame
                local framerow, framecol = getClosestBuilding(enum.improvementHouseFrame, 1, agentrow, agentcol)
                if framerow ~= nil then
                    -- print("Foxtrot")
                    addMoveAction(queue, agentrow, agentcol, framerow, framecol)   -- will add as many 'move' actions as necessary
                    local action = {}
                    action.action = "work"
                    action.timeleft = love.math.random(30, 60)
                    table.insert(queue, action)
                else
                    -- print("Carpenter has nothing to build")
                end
            end
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
        action = {}     --! this perhaps should be inside one of the IF statements
        action.action = "buy"
        action.stockType = enum.stockFruit
        action.purchaseAmount = qtyneeded
        -- print("Added 'buy' goal")
        table.insert(queue, action)
        assert(action.stockType ~= nil)
        print("move and buy fruit action added")
    end
    if goal == enum.goalBuyWood then
        -- print("Goal = buy wood")
        local qtyneeded = 1
        local shoprow, shopcol = getClosestBuilding(enum.improvementWoodsman, qtyneeded, agentrow, agentcol)
        if shoprow ~= nil then
            addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
            -- buy wood
            action = {}
            action.action = "buy"
            action.stockType = enum.stockWood
            action.purchaseAmount = qtyneeded
            -- print("Added 'buy' goal")
            table.insert(queue, action)
            print("move and buy wood action added")
            assert(action.stockType ~= nil)
        else
            -- print("No woodsman found")
        end
    end
    if goal == enum.goalStartHouse then
        -- pick an empty tile
        local houserow, housecol = getBlankTile()
        agent:give("residenceFrame", houserow, housecol)

        -- place a frame
        MAP[houserow][housecol].entity.isTile.improvementType = enum.improvementHouseFrame
        MAP[houserow][housecol].entity.isTile.stockType = enum.stockHouseFrame
        MAP[houserow][housecol].entity.isTile.stockLevel = 1
        MAP[houserow][housecol].entity.isTile.tileOwner = agent
        MAP[houserow][housecol].entity.isTile.timeToBuild = 60          -- seconds

        -- subtract wood
        agent.isPerson.stockInv[enum.stockWood] = agent.isPerson.stockInv[enum.stockWood] - 5
        agent.isPerson.wealth = agent.isPerson.wealth - 8               -- this is forward payment for the carpenter
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

    e.position.row = cf.round((currenty + TOP_MARGIN) / TILE_SIZE)
    e.position.col = cf.round((currentx + LEFT_MARGIN) / TILE_SIZE)
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
