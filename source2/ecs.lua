ecs = {}


function ecs.init()

    -- Create the World
    WORLD = Concord.world()

    local compmodule = require 'comp'

    -- define components
    compmodule.init()

    -- define Systems
    systemDraw = Concord.system({
        pool = {"position", "drawable"}
    })
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        for _, e in ipairs(self.pool) do
            if e.isTile then
                local img = IMAGES[e.isTile.imageNumber]
                local x, y = e.position.x - (TILE_SIZE / 2), e.position.y - (TILE_SIZE / 2)
				love.graphics.setColor(1,1,1,1)
                love.graphics.draw(img, x, y, 0, TILE_SIZE / 256)
                if e.isSelected then
                    love.graphics.rectangle("line", x, y, TILE_SIZE, TILE_SIZE - 1)
                end
				-- draw a building if there is one
				if e:has("hasBuilding") then
					if e.hasBuilding.isConstructed then
						love.graphics.setColor(1,1,1,1)
					else
						-- ghost buildings not yet constructed
						love.graphics.setColor(1,1,1,0.5)
					end

					love.graphics.draw(IMAGES[e.hasBuilding.buildingNumber], x + (TILE_SIZE / 4), y, 0, 1, 1)
				end
				love.graphics.setColor(1,1,1,1)
            end

            if e.isPerson then
                love.graphics.setColor(1,1,1,1)
                if e:has("occupation") then
                    if e.occupation.value == Enum.jobFarmer then
                        love.graphics.setColor(0,1,0,1)
                    end
                    if e.occupation.value == Enum.jobConstruction then
                        love.graphics.setColor(1,1,0,1)		-- yellow
                    end
                end
                local drawwidth = Enum.personDrawWidth
                local x, y = e.position.x, e.position.y
                love.graphics.circle("fill", x, y, drawwidth)
                if e.isSelected then
                    love.graphics.setColor(1,0,0,1)
                    love.graphics.circle("fill", x, y, drawwidth / 2)
                    love.graphics.setColor(1,1,1,1)
                end
                local text = Fun.getLabel(e)
                love.graphics.setColor(1,1,1,1)
                love.graphics.print(text, x + 15, y - 7)
            end
        end
    end

    systemDoWork = Concord.system({
        pool = {"occupation"}
    })
    function systemDoWork:update(dt)
        -- ensure a workplace exists
        -- if not at workplace then set targetTile
        -- if at workplace then do work
        for _, e in ipairs(self.pool) do
            if Fun.AtWorkplace(e) then
				local r, c = Fun.getRowColfromXY(e.position.x, e.position.y)		-- feed in col then row
				-- constructors need to build
				if e.occupation.value == Enum.jobConstruction then
					if MAP[r][c]:has("hasBuilding") then
						if not MAP[r][c].hasBuilding.isConstructed then
							-- construct building
							MAP[r][c].hasBuilding.isConstructed = true
						end
					end
                    -- process wages etc for a hard work
                    Fun.DoWork(e, dt)
                    if e.occupation.timeWorking > Enum.timerWorkperiod then
                        e.occupation.timeWorking = 0
                        e:remove("hasTargetTile")
                        -- e:remove("currentAction")
                        Fun.removeActionFromQueue(e)
print("juliet")
                        -- when the building is donw and timer is expired then find new workplace
                        e:remove("hasWorkplace")
                    end
				else
					-- not a construction worker
					if MAP[r][c]:has("hasBuilding") then
						if MAP[r][c].hasBuilding.isConstructed then
							Fun.DoWork(e, dt)
                            if e.occupation.timeWorking > Enum.timerWorkperiod then
                                e.occupation.timeWorking = 0
                                e:remove("hasTargetTile")
                                -- e:remove("currentAction")
                                Fun.removeActionFromQueue(e)
print("kilo")
                            end
						else
							-- has an occupation and a work place but the building is not yet constructed. Do nothing.
						end
					else
						-- can't do work - no building allocated. Is this even possible?
					end
				end
            end
        end
    end

    systemPersonTick = Concord.system({
        pool = {"isPerson"}
    })
    function systemPersonTick:update(dt)
        for _, e in ipairs(self.pool) do
            -- process hunger
            e.fullness.value = e.fullness.value  - (1 * dt)

            if e:has("currentAction") then
                if #e.currentAction.value > 0 then
