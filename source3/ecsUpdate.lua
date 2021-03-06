ecsUpdate = {}

local function killAgent(uniqueid, array)
    -- remvoves uniqueid from array
    -- can be used on VILLAGERS and MONSTERS

    local deadID

    -- remove any bubbles associated with this villager
    for i = #DRAWQUEUE, 1, -1 do
        if DRAWQUEUE[i].uid == uniqueid then
            table.remove(DRAWQUEUE, i)
        end
    end

    for k, v in ipairs(array) do
        -- print(uniqueid, v.uid.value)
        if v.uid.value == uniqueid then
            -- print("Found dead guy. " .. k)
            -- print("Time worked = " .. v.isPerson.timeWorking)
            -- print("Time rested = " .. v.isPerson.timeResting)
            deadID = k
            break
        end
    end
    assert(deadID ~= nil)
    table.remove(array, deadID)     -- Note: need to kill entity from WORLD before removing from table
    print("There are now " .. #array .. " entities.")
end

function ecsUpdate.isPerson()

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
                decision.getNewGoal(e)
            end

            -- add 'idle' action if queue is still empty
            if #e.isPerson.queue < 1 then
                -- add an 'idle' action
                local action = {}
                action.action = "idle"      -- idle is same as rest but idle means "nothing else to do" but rest was chosen from btree
                action.timeleft = love.math.random(5, 10)
                action.log = "Idle"
                table.insert(e.isPerson.queue, action)

                -- determine animation/anim8
                if e:has("occupation") then
                    -- add a talking bubble
                    local item = {}
                    item.imagenumber = enum.imagesEmoteTalking
                    item.start = love.math.random(0, 4)
                    item.stop = love.math.random(item.start, action.timeleft)
                    item.x, item.y = e.position.x, e.position.y
                    item.uid = e.uid.value
                else
                    if e.gender == enum.genderMale then
                        -- add a talking bubble
                        local item = {}
                        item.imagenumber = enum.imagesEmoteTalking
                        item.start = love.math.random(0, 4)
                        item.stop = love.math.random(item.start, action.timeleft)
                        item.x, item.y = e.position.x, e.position.y
                        item.uid = e.uid.value
                        table.insert(DRAWQUEUE, item)
                    else    -- gender == female
                        local rndanimation = love.math.random(1,3)
                        -- rndanimation = 2
                        if rndanimation == 1 then
                            -- add a talking bubble
                            local item = {}
                            item.imagenumber = enum.imagesEmoteTalking
                            item.start = love.math.random(0, 4)
                            item.stop = love.math.random(item.start, action.timeleft)
                            item.x, item.y = e.position.x, e.position.y
                            item.uid = e.uid.value
                            table.insert(DRAWQUEUE, item)
                        elseif rndanimation == 2 then       -- only do this if female and unemployed
                            -- wave
                            local item = {}
                            item.animationnumber = enum.spriteRedWomanWaving
                            item.start = love.math.random(0, 4)
                            item.stop = love.math.random(item.start, action.timeleft)
                            item.x, item.y = e.position.x, e.position.y
                            item.uid = e.uid.value
                            item.entity = e
                            table.insert(DRAWQUEUE, item)
                        elseif rndanimation == 3 then
                            local item = {}
                            item.animationnumber = enum.spriteRedWomanFlute
                            item.start = love.math.random(0, 4)
                            item.stop = love.math.random(item.start, action.timeleft)
                            item.x, item.y = e.position.x, e.position.y
                            item.uid = e.uid.value
                            item.entity = e
                            table.insert(DRAWQUEUE, item)
                        else
                            -- should not happen
                            error("Unknown animation can't play.")
                        end
                    end
                end
            end

            -- if e:has("occupation") then
            --     if e.occupation.value == enum.jobSwordsman then
            --         for i = 1, #e.isPerson.queue do
            --             print(e.isPerson.queue[i].action)
            --         end
            --         print("###########")
            --     end
            -- end

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
                actmove.move(e, currentaction, e.isPerson.queue, e.isPerson.stamina, dt)
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

            if currentaction.action == "goalBuyFruit" then
                fun.createActions(enum.goalEatFruit, e)
                table.remove(e.isPerson.queue, 1)
            end

            if currentaction.action == "goalWork" then
                fun.createActions(enum.goalWork, e)
                table.remove(e.isPerson.queue, 1)
            end

            if currentaction.action == "goalBuyWood" then
                fun.createActions(enum.goalBuyWood, e)
                table.remove(e.isPerson.queue, 1)
            end

            if currentaction.action == "goalBuyHerbs" then
                fun.createActions(enum.goalHeal, e)
                table.remove(e.isPerson.queue, 1)
            end

            if currentaction.action == "chasemonster" then
                -- only applies to guards
                fun.createActions(enum.goalChaseMonster, e)
                table.remove(e.isPerson.queue, 1)

            end

            -- ******************* --
            -- do things that don't depend on an action
            -- ******************* --
            local row = e.position.row
            local col = e.position.col

            -- add mud
            if MAP[row][col].entity.isTile.improvementType == nil or MAP[row][col].entity.isTile.improvementType == enum.improvementWell then
                MAP[row][col].entity.isTile.mudLevel = MAP[row][col].entity.isTile.mudLevel + (dt * 15 * TIME_SCALE)       --! make constants
            end
            if MAP[row][col].entity.isTile.mudLevel > 255 then MAP[row][col].entity.isTile.mudLevel = 255 end

            -- reduce stamina
            e.isPerson.stamina = e.isPerson.stamina - (STAMINA_USE_RATE * TIME_SCALE * dt)
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
                if e.occupation.value == enum.jobSwordsman then
                    local amount = SWORDSMAN_INCOME_PER_JOB * dt * TIME_SCALE
                    if VILLAGE_WEALTH >= amount then
                        e.isPerson.wealth = e.isPerson.wealth + amount
                        VILLAGE_WEALTH = VILLAGE_WEALTH - amount
                    end
                    -- attack monsters
                    for k, m in pairs(MONSTERS) do
                        if row == m.position.row and col == m.position.col then
                            m.isMonster.health = 0
                            print("Attack!!")
                        end
                    end
                    if #MONSTERS > 0 then
                        --! this is a hack!!
                        local action = {}
                        action.action = "chasemonster"
                        action.stockType = nil
                        action.purchaseAmount = nil
                        action.timeleft = 0
                        action.log = "Chased monster"
                        table.insert(e.isPerson.queue, action)
                    end

                end
            end

            -- do this last as it may nullify the entity
            if (e:has("occupation") and e.isPerson.fullness < -300) or
                (not e:has("occupation") and e.isPerson.fullness < 0) or
                (e.isPerson.health <= 0)
                then
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
                    if not e.occupation.value == enum.jobTaxCollector and not e.occupation == enum.jobCarpenter then
                        txt = "It's workplace has been demolished."
                        --! add the occupation
                        fun.addGameLog(txt)
                    end
                end

                killAgent(e.uid.value, VILLAGERS)  -- removes the agent from the VILLAGERS table
                e:destroy()                 -- destroys the entity from the world
            end
        end
    end
end

function ecsUpdate.isTile()
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
end

local function getMostStockedShop()
    -- determines which shop/tile/workspace has the most stock
    -- returns row/col
    -- check for row = -1 meaning no stock found at all

    local mostrow, mostcol
    local moststock = 0

    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            if MAP[row][col].entity.isTile.stockLevel > moststock then
                moststock = MAP[row][col].entity.isTile.stockLevel
                mostrow = row
                mostcol = col
            end
        end
    end
    return mostrow, mostcol
end

function ecsUpdate.isMonster()
    systemIsMonsterUpdate = concord.system({
        pool = {"isMonster"}
    })
    function systemIsMonsterUpdate:update(dt)
        for _, e in ipairs(self.pool) do

            local agentrow = e.position.row
            local agentcol = e.position.col

            if #e.isMonster.queue == 0 then
                -- determine target
                local targetrow, targetcol = getMostStockedShop()
                e.isMonster.targetrow = targetrow
                e.isMonster.targetcol = targetcol
                if targetrow ~= nil then
                    -- found a target row/col

                    -- add move commands
                    fun.addMoveAction(e.isMonster.queue, agentrow, agentcol, targetrow, targetcol)   -- will add as many 'move' actions as necessary

                    --! add "steal" command
                    local action = {}
                    action.action = "goalSteal"
                    action.log = "Stealing!"
                    table.insert(e.isMonster.queue, action)
                else
                    -- no stock found on map. Just leave.
                    e.isMonster.health = -1         -- kill it
                    table.remove(e.isMonster.queue, 1)
                end
            end

            -- process head of queue
            local currentaction = {}
            currentaction = e.isMonster.queue[1]      -- a table

            if currentaction ~= nil then
                if currentaction.action == "move" then
                    actmove.move(e, currentaction, e.isMonster.queue, 1000, dt)
                end

                if currentaction.action == "goalSteal" then
                    local stolenamt = MAP[agentrow][agentcol].entity.isTile.stockLevel
                    print("Monster stole " .. stolenamt .. " units!")
                    MAP[agentrow][agentcol].entity.isTile.stockLevel = 0
                    table.remove(e.isMonster.queue, 1)
                    e.isMonster.targetrow = 0
                    e.isMonster.targetcol = 0

                    local exitrow, exitcol = fun.getBlankBorderTile()
                    fun.addMoveAction(e.isMonster.queue, agentrow, agentcol, exitrow, exitcol)   -- will add as many 'move' actions as necessary

                    local action = {}
                    action.action = "die"
                    action.log = "Fleeing"
                    table.insert(e.isMonster.queue, action)
                end

                if currentaction.action == "die" then
                    e.isMonster.health = -1         -- kill it
                    table.remove(e.isMonster.queue, 1)
                end
            end

            if e.isMonster.health <= 0 then
                killAgent(e.uid.value, MONSTERS)      -- operates directly on VILLAGERS
                e:destroy()                 -- destroys the entity from the world
                -- print("ack! Monster dead. Either had no target or left the map")
            else
                AUDIO[enum.audioDanger]:play()
            end

        end
    end
end

return ecsUpdate
