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

    -- put this here for convenience
    for i = 1, NUMBER_OF_STOCK_TYPES do
        STOCK_HISTORY[i] = {}
    end
    STOCK_HISTORY[enum.stockFruit][1] = FRUIT_SELL_PRICE        -- ensure this history is not empty because logic breaks when it is
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
    IMAGES[enum.iconsSword] = love.graphics.newImage("assets/images/swordicon_64x64.png")


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

    SPRITES[enum.spriteMonster1] = love.graphics.newImage("assets/images/monster1_30x32.png")
    QUADS[enum.spriteMonster1] = cf.fromImageToQuads(SPRITES[enum.spriteMonster1], 30, 32)

    -- farmer
    SPRITES[enum.spriteFarmerMan] = love.graphics.newImage("assets/images/Farmer Male Walk.png")
    QUADS[enum.spriteFarmerMan] = cf.fromImageToQuads(SPRITES[enum.spriteFarmerMan], 15, 32)


    -- anim8
    SPRITES[enum.spriteRedWomanWaving] = love.graphics.newImage("assets/images/RedWomanWaving30x32v3.png")
    GRID[enum.spriteRedWomanWaving] = anim8.newGrid(30,32,150,32)       -- sprite width/height, sheet width/height
    FRAME[enum.spriteRedWomanWaving] = GRID[enum.spriteRedWomanWaving]:getFrames(1,1,2,1,3,1,4,1,5,1,4,1,3,1,2,1,1,1)  -- each pair is col/row within the quad/grid
    ANIMATION[enum.spriteRedWomanWaving] = anim8.newAnimation(FRAME[enum.spriteRedWomanWaving], 0.15)   -- frames and frame duration

    SPRITES[enum.spriteRedWomanFlute] = love.graphics.newImage("assets/images/RedWomanFlute30x32v3.png")
    GRID[enum.spriteRedWomanFlute] = anim8.newGrid(30,32,150,32)       -- sprite width/height, sheet width/height
    FRAME[enum.spriteRedWomanFlute] = GRID[enum.spriteRedWomanFlute]:getFrames(1,1,2,1,3,1,4,1,5,1)  -- each pair is col/row within the quad/grid
    ANIMATION[enum.spriteRedWomanFlute] = anim8.newAnimation(FRAME[enum.spriteRedWomanFlute], 0.30)   -- frames and frame duration
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

    AUDIO[enum.audioWarning] = love.audio.newSource("assets/audio/507906__m-cel__warning-sound.ogg", "static")


    AUDIO[enum.audioWork]:setVolume(0.2)
    AUDIO[enum.musicMedievalFiesta]:setVolume(0.2)
    AUDIO[enum.musicOvertheHills]:setVolume(0.2)
    AUDIO[enum.audioNewVillager]:setVolume(0.2)
    AUDIO[enum.musicCityofMagic]:setVolume(0.2)
    AUDIO[enum.musicSpring]:setVolume(0.1)
    AUDIO[enum.audioEat]:setVolume(0.2)
    AUDIO[enum.musicBirdsinForest]:setVolume(1)
    AUDIO[enum.audioSawWood]:setVolume(0.2)
    AUDIO[enum.audioBandage]:setVolume(0.2)
    AUDIO[enum.audioWarning]:setVolume(0.2)

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
            if count == 10000 then
                print("Can't find path to new tile. Trying to find a new tile.")
            end
        end
    until tilevalid or count > 10000

    if count > 10000 then
        print("Can't find a blank tile. Giving up after 1000 tries." .. count)
        return nil, nil
    else
        return row, col
    end
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
        -- print("found villager at row/col: ".. closestvillager.position.row, closestvillager.position.col)
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

function functions.getClosestBuilding(buildingtype, requiredstocklevel, startrow, startcol)
    -- returns the closest building of required type (row, col)
    -- ensure the return value is checked for nil - meaning - building not found
    local closestvalue = -1
    local closestrow, closestcol

    if startrow ~= nil and startcol ~= nil then
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
    else
        return nil, nil
    end
end

