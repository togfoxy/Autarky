actionwork = {}


function actionwork.work(e, currentaction, dt)

    currentaction.timeleft = currentaction.timeleft - dt
    e.isPerson.timeWorking = e.isPerson.timeWorking + dt

    -- play audio
    if currentaction.timeleft > 3 and love.math.random(1, 5000) == 1 then
        -- play audio
        if e.occupation.value == enum.jobFarmer then
            fun.playAudio(enum.audioRustle, false, true)
        end
        if e.occupation.value == enum.jobWoodsman then
            fun.playAudio(enum.audioSawWood, false, true)
        end
    end

    -- see if they hurt themselves at work
    local injrate = INJURY_RATE * TIME_SCALE * dt
    local random = love.math.random(0, 1)
    if random < injrate then
        local dmg = cf.round(love.math.random(1, 10) * TIME_SCALE * dt, 4)
        e.isPerson.health = e.isPerson.health - dmg
    end

    -- update log
    if currentaction.timeleft <= 0 then
        table.remove(e.isPerson.queue, 1)
        fun.addLog(e, currentaction.log)
    end

    -- reap benefits of work

    if e.occupation.stockType ~= nil and e.occupation.value ~= enum.jobCarpenter then
        -- accumulate stock
        local row = e.position.row
        local col = e.position.col
        if MAP[row][col].stockLevel == nil then MAP[row][col].stockLevel = 0 end

        local stockgained
        if e.occupation.stockType == enum.stockFruit then
            stockgained = (FRUIT_PRODUCTION_RATE * dt)
        elseif e.occupation.stockType == enum.stockWood then
            stockgained = (WOOD_PRODUCTION_RATE * dt)
        elseif e.occupation.stockType == enum.stockHealingHerbs then
            stockgained = (HERB_PRODUCTION_RATE * dt)
        end
        assert(stockgained ~= nil)

        if e.isPerson.stamina <= 0 then
            stockgained = stockgained / 2   -- less productive when tired
        end

        stockgained = cf.round(stockgained, 4)
        MAP[row][col].entity.isTile.stockLevel = MAP[row][col].entity.isTile.stockLevel + stockgained
    end

    if e.occupation.value == enum.jobCarpenter then
        -- if wood is onsite then use the wood to increase max health
        -- if health is less than maxhealth then increase the health for a wage

        local row = e.position.row
        local col = e.position.col
        local owner = MAP[row][col].entity.isTile.tileOwner
        local woodqty = MAP[row][col].entity.isTile.stockLevel
        if owner.residence.unbuiltMaxHealth < 100 and woodqty >= 1 then
            -- okay to add more wood
            owner.residence.unbuiltMaxHealth = owner.residence.unbuiltMaxHealth + HEALTH_GAIN_PER_WOOD
            MAP[row][col].entity.isTile.stockLevel = MAP[row][col].entity.isTile.stockLevel - 1
        else
            -- max is already very high. Ensure builders don't come here unnecessarily
        end

        -- convert unbuilt health into real health
        if owner.residence.health < owner.residence.unbuiltMaxHealth then
            -- repair the house
            owner.residence.health = owner.residence.health + (dt * CARPENTER_BUILD_RATE * HEALTH_GAIN_FROM_WOOD)

            -- pay the builder
            local wage = (dt * CARPENTER_WAGE)
            local taxamount = wage * 0.10
            e.isPerson.wealth = e.isPerson.wealth + (wage - taxamount)          -- e = the carpenter
            e.isPerson.taxesOwed = e.isPerson.taxesOwed + taxamount
            VILLAGE_WEALTH = VILLAGE_WEALTH + taxamount
            owner.isPerson.wealth = owner.isPerson.wealth - wage          -- is okay if goes negative
            if (owner.isPerson.wealth <= FRUIT_SELL_PRICE * 1.1) or (owner.residence.health >= owner.residence.unbuiltMaxHealth) then
                table.remove(e.isPerson.queue, 1)   -- stop the job when home owner runs low on money
            end
        else
            -- nothing to repair
        end
    end

    if e.occupation.value == enum.jobTaxCollector then
        -- tax all the villagers on this tile
        local row = e.position.row
        local col = e.position.col

        for k, villager in pairs(VILLAGERS) do
            if villager.position.row == row and villager.position.col == col and villager.isPerson.taxesOwed >= 1 then
               local taxamount = villager.isPerson.taxesOwed
               villager.isPerson.taxesOwed = villager.isPerson.taxesOwed - taxamount
               VILLAGE_WEALTH = VILLAGE_WEALTH + taxamount
            end
        end
    end

    if e.occupation.value == enum.jobWelfareOfficer then
        -- convert coffer into payments
        local row = e.position.row
        local col = e.position.col
        local maxamt = math.floor(#VILLAGERS / 2)
        if MAP[row][col].entity.isTile.stockLevel < maxamt then
            local amt = (WELFARE_PRODUCTION_RATE * dt)
            if VILLAGE_WEALTH >= amt then
                MAP[row][col].entity.isTile.stockLevel = MAP[row][col].entity.isTile.stockLevel + (WELFARE_PRODUCTION_RATE * dt)
                VILLAGE_WEALTH = VILLAGE_WEALTH - amt
            else
                -- coffers are empty!
                table.remove(e.isPerson.queue, 1)
            end
        else
            -- print("Too much welfare. Won't create more")
        end
    end



end







return actionwork
