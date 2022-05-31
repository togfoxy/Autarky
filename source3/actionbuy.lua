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
        purchaseamt = math.floor(purchaseamt)       -- round down to nearest unit
        if purchaseamt <= 0 then purchaseamt = 0 end
        shoptile.stockLevel = shoptile.stockLevel  - purchaseamt
    else
        local canafford = math.floor(buyer.isPerson.wealth / agreedprice)     -- units that can be afforded rounds down
        purchaseamt = math.min(stockavail, canafford, desiredQty)   -- limit transaction to what can be afforded, desired and provisioned
        purchaseamt = math.floor(purchaseamt)       -- round down to nearest unit
        if purchaseamt <= 0 then purchaseamt = 0 end
        if purchaseamt > 0 then
            local transactionprice = purchaseamt * agreedprice      -- purchaseamt is the quantity of stocks moved

            shoptile.stockLevel = shoptile.stockLevel  - purchaseamt
            buyer.isPerson.stockInv[stocktype] = buyer.isPerson.stockInv[stocktype] + purchaseamt

            seller.isPerson.wealth = seller.isPerson.wealth + (transactionprice * (1-GST_RATE))
            seller.isPerson.taxesOwed = seller.isPerson.taxesOwed + (transactionprice * GST_RATE)
            buyer.isPerson.wealth = buyer.isPerson.wealth - transactionprice

            buyer.isPerson.stockBelief[stocktype][3] = buyer.isPerson.stockBelief[stocktype][3] + transactionprice
            buyer.isPerson.stockBelief[stocktype][4] = buyer.isPerson.stockBelief[stocktype][4] + purchaseamt

            seller.isPerson.stockBelief[stocktype][3] = seller.isPerson.stockBelief[stocktype][3] + transactionprice
            seller.isPerson.stockBelief[stocktype][4] = seller.isPerson.stockBelief[stocktype][4] + purchaseamt

            -- if purchaseamt > 0 then
            --     -- log the transaction for future graphing
            --     local nextindex = #STOCK_HISTORY[stocktype] + 1
            --     STOCK_HISTORY[stocktype][nextindex] = agreedprice
            --     if #STOCK_HISTORY[stocktype] > 100 then
            --         table.remove(STOCK_HISTORY[stocktype], 1)
            --     end
            -- end
        end
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

    -- data checking
    if agent.isPerson.stockBelief[stocktype][1] <= 0 then agent.isPerson.stockBelief[stocktype][1] = 0.5 end
    if agent.isPerson.stockBelief[stocktype][2] < agent.isPerson.stockBelief[stocktype][1] then
        agent.isPerson.stockBelief[stocktype][2] = agent.isPerson.stockBelief[stocktype][1]
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

    -- data checking
    if agent.isPerson.stockBelief[stocktype][1] <= 0 then agent.isPerson.stockBelief[stocktype][1] = 0.5 end
    if agent.isPerson.stockBelief[stocktype][2] < agent.isPerson.stockBelief[stocktype][1] then
        agent.isPerson.stockBelief[stocktype][2] = agent.isPerson.stockBelief[stocktype][1]
    end
end

local function playPurchaseAudio(stocktype)

    if stockType == enum.stockFruit and love.math.random(1, 1000) == 1 then
        fun.playAudio(enum.audioEat, false, true)   -- stocktype, is music, is sound
    end
    if stocktype == enum.stockHealingHerbs and love.math.random(1, 500) == 1 then
        fun.playAudio(enum.audioBandage, false, true)
    end
end

