actionbuy = {}

function actionbuy.buy(e, currentaction)

    local agentrow = e.position.row
    local agentcol = e.position.col
    print("Buying stock type " .. currentaction.stockType)

    local amtbought
    if currentaction.stockType ~= enum.stockWelfare then    -- welfare has a special formula
        amtbought = fun.buyStock(e, currentaction.stockType, currentaction.purchaseAmount)    -- this deducts stock from the shop
        print("Bought " .. amtbought .. " of stock type " .. currentaction.stockType)
        if currentaction.stockType == enum.stockFruit then
            e.isPerson.fullness = e.isPerson.fullness + (amtbought * 100)   -- each food restores 100 fullness
            if amtbought > 0 and love.math.random(1, 1000) == 1 then
                fun.playAudio(enum.audioEat, false, true)
            end
        elseif currentaction.stockType == enum.stockHealingHerbs then
            e.isPerson.health = e.isPerson.health + (amtbought * 10)
            if amtbought > 0 and love.math.random(1, 1000) == 1 then
                fun.playAudio(enum.audioBandage, false, true)
            end
        else
            e.isPerson.stockInv[currentaction.stockType] = e.isPerson.stockInv[currentaction.stockType] + amtbought
        end
    else
        -- handle welfare differently
        local agentrow = e.position.row
        local agentcol = e.position.col
        local stockavail = math.floor(MAP[agentrow][agentcol].entity.isTile.stockLevel)
        amtbought = math.min(stockavail, currentaction.purchaseAmount)
        if stockavail >= amtbought then
            MAP[agentrow][agentcol].entity.isTile.stockLevel = MAP[agentrow][agentcol].entity.isTile.stockLevel - amtbought
            e.isPerson.wealth = e.isPerson.wealth + amtbought
        else
            print("Tried to get welfare but no stock")
        end
    end

    if amtbought > 0 then
        -- add a money bubble
        local item = {}
        item.imagenumber = enum.imagesEmoteCash
        item.start = 0
        item.stop = 3
        item.x, item.y = fun.getXYfromRowCol(agentrow, agentcol)
        table.insert(DRAWQUEUE, item)
    end

    table.remove(e.isPerson.queue, 1)
    fun.addLog(e, currentaction.log)


end


return actionbuy
