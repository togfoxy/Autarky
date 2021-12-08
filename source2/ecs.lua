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
				else
					-- not a construction worker
					if MAP[r][c]:has("hasBuilding") then
						if MAP[r][c].hasBuilding.isConstructed then
							Fun.DoWork(e)
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

    systemDecideAction = Concord.system({
        pool = {"isPerson"}
    })
    function systemDecideAction:update(dt)
        for _, e in ipairs(self.pool) do
            if not e:has("currentAction") then
                -- doing nothing. Decide action
                if e:has("occupation") then
                    -- has a job
                    if e:has("hasWorkplace") then
                        -- lets go to work
                        e:ensure("currentAction", Enum.actionMovingToWorkplace)
                        e:ensure("hasTargetTile", e.hasWorkplace.row, e.hasWorkplace.col)
                    else
                        -- has an occupation but no workplace
						if e.occupation.value == Enum.jobConstruction then
							-- look for something to construct
							local r,c = Fun.getUnbuiltBuilding()
							if r > 0 then
								e:ensure("hasWorkplace", r, c)
								e:ensure("hasTargetTile", r, c)
								e:ensure("currentAction", actionBuildingWorkplace)
							end
						else
							-- allocate a tile that will become the workplace
							local r, c = Fun.getBlankTile()
							if r > 0 then
								e:ensure("hasWorkplace", r, c)
								e:ensure("currentAction", actionMovingToWorkplace)
								e:ensure("hasTargetTile", e.hasWorkplace.row, e.hasWorkplace.col)
								MAP[r][c]:ensure("hasBuilding", Enum.buildingFarm)
							end
						end
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
				if e.occupation.value == Enum.jobConstruction then
					-- also remove workplace
					e:remove("hasWorkplace")
					e:remove("currentAction")
				end
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
    WORLD:addSystems(systemDraw, systemIsTile, systemDoWork, systemDecideAction, systemMove)

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

    -- add starting villagers
    for i = 1, NUMBER_OF_VILLAGERS do
        local VILLAGER = Concord.entity(WORLD)
        :give("drawable")
        :give("position")
        :give("maxSpeed")
        :give("uid")
        :give("isPerson")
        table.insert(VILLAGERS, VILLAGER)
    end


end


return ecs
