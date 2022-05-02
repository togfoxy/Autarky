GAME_VERSION = "0.01"

Inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

Concord = require 'lib.concord'
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
NUMBER_OF_ROWS = (Cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 2
NUMBER_OF_COLS = (Cf.round(SCREEN_WIDTH / TILE_SIZE)) - 2
WELL_ROW = 0			-- capture the tile that has the well
WELL_COL = 0

NUMBER_OF_VILLAGERS = 3

MAP = {}			-- a 2d table of tiles
VILLAGERS = {}

function love.load()
    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

    love.window.setTitle("Autarky " .. GAME_VERSION)

	Cf.AddScreen("World", SCREEN_STACK)

    fun.loadImages()
    fun.initialiseMap()

end
