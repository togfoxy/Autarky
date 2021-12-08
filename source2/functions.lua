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

function functions.AtWorkplace(e)
    -- check if entity has a workplace and is at the at the workplace
    local result = false
    if e:has("hasWorkplace") then
        local erow, ecol = Fun.getRowColfromXY(e.position.x, e.position.y)
        if erow == e.hasWorkplace.row and ecol == e.hasWorkplace.col then
            result  = true
        end
    end
    return result
end

function functions.DoWork(e,dt)
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

function functions.getLabel(e)
    -- construct a label and pass it back to the drawing loop
    local text = ""
    if e:has("currentAction") then
        text = text .. e.currentAction.value .. "\n"
    end
    text = text .. Cf.round(e.wealth.value) .. "\n"


    return text
end


return functions
