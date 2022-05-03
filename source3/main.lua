GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'
fun = require 'functions'
ecs = require 'ecsfunctions'
enum = require 'enum'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}
IMAGES = {}

TILE_SIZE = 50
NUMBER_OF_ROWS = (cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 2
NUMBER_OF_COLS = (cf.round(SCREEN_WIDTH / TILE_SIZE)) - 1
BORDER_SIZE = 25
UPPER_TERRAIN_HEIGHT = 6

print("There are " .. NUMBER_OF_ROWS .. " rows and " .. NUMBER_OF_COLS .. " columns.")

-- capture the tile that has the well
WELLS = {}
WELLS[1] = {}
WELLS[1].row = love.math.random(3, NUMBER_OF_ROWS - 4)  -- The 3 and -2 keeps the well off the screen edge
WELLS[1].col = love.math.random(3, NUMBER_OF_COLS - 2)

NUMBER_OF_VILLAGERS = 3
PERSON_DRAW_WIDTH = 10

MAP = {}			-- a 2d table of tiles
VILLAGERS = {}

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
end

function love.load()

    res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)

    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

    love.window.setTitle("Autarky " .. GAME_VERSION)

	cf.AddScreen("World", SCREEN_STACK)

    fun.loadImages()
    fun.initialiseMap()     -- initialises 2d map with nils
    ecsfunctions.init()	    -- loads all the components etc
    WORLD:emit("init")      -- triggers the init functions which load arrays and tables

end

function love.draw()

    res.start()
    res.stop()

    WORLD:emit("draw")

    -- -- draw tile types (grass etc)
    -- for col = 1, NUMBER_OF_COLS do
    --     for row = 1,NUMBER_OF_ROWS do
    --         -- convert col/row into x/y
    --         local drawx, drawy = fun.getXYfromRowCol(row, col)
    --         local imagex = IMAGES[MAP[row][col].tiletype]:getWidth()
    --         local imagey = IMAGES[MAP[row][col].tiletype]:getHeight()
    --
    --         local drawscalex = (TILE_SIZE / imagex)
    --         local drawscaley = (TILE_SIZE / imagey)
    --
    --         love.graphics.setColor(1,1,1,1)
    --         love.graphics.draw(IMAGES[MAP[row][col].tiletype], drawx, drawy, 0, drawscalex, drawscaley)
    --         -- love.graphics.print(MAP[row][col].tiletype, drawx, drawy)
    --         -- love.graphics.print(MAP[row][col].height, drawx, drawy)
    --     end
    -- end

    -- draw contour lines (height)
    -- for col = 1, NUMBER_OF_COLS do
    --     for row = 1,NUMBER_OF_ROWS do
    --         -- check if top neighbour is different to current cell
    --         if row > 1 then
    --             if MAP[row-1][col].height ~= MAP[row][col].height then
    --                 -- draw line
    --                 local x1, y1 = fun.getXYfromRowCol(row, col)
    --                 local x2, y2 = x1 + TILE_SIZE, y1
    --                 local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
    --                 love.graphics.setColor(1,1,1,alpha)
    --                 love.graphics.line(x1, y1, x2, y2)
    --             end
    --         end
    --         -- left side
    --         if col > 1 then
    --             if MAP[row][col-1].height ~= MAP[row][col].height then
    --                 -- draw line
    --                 local x1, y1 = fun.getXYfromRowCol(row, col)
    --                 local x2 = x1
    --                 local y2 = y1 + TILE_SIZE
    --                 local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
    --                 love.graphics.setColor(1,1,1,alpha)
    --                 love.graphics.line(x1, y1, x2, y2)
    --             end
    --         end
    --     end
    -- end
    --
    -- -- draw water wells
    -- for k,well in pairs(WELLS) do
    --     local drawx, drawy = fun.getXYfromRowCol(well.row, well.col)
    --     local imagex = IMAGES[enum.terrainWell]:getWidth()
    --     local imagey = IMAGES[enum.terrainWell]:getHeight()
    --
    --     local drawscalex = (TILE_SIZE / imagex)
    --     local drawscaley = (TILE_SIZE / imagey)
    --
    --     love.graphics.setColor(1,1,1,1)
    --     love.graphics.draw(IMAGES[enum.terrainWell], drawx, drawy, 0, drawscalex, drawscaley)
    -- end

end


function love.update(dt)

    WORLD:emit("update", dt)

	res.update()


end
