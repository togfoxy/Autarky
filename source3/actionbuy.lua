actionbuy = {}

local function tradeGoods(buyer, seller, stocktype, desiredQty, agreedprice)

    local agentrow = buyer.position.row
    local agentcol = buyer.position.col
    local stockavail = math.floor(MAP[agentrow][agentcol].entity.isTile.stockLevel)
    local shoptile = MAP[agentrow][agentcol].entity.isTile      --! this is buyer tile - could it be null?
    local purchaseamt
    -- determine how much is actually traded
    if buyer == seller then
        -- agent is buying from own shop. Waive the purchase price
        -- doing this allows farms with 0 wealth to still buy and survive
        purchaseamt = math.min(desiredQty, stockavail)
        shoptile.stockLevel = shoptile.stockLevel  - purchaseamt
    else
        local canafford = math.floor(buyer.isPerson.wealth / agreedprice)     -- units that can be afforded rounds down
        purchaseamt = math.min(stockavail, canafford, desiredQty)   -- limit transaction to what can be afforded, desired and provisioned
        purchaseamt = math.floor(purchaseamt)       -- round down to nearest unit

        local transactionprice = purchaseamt * agreedprice

        shoptile.stockLevel = shoptile.stockLevel  - purchaseamt
        buyer.isPerson.stockInv[stocktype] = buyer.isPerson.stockInv[stocktype] + purchaseamt

        seller.isPerson.wealth = seller.isPerson.wealth + (transactionprice * (1-GST_RATE))
        seller.isPerson.taxesOwed = seller.isPerson.taxesOwed + (transactionprice * GST_RATE)
        buyer.isPerson.wealth = buyer.isPerson.wealth - transactionprice

        buyer.isPerson.stockBelief[stocktype][3] = buyer.isPerson.stockBelief[stocktype][3] + agreedprice
        buyer.isPerson.stockBelief[stocktype][4] = buyer.isPerson.stockBelief[stocktype][4] + purchaseamt

        seller.isPerson.stockBelief[stocktype][3] = buyer.isPerson.stockBelief[stocktype][3] + agreedprice
        seller.isPerson.stockBelief[stocktype][4] = buyer.isPerson.stockBelief[stocktype][4] + purchaseamt

    end
    return purchaseamt
end

local function adjustBuyersBelief(agent, stocktype, bidprice, askprice)
    -- success = boolean = true if transaction proceeded

    local adjamount = agent.isPerson.stockBelief[stocktype][2] * 0.10        -- 10% of upper belief
    if bidprice > askprice then -- succcess
        -- move the lower and upper closer together
        agent.isPerson.stockBelief[stocktype][1] = agent.isPerson.stockBelief[stocktype][1] + adjamount
        agent.isPerson.stockBelief[stocktype][2] = agent.isPerson.stockBelief[stocktype][2] - adjamount
        if agent.isPerson.stockBelief[stocktype][1] > agent.isPerson.stockBelief[stocktype][2] then
            local avgvalue = (agent.isPerson.stockBelief[stocktype][1] + agent.isPerson.stockBelief[stocktype][2])  / 2
            agent.isPerson.stockBelief[stocktype][1] = avgvalue
            agent.isPerson.stockBelief[stocktype][2] = avgvalue
        end
    else    -- no success
        -- move upper belief up a bit
        agent.isPerson.stockBelief[stocktype][2] = agent.isPerson.stockBelief[stocktype][2] + adjamount

        -- move the range down by 10% of the overbid
        local overbid = bidprice - askprice
        local adjamount = overbid * 0.10
        agent.isPerson.stockBelief[stocktype][1] = agent.isPerson.stockBelief[stocktype][1] - adjamount
        agent.isPerson.stockBelief[stocktype][2] = agent.isPerson.stockBelief[stocktype][2] - adjamount
    end
end

