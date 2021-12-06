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
    local r = Cf.round(y / TILE_SIZE)
    local c = Cf.round(x / TILE_SIZE)
    return r, c

end

function functions.loadImages()
	IMAGES[Enum.terrainGrassDry] = love.graphics.newImage("assets/images/grass_dry_block_256x.png")
	IMAGES[Enum.terrainGrassGreen] = love.graphics.newImage("assets/images/grass_green_block_256x.png")
	IMAGES[Enum.terrainTeal] = love.graphics.newImage("assets/images/grass_teal_block_256x.png")
    IMAGES[Enum.terrainWell] = love.graphics.newImage("assets/images/well_256.png")
end





return functions
