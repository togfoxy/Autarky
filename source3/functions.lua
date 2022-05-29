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

            -- add random trees
            if love.math.random(0, 50) == 1 then
                local random = love.math.random(1,6)        -- sprite number
                MAP[row][col].decoration = random
            end
		end
	end

    -- put this here for convenience
    for i = 1, NUMBER_OF_STOCK_TYPES do
        STOCK_HISTORY[i] = {}
    end
    -- STOCK_HISTORY[enum.stockFruit][1] = 1
    -- STOCK_HISTORY[enum.stockFruit][2] = 1.2
    -- STOCK_HISTORY[enum.stockFruit][3] = 2.1
    -- STOCK_HISTORY[enum.stockFruit][4] = 2.4
    -- STOCK_HISTORY[enum.stockFruit][5] = 1.5
    -- STOCK_HISTORY[enum.stockFruit][6] = 0.7



end

function functions.loadImages()
	-- terrain tiles
	IMAGES[enum.imagesGrassDry] = love.graphics.newImage("assets/images/grass_dry_block_256x.png")
	IMAGES[enum.imagesGrassGreen] = love.graphics.newImage("assets/images/grass_green_block_256x.png")
	IMAGES[enum.imagesGrassTeal] = love.graphics.newImage("assets/images/grass_teal_block_256x.png")
    -- IMAGES[enum.imagesWell] = love.graphics.newImage("assets/images/well_alpha.png")
    IMAGES[enum.imagesWell] = love.graphics.newImage("assets/images/well_50x45.png")
    IMAGES[enum.imagesMud] = love.graphics.newImage("assets/images/mud.png")

    IMAGES[enum.imagesHealingHouse] = love.graphics.newImage("assets/images/healerhouse.png")
    IMAGES[enum.imagesVillagerLog] = love.graphics.newImage("assets/images/villagerlog.png")
    IMAGES[enum.imagesWelfareHouse] = love.graphics.newImage("assets/images/welfarehouse.png")

    IMAGES[enum.iconsApple] = love.graphics.newImage("assets/images/appleicon.png")
    IMAGES[enum.iconsAxe] = love.graphics.newImage("assets/images/axeicon64x64.png")
    IMAGES[enum.iconsHammer] = love.graphics.newImage("assets/images/hammericon164x64.png")
    IMAGES[enum.iconsHealer] = love.graphics.newImage("assets/images/healericon64x64.png")
    IMAGES[enum.iconsCoin] = love.graphics.newImage("assets/images/coinicon64x64.png")
    IMAGES[enum.iconsWelfare] = love.graphics.newImage("assets/images/handshakeicon64x64.png")

    IMAGES[enum.imagesEmoteSleeping] = love.graphics.newImage("assets/images/emote_sleeps.png")
    IMAGES[enum.imagesEmoteTalking] = love.graphics.newImage("assets/images/emote_talking.png")
    IMAGES[enum.imagesEmoteCash] = love.graphics.newImage("assets/images/emote_cash.png")

    -- quads
    SPRITES[enum.spriteAppleTree] = love.graphics.newImage("assets/images/AppleTree_sheet.png")
    QUADS[enum.spriteAppleTree] = cf.fromImageToQuads(SPRITES[enum.spriteAppleTree], 37, 50)

    SPRITES[enum.spriteWoodPile] = love.graphics.newImage("assets/images/WoodPile_sheet_50x50.png")
    QUADS[enum.spriteWoodPile] = cf.fromImageToQuads(SPRITES[enum.spriteWoodPile], 50, 50)

    SPRITES[enum.spriteHouse] = love.graphics.newImage("assets/images/House_sheet_50x104.png")
    QUADS[enum.spriteHouse] = cf.fromImageToQuads(SPRITES[enum.spriteHouse], 50, 104)

    SPRITES[enum.spriteBlueMan] = love.graphics.newImage("assets/images/Civilian Male Walk Blue.png")
    QUADS[enum.spriteBlueMan] = cf.fromImageToQuads(SPRITES[enum.spriteBlueMan], 15, 32)

    SPRITES[enum.spriteBlueWoman] = love.graphics.newImage("assets/images/Civilian Female Walk Blue.png")
    QUADS[enum.spriteBlueWoman] = cf.fromImageToQuads(SPRITES[enum.spriteBlueWoman], 15, 32)

    SPRITES[enum.spriteRedMan] = love.graphics.newImage("assets/images/Civilian Male Walk Red.png")
    QUADS[enum.spriteRedMan] = cf.fromImageToQuads(SPRITES[enum.spriteRedMan], 15, 32)

    SPRITES[enum.spriteRedWoman] = love.graphics.newImage("assets/images/Civilian Female Walk Red.png")
    QUADS[enum.spriteRedWoman] = cf.fromImageToQuads(SPRITES[enum.spriteRedWoman], 15, 32)

    SPRITES[enum.spriteRandomTree] = love.graphics.newImage("assets/images/randomtrees_50x50.png")
    QUADS[enum.spriteRandomTree] = cf.fromImageToQuads(SPRITES[enum.spriteRandomTree], 50, 50)

    -- farmer
    SPRITES[enum.spriteFarmerMan] = love.graphics.newImage("assets/images/Farmer Male Walk.png")
    QUADS[enum.spriteFarmerMan] = cf.fromImageToQuads(SPRITES[enum.spriteFarmerMan], 15, 32)
