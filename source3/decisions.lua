decision = {}

function decision.getNewGoal(villager)
    -- decision tree
    local personIsHungry = villager.isPerson.fullness < 50
    local personIsTired = villager.isPerson.stamina < 30
    local personisPoor = villager.isPerson.wealth < fun.getAvgSellPrice(enum.stockFruit)
    local personisSick = villager.isPerson.health < 30
    local row, col
    local agentrow = villager.position.row
    local agentcol = villager.position.col
    local workplacerow, workplacecol
    local occupation = 0    -- default value meaning no occupation
    local workstock = 0

    if villager:has("workplace") then          --! is this even needed?
        workplacerow = villager.workplace.row
        workplacecol = villager.workplace.col
        workstock = MAP[workplacerow][workplacecol].entity.isTile.stockLevel
    end

    if villager:has("occupation") then
        occupation = villager.occupation.value
    end

    local houserow
    local housecol
    local housewood = 0     -- how much spare wood at house
    if villager:has("residence") then
        houserow = villager.residence.row
        housecol = villager.residence.col
        housewood = MAP[houserow][housecol].entity.isTile.stockLevel
    end


    -- ***************
    -- * Decison tree
    -- ***************
    if personIsHungry then
        row, col = fun.getClosestBuilding(enum.improvementFarm, 1, agentrow, agentcol)
        if row ~= nil then
            -- farm with food is found
            if personIsTired then
                if personisPoor then
                    if occupation == enum.jobFarmer then
                        if workstock >= 1 then
                            -- get fruit from own farm
                            fun.createActions(enum.goalGotoWorkplace, villager)
                            fun.createActions(enum.goalEatFruit, villager)
                        else
                            -- work and create fruit for self
                            fun.createActions(enum.goalWork, villager)
                            print("alpha")
                        end
                    else    -- not a farmer
                        local restdist = cf.GetDistance(agentrow, agentcol, WELLS[1].row, WELLS[1].col)   -- distance to farm

                        row, col = fun.getClosestBuilding(enum.improvementWelfare, agentrow, agentcol)  --! what if owns house?
                        local wfdist = 999
                        if row ~= nil then
                            wfdist = cf.GetDistance(agentrow, agentcol, row, col)   -- distance
                        end

                        if restdist < wfdist then
                            -- town centre is closer so rest first
                            fun.createActions(enum.goalRest, villager)
                            fun.createActions(enum.goalGetWelfare, villager)
                            fun.createActions(enum.goalEatFruit, villager)
                        else    -- welfare is closer
                            fun.createActions(enum.goalGetWelfare, villager)

                            local fruitdist = 999
                            row, col = fun.getClosestBuilding(enum.improvementFarm, 1, agentrow, agentcol)
                            if row ~= nil then
                                fruitdist = cf.GetDistance(agentrow, agentcol, row, col)   -- distance
                            end

                            if restdist < fruitdist then
                                fun.createActions(enum.goalRest, villager)
                                fun.createActions(enum.goalEatFruit, villager)
                            else
                                fun.createActions(enum.goalEatFruit, villager)
                            end
                        end
                    end
                else    -- not poor
                    local farmdist = cf.GetDistance(agentrow, agentcol, row, col)   -- distance to farm
                    if farmdist >= 5 then
                        fun.createActions(enum.goalRest, villager)
                        fun.createActions(enum.goalEatFruit, villager)      --! should this be "enum.goalEatFruit"  ??!!
                    else
                        fun.createActions(enum.goalEatFruit, villager)
                    end
                end
            else    -- not tired
                if personisPoor then
                    if occupation == enum.jobFarmer then
                        if workstock >= 1 then
                            -- get fruit from own farm
                            fun.createActions(enum.goalGotoWorkplace, villager)
                            fun.createActions(enum.goalEatFruit, villager)
                        else
                            -- work and create fruit for self
                            fun.createActions(enum.goalWork, villager)
                            print("beta")
                        end
                    else    -- not a farmer
                        -- look for welfare office
                        row, col = fun.getClosestBuilding(enum.improvementWelfare, agentrow, agentcol)
                        if row ~= nil then
                            -- found welfare
                            fun.createActions(enum.goalGetWelfare, villager)
                            fun.createActions(enum.goalEatFruit, villager)
                        else
                            -- go to work and try to make money
                            if occupation > 0 then
                                fun.createActions(enum.goalWork, villager)
                                -- print("charlie")
                            else
                                -- out of options
                                goal = ft.DetermineAction(TREE, villager)
                                fun.createActions(goal, villager)
                            end
                        end
                    end
                else    -- not poor
                    fun.createActions(enum.goalEatFruit, villager)
                end
            end
        else    -- can't find building
            -- play audio here
            fun.playAudio(enum.audioWarning, false, true)       -- is music, is sound

            if occupation > 0 and workstock <= 4 then
                fun.createActions(enum.goalWork, villager)
            else    -- no occupation
                goal = ft.DetermineAction(TREE, villager)
                fun.createActions(goal, villager)
            end
        end
    else    -- not hungry
        if personIsTired then
            fun.createActions(enum.goalRest, villager)
        else    -- not tired
            if personisPoor then
                if personisSick then
                    fun.createActions(enum.goalGetWelfare, villager)
                    row, col = fun.getClosestBuilding(enum.improvementHealer, 1, agentrow, agentcol)
                    if row ~= nil and (villager.isPerson.wealth >= fun.getAvgSellPrice(enum.stockHealingHerbs)) then
                        fun.createActions(enum.goalHeal, villager)
                    else
                        goal = ft.DetermineAction(TREE, villager)
                        print("Echo goal is " .. goal)
                        fun.createActions(goal, villager)
                        -- if sick and poor, break the cycle by working if possible - even if sick
                        if occupation > 0 then
                            local action = {}
                            action.action = "goalWork"      --
                            action.timeleft = love.math.random(5, 10)       --! not sure this is the right timer
                            action.log = "Working"
                            table.insert(villager.isPerson.queue, action)
                        end
                    end
                else    -- not sick
                    if occupation > 0 and workstock <= 4 then
                        -- NOTE: the removed lines was causing an endless loop
                        -- fun.createActions(enum.goalWork, villager)
                        -- print("foxtrot")
                        goal = ft.DetermineAction(TREE, villager)
                        fun.createActions(goal, villager)
                    else    -- no occupation
                        goal = ft.DetermineAction(TREE, villager)
                        fun.createActions(goal, villager)
                    end
                end
            else    -- not poor
                if personisSick then
                    row, col = fun.getClosestBuilding(enum.improvementHealer, 1, agentrow, agentcol)
                    if row ~= nil then
                        fun.createActions(enum.goalHeal, villager)
                    else
                        fun.createActions(enum.goalRest, villager)
                    end
                else    -- not sick
                    if villager.isPerson.stockInv[enum.stockWood] <= 2 and housewood <= 2 and occupation > 0 then
                        row, col = fun.getClosestBuilding(enum.improvementWoodsman, 1, agentrow, agentcol)
                        if row ~= nil then
                            fun.createActions(enum.goalBuyWood, villager)
                        else
                            fun.createActions(enum.goalWork, villager)
                            -- print("golf - try to work")
                        end
                    else    -- has wood
                        if villager.isPerson.stockInv[enum.stockWood] > 0 then
                            fun.createActions(enum.goalStockHouse, villager)
                        else
                            goal = ft.DetermineAction(TREE, villager)
                            fun.createActions(goal, villager)
                        end
                    end
                end
            end
        end
    end
end
return decision