local function assignWorkplace(agent)
    -- print("beta")
    -- create a workplace
    local agentrow = agent.position.row
    local agentcol = agent.position.col
    local workplacerow
    local workplacecol

    if agent.occupation.value == enum.jobWelfareOfficer then
        workplacerow, workplacecol = fun.getClosestBuilding(enum.improvementWelfare, 0, agentrow, agentcol)      -- row/col is actually not used
        if workplacerow == nil then
            -- no building exists yet - create one
            workplacerow, workplacecol = getBlankTile()
        end
    else
        workplacerow, workplacecol = getBlankTile()
    end

    assert(workplacerow ~= nil)     --! what happens when all tiles are full?
    agent:give("workplace", workplacerow, workplacecol)
    MAP[workplacerow][workplacecol].entity.isTile.improvementType = agent.occupation.value
    MAP[workplacerow][workplacecol].entity.isTile.stockType = agent.occupation.stockType
    MAP[workplacerow][workplacecol].entity.isTile.tileOwner = agent
    MAP[workplacerow][workplacecol].entity.isTile.decorationType = nil          -- clear any tree or other decoration
end

function functions.createActions(goal, agent)
    -- takes the goal provided by the behavior tree and returns a complex set of actions to achieve that goal
    -- returns a table of actions

    --! the 'goal' parameter is redundant as it is already in agent.isPerson.queue

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

        local time1 = ((150 - agent.isPerson.stamina) * 0.75)      -- some random formula. Please tweak!
        local time2 = math.max(agent.isPerson.fullness, 0) * 0.75   -- fullness might be a negative value
        if time2 <= 10 then time2 = 10 end
        action.timeleft = math.min(time1, time2)    -- rest as much as you want (time1) but don't starve doing it (time2)
        action.log = "Rested"
        table.insert(queue, action)

        if agent.isPerson.stockInv[enum.stockWood] > 0 then
            fun.createActions(enum.goalStockHouse, agent)
        end
    end
    if goal == enum.goalWork then
        -- time to earn a paycheck
        if agent.occupation.value == enum.jobSwordsman then
            -- pick a random corner to move to and then move to it
            local corner = love.math.random(1,4)    -- four corners
            local coloffset = love.math.random(-2, 2)
            local rowoffset = love.math.random(-2, 2)
            local coltarget, rowtarget
            if corner == 1 then
                coltarget = 3 + coloffset
                rowtarget = 3 + rowoffset
            elseif corner == 2 then
                coltarget = NUMBER_OF_COLS - 3 + coloffset
                rowtarget = 3 + rowoffset
            elseif corner == 3 then
                coltarget = NUMBER_OF_COLS - 3 + coloffset
                rowtarget = NUMBER_OF_ROWS - 3 + rowoffset
            elseif corner == 4 then
                coltarget = 3 + coloffset
                rowtarget = NUMBER_OF_ROWS - 3 + rowoffset
            else
                error()
            end
            addMoveAction(queue, agentrow, agentcol, rowtarget, coltarget)   -- will add as many 'move' actions as necessary
            action = {}
            action.action = "idle"      -- idle is same as rest but idle means "nothing else to do" but rest was chosen from btree
            action.timeleft = love.math.random(5, 10)
            action.log = "Guarding"
            table.insert(agent.isPerson.queue, action)
        else
            if agent.occupation.isProducer then
                if not agent:has("workplace") then
                    assignWorkplace(agent)
                end
                if agent:has("workplace") then
                    workplacerow = agent.workplace.row
                    workplacecol = agent.workplace.col
                    -- move to workplace
                    -- add a 'move' action
                    addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
                    -- do work
                    local time1 = agent.isPerson.stamina * 0.4      --! make this more scientific by factoring stamina rate
                    local time2 = math.max(agent.isPerson.fullness, 0) * 0.4    -- fullness migh tbe a negative value
                    local time3 = love.math.random(20, 35)
                    local action = {}
                    action.action = "work"
                    action.timeleft = math.min(time1, time2, time3)
                    action.log = "Farmed"
                    table.insert(queue, action)
                else
                    error()     -- should never happen
                end
            end
            if agent.occupation.isConverter then
                -- time to convert things
                if agent.occupation.value == enum.jobCarpenter then
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
                            -- print("Found a house with health " .. househealth .. " and max health " .. housemaxhealth .. ". Nothing to do.")
                        end
                    else
                        -- print("Carpenter has nothing to build")
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
                    local time2 = math.max(agent.isPerson.fullness, 0) * 0.75   -- fullness migh tbe a negative value
                    local action = {}
                    action.action = "work"
                    action.timeleft = math.min(time1,time2)
                    action.log = "Provided welfare"
                    table.insert(queue, action)
                end
            end
        end
    end
    if goal == enum.goalEatFruit then
        local qtyneeded = 1
        local ownsFruitshop = false
        if agent:has("workplace") and agent.isPerson.wealth < (qtyneeded * FRUIT_SELL_PRICE * 1.5) then -- the 1.5 provides a generous buffer
            if MAP[workplacerow][workplacecol].entity.isTile.stockLevel >= qtyneeded and
                MAP[workplacerow][workplacecol].entity.isTile.stockType == enum.stockFruit then
                    ownsFruitshop = true
            end
        end
        local shoprow, shopcol
        if ownsFruitshop then
            addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
            -- buy food
            action = {}
            action.action = "buy"
            action.stockType = enum.stockFruit
            action.purchaseAmount = qtyneeded
            action.log = "Bought some fruit"
            -- print("Added 'buy' goal")
            table.insert(queue, action)
        else
            -- not a farmer or rich or own farm has no stock
            shoprow, shopcol = fun.getClosestBuilding(enum.improvementFarm, qtyneeded, agentrow, agentcol)
            if shoprow ~= nil then
                local dist = cf.GetDistance(agentrow, agentcol, shoprow, shopcol)   -- tiles
                if dist > 8 then
                    -- determine half way
                    -- print("moving half way in search of fruit")
                    local newrow, newcol
                    newrow = cf.round((agentrow + shoprow) / 2)
                    newcol = cf.round((agentcol + shopcol) / 2)
                    -- move to half way
                    addMoveAction(queue, agentrow, agentcol, newrow, newcol)   -- will add as many 'move' actions as necessary
                    action = {}
                    action.action = "goalBuyFruit"
                    action.stockType = enum.stockFruit
                    action.purchaseAmount = qtyneeded
                    action.log = "Looking for some fruit"
                    table.insert(queue, action)
                else
                    addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
                    -- buy food
                    action = {}
                    action.action = "buy"
                    action.stockType = enum.stockFruit
                    action.purchaseAmount = qtyneeded
                    action.log = "Bought some fruit"
                    -- print("Added 'buy' goal")
                    table.insert(queue, action)
                end
            end
        end
    end
    if goal == enum.goalBuyWood then
        -- print("Goal = buy wood")
        local qtyneeded = 1
        local shoprow, shopcol = fun.getClosestBuilding(enum.improvementWoodsman, qtyneeded, agentrow, agentcol)
        if shoprow ~= nil then
            local dist = cf.GetDistance(agentrow, agentcol, shoprow, shopcol)   -- tiles
            if dist > 6 then
                -- determine half way
                -- print("moving half way in search of wood")
                local newx, newy
                newrow = cf.round((agentrow + shoprow) / 2)
                newcol = cf.round((agentcol + shopcol) / 2)
                -- move to half way
                addMoveAction(queue, agentrow, agentcol, newrow, newcol)   -- will add as many 'move' actions as necessary
                action = {}
                action.action = "goalBuyWood"
                action.stockType = enum.stockWood
                action.purchaseAmount = qtyneeded
                action.log = "Looking for some wood"
                table.insert(queue, action)

            else
                addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
                -- buy wood
                action = {}
                action.action = "buy"
                action.stockType = enum.stockWood
                action.purchaseAmount = qtyneeded
                action.log = "Bought some wood"
                table.insert(queue, action)
            end
        else
            -- print("No woodsman found")
        end
    end
    if goal == enum.goalHeal then
        local qtyneeded = 100 - agent.isPerson.health + 1
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
            local shoprow, shopcol = fun.getClosestBuilding(enum.improvementHealer, qtyneeded, agentrow, agentcol)
            if shoprow == nil then  -- if can't find the qty needed then find any shop with at least 1
                shoprow, shopcol = fun.getClosestBuilding(enum.improvementHealer, 1, agentrow, agentcol)
            end
            if shoprow ~= nil then
                -- buy herbs
                local dist = cf.GetDistance(agentrow, agentcol, shoprow, shopcol)   -- tiles
                if dist > 6 then
                    -- determine half way
                    -- print("moving half way in search of herbs")
                    local newx, newy
                    newrow = cf.round((agentrow + shoprow) / 2)
                    newcol = cf.round((agentcol + shopcol) / 2)
                    -- move to half way
                    addMoveAction(queue, agentrow, agentcol, newrow, newcol)   -- will add as many 'move' actions as necessary
                    action = {}
                    action.action = "goalBuyHerbs"
                    action.stockType = enum.stockHealingHerbs
                    action.purchaseAmount = qtyneeded
                    action.log = "Looking for some herbs"
                    table.insert(queue, action)
                else
                    addMoveAction(queue, agentrow, agentcol, shoprow, shopcol)   -- will add as many 'move' actions as necessary
                    action = {}
                    action.action = "buy"
                    action.stockType = enum.stockHealingHerbs
                    action.purchaseAmount = qtyneeded
                    action.log = "Bought some healing herbs"
                    table.insert(queue, action)
                end

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

                -- print("House established on tile " .. houserow, housecol)
            end
        end

        local houserow = agent.residence.row
        local housecol = agent.residence.col

        addMoveAction(queue, agentrow, agentcol, houserow, housecol)   -- will add as many 'move' actions as necessary
        local time1 = love.math.random(10, 30)
        local time2 = math.max(agent.isPerson.fullness, 0) * 0.5    -- fullness migh tbe a negative value
        local action = {}
        action.action = "stockhouse"
        action.timeleft = math.min(time1, time2)
        action.log = "Brought wood to house"
        table.insert(queue, action)
    end
    if goal == enum.goalGetWelfare then
        if fun.getJobCount(enum.jobWelfareOfficer) > 0 then
            shoprow, shopcol = fun.getClosestBuilding(enum.improvementWelfare, 1, agentrow, agentcol)
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
    if goal == enum.goalGotoWorkplace then      -- only important if occupation == enum.jobFarmer
        if not agent:has("workplace") then
            assignWorkplace(agent)
        end
        if agent:has("workplace") then
            workplacerow = agent.workplace.row
            workplacecol = agent.workplace.col
            -- move to workplace
            -- add a 'move' action
            addMoveAction(queue, agentrow, agentcol, workplacerow, workplacecol)   -- will add as many 'move' actions as necessary
            -- do work
            local action = {}
            action.action = "work"
            action.timeleft = 1
            action.log = "Going to work"
            table.insert(queue, action)
        else
            error()     -- should never happen
        end
    end
    return queue
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