end

function functions.loadAudio()

    AUDIO[enum.musicCityofMagic] = love.audio.newSource("assets/audio/City of magic.wav", "stream")
	AUDIO[enum.musicOvertheHills] = love.audio.newSource("assets/audio/Over the hills.wav", "stream")
	AUDIO[enum.musicSpring] = love.audio.newSource("assets/audio/Spring.wav", "stream")
    AUDIO[enum.musicMedievalFiesta] = love.audio.newSource("assets/audio/Medieval fiesta.wav", "stream")
    AUDIO[enum.musicFuji] = love.audio.newSource("assets/audio/Fuji.mp3", "stream")
    AUDIO[enum.musicHiddenPond] = love.audio.newSource("assets/audio/Hidden-Pond.mp3", "stream")
    AUDIO[enum.musicDistantMountains] = love.audio.newSource("assets/audio/Distant-Mountains.mp3", "stream")

    AUDIO[enum.musicBirdsinForest] = love.audio.newSource("assets/audio/430917__ihitokage__birds-in-forest-5.mp3", "stream")
    AUDIO[enum.musicBirds] = love.audio.newSource("assets/audio/532148__patchytherat__birds-1.wav", "stream")

    AUDIO[enum.audioYawn] = love.audio.newSource("assets/audio/272030__aldenroth2__male-yawn.wav", "static")
    AUDIO[enum.audioWork] = love.audio.newSource("assets/audio/working.wav", "static")
    AUDIO[enum.audioEat] = love.audio.newSource("assets/audio/543386__chomp.wav", "static")
    AUDIO[enum.audioNewVillager] = love.audio.newSource("assets/audio/387232__steaq__badge-coin-win.wav", "static")
    AUDIO[enum.audioRustle] = love.audio.newSource("assets/audio/437356__giddster__rustling-leaves.wav", "static")
    AUDIO[enum.audioSawWood] = love.audio.newSource("assets/audio/sawwood.wav", "static")
    AUDIO[enum.audioBandage] = love.audio.newSource("assets/audio/174627__altfuture__ripping-clothes.mp3", "static")


    AUDIO[enum.audioWork]:setVolume(0.2)
    AUDIO[enum.musicMedievalFiesta]:setVolume(0.2)
    AUDIO[enum.musicOvertheHills]:setVolume(0.2)
    AUDIO[enum.audioNewVillager]:setVolume(0.2)
    AUDIO[enum.musicCityofMagic]:setVolume(0.2)
    AUDIO[enum.musicSpring]:setVolume(0.1)
    AUDIO[enum.audioEat]:setVolume(0.2)
    AUDIO[enum.musicBirdsinForest]:setVolume(1)
    AUDIO[enum.audioSawWood]:setVolume(0.2)
    AUDIO[enum.audioSawWood]:setVolume(0.2)

end

