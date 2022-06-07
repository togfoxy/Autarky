ecsfunctions = {}

function ecsfunctions.init()

    -- create the world
    WORLD = concord.world()

    local compmodule = require 'comp'

    -- define components
    compmodule.init()

    -- declare systems
    systemDraw = concord.system({
        pool = {"position", "drawable"}
    })
    -- define same systems
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        for _, e in ipairs(self.pool) do
            if e.isTile then
                local row, col = e.position.row, e.position.col
                -- draw tile image
                local img
                local imgnumber

                -- NOTE: This is NOT the improvement
                local img = IMAGES[e.isTile.tileType]
                local drawx, drawy = LEFT_MARGIN + e.position.x, TOP_MARGIN + e.position.y
                local imagewidth = img:getWidth()
                local imageheight = img:getHeight()
                local drawscalex = (TILE_SIZE / imagewidth)
                local drawscaley = (TILE_SIZE / imageheight)
                local offsetx = imagewidth / 2
                local offsety = imageheight / 2

                -- draw the tile
				love.graphics.setColor(1,1,1,1)
                love.graphics.draw(img, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)

                -- draw the mud
                local mudalpha = cf.round((e.isTile.mudLevel / 255),3)
                love.graphics.setColor(1,1,1,mudalpha)
                love.graphics.draw(IMAGES[enum.imagesMud], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)

                -- draw the random decoration - if there is one
                -- if MAP[row][col].decoration ~= nil then
                if e.isTile.decorationType ~= nil then
                    local imagenum = e.isTile.decorationType
                    local sprite = SPRITES[enum.spriteRandomTree]
                    local quad = QUADS[enum.spriteRandomTree][imagenum]
                    local imagewidth, imageheight = 50,50       --! needs to line up with the size in LOADIMAGES()
                    local drawscalex = (TILE_SIZE / imagewidth)
                    local drawscaley = (TILE_SIZE / imageheight)

                    local offsetx = imagewidth / 2
                    local offsety = imageheight / 2

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.draw(sprite, quad, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                end

                -- draw contour lines

                -- check if top neighbour is different to current cell
                if row > 1 then
                    if MAP[row-1][col].height ~= MAP[row][col].height then
                        -- draw line
                        local x1, y1 = fun.getXYfromRowCol(row, col)
                        local x2, y2 = x1 + TILE_SIZE, y1
                        local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
                        x1 = x1 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y1 = y1 - (TILE_SIZE / 2) + TOP_MARGIN
                        x2 = x2 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y2 = y2 - (TILE_SIZE / 2) + TOP_MARGIN
                        -- love.graphics.setColor(1,1,1,alpha)
                        -- love.graphics.line(x1, y1, x2, y2)
                    end
                end
                -- left side
                if col > 1 then
                    if MAP[row][col-1].height ~= MAP[row][col].height then
                        -- draw line
                        local x1, y1 = fun.getXYfromRowCol(row, col)
                        local x2 = x1
                        local y2 = y1 + TILE_SIZE
                        local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
                        x1 = x1 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y1 = y1 - (TILE_SIZE / 2) + TOP_MARGIN
                        x2 = x2 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y2 = y2 - (TILE_SIZE / 2) + TOP_MARGIN
                        -- love.graphics.setColor(1,1,1,alpha)
                        -- love.graphics.line(x1, y1, x2, y2)
                    end
                end

                local imptype
                if MAP[row][col].entity.isTile.improvementType ~= nil then imptype = e.isTile.improvementType end

                -- draw the improvement
                local sprite, quad
                if imptype ~= nil then
                    local imagenumber = imptype
                    local imagewidth, imageheight

                    if imptype == enum.improvementFarm then
                        -- determine which image from spritesheet
                        imagenum = cf.round(e.isTile.stockLevel * 4) + 1
                        if imagenum > 5 then imagenum = 5 end
                        sprite = SPRITES[enum.spriteAppleTree]
                        quad = QUADS[enum.spriteAppleTree][imagenum]
                        imagewidth, imageheight = 37,50     --! need to not hardcode this
                    end
                    if imptype == enum.improvementWoodsman then
                        -- determine which image from spritesheet
                        imagenum = math.floor(e.isTile.stockLevel) + 1
                        if imagenum > 6 then imagenum = 6 end
                        sprite = SPRITES[enum.spriteWoodPile]
                        quad = QUADS[enum.spriteWoodPile][imagenum]
                        imagewidth, imageheight = 50,50     --! need to not hardcode this
                    end
                    if imptype == enum.improvementHouse then
                        local househealth = MAP[row][col].entity.isTile.tileOwner.residence.health
                        imagenum = math.floor(househealth / 25) + 1
                        if imagenum > 5 then imagenum = 5 end
                        sprite = SPRITES[enum.spriteHouse]
                        quad = QUADS[enum.spriteHouse][imagenum]
                        imagewidth, imageheight = 50,104     --! need to not hardcode this
                    end

                    if imagewidth == nil then
                        imagewidth = IMAGES[imagenumber]:getWidth()
                        imageheight = IMAGES[imagenumber]:getHeight()
                    end

                    local drawscalex = (TILE_SIZE / imagewidth)
                    local drawscaley = (TILE_SIZE / imageheight)

                    local offsetx = imagewidth / 2
                    local offsety = imageheight / 2

                    love.graphics.setColor(1,1,1,1)

                    if imptype == enum.improvementFarm or imptype == enum.improvementWoodsman or imptype == enum.improvementHouse then
                        love.graphics.draw(sprite, quad, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                    else
                        love.graphics.draw(IMAGES[imagenumber], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                    end

                    -- health bar
                    if imptype == enum.improvementHouse then
                        -- draw health bar after the house so that it sits on top of the house
                        -- draw the health of the improvement as a bar

                        -- draw maxhealth first
                        local maxhealth = MAP[row][col].entity.isTile.tileOwner.residence.unbuiltMaxHealth
                        local barheight = TILE_SIZE * (maxhealth / 100)       -- can exceed 100!
                        local drawx2 = drawx + (TILE_SIZE / 2)      -- The '5' avoids blocking by the house
                        local drawy2 = drawy + (TILE_SIZE / 2)
                        local drawy3 = drawy2 - barheight
                        love.graphics.setColor(1,0,0,1)
                        love.graphics.line(drawx2, drawy2, drawx2, drawy3)

                        -- real house health
                        local househealth = MAP[row][col].entity.isTile.tileOwner.residence.health
                        local barheight = TILE_SIZE * (househealth / 100)       -- house health can exceed 100!
                        local drawx2 = drawx + (TILE_SIZE / 2)      -- The '5' avoids blocking by the house
                        local drawy2 = drawy + (TILE_SIZE / 2)
                        local drawy3 = drawy2 - barheight
                        love.graphics.setColor(0,1,0,1)
                        love.graphics.line(drawx2, drawy2, drawx2, drawy3)
                    end
                end

                -- draw stocklevels for each tile
                if MAP[row][col].entity.isTile.stockLevel > 0 then
                    love.graphics.setColor(0/255,0/255,115/255,1)
                    love.graphics.print(cf.round(MAP[row][col].entity.isTile.stockLevel,1), drawx, drawy, 0, 1, 1, 20, -10)
                end

                -- debugging
                -- draw mud levels for each tile
                -- if MAP[row][col].entity.isTile.mudLevel > 0 then
                --     love.graphics.setColor(1,1,1,1)
                --     love.graphics.print(cf.round(MAP[row][col].entity.isTile.mudLevel,4), drawx, drawy, 0, 1, 1, 20, 20)
                -- end
            end

            if e.isPerson then
                if e.isSelected then
                    love.graphics.setColor(0,1,0,1)
                else
                    love.graphics.setColor(1,1,1,1)
                end

                local drawwidth = PERSON_DRAW_WIDTH
                local drawx, drawy = LEFT_MARGIN + e.position.x, TOP_MARGIN + e.position.y

                -- draw occupation icon
                if e:has("occupation") then
                    local imgnumber = e.occupation.value + 30       -- there is an offset to avoid clashes. See enum.lua
                    love.graphics.draw(IMAGES[imgnumber], drawx, drawy, 0, 0.25, 0.25, 0, 130)
                end

                -- draw if sleeping
                local imgrotation = 0
                if e.isPerson.queue[1] ~= nil then
                    if e.isPerson.queue[1].action == "rest" then
                        imgrotation = math.rad(90)
                    end
                end

                -- draw the villager
                local facing = fun.determineFacing(e)      -- gets the cardinal facing of the entity. Is a string
                local imagenum = fun.getImageNumberFromFacing(facing)
                local imagenumoffset = cf.round(e.position.movementDelta / 0.5)
                imagenum = imagenum + imagenumoffset

                local sprite, quad
                if e.isPerson.gender == enum.genderMale and e:has("occupation") then
                    if e.occupation.value == enum.jobFarmer then
                        sprite = SPRITES[enum.spriteFarmerMan]
                        quad = QUADS[enum.spriteFarmerMan][imagenum]
                    else
                        sprite = SPRITES[enum.spriteBlueMan]
                        quad = QUADS[enum.spriteBlueMan][imagenum]
                    end
                end
                if e.isPerson.gender == enum.genderFemale and e:has("occupation") then
                    sprite = SPRITES[enum.spriteBlueWoman]
                    quad = QUADS[enum.spriteBlueWoman][imagenum]
                end
                if e.isPerson.gender == enum.genderMale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedMan]
                    quad = QUADS[enum.spriteRedMan][imagenum]
                end
                if e.isPerson.gender == enum.genderFemale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedWoman]
                    quad = QUADS[enum.spriteRedWoman][imagenum]
                end
                love.graphics.draw(sprite, quad, drawx, drawy, imgrotation, 1, 1, 10, 25)

                -- display the log
                local maxindex = #e.isPerson.log
                if e:has("isSelected") and VILLAGERS_SELECTED == 1 then
                    img = IMAGES[enum.imagesVillagerLog]
                    local imageheight = img:getHeight()
                    local drawboxy = SCREEN_HEIGHT - imageheight - 100

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.draw(img, 50, drawboxy, 0, 1.5, 1)
                    local texty = drawboxy + 7


                    for i = maxindex, maxindex - 4, -1 do
                        if i < 1 then break end
                        love.graphics.setColor(47/255,11/255,50/255,1)
                        love.graphics.print(e.isPerson.log[i].text, 57, texty)
                        texty = texty + 12
                    end
                end

                -- draw villager debug information
                local txt = ""
                if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
                    -- display some debugging information
                    if e.isPerson.queue[1] ~= nil then
                        txt = "action: " .. e.isPerson.queue[1].action .. "\n"
                        if e.isPerson.queue[1].timeleft ~= nil then
                            txt = txt .. "timer: " .. cf.round(e.isPerson.queue[1].timeleft) .. "\n"
                        end
                    end
                    txt = txt .. "health: " .. cf.round(e.isPerson.health) .. "\n"
                    txt = txt .. "stamina: " .. cf.round(e.isPerson.stamina) .. "\n"
                    txt = txt .. "fullness: " .. cf.round(e.isPerson.fullness) .. "\n"
                    txt = txt .. "wealth: " .. cf.round(e.isPerson.wealth,1) .. "\n"
                    txt = txt .. "wood: " .. cf.round(e.isPerson.stockInv[enum.stockWood]) .. "\n"
                    txt = txt .. "tax owed: " .. cf.round(e.isPerson.taxesOwed, 1) .. "\n"

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 60)

                    -- stock belief
                    txt = cf.round(e.isPerson.stockBelief[enum.stockFruit][2], 1) .. "\n"
                    txt = txt .. cf.round(e.isPerson.stockBelief[enum.stockFruit][1], 1) .. "\n"
                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, 30, 30)     -- positive x = move left
                else
                    if e.isPerson.health < 25 then
                        txt = txt .. "health: " .. cf.round(e.isPerson.health) .. "\n"
                    end
                    if e.isPerson.stamina < 25 then
                        txt = txt .. "stamina: " .. cf.round(e.isPerson.stamina) .. "\n"
                    end
                    if e.isPerson.fullness < 25 then
                        txt = txt .. "fullness: " .. cf.round(e.isPerson.fullness) .. "\n"
                    end
                    if e.isPerson.wealth < 1 then
                        txt = txt .. "wealth: " .. cf.round(e.isPerson.wealth,1) .. "\n"
                    end
                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 25)
                end
            end
        end
    end

    systemIsPerson = concord.system({
        pool = {"isPerson"}
    })
    function systemIsPerson:update(dt)
        for _, e in ipairs(self.pool) do
            -- check if queue is empty and if so then get a new action from the behavior tree

            local agentrow = e.position.row
            local agentcol = e.position.col

           -- determine new action for queue (or none)
            if #e.isPerson.queue == 0 then
                fun.getNewGoal(e)
            end

            -- add 'idle' action if queue is still empty
            if #e.isPerson.queue < 1 then
                -- add an 'idle' action
                action = {}
                action.action = "idle"      -- idle is same as rest but idle means "nothing else to do" but rest was chosen from btree
                action.timeleft = love.math.random(5, 10)
                action.log = "Idle"
                table.insert(e.isPerson.queue, action)

                -- add a talking bubble
                local item = {}
                item.imagenumber = enum.imagesEmoteTalking
                item.start = love.math.random(0, 7)
                item.stop = love.math.random(item.start, action.timeleft)
                item.x, item.y = fun.getXYfromRowCol(agentrow, agentcol)
                table.insert(DRAWQUEUE, item)
            end

            -- process head of queue
            local currentaction = {}
            currentaction = e.isPerson.queue[1]      -- a table

            if currentaction.action == "idle" then
                actidle.idle(e, currentaction, dt)
            end

            if currentaction.action == "rest" then
                actrest.rest(e, currentaction, dt)
            end

            if currentaction.action == "move" then
                actmove.move(e, currentaction, dt)
            end

            if currentaction.action == "work" then
                actwork.work(e, currentaction, dt)
            end

            if currentaction.action == "buy" then
                -- actbuy.buy(e, currentaction)
                actbuy.newbuy(e, currentaction)
            end

            if currentaction.action == "stockhouse" then
                actstockhouse.stockhouse(e, currentaction)
            end

            -- ******************* --
            -- do things that don't depend on an action
            -- ******************* --
            local row = e.position.row
            local col = e.position.col

            -- add mud
            if MAP[row][col].entity.isTile.improvementType == nil then
                MAP[row][col].entity.isTile.mudLevel = MAP[row][col].entity.isTile.mudLevel + (dt * 15 * TIME_SCALE)       --! make constants
            end
            if MAP[row][col].entity.isTile.mudLevel > 255 then MAP[row][col].entity.isTile.mudLevel = 255 end

            -- reduce stamina
            e.isPerson.stamina = e.isPerson.stamina - (STAMINA_USE_RATE * TIME_SCALE * dt)   --! make constants
            if e.isPerson.stamina < 0 then e.isPerson.stamina = 0 end

            -- reduce fullness
            e.isPerson.fullness = e.isPerson.fullness - (10 * TIME_SCALE * dt)    --! make constants

            -- apply wear to house if they have one
            if e:has("residence") then
                e.residence.unbuiltMaxHealth = e.residence.unbuiltMaxHealth - (dt * TIME_SCALE * HOUSE_WEAR)
                e.residence.health = e.residence.health - (dt * TIME_SCALE * HOUSE_WEAR)

                if e.residence.unbuiltMaxHealth < 0 then e.residence.unbuiltMaxHealth = 0 end
                if e.residence.health < 0 then e.residence.health = 0 end
            end

            -- pay public servants
            if  e:has("occupation") then
                if e.occupation.value == enum.jobTaxCollector then
                    local amount = TAXCOLLECTOR_INCOME_PER_JOB * dt * TIME_SCALE
                    if VILLAGE_WEALTH >= amount then
                        e.isPerson.wealth = e.isPerson.wealth + amount
                        VILLAGE_WEALTH = VILLAGE_WEALTH - amount
                    end
                end
                if e.occupation.value == enum.jobWelfareOfficer then
                    local amount = WELLFAREOFFICER_INCOME_PER_JOB * dt * TIME_SCALE
                    if VILLAGE_WEALTH >= amount then
                        e.isPerson.wealth = e.isPerson.wealth + amount
                        VILLAGE_WEALTH = VILLAGE_WEALTH - amount
                    end
                end
            end

            -- do this last as it may nullify the entity
            if e.isPerson.fullness < 0 or e.isPerson.health <= 0 then
                -- destroy any improvement belonging to starving agent
                if e:has("workplace") then
                    -- destroy workplace
                    local wprow = e.workplace.row
                    local wpcol = e.workplace.col
                    MAP[wprow][wpcol].entity.isTile.improvementType = nil
                    MAP[wprow][wpcol].entity.isTile.stockType = nil
                    MAP[wprow][wpcol].entity.isTile.tileOwner = nil
                    MAP[wprow][wpcol].entity.isTile.stockLevel = 0
                end
                if e:has("residence") then
                    -- destroy house
                    local wprow = e.residence.row
                    local wpcol = e.residence.col
                    MAP[wprow][wpcol].entity.isTile.improvementType = nil
                    MAP[wprow][wpcol].entity.isTile.stockType = nil
                    MAP[wprow][wpcol].entity.isTile.tileOwner = nil
                    MAP[wprow][wpcol].entity.isTile.stockLevel = 0
                end

                -- create game log
                local txt = "A villager has left due to "
                if e.isPerson.fullness < 0 then
                    txt = txt .. "lack of food."
                elseif e.isPerson.health < 0 then
                    txt = txt .. "poor health."
                end
                fun.addGameLog(txt)
                if e:has("residence") then
                    txt = "It's house has been demolished."
                    fun.addGameLog(txt)
                end
                if e:has("occupation") then
                    txt = "It's workplace has been demolished."
                    --! add the occupation
                    fun.addGameLog(txt)
                end

                fun.killAgent(e.uid.value)  -- removes the agent from the VILLAGERS table
                e:destroy()                 -- destroys the entity from the world
            end
        end
    end

    systemIsTile = concord.system({
        pool = {"isTile"}
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col].entity = entity       -- this assigns isTile amongst other things
        end
    end

    systemIsTileUpdate = concord.system({
        pool = {"isTile"}
    })
    function systemIsTileUpdate:update(dt)
        for _, e in ipairs(self.pool) do

            -- decrease mud so that grass grows
            e.isTile.mudLevel = cf.round(e.isTile.mudLevel - (dt / 3) * TIME_SCALE, 4)
            if e.isTile.mudLevel < 0 then e.isTile.mudLevel = 0 end
        end
    end

    -- add the systems to the world
    -- ## ensure all systems are added to the world
    WORLD:addSystems(systemDraw, systemIsTile, systemIsTileUpdate, systemIsPerson)

    -- create entities

    -- capture the tile that has the well firs of all
	WELLS = {}
	WELLS[1] = {}
	WELLS[1].row = love.math.random(4, NUMBER_OF_ROWS - 4)  -- The 3 and -2 keeps the well off the screen edge
	WELLS[1].col = love.math.random(4, NUMBER_OF_COLS - 4)

    -- debugging
    -- WELLS[1].row = 4
	-- WELLS[1].col = 4


    -- create tiles
    local terrainheightperlinseed
    local terraintypeperlinseed = love.math.random(0,20) / 20
    repeat
        terrainheightperlinseed = love.math.random(0,20) / 20
    until terrainheightperlinseed ~= terraintypeperlinseed

    -- create tile entities
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            local rowvalue = row / NUMBER_OF_ROWS
            local colvalue = col / NUMBER_OF_COLS
            -- the noise function only works with numbers between 0 and 1
            MAP[row][col].height = cf.round(love.math.noise(rowvalue, colvalue, terrainheightperlinseed) * UPPER_TERRAIN_HEIGHT)
            MAP[row][col].tileType = cf.round(love.math.noise(rowvalue, colvalue, terraintypeperlinseed) * 4)
            local tiles = concord.entity(WORLD)     -- this calls tile:init() which then loads the entity into MAP
            :give("drawable")
            :give("position", row, col)
            :give("uid")
            if row == WELLS[1].row and col == WELLS[1].col then
                -- this tile has a well
                tiles:give("isTile", MAP[row][col].tileType, MAP[row][col].height, enum.improvementWell)
            else
                tiles:give("isTile", MAP[row][col].tileType, MAP[row][col].height)
            end
        end
    end

    -- add starting villagers
    for i = 1, NUMBER_OF_VILLAGERS do
        local villager = concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("uid")
        :give("isPerson")
        table.insert(VILLAGERS, villager)
    end

end

return ecsfunctions
