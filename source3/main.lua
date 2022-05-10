GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

ft = require 'lib.foxtree'		-- foxtree

cf = require 'lib.commonfunctions'
fun = require 'functions'
ecs = require 'ecsfunctions'
enum = require 'enum'
bt = require 'behaviortree'
draw = require 'draw'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}
IMAGES = {}

TILE_SIZE = 50
NUMBER_OF_ROWS = (cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 2
NUMBER_OF_COLS = (cf.round(SCREEN_WIDTH / TILE_SIZE)) - 1
LEFT_MARGIN = TILE_SIZE / 2
TOP_MARGIN = TILE_SIZE / 2

-- debugging
-- NUMBER_OF_ROWS = 4
-- NUMBER_OF_COLS = 5

UPPER_TERRAIN_HEIGHT = 6

print("There are " .. NUMBER_OF_ROWS .. " rows and " .. NUMBER_OF_COLS .. " columns.")

NUMBER_OF_VILLAGERS = 3
PERSON_DRAW_WIDTH = 10

MAP = {}			-- a 2d table of tiles
VILLAGERS = {}
TREE = {}			-- a tree that holds all possible behaviours for a person
WALKING_SPEED = 50

DEBUG = false
NEW_VILLAGER_TIMER = 0

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
	-- turn selected agent into farmers
	if key == "f" then
		for k,v in pairs(VILLAGERS) do
			if v:has("isSelected") and (not v:has("occupation")) then
				-- print("occup granted")
				v:ensure("occupation", enum.jobFarmer, enum.stockFruit)		-- a farmer that farms fruit
				v:remove("isSelected")
			end
		end
	end
end


function love.mousepressed( x, y, button, istouch, presses )

	--! local mousex,mousey = res.toScreen(x, y)
    local mousex = x
    local mousey = y

	if button == 1 then
		-- select the villager if clicked, else select the tile (further down)
		for k, v in pairs(VILLAGERS) do
			x2 = v.position.x
			y2 = v.position.y
			local dist = cf.GetDistance(mousex - LEFT_MARGIN, mousey - TOP_MARGIN, x2, y2)
			if dist <= PERSON_DRAW_WIDTH then
				if v.isSelected then
					v:remove("isSelected")
				else
					v:ensure("isSelected")
				end
			end
		end
	end
end

function love.load()

    --! res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)

    if love.filesystem.isFused( ) then
		DEBUG = false
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
		DEBUG = true
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

    love.window.setTitle("Autarky " .. GAME_VERSION)

	cf.AddScreen("World", SCREEN_STACK)

	bt.EstablishTree(TREE)

    fun.loadImages()
    fun.initialiseMap()     -- initialises 2d map with nils
    ecsfunctions.init()	    -- loads all the components etc
    WORLD:emit("init")      -- triggers the init functions which load arrays and tables

end

function love.draw()

    --! res.start()
    --! res.stop()

    WORLD:emit("draw")

	draw.HUD()
end


function love.update(dt)

    WORLD:emit("update", dt)

	NEW_VILLAGER_TIMER = NEW_VILLAGER_TIMER + dt
	if NEW_VILLAGER_TIMER > 300 then
		NEW_VILLAGER_TIMER = 0
		local villager = concord.entity(WORLD)
		:give("drawable")
		:give("position")
		:give("uid")
		:give("isPerson")
		table.insert(VILLAGERS, villager)
	end
	--! res.update()
end