function functions.getAvgSellPrice(commodity)
    local totalspent = 0
    local numberpurchased = 0
    for k, villager in pairs(VILLAGERS) do
        totalspent = totalspent + villager.isPerson.stockBelief[commodity][3]
        numberpurchased = numberpurchased + villager.isPerson.stockBelief[commodity][4]
    end

    local retvalue
    if numberpurchased > 0 then
        retvalue = cf.round(totalspent / numberpurchased, 2)
        if love.math.random(1, 100) == 1 then
            -- print("Average price for stocktype " .. commodity .. " is " .. retvalue)
        end
    else
        if commodity == enum.stockFruit then
            retvalue = FRUIT_SELL_PRICE
        elseif commodity == enum.stockWood then
            retvalue = WOOD_SELL_PRICE
        elseif commodity == enum.stockHealingHerbs then
            retvalue = HERB_SELL_PRICE
        else
            print("error: can't get average price for stocktype :" .. commodity)
            -- error()
        end
    end
    return retvalue
end

local function prepTiles()
    -- create a temporory table to hold tiles for saving
    local tilestable = {}
    local item = {}

    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            item = {}
            e = MAP[row][col].entity
            -- do the isTile
            item.row = row
            item.col = col
            item.uid = e.isTile.uid
            item.tileType = e.isTile.tileType
            item.tileHeight = e.isTile.tileHeight
            item.improvementType = e.isTile.improvementType
            item.decorationType = e.isTile.decorationType
            item.stockType = e.isTile.stockType
            item.stockLevel = e.isTile.stockLevel
            item.mudLevel = e.isTile.mudLevel
            item.timeToBuild = e.isTile.timeToBuild

            if e.isTile.tileOwner ~= nil then
                if e.isTile.tileOwner.uid ~= nil then
                    item.tileOwnerUID = e.isTile.tileOwner.uid.value
                    -- print("Saving tile that has an owner with UID " .. item.tileOwnerUID)
                end
            end
            table.insert(tilestable, item)
            -- print(inspect(item))
        end
    end
    -- print(inspect(tilestable))
    return tilestable
