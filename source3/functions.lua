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

function functions.loadImages()
	-- terrain tiles
	IMAGES[enum.terrainGrassDry] = love.graphics.newImage("assets/images/grass_dry_block_256x.png")
	IMAGES[enum.terrainGrassGreen] = love.graphics.newImage("assets/images/grass_green_block_256x.png")
	IMAGES[enum.terrainTeal] = love.graphics.newImage("assets/images/grass_teal_block_256x.png")
    IMAGES[enum.terrainWell] = love.graphics.newImage("assets/images/well_256.png")

	-- buildings
	IMAGES[enum.buildingFarm] = love.graphics.newImage("assets/images/house1.png")


end


return functions
