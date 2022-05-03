ecsfunctions = {}

function ecsfunctions.init()

    -- create the world
    WORLD = concord.world

    local compmodule = require 'comp'

    -- define components
    compmodule.init()

    -- define systems
    systemDraw = concord.systems({pool = {"drawable"}})
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
    end

    -- ## define more systems here

    -- add the systems to the world
    -- ## ensure all systems are added to the world
    WORLD:addSystems(systemDraw)

    -- create entities

    -- add starting villagers
    for i = 1, NUMBER_OF_VILLAGERS do
        local VILLAGER = Concord.entity(WORLD)
        :give("drawable")
        table.insert(VILLAGERS, VILLAGER)
    end

end

return ecsfunctions