end

local function prepPerson()
    local persontable = {}
    local item = {}

    for k, v in pairs(VILLAGERS) do
        item = {}
        --! item.queue = v.isPerson.queue
        item.uid = v.uid.value
        item.gender = v.isPerson.gender
        item.health = v.isPerson.health
        item.stamina = v.isPerson.stamina
        item.fullness = v.isPerson.fullness
        item.stockinv = v.isPerson.stockInv
        item.stockbelief = v.isPerson.stockBelief
        item.wealth = v.isPerson.wealth
        item.log = v.isPerson.log
        item.taxesowed = v.isPerson.taxesOwed
        item.positionrow = v.position.row
        item.positioncol = v.position.col
        item.positionx = v.position.x
        item.positiony = v.position.y
        item.positionpreviousx = v.position.previousx
        item.positionpreviousy = v.position.previousy
        item.positionmovementdelta = v.position.movementDelta
        if v:has("occupation") then
            item.occupation = v.occupation.value
            item.occupationstocktype = v.occupation.stockType
            item.occupationisproducer = v.occupation.isProducer
            item.occupationisservice = v.occupation.isService
            item.occupationisconverter = v.occupation.isConverter
        end
        if v:has("workplace") then
            item.workplacerow = v.workplace.row
            item.workplacecol = v.workplace.col
            item.workplacex = v.workplace.x
            item.workplacey = v.workplace.y
        end
        if v:has("residence") then
            item.residencerow = v.residence.row
            item.residencecol = v.residence.col
            item.residencex = v.residence.x
            item.residencey = v.residence.y
            item.residencehealth = v.residence.health
            item.residenceunbuiltmaxhealth = v.residence.unbuiltMaxHealth
        end
        table.insert(persontable, item)
    end
    -- print(inspect(persontable))
    return persontable