-- print("alpha")
                    local myaction = e.currentAction.value[1]

                    if myaction == Enum.actionMoveToTile and e:has("hasTargetTile") then
                        -- adjust x and y
                        Fun.applyMovement(e, e.maxSpeed.value, dt)
                        -- remove hasTargetTile if at destination
            			local targetx, targety = Fun.getXYfromRowCol(e.hasTargetTile.row, e.hasTargetTile.col)
            			if (Cf.round(e.position.y,2) == Cf.round(targety,2)) and Cf.round(e.position.x,2) == Cf.round(targetx,2) then
                            e:remove("hasTargetTile")
                            Fun.removeActionFromQueue(e)
print("lima")
                        end
                    end
-- print("bravo")
                    if myaction == Enum.actionEat then
                        -- if at an eatery then eat
                        -- see if at an eating place
                        local r, c = Fun.getClosestBuilding(e, Enum.buildingFarm)
                        if r > 0 then
                            Fun.updateRowCol(e)
print(e.position.row, e.position.col, r, c)
                            if e.position.row == r and e.position.col == c then
                                -- at an eatery so eat
                                local amt = 1 * dt * 4  -- fullness gain * delta * a magnifier to make this go faster
                                e.fullness.value = e.fullness.value + amt
                                e.wealth.value = e.wealth.value - amt
                                -- keep eating till full or broke
                                if e.wealth.value < 1 or e.fullness.value > 99 then
                                    Fun.removeActionFromQueue(e)
print("Boo boo")
                                end
                            else
                                -- not an an eatery. Consider adding a "move" action later on
                                -- "eat" is at the top of the queue but can't eat so remove it from the head of the queue
                                Fun.removeActionFromQueue(e)
print("Boo")
                            end
                        else
                            -- no eateries exist so do nothing
                        end
                    end
-- print("foxtrot " .. myaction)
                    if myaction == Enum.actionBuild and e:has("occupation") then
-- print("echo")
                        if e.occupation.value == Enum.jobConstruction then
                            Fun.updateRowCol(e)
                            local r, c = e.position.row, e.position.col
                            if MAP[r][c]:has("hasBuilding") then
                                if MAP[r][c].hasBuilding.isConstructed == false then
                                    -- construct building
-- print("charlie", e.occupation.timeWorking)
                                    Fun.getPaid(e,dt)
                                    if e.occupation.timeWorking > Enum.timerWorkperiod then
-- print("delta")
                                        e.occupation.timeWorking = 0
                                        Fun.removeActionFromQueue(e)
print("golf")
                                        e:remove("hasWorkplace")
                                        MAP[r][c].hasBuilding.isConstructed = true
                                    end
                                end
                            else
                                -- have a build order but no building on this tile. Remove the build order
                                Fun.removeActionFromQueue(e)
print("hotel")
                            end
                        else
                            print("alpha: " .. myaction, e:has("occupation"), e.occupation.value)
                            error("a non-builder has 'build' in their action queue'")
                        end
                    end

                    if myaction == Enum.actionWork and e:has("occupation") then
                        if Fun.atWorkplace(e) then
                            local r, c = Fun.getRowColfromXY(e.position.x, e.position.y)
                            if MAP[r][c]:has("hasBuilding") then
                                if MAP[r][c].hasBuilding.isConstructed then
                            		Fun.getPaid(e,dt)
                                    if e.occupation.timeWorking > Enum.timerWorkperiod then
                                        e.occupation.timeWorking = 0
                                        Fun.removeActionFromQueue(e)
