functions = {}

function functions.initialiseMap()
    for row = 1, NUMBER_OF_ROWS do
		MAP[row] = {}
	end
	for col = 1, NUMBER_OF_COLS do
		for row = 1,NUMBER_OF_ROWS do
			MAP[row][col] = {}
		end
	end
end

function functions.getXYfromRowCol(row, col)
    -- determine the drawing x based on column
    -- input row and col
    -- returns x, y (reverse order)
    local x = (col * TILE_SIZE)
    local y = (row * TILE_SIZE)
    return x, y
end

function functions.getRowColfromXY(x, y)
    -- returns row and col
    local r = Cf.round(y / TILE_SIZE)
    local c = Cf.round(x / TILE_SIZE)
    return r, c

end

function functions.loadImages()
	-- terrain tiles
	IMAGES[Enum.terrainGrassDry] = love.graphics.newImage("assets/images/grass_dry_block_256x.png")
	IMAGES[Enum.terrainGrassGreen] = love.graphics.newImage("assets/images/grass_green_block_256x.png")
	IMAGES[Enum.terrainTeal] = love.graphics.newImage("assets/images/grass_teal_block_256x.png")
    IMAGES[Enum.terrainWell] = love.graphics.newImage("assets/images/well_256.png")

	-- buildings
	IMAGES[Enum.buildingFarm] = love.graphics.newImage("assets/images/house1.png")


end

function functions.atWorkplace(e)
    -- check if entity has a workplace and is at the at the workplace
    -- returns a boolean value
    local result = false
    if e:has("hasWorkplace") then
        local erow, ecol = Fun.getRowColfromXY(e.position.x, e.position.y)
        if erow == e.hasWorkplace.row and ecol == e.hasWorkplace.col then
            result  = true
        end
    end
    return result
end

function functions.getPaid(e,dt)
    e.occupation.timeWorking = e.occupation.timeWorking + dt

    if e.occupation.value == Enum.jobFarmer then
        e.wealth.value = e.wealth.value + (Enum.workIncomeFarmer * dt)
    elseif e.occupation.value == Enum.jobConstruction then
        e.wealth.value = e.wealth.value +  (Enum.workIncomeConstruction * dt)
    end

    --! make sound some of the time
end

function functions.getBlankTile()
    -- return a tile row/col that has no buildings on it (or wells)
    local r
    local c
    repeat
        r = love.math.random(1, NUMBER_OF_ROWS)
        c = love.math.random(1, NUMBER_OF_COLS)
    until not MAP[r][c]:has("hasBuilding")
    return r, c
end

function functions.applyMovement(e, velocity, dt)
    -- assumes an entity has a position and a target.
    -- return a new row/col that progresses towards that target

    local distancemovedthisstep = velocity * dt
    -- map row/col to x/y
    local currentx = (e.position.x)
    local currenty = (e.position.y)
    local targetx, targety = Fun.getXYfromRowCol(e.hasTargetTile.row, e.hasTargetTile.col)

    -- get the vector that moves the entity closer to the destination
    local xvector = targetx - currentx  -- tiles
    local yvector = targety - currenty  -- tiles

  --print(distancemovedthisstep, currentx,currenty,targetx,targety,xvector,yvector)

    local xscale = math.abs(xvector / distancemovedthisstep)
    local yscale = math.abs(yvector / distancemovedthisstep)
    local scale = math.max(xscale, yscale)

    if scale > 1 then
        xvector = xvector / scale
        yvector = yvector / scale
    end

    currentx = Cf.round(currentx + xvector, 1)
    currenty = Cf.round(currenty + yvector, 1)

    e.position.x = currentx
    e.position.y = currenty

  -- print(currentx, currenty, xvector  , yvector  )

    e.position.row = (currenty / TILE_SIZE)
    e.position.col = (currentx / TILE_SIZE)
    if e.position.row < 1 then e.position.row = 1 end
    if e.position.col < 1 then e.position.col = 1 end
    if e.position.row > NUMBER_OF_ROWS then e.position.row = NUMBER_OF_ROWS end
    if e.position.col > NUMBER_OF_COLS then e.position.col = NUMBER_OF_COLS end
end

function functions.getUnbuiltBuilding()
	-- scans the MAP table for a building that is not yet constructed and returns row/col

	for col = 1, NUMBER_OF_COLS do
		for row = 1, NUMBER_OF_ROWS do
			if MAP[row][col]:has("hasBuilding") then
				if MAP[row][col].hasBuilding.isConstructed == false then
					return row, col
				end
			end
		end
	end
	return 0,0
end

function functions.getClosestBuilding(e, buildingtype)
    for col = 1, NUMBER_OF_COLS do
		for row = 1, NUMBER_OF_ROWS do
			if MAP[row][col]:has("hasBuilding") then
				if MAP[row][col].hasBuilding.isConstructed == true then
                    if MAP[row][col].hasBuilding.buildingNumber == buildingtype then
                        if MAP[row][col]:has("stock") then
                            if MAP[row][col].stock.value > 10 then
                               return row, col
                            end
                        end
                    end
				end
			end
		end
	end
	return 0,0
end

function functions.getLabel(e)
    -- construct a label and pass it back to the drawing loop
    local text = ""
    text = text .. "Wealth: " .. Cf.round(e.wealth.value) .. "\n"
    text = text .. "Fullness: " .. Cf.round(e.fullness.value) .. "\n"

    local r, c = Fun.getRowColfromXY(e.position.x, e.position.y)
    if MAP[r][c]:has("stock") then
        text = text .. "Stock: " .. Cf.round(MAP[r][c].stock.value) .. "\n"
    end

    if #e.currentAction.value > 0 then
        text = text .. "~~~" .. "\n"
        for k, v in ipairs(e.currentAction.value) do
            text = text .. v .. "\n"
        end
    end
    return text
end

function functions.updateRowCol(e)
    -- ensure the row/col correctly reflects the x/y
    -- returns nothing (not a function)
    local r, c = Fun.getRowColfromXY(e.position.x, e.position.y)
    e.position.row = r
    e.position.col = c
end

function functions.addActionToQueue(e, action)
    -- action = Enum
    if not e:has("currentAction") then
        e:ensure("currentAction")
    end

    if not Cf.bolTableHasValue (e.currentAction.value, action) then
        table.insert(e.currentAction.value, action)
    end
end

function functions.removeActionFromQueue(e)
   -- remove an action from the entities queue then remove the component if empty
   table.remove(e.currentAction.value, 1)
   if #e.currentAction.value < 1 then
       -- e:remove("currentAction")
   end
-- print("removed")
end

function functions.getRandomMovement(e)
    -- get random directions to simulate idle movement
    -- returns a row, col
    Fun.updateRowCol(e)
    local newrow = love.math.random(e.position.row - 1, e.position.row + 1)
    local newcol = love.math.random(e.position.col - 1, e.position.col + 1)

    if newrow < 1 then newrow = 1 end
    if newcol < 1 then newcol = 1 end

    if newrow > NUMBER_OF_ROWS then newrow = NUMBER_OF_ROWS end
    if newcol > NUMBER_OF_COLS then newcol = NUMBER_OF_COLS end

    return newrow, newcol
end


return functions