end

local function prepGlobals()
    local globalTable = {}
    local item = {}
    item.treasury = VILLAGE_WEALTH
    item.gst = GST_RATE
    item.music = MUSIC_TOGGLE
    item.sound = SOUND_TOGGLE
    table.insert(globalTable, item)
    return globalTable
end

local function loadTile(tilestable)

    for i = 1, #tilestable do
        local row = tilestable[i].row
        local col = tilestable[i].col
        MAP[row][col].row = row
        MAP[row][col].col = col

        local tiles = concord.entity(WORLD)
        :give("drawable")
        :give("position", tilestable[i].row, tilestable[i].col)
        :give("uid")
        tiles:give("isTile", tilestable[i].tileType, tilestable[i].height)

        tiles.uid.value = tilestable[i].uid
        tiles.isTile.tileType = tilestable[i].tileType
        tiles.isTile.tileHeight = tilestable[i].tileHeight
        tiles.isTile.improvementType = tilestable[i].improvementType
        tiles.isTile.decorationType = tilestable[i].decorationType
        tiles.isTile.stockType = tilestable[i].stockType
        tiles.isTile.stockLevel = tilestable[i].stockLevel
        tiles.isTile.mudLevel = tilestable[i].mudLevel
        tiles.isTile.timeToBuild = tilestable[i].timeToBuild

        if tilestable[i].tileOwnerUID ~= nil then
            -- find the villager with this UID
            for k, vill in pairs(VILLAGERS) do
                if vill.uid.value == tilestable[i].tileOwnerUID then
                    tiles.isTile.tileOwner = vill
                end
            end
        end

        if tilestable[i].improvementType == enum.improvementWell then
            local nextindex = #WELLS + 1
            WELLS[nextindex] = {}
            WELLS[nextindex].row = row
            WELLS[nextindex].col = col
        end

        MAP[row][col].entity = tiles
    end
