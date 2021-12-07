GAME_VERSION = "0.03"

Inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

TLfres = require 'lib.tlfres'
-- https://love2d.org/wiki/TLfres

Concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

Cf = require 'lib.commonfunctions'
Fun = require 'functions'
Ecs = require 'ecs'
Enum = require 'enum'


SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}
IMAGES = {}

TILE_SIZE = 50
NUMBER_OF_ROWS = (Cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 2
NUMBER_OF_COLS = (Cf.round(SCREEN_WIDTH / TILE_SIZE)) - 2

print("There are " .. NUMBER_OF_ROWS .. " rows and " .. NUMBER_OF_COLS .. " columns.")

NUMBER_OF_VILLAGERS = 3

MAP = {}			-- a 2d table of tiles
VILLAGERS = {}

function love.keyreleased(key, scancode)
	if key == "escape" then
		Cf.RemoveScreen(SCREEN_STACK)
	end

	-- turn selected bots into farmers
	if key == "f" then

		for k,v in pairs(VILLAGERS) do
			if v:has("isSelected") and (not v:has("occupation")) then
				v:ensure("occupation", Enum.jobFarmer)
				v:remove("isSelected")
			end
		end
	end
end

function love.mousepressed( x, y, button, istouch, presses )

	local mousex,mousey = TLfres.getMousePosition(SCREEN_WIDTH, SCREEN_HEIGHT)    -- lets you pretend screen is 1920 * 1080

	if button == 1 then
		-- select the villager if clicked, else select the tile (further down)
		local villagerclicked = false
		for k, v in pairs(VILLAGERS) do
			x2 = v.position.x
			y2 = v.position.y
			local dist = Cf.GetDistance(mousex, mousey, x2, y2)
			if dist <= Enum.personDrawWidth then
				if v.isSelected then
					v:remove("isSelected")
				else
					v:ensure("isSelected")
				end
				villagerclicked = true
			end
		end

		-- if a villager was clicked then don't click the underlying tile
		if not villagerclicked then
			local row, col = Fun.getRowColfromXY(mousex, mousey)
			if row < 1 then row = 1 end
			if col < 1 then col = 1 end

			if row > NUMBER_OF_ROWS then row = NUMBER_OF_ROWS end
			if col > NUMBER_OF_COLS then col = NUMBER_OF_COLS end

			if not MAP[row][col].isSelected then
				MAP[row][col]:ensure("isSelected")
			else
				MAP[row][col]:remove("isSelected")
			end
		end

	end
end

function love.load()

    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

	love.window.setTitle("Autarky " .. GAME_VERSION)

	Cf.AddScreen("World", SCREEN_STACK)

	Fun.loadImages()
	Fun.initialiseMap()
	Ecs.init()	-- loads all the components etc
	WORLD:emit("init")	-- triggers the init functions which load arrays and tables

end


function love.draw()

	TLfres.beginRendering(SCREEN_WIDTH,SCREEN_HEIGHT)

	WORLD:emit("draw")

	TLfres.endRendering({0, 0, 0, 1})

end


function love.update(dt)
	WORLD:emit("update", dt)
end