function functions.PlayAmbientMusic()
	local intCount = love.audio.getActiveSourceCount()
	if intCount == 0 then
		if love.math.random(1,2000) == 1 then		-- allow for some silence between ambient music
			if love.math.random(1,2) == 1 then
                -- music
                local random = love.math.random(11, 17)
                fun.playAudio(random, true, false)
			else

                local random = love.math.random(21, 22)
                fun.playAudio(random, true, false)
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
    -- ensure the result is checked for nil - meaning - a blank tile was not found

    local row, col

    local count = 0

    repeat
        count = count + 1
        local tilevalid = true
        row = love.math.random(1, NUMBER_OF_ROWS)
        col = love.math.random(1, NUMBER_OF_COLS)

        if MAP[row][col].entity.isTile.improvementType ~= nil then
            tilevalid = false
            -- print("Selected tile is already improved." .. count)
        end

        if row >= WELLS[1].row - 3 and row <= WELLS[1].row + 3 and
            col >= WELLS[1].col - 3 and col <= WELLS[1].col + 3 then
                tilevalid = false
                -- print("New improvement inside town square. Trying to find a new tile. " .. count, row, col)
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
        return nil, nil
    else
        return row, col
    end
end

local function getClosestBuilding(buildingtype, requiredstocklevel, startrow, startcol)
    -- returns the closest building of required type
    -- ensure the return value is checked for nil - meaning - building not found
    local closestvalue = -1
    local closestrow, closestcol

    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if MAP[row][col].entity.isTile.improvementType == buildingtype and MAP[row][col].entity.isTile.stockLevel >= requiredstocklevel then
                local cmap = convertToCollisionMap(MAP)
                cmap[row][col] = TILEWALKABLE
                local _, dist = cf.findPath(cmap, TILEWALKABLE, startcol, startrow, col, row, false)
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
    return closestrow, closestcol
end

local function getRandomBuilding(buildingtype, requiredstocklevel)
    -- keeps checking tiles randomly till it finds the building with the right stock level
    for i = 1, 3000 do      -- check an arbitrary number of times
        local row = love.math.random(1, NUMBER_OF_ROWS)
        local col = love.math.random(1, NUMBER_OF_COLS)
        if MAP[row][col].entity.isTile.improvementType == buildingtype and MAP[row][col].entity.isTile.stockLevel >= requiredstocklevel then
            return row, col
        end
    end
    return nil, nil
end

local function getClosestPerson(taxesOwed, startrow, startcol)
    -- gets closest person that meets the needed criteria
    local closestvalue = -1
    local closestrow, closestcol
    local closestvillager

    for k, villager in pairs(VILLAGERS) do
        if villager.isPerson.taxesOwed >= taxesOwed then
            local endrow = villager.position.row
            local endcol = villager.position.col
            local cmap = convertToCollisionMap(MAP)
            cmap[endrow][endcol] = TILEWALKABLE
            local _, dist = cf.findPath(cmap, TILEWALKABLE, startcol, startrow, endcol, endrow, false)
            if closestvalue < 0 or dist < closestvalue then
               closestvalue = dist
               closestrow = endrow
               closestcol = endcol
               closestvillager = villager
            end
        end
    end
    if closestrow == nil then
        -- print("Can't find building of type " .. buildingtype .. " with stocklevel of at least " .. requiredstocklevel)
    else
        print("found villager at row/col: ".. closestvillager.position.row, closestvillager.position.col)
    end
    return closestrow, closestcol
end

local function addMoveAction(queue, startrow, startcol, stoprow, stopcol)
    -- uses jumper to add as many "move" actions as necessary to get to the waypoint

    -- get path to destination
    local cmap = convertToCollisionMap(MAP)

    -- print(inspect(cmap))

    -- need to 'blank' out the destination so jumper can find a path.
    cmap[stoprow][stopcol] = TILEWALKABLE

    -- jumper uses x and y which is really col and row
    local startx = startcol
    local starty = startrow
    local endx = stopcol
    local endy = stoprow
    local path = cf.findPath(cmap, TILEWALKABLE, startx, starty, endx, endy, false)        -- startx, starty, endx, endy
    if path ~= nil then
        for index, node in ipairs(path) do
            if index > 1 then   -- don't apply the first waypoint as it is too close to the agent
                local action = {}
                action.action = "move"
                action.log = "Moved"
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
    else
        -- can't find a path. Probably too many buildings.
        -- can happen when a getBlankTile() returns a tile that blocks a street
    end
end