local function applyBuffs(agent, stocktype, amtbought)
    if stocktype == enum.stockWelfare then
        agent.isPerson.wealth = agent.isPerson.wealth + 1
        agent.isPerson.stockInv[stocktype] = 0       -- apply buff and wipe the inventory
    end

    if stocktype == enum.stockFruit then
        agent.isPerson.fullness = agent.isPerson.fullness + 100
        agent.isPerson.stockInv[stocktype] = 0       -- apply buff and wipe the inventory
    end

    if stocktype == enum.stockHealingHerbs then
        -- print("Agent health was " .. agent.isPerson.health)
        agent.isPerson.health = agent.isPerson.health + (amtbought * HERB_HEAL_AMOUNT)
        -- print("Bought " .. amtbought .. " herbs that heal at " .. HERB_HEAL_AMOUNT .. " per unit." )
        -- print("Agent health is now " .. agent.isPerson.health)
        agent.isPerson.stockInv[stocktype] = 0       -- apply buff and wipe the inventory
    end
end

function actionbuy.newbuy(e, currentaction)
    -- print("Trying to buy stock type " .. currentaction.stockType)
    local agentrow = e.position.row
    local agentcol = e.position.col
    local desiredQty = currentaction.purchaseAmount

    assert(agentrow ~= nil)
    assert(agentcol ~= nil)

    local buyer = e
    local seller = MAP[agentrow][agentcol].entity.isTile.tileOwner
    local stocktype = currentaction.stockType

    local bid, ask = 0, 99      -- default values

    assert(buyer ~= nil)
    if (seller ~= nil) then
        if stocktype == enum.stockWelfare then
            bid = 0
            ask = 0
        else
            -- determine the bid
            local buyerlowestbelief = buyer.isPerson.stockBelief[stocktype][1]
            local buyerhighestbelief = buyer.isPerson.stockBelief[stocktype][2]
            assert(buyerlowestbelief <= buyerhighestbelief)
            bid = love.math.random(buyerlowestbelief * 10, buyerhighestbelief * 10)
            bid = bid / 10
            if bid <= 0 then bid = 0 end

            -- determine the ask
            assert(buyer ~= nil)
            assert(seller.isPerson ~= {})

            if seller.isPerson ~= nil then  -- don't know how it can be nil but it happens somehow. Maybe villager dies?
                local sellerlowestbelief = seller.isPerson.stockBelief[stocktype][1]
                local sellerhighestbelief = seller.isPerson.stockBelief[stocktype][2]
                assert(sellerlowestbelief <= sellerhighestbelief)
                ask = love.math.random(sellerlowestbelief * 10, sellerhighestbelief * 10)
                ask = ask / 10
            else
                ask = 999   -- nonsense value. Not sure if this is a good idea
            end
            if ask <= 0.1 then ask = 0.1 end

            assert(buyer ~= nil)
            assert(seller ~= nil)

            if MAP[agentrow][agentcol].entity.isTile.stockLevel >= 3 then
                -- offer a discount due to too much supply
                ask = ask * 0.8
            end
            if buyer == seller then
                -- make bid same as ask just to ensure the transaction is successful
                bid = 1
                ask = 1
            end
        end

        local amtbought = -1    -- 0 = can't afford; >0 means successful transaction, -1 = bid unsuccessful
        if bid >= ask then
            -- transaction successful
            -- do transaction
            local agreedprice = (bid + ask ) / 2        -- average
            amtbought = tradeGoods(buyer, seller, stocktype, desiredQty, agreedprice)

            if amtbought >= 1 then
                applyBuffs(buyer, stocktype, amtbought)        -- fruit and herbs have buffs
                if seller ~= buyer then
                    adjustBuyersBelief(buyer, stocktype, bid, ask)
                    adjustSellersBelief(seller, stocktype, bid, ask)
                    print("Bought stocktype " .. stocktype .. " for $" .. cf.round(agreedprice,2) .. " each.")
                end
            else
                print("Agreed on a price but no wealth left")
            end
        else
            print("Failed to agree on price for " .. stocktype .. ". Bid = " .. bid .. " / " .. cf.round(ask, 2))
            adjustBuyersBelief(buyer, stocktype, bid, ask)
            adjustSellersBelief(seller, stocktype, bid, ask)
        end

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


    else
        -- shop/tile has no owner. Probably died. Do nothing.
    end
    table.remove(e.isPerson.queue, 1)
    fun.addLog(e, currentaction.log)
end

return actionbuy
