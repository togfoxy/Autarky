file = {}

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

function file.saveGame()
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

function file.LoadGame()

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









return file