function functions.buyStock(agent, stocktype, maxqty)
    -- returns the amount of stock purchased
    -- assumes agent is in the correct location
    local agentrow = agent.position.row
    local agentcol = agent.position.col
    local sellprice
    local purchaseamt = 0
    local stockavail = math.floor(MAP[agentrow][agentcol].entity.isTile.stockLevel)

    if MAP[agentrow][agentcol].entity.isTile.tileOwner == agent then
        -- agent is buying from own shop. Waive the purchase price
        -- doing this allows farms with 0 wealth to still buy and survive
        purchaseamt = math.min(maxqty, stockavail)
        MAP[agentrow][agentcol].entity.isTile.stockLevel = MAP[agentrow][agentcol].entity.isTile.stockLevel - purchaseamt
    else
        -- normal purchase transaction
        if MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson ~= nil then
            sellprice = MAP[agentrow][agentcol].entity.isTile.stockSellPrice
            local canafford = math.floor(agent.isPerson.wealth / sellprice)     -- rounds down
            purchaseamt = math.min(stockavail, canafford)
            purchaseamt = math.min(purchaseamt, maxqty)       -- limit purchase to the requested amount
            purchaseamt = math.floor(purchaseamt)
            local funds = purchaseamt * sellprice

            MAP[agentrow][agentcol].entity.isTile.stockLevel = MAP[agentrow][agentcol].entity.isTile.stockLevel - purchaseamt
            MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.wealth = MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.wealth + (funds * (1-GST_RATE))
            MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.taxesOwed = MAP[agentrow][agentcol].entity.isTile.tileOwner.isPerson.taxesOwed + (funds * (GST_RATE))
            agent.isPerson.wealth = agent.isPerson.wealth - funds
        else
            -- print(inspect(MAP[agentrow][agentcol].entity.isTile.tileOwner))
            -- print(agentrow, agentcol, stocktype, stockavail)
            -- error("Agent tried to buy stock from tile that has no owner.")
        end
    end
    return purchaseamt
end