end

local function loadPerson(persontable)

    for i = 1, #persontable do
        local v = concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("uid")
        :give("isPerson")

        -- put up top and let it get overwritten
        for i = 1, NUMBER_OF_STOCK_TYPES do
            v.isPerson.stockBelief[i] = {}
            v.isPerson.stockBelief[i][1] = 0       -- lowest belief for stock item 'i'
            v.isPerson.stockBelief[i][2] = 0       -- highest belief
            v.isPerson.stockBelief[i][3] = 0       -- total financial amount transacted    -- finanical amount / count = average for item 'i'
            v.isPerson.stockBelief[i][4] = 0       -- total count transacted
        end

        --! v.isPerson.queue = {}

        v.uid.value = persontable[i].uid
        --! v.isPerson.queue = persontable[i].queue
        v.isPerson.gender = persontable[i].gender
        v.isPerson.health = persontable[i].health
        v.isPerson.stamina = persontable[i].stamina
        v.isPerson.fullness = persontable[i].fullness
        v.isPerson.stockInv = persontable[i].stockinv
        v.isPerson.stockBelief = persontable[i].stockbelief
        v.isPerson.wealth = persontable[i].wealth
        v.isPerson.log = persontable[i].log
        v.isPerson.taxesOwed = persontable[i].taxesowed
        v.position.row = persontable[i].positionrow
        v.position.col = persontable[i].positioncol
        v.position.x = cf.round(persontable[i].positionx)
        v.position.y = cf.round(persontable[i].positiony)
        v.position.previousx = persontable[i].positionpreviousx
        v.position.previousy = persontable[i].positionpreviousy
        v.position.movementDelta = persontable[i].positionmovementdelta

        if persontable[i].occupation ~= nil then
            v:give("occupation",persontable[i].occupation, persontable[i].occupationstocktype, persontable[i].occupationisproducer, persontable[i].occupationisservice, persontable[i].occupationisconverter)
        end
        if persontable[i].workplacerow ~= nil then
            v:give("workplace", persontable[i].workplacerow, persontable[i].workplacecol)
            v.workplace.x = persontable[i].workplacex
            v.workplace.y = persontable[i].workplacey
        end
        if persontable[i].residencerow ~= nil then
            v:give("residence", persontable[i].residencerow, persontable[i].residencecol)
            v.residence.x = persontable[i].residencex
            v.residence.y = persontable[i].residencey
            v.residence.health = persontable[i].residencehealth
            v.residence.unbuiltMaxHealth = persontable[i].residenceunbuiltmaxhealth
        end
        table.insert(VILLAGERS, v)

        assert(v.isPerson.stockBelief[enum.stockFruit][2] ~= nil)
        assert(v.isPerson.stockBelief[enum.stockWood][2] ~= nil)
        assert(v.isPerson.stockBelief[enum.stockHealingHerbs][2] ~= nil)
    end
end

