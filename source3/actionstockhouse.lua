actionstockhouse = {}

function actionstockhouse.stockhouse(e, currentaction)
    -- transfer wood from agent to house
    local woodamt = e.isPerson.stockInv[enum.stockWood]
    e.isPerson.stockInv[enum.stockWood] = 0

    local houserow = e.residence.row
    local housecol = e.residence.col
    MAP[houserow][housecol].entity.isTile.stockLevel = MAP[houserow][housecol].entity.isTile.stockLevel + woodamt
    table.remove(e.isPerson.queue, 1)
    fun.addLog(e, currentaction.log)
end






return actionstockhouse