local function assignWorkplace(agent)
    -- print("beta")
    -- create a workplace
    local workplacerow
    local workplacecol

    workplacerow, workplacecol = getBlankTile()
    assert(workplacerow ~= nil)
    agent:give("workplace", workplacerow, workplacecol)
    MAP[workplacerow][workplacecol].entity.isTile.improvementType = agent.occupation.value
    MAP[workplacerow][workplacecol].entity.isTile.stockType = agent.occupation.stockType
    MAP[workplacerow][workplacecol].entity.isTile.tileOwner = agent
    MAP[workplacerow][workplacecol].entity.isTile.decorationType = nil          -- clear any tree or other decoration

    if agent.occupation.stockType == enum.stockFruit then
        MAP[workplacerow][workplacecol].entity.isTile.stockSellPrice = FRUIT_SELL_PRICE
    elseif agent.occupation.stockType == enum.stockWood then
        MAP[workplacerow][workplacecol].entity.isTile.stockSellPrice = WOOD_SELL_PRICE
    elseif agent.occupation.stockType == enum.stockHealingHerbs then
        MAP[workplacerow][workplacecol].entity.isTile.stockSellPrice = HERB_SELL_PRICE
    end
    -- print("Owner assigned to " .. workplacerow, workplacecol)

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
        local destrow
        local destcol
        if agent:has("residence") then       --!
             -- rest at house
            destrow = agent.residence.row
            destcol = agent.residence.col
         else
            -- choose a random location near the well
            local random1 = love.math.random(-3, 3)
            local random2 = love.math.random(-3, 3)
            destrow = WELLS[1].row + random1
            destcol = WELLS[1].col + random2
            if destrow < 1 then destrow = 1 end
            if destrow > NUMBER_OF_ROWS then destrow = NUMBER_OF_ROWS end
            if destcol < 1 then destcol = 1 end
            if destcol > NUMBER_OF_COLS then destcol = NUMBER_OF_COLS end
        end

        -- add a 'move' action
        addMoveAction(queue, agentrow, agentcol, destrow, destcol)   -- will add as many 'move' actions as necessary

        -- add an 'idle' action
        action = {}
        action.action = "rest"

        local time1 = ((100 - agent.isPerson.stamina) / 2) + love.math.random(5, 30)      -- some random formula. Please tweak!
        local time2 = agent.isPerson.fullness * 0.8
        action.timeleft = math.min(time1, time2)    -- rest as much as you want (time1) but don't starve doing it (time2)
        action.log = "Rested"
        table.insert(queue, action)
    end
    if goal == enum.goalWork then
        -- time to earn a paycheck

        -- print("alpha:" .. tostring(agent.occupation.isConverter))
        if agent.occupation.isProducer then
            if not agent:has("workplace") then
                assignWorkplace(agent)
            end
            if agent:has("workplace") then
                workplacerow = agent.workplace.row
                workplacecol = agent.workplace.col

                -- print("charlie")
                -- move to workplace
                -- add a 'move' action
                addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
                -- do work
                local time1 = love.math.random(20, 45)      -- some random formula. Please tweak!
                local time2 = agent.isPerson.fullness
                local action = {}
                action.action = "work"
                action.timeleft = math.min(time1, time2)
                action.log = "Farmed"
                table.insert(queue, action)
            else
                error()     -- should never happen
            end
        end
        if agent.occupation.isConverter then
            -- time to convert things
            if agent.occupation.value == enum.jobCarpenter then
                -- local destrow, destcol = getClosestBuilding(enum.improvementHouse, 1, agentrow, agentcol)
                local destrow, destcol = getRandomBuilding(enum.improvementHouse, 1)

                if destrow ~= nil then
                    local owner = MAP[destrow][destcol].entity.isTile.tileOwner
                    local woodqty = MAP[destrow][destcol].entity.isTile.stockLevel
                    local househealth = owner.residence.health
                    local housemaxhealth = owner.residence.unbuiltMaxHealth

                    if (woodqty >= 1 and housemaxhealth < 100) or (househealth < housemaxhealth and owner.isPerson.wealth >= FRUIT_SELL_PRICE * 1.1) then
                        addMoveAction(queue, agentrow, agentcol, destrow, destcol)   -- will add as many 'move' actions as necessary

                        -- work out how long to work
                        local worktime = woodqty * CARPENTER_BUILD_RATE   -- seconds

                        local action = {}
                        action.action = "work"
                        action.timeleft = worktime
                        action.log = "Working on house"
                        table.insert(queue, action)
                        print("Maintaining house using at most ".. (worktime) .. " seconds and " .. woodqty .. " wood used.")
                    else
                        print("Found a house with health " .. househealth .. " and max health " .. housemaxhealth .. ". Nothing to do.")
                    end
                else
                    print("Carpenter has nothing to build")
                end
            end
            if agent.occupation.value == enum.jobTaxCollector then
                local destrow, destcol = getClosestPerson(1, agentrow, agentcol)
                if destrow ~= nil then
                    addMoveAction(queue, agentrow, agentcol, destrow, destcol)
                    local action = {}
                    action.action = "work"
                    action.timeleft = 5
                    action.log = "Collected taxes"
                    table.insert(queue, action)
                    print("Collecting taxes")
                end
            end
        end
        if agent.occupation.isService then
            if not agent:has("workplace") then
                assignWorkplace(agent)
            end
            if agent:has("workplace") then
                workplacerow = agent.workplace.row
                workplacecol = agent.workplace.col
                addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary

                local time1 = love.math.random(20, 45)
                local time2 = agent.isPerson.fullness * 0.75
                local action = {}
                action.action = "work"
                action.timeleft = math.min(time1,time2)
                action.log = "Provided welfare"
                table.insert(queue, action)
            end
        end
    end
    if goal == enum.goalEatFruit then
        local qtyneeded = 1
        local ownsFruitshop = false
        if agent:has("workplace") and agent.isPerson.wealth < (qtyneeded * FRUIT_SELL_PRICE) then
            if MAP[workplacerow][workplacecol].entity.isTile.stockLevel >= qtyneeded and
                MAP[workplacerow][workplacecol].entity.isTile.stockType == enum.stockFruit then
                    ownsFruitshop = true
            end
        end
        local shoprow, shopcol
        if ownsFruitshop then
            addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
        else
            -- not a farmer or rich or own farm has no stock
            shoprow, shopcol = getClosestBuilding(enum.improvementFarm, qtyneeded, agentrow, agentcol)
            if shoprow ~= nil then
                addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
            end
        end
        if ownsFruitshop or shoprow ~= nil then
            -- buy food
            action = {}
            action.action = "buy"
            action.stockType = enum.stockFruit
            action.purchaseAmount = qtyneeded
            action.log = "Bought some fruit"
            -- print("Added 'buy' goal")
            table.insert(queue, action)
            assert(action.stockType ~= nil)
            -- print("move and buy fruit action added")
        end
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
            action.log = "Bought some wood"
            table.insert(queue, action)
            -- print("move and buy wood action added")
            assert(action.stockType ~= nil)
        else
            -- print("No woodsman found")
        end
    end
    if goal == enum.goalHeal then
        local qtyneeded = (cf.round((100 - agent.isPerson.health) / 10)) + 1
        local ownsHealershop = false
        -- see if healer owns a healing shop
        if agent:has("workplace") and agent.isPerson.wealth <= 4 then
            if MAP[workplacerow][workplacecol].entity.isTile.stockLevel >= qtyneeded and
                MAP[workplacerow][workplacecol].entity.isTile.stockType == enum.stockHealingHerbs then
                    ownsHealershop = true
            end
        end

        if ownsHealershop then
            addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
            action = {}
            action.action = "buy"
            action.stockType = enum.stockHealingHerbs
            action.purchaseAmount = qtyneeded
            action.log = "Trying to buy " .. qtyneeded .. " healing herbs"
            table.insert(queue, action)
            assert(action.stockType ~= nil)
        else
            -- not a farmer or rich or own farm has no stock
            local shoprow, shopcol = getClosestBuilding(enum.improvementHealer, qtyneeded, agentrow, agentcol)
            if shoprow == nil then  -- if can't find the qty needed then find any shop with at least 1
                shoprow, shopcol = getClosestBuilding(enum.improvementHealer, 1, agentrow, agentcol)
            end
            if shoprow ~= nil then
                -- buy herbs
                addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary

                action = {}
                action.action = "buy"
                action.stockType = enum.stockHealingHerbs
                action.purchaseAmount = qtyneeded
                action.log = "Bought some healing herbs"
                table.insert(queue, action)
                assert(action.stockType ~= nil)
                -- print("move and buy herbs action added")
            end
        end
    end
    if goal == enum.goalStockHouse then
        -- establish, build, maintain or add to house
        -- bring wood to house so carpenter can make house

        if not agent:has("residence") then
            local houserow, housecol = getBlankTile()
            if houserow ~= nil then
                agent:give("residence", houserow, housecol)

                MAP[houserow][housecol].entity.isTile.improvementType = enum.improvementHouse
                MAP[houserow][housecol].entity.isTile.stockType = enum.stockHouse
                MAP[houserow][housecol].entity.isTile.stockLevel = 0
                MAP[houserow][housecol].entity.isTile.tileOwner = agent
                MAP[houserow][housecol].entity.isTile.decorationType = nil          -- clear tree or other decoration

                print("House established on tile " .. houserow, housecol)
            end
        end

        local houserow = agent.residence.row
        local housecol = agent.residence.col

        addMoveAction(queue, agentrow, agentcol, houserow, housecol)   -- will add as many 'move' actions as necessary
        local action = {}
        action.action = "stockhouse"
        action.timeleft = love.math.random(30, 60)
        action.log = "Brought wood to house"
        table.insert(queue, action)
    end
    if goal == enum.goalGetWelfare then
        if fun.getJobCount(enum.jobWelfareOfficer) > 0 then
            shoprow, shopcol = getClosestBuilding(enum.improvementWelfare, 1, agentrow, agentcol)
            if shoprow ~= nil then
                addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
                action = {}
                action.action = "buy"
                action.stockType = enum.stockWelfare
                action.purchaseAmount = 1
                action.log = "Seek welfare"
                -- print("Added 'buy' goal")
                table.insert(queue, action)
            end
        else
            -- print("Looking for welfare but can't find an officer")
        end
    end

    return queue