print("indigo")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    systemDecideAction = Concord.system({
        pool = {"isPerson"}
    })
    function systemDecideAction:update(dt)
        for _, e in ipairs(self.pool) do
            -- person is hungry and can afford food?
            if e.fullness.value <= 33 and e.wealth.value > 10 then
                -- try to move to food and eat
                 -- find closest farm
                local r, c = Fun.getClosestBuilding(e, Enum.buildingFarm)
                if r > 0 then
                    -- set target to farm
                    Fun.addActionToQueue(e, Enum.actionMoveToTile)
                    e:ensure("hasTargetTile", r, c)
                    functions.addActionToQueue(e, Enum.actionEat)
                end
            else
                -- work if possible
                if e:has("occupation") then
                    if e:has("hasWorkplace") then
                        if not Fun.atWorkplace(e) then
                            Fun.addActionToQueue(e, Enum.actionMoveToTile)
                            e:ensure("hasTargetTile", e.hasWorkplace.row, e.hasWorkplace.col)
                        end

                        -- check if a builder
                        if (e.occupation.value == Enum.jobConstruction) then
                            Fun.addActionToQueue(e, Enum.actionBuild)
                        else
                            -- Not a builder - lets go to work
                            Fun.addActionToQueue(e, Enum.actionWork)
                        end
                    else
                        -- has no workplace but is allowed to have one so create one
                        if e.occupation.value == Enum.jobConstruction then
                            -- look for something to construct
                            local r,c = Fun.getUnbuiltBuilding()
                            if r > 0 then
                                e:ensure("hasWorkplace", r, c)
                                e:ensure("hasTargetTile", r, c)
                                Fun.addActionToQueue(e, Enum.actionMoveToTile)
                                Fun.addActionToQueue(e, Enum.actionBuild)
                            else
                                -- nothing to do - use random movements
                                local newrow, newcol = Fun.getRandomMovement(e)
                                e:ensure("hasTargetTile", newrow, newcol)
                                Fun.addActionToQueue(e, Enum.actionMoveToTile)
                            end
                        else
                            -- allocate a tile that will become the workplace
                            local r, c = Fun.getBlankTile()
                            if r > 0 then
                                e:ensure("hasWorkplace", r, c)
                                e:ensure("hasTargetTile", e.hasWorkplace.row, e.hasWorkplace.col)
                                Fun.addActionToQueue(e, Enum.actionMoveToTile)
                                Fun.addActionToQueue(e, Enum.actionWork)
                                MAP[r][c]:ensure("hasBuilding", Enum.buildingFarm)
                            end
                        end
                    end
                else
                    -- no occupation
                    -- move a random ammount
                    if #e.currentAction.value == 0 then
-- print("hi")
                        local newrow, newcol = Fun.getRandomMovement(e)
                        e:ensure("hasTargetTile", newrow, newcol)
                        Fun.addActionToQueue(e, Enum.actionMoveToTile)
                    end
                end
            end
        end
    end

    systemMove = Concord.system({
        pool = {"hasTargetTile"}
    })
    function systemMove:update(dt)
        for k, e in ipairs(self.pool) do
            -- adjust x and y
            Fun.applyMovement(e, e.maxSpeed.value, dt)
            -- remove hasTargetTile if at destination
			local targetx, targety = Fun.getXYfromRowCol(e.hasTargetTile.row, e.hasTargetTile.col)
			if (Cf.round(e.position.y,2) == Cf.round(targety,2)) and Cf.round(e.position.x,2) == Cf.round(targetx,2) then
                e:remove("hasTargetTile")
            end
        end
    end

    systemIsTile = Concord.system({
        pool = {"isTile"},
        --poolB = {"isPerson"}
    })
    function systemIsTile:init()
        self.pool.onEntityAdded = function(_, entity)
            local row = entity.position.row
            local col = entity.position.col
            MAP[row][col] = entity
        end
        --self.poolB.onEntityAdded = function(_, entity)
        --    table.insert(VILLAGERS, entity)
        --end
    end

    -- Add the Systems
    WORLD:addSystems(systemDraw, systemIsTile, systemDecideAction, systemPersonTick)

    -- Create entitites

    -- create tiles
    for col = 1, NUMBER_OF_COLS do
        for row = 1, NUMBER_OF_ROWS do
            local TILES = Concord.entity(WORLD)
            :give("drawable")
            :give("position", row, col)
            :give("isTile")
            :give("uid")
        end
    end

    -- add a well
    local wellrow = love.math.random(4,NUMBER_OF_ROWS - 3)
    local wellcol = love.math.random(4,NUMBER_OF_COLS - 3)
    local WELL = Concord.entity(WORLD)
    :give("drawable")
    :give("position", wellrow, wellcol)
    :give("isTile", Enum.terrainWell)
    :give("uid")
    WELL_ROW = wellrow
    WELL_COL = wellcol

    -- add starting villagers
    for i = 1, NUMBER_OF_VILLAGERS do
        local VILLAGER = Concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("maxSpeed")
        :give("uid")
        :give("isPerson")
        :give("wealth")
        :give("fullness")
        :give("currentAction")
        table.insert(VILLAGERS, VILLAGER)
    end
end
return ecs