function functions.saveGame()
    local savefile
    local contents
    local success, message
    local savedir = love.filesystem.getSource()

    local isTileTable = prepTiles()
    savefile = savedir .. "/savedata/" .. "tiles.dat"
    serialisedString = bitser.dumps(isTileTable)
    success, message = nativefs.write(savefile, serialisedString)

    local isPersonTable = prepPerson()
    savefile = savedir .. "/savedata/" .. "person.dat"
    serialisedString = bitser.dumps(isPersonTable)
    success, message = nativefs.write(savefile, serialisedString)

    savefile = savedir .. "/savedata/" .. "stockhistory.dat"
    serialisedString = bitser.dumps(STOCK_HISTORY)
    success, message = nativefs.write(savefile, serialisedString)

    local globalsTable = prepGlobals()
    savefile = savedir .. "/savedata/" .. "globals.dat"
    serialisedString = bitser.dumps(globalsTable)
    success, message = nativefs.write(savefile, serialisedString)

    lovelyToasts.show("Game saved",5)
end

function functions.LoadGame()

    -- destroy all the villager entities
    for i = #VILLAGERS, 1, -1 do
        local villager = VILLAGERS[i]       -- get the entity
        villager:destroy()
        table.remove(VILLAGERS, i)
    end

    VILLAGERS = {}

    for col = 1, NUMBER_OF_COLS do
        for row = 1,NUMBER_OF_ROWS do
            local e = MAP[row][col].entity
            e:destroy()
            MAP[row][col] = nil
        end
    end

    MAP = {}        -- Note: need to destroy all tiles from world before doing this
    WELLS = {}

    fun.initialiseMap()     -- initialises 2d map with nils

    DRAWQUEUE = {}      -- erase this and start fresh. Holds bubbles
    STOCK_HISTORY = {}

    local tilestable
    local persontable
    local globalsTable

    local savedir = love.filesystem.getSource()
    love.filesystem.setIdentity(savedir)

    local savefile
    local contents
	local size
	local error = false

	savefile = savedir .. "/savedata/" .. "person.dat"
	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    persontable = bitser.loads(contents)
        loadPerson(persontable)
	else
		error = true
	end

	savefile = savedir .. "/savedata/" .. "tiles.dat"
	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    tilestable = bitser.loads(contents)
        loadTile(tilestable)
	else
		error = true
	end

	savefile = savedir .. "/savedata/" .. "stockhistory.dat"
	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    STOCK_HISTORY = bitser.loads(contents)
	else
		error = true
	end

    savefile = savedir .. "/savedata/" .. "globals.dat"
	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    globalsTable = bitser.loads(contents)

        VILLAGE_WEALTH = globalsTable[1].treasury
        GST_RATE = globalsTable[1].gst
        MUSIC_TOGGLE = globalsTable[1].music
        SOUND_TOGGLE = globalsTable[1].sound
	else
		error = true
	end

    lovelyToasts.show("Game continued",5)
end

function functions.addGameLog(txt)
    table.insert(GAME_LOG, txt)
end

local function getBlankBorderTile()

    local row, col
    local count = 0

    repeat
        count = count + 1
        local tilevalid = true
        local side = love.math.random(1, 4)
        -- get a row/col for that side
        if side == 1 then -- top border
            row = 1
            col = love.math.random(1, NUMBER_OF_COLS)
        elseif side == 2 then   -- right border
            col = NUMBER_OF_COLS
            row = love.math.random(1, NUMBER_OF_ROWS)
        elseif side == 3 then   -- bottom border
            row = NUMBER_OF_ROWS
            col = love.math.random(1, NUMBER_OF_COLS)
        elseif side == 4 then   -- left border
            col = 1
            row = love.math.random(1, NUMBER_OF_ROWS)
        else
            error()
        end
        if MAP[row][col].entity.isTile.improvementType ~= nil then
            tilevalid = false
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
            if count == 10000 then
                print("Can't find path to new tile. Trying to find a new tile.")
            end
        end
    until tilevalid or count > 10000

    if count > 10000 then
        print("Can't find a blank tile for monster. Giving up after 1000 tries." .. count)
        return nil, nil
    else
        return row, col
    end
end

function functions.spawnMonster()
    --! get an empty border tile
    local row, col = getBlankBorderTile()
    -- spawn monster
    local monster = concord.entity(WORLD)
    :give("drawable")
    :give("position", row, col)
    :give("uid")
    :give("isMonster")
    table.insert(MONSTERS, monster)
    print("Monster spawned")

    --! identify target
    --! issue 'move' command

end

return functions