end

function functions.applyMovement(e, targetx, targety, velocity, dt)
    -- assumes an entity has a position and a target.
    -- updates the x,y for the entity (e)

    -- print("Target is " .. targetx, targety)

    local distancemovedthisstep = velocity * dt * TIME_SCALE
    -- print(distancemovedthisstep, velocity, velocity * dt)
    --if e.isPerson.stamina < 1 then print("Hi") end

    -- map row/col to x/y
    local currentx = (e.position.x)
    local currenty = (e.position.y)

    -- capture the current position as the previous position
    e.position.previousx = currentx
    e.position.previousy = currenty
    e.position.movementDelta = e.position.movementDelta + dt    -- track time between animation frames
    if e.position.movementDelta > 2 then
        -- reset the animation timer back to zero
        e.position.movementDelta = 0
    end

    -- get the vector that moves the entity closer to the destination
    local xvector = targetx - currentx  -- tiles
    local yvector = targety - currenty  -- tiles

    -- print(distancemovedthisstep, currentx,currenty,targetx,targety,xvector,yvector)

    local xscale = math.abs(xvector / distancemovedthisstep)
    local yscale = math.abs(yvector / distancemovedthisstep)
    local scale = math.max(xscale, yscale)

    --print(cf.round(scale), cf.round(xscale),cf.round(yscale))

    if scale > 1 then
        xvector = xvector / scale
        yvector = yvector / scale
    end

    --print(xvector, yvector)

    -- currentx = cf.round(currentx + xvector, 0)
    -- currenty = cf.round(currenty + yvector, 0)
    currentx = (currentx + xvector)
    currenty = (currenty + yvector)

    e.position.x = currentx
    e.position.y = currenty

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