local function adjustSellersBelief(agent, stocktype, bidprice, askprice)
    if askprice < bidprice then
        -- move the range up by 20% of the overbid
        local overbid = bidprice - askprice
        local adjamount = overbid * 0.20
        agent.isPerson.stockBelief[stocktype][1] = agent.isPerson.stockBelief[stocktype][1] + adjamount
        agent.isPerson.stockBelief[stocktype][2] = agent.isPerson.stockBelief[stocktype][2] + adjamount
    else    -- askprice > bidprice
        -- move the range down by 20% of the overbid
        local overbid = askprice - bidprice
        local adjamount = overbid * 0.20
        agent.isPerson.stockBelief[stocktype][1] = agent.isPerson.stockBelief[stocktype][1] - adjamount
        agent.isPerson.stockBelief[stocktype][2] = agent.isPerson.stockBelief[stocktype][2] - adjamount
    end
end

local function playPurchaseAudio(stocktype)

    if stockType == enum.stockFruit and love.math.random(1, 1000) == 1 then
        fun.playAudio(enum.audioEat, false, true)   -- stocktype, is music, is sound
    end
    if stocktype == enum.stockHealingHerbs and love.math.random(1, 1000) == 1 then
        fun.playAudio(enum.audioBandage, false, true)
    end
end

local function applyBuffs(agent, stocktype, amtbought)
    if stocktype == enum.stockWelfare then agent.isPerson.wealth = agent.isPerson.wealth + 1 end

    if stocktype == enum.stockFruit then agent.isPerson.fullness = agent.isPerson.fullness + 100 end

    if stocktype == enum.stockHealingHerbs then agent.isPerson.health = agent.isPerson.health + (amtbought * HERB_HEAL_AMOUNT) end

    agent.isPerson.stockInv[stocktype] = 0       -- apply buff and wipe the inventory
end

function actionbuy.newbuy(e, currentaction)
    print("Trying to buy stock type " .. currentaction.stockType)
    local agentrow = e.position.row
    local agentcol = e.position.col
    local desiredQty = currentaction.purchaseAmount

    assert(agentrow ~= nil)
    assert(agentcol ~= nil)

    local buyer = e
    local seller = MAP[agentrow][agentcol].entity.isTile.tileOwner
    local stocktype = currentaction.stockType

    assert(buyer ~= nil)
    assert(seller ~= nil)

    -- determine the bid
print("stocktype = " .. stocktype)

    local buyerlowestbelief = buyer.isPerson.stockBelief[stocktype][1]
    local buyerhighestbelief = buyer.isPerson.stockBelief[stocktype][2]
    assert(buyerlowestbelief <= buyerhighestbelief)
    local bid = love.math.random(buyerlowestbelief, buyerhighestbelief)

    -- determine the ask
    local sellerlowestbelief = seller.isPerson.stockBelief[stocktype][1]
    local sellerhighestbelief = seller.isPerson.stockBelief[stocktype][2]
    assert(sellerlowestbelief <= sellerhighestbelief)
    local ask = love.math.random(sellerlowestbelief, sellerhighestbelief)

    local amtbought = 0
    if bid >= ask then
        -- transaction successful
        -- do transaction
        local agreedprice = (bid + ask ) / 2        -- average
        amtbought = tradeGoods(buyer, seller, stocktype, desiredQty, agreedprice)

        applyBuffs(buyer, stocktype, amtbought)        -- fruit and herbs have buffs

        print("Bought stocktype " .. stocktype .. " for $" .. agreedprice)
    else
        print("Failed to agree on price for " .. stocktype)
    end
    adjustBuyersBelief(buyer, stocktype, bid, ask)
    adjustSellersBelief(seller, stocktype, bid, ask)

    if amtbought > 0 then
        playPurchaseAudio(stocktype)

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
            e.isPerson.health = e.isPerson.health + (amtbought * HERB_HEAL_AMOUNT)
            if amtbought > 0 and love.math.random(1, 1000) == 1 then
                fun.playAudio(enum.audioBandage, false, true)
            end
        else
            e.isPerson.stockInv[currentaction.stockType] = e.isPerson.stockInv[currentaction.stockType] + amtbought
        end
        e.isPerson.stockBelief[currentaction.stockType][4] = e.isPerson.stockBelief[currentaction.stockType][4] + amtbought
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