function functions.addLog(person, txtitem)
    assert(txtitem ~= nil)
    local logitem = {}
    logitem.text = txtitem
    table.insert(person.isPerson.log, logitem)
end

function functions.playAudio(audionumber, isMusic, isSound)
    if isMusic and MUSIC_TOGGLE then
        AUDIO[audionumber]:play()
    end
    if isSound and SOUND_TOGGLE then
        AUDIO[audionumber]:play()
    end
    -- print("playing music/sound #" .. audionumber)

end

function functions.determineFacing(e)
    local prevx = (e.position.previousx)
    local prevy = (e.position.previousy)
    local currentx = (e.position.x)
    local currenty = (e.position.y)

    if prevx == currentx and prevy == currenty then
        -- not moving
        return "S"
    end
    if prevx == currentx and prevy > currenty then
        -- moving up
        return "N"
    end
    if prevx == currentx and prevy < currenty then
        -- moving down
        return "S"
    end
    if prevx > currentx and prevy == currenty then
        -- moving left
        return "W"
    end
    if prevx < currentx and prevy == currenty then
        -- moving right
        return "E"
    end
    if prevx < currentx and prevy > currenty then
        -- moving up and right
        return "NE"
    end
    if prevx < currentx and prevy < currenty then
        -- moving down and right
        return "SE"
    end
    if prevx > currentx and prevy < currenty then
        -- moving down and left
        return "SW"
    end
    if prevx > currentx and prevy > currenty then
        -- moving up and left
        return "NW"
    end
    error("Entity has unknown facing")
end

function functions.getImageNumberFromFacing(facing)
    if facing == "N" then return 21 end
    if facing == "NE" then return 26 end
    if facing == "E" then return 31 end
    if facing == "SE" then return 36 end
    if facing == "S" then return 1 end
    if facing == "SW" then return 6 end
    if facing == "W" then return 11 end
    if facing == "NW" then return 16 end
    error("Unknown facing")
end

function functions.getJobCount(jobID)
    local count = 0
    for i = 1, #VILLAGERS do
        if VILLAGERS[i]:has("occupation") then
            if VILLAGERS[i].occupation.value == jobID then
                count = count + 1
            end
        end
    end
    return count
end

function getAvgSellPrice(commodity)
    local totalspent
    local numberpurchased
    for k, villager in pairs(VILLAGERS) do
        totalspent = totalspent + villager.isPerson.stockBelief[commodity][3]
        numberpurchased = numberpurchased + villager.isPerson.stockBelief[commodity][4]
    end

    local retvalue = cf.round(totalspent / numberpurchased, 4)
    if love.math.random(1, 100) == 1 then
        print("Average price for stocktype " .. commodity .. " is " .. retvalue)
    end
    return retvalue
end

return functions
