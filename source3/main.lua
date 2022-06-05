GAME_VERSION = "0.14"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'
-- https://notabug.org/pgimeno/cam11

bitser = require 'lib.bitser'
-- https://github.com/gvx/bitser

nativefs = require 'lib.nativefs'
-- https://github.com/megagrump/nativefs

lovelyToasts = require 'lib.lovelyToasts'
-- https://github.com/Loucee/Lovely-Toasts

ft = require 'lib.foxtree'		-- foxtree

cf = require 'lib.commonfunctions'
fun = require 'functions'
ecs = require 'ecsfunctions'
enum = require 'enum'
bt = require 'behaviortree'
draw = require 'draw'
con = require 'constants'

actbuy = require 'actionbuy'
actidle = require 'actionidle'
actmove = require 'actionmove'
actrest = require 'actionrest'
actstockhouse = require 'actionstockhouse'
actwork = require 'actionwork'

con.load()	-- load the constants

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
	-- turn selected agent into farmers
	if key == "f" then
		for k,v in pairs(VILLAGERS) do
			if v:has("isSelected") and (not v:has("occupation")) then
				-- print("occup granted")
				v:ensure("occupation", enum.jobFarmer, enum.stockFruit, true, false, false)		-- a farmer that farms fruit
				v:remove("isSelected")
			end
			v:remove("isSelected")
		end
		VILLAGERS_SELECTED = 0
	end
	-- turn selected agent into woodsman
	if key == "l" then
		for k,v in pairs(VILLAGERS) do
			if v:has("isSelected") and (not v:has("occupation")) then
				-- print("occup granted")
				v:ensure("occupation", enum.jobWoodsman, enum.stockWood, true, false, false)
			end
			v:remove("isSelected")
		end
		VILLAGERS_SELECTED = 0
	end
	if key == "b" then
		for k,v in pairs(VILLAGERS) do
			if v:has("isSelected") and (not v:has("occupation")) then
				-- print("occup granted")
				v:ensure("occupation", enum.jobCarpenter, enum.stockHouseFrame, false, false, true)
			end
			v:remove("isSelected")
		end
		VILLAGERS_SELECTED = 0
	end
	if key == "h" then
		for k,v in pairs(VILLAGERS) do
			if v:has("isSelected") and (not v:has("occupation")) then
				-- print("occup granted")
				v:ensure("occupation", enum.jobHealer, enum.stockHealingHerbs, true, false, false)
			end
			v:remove("isSelected")
		end
		VILLAGERS_SELECTED = 0
	end
	if key == "t" then
		for k,v in pairs(VILLAGERS) do
			if v:has("isSelected") and (not v:has("occupation")) then
				v:ensure("occupation", enum.jobTaxCollector, nil, false, false, true)	-- jobtype, stocktype, bolProducer, bolService, bolConverter)
			end
			v:remove("isSelected")
		end
		VILLAGERS_SELECTED = 0
	end

	if key == "w" then
		-- if VILLAGERS_SELECTED == 1 then	-- can only be one welfare officer
			-- local numofwelfareofficers = fun.getJobCount(enum.jobWelfareOfficer)
			for k,v in pairs(VILLAGERS) do
				if v:has("isSelected") and (not v:has("occupation")) then
					v:ensure("occupation", enum.jobWelfareOfficer, stockWelfare, false, true, false)	-- jobtype, stocktype, bolProducer, bolService, bolConverter)
				end
				v:remove("isSelected")
			end
		-- end
		VILLAGERS_SELECTED = 0
	end

	if key == "kp5" then
		ZOOMFACTOR = 1
		TRANSLATEX = 960
		TRANSLATEY = 540

		-- unselect everyone
		for k,v in pairs(VILLAGERS) do
			v:remove("isSelected")
		end
		VILLAGERS_SELECTED = 0
	end

	if key == "m" then
		MUSIC_TOGGLE = not MUSIC_TOGGLE
	end
	if key == "e" then
		SOUND_TOGGLE = not SOUND_TOGGLE
	end

	if key == "c" then
		fun.LoadGame()
	end
	if key == "s" then
		fun.saveGame()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	local wx, wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	if button == 1 then
		-- select the villager if clicked, else select the tile (further down)
		for k, v in pairs(VILLAGERS) do

			x2 = v.position.x
			y2 = v.position.y

			local dist = cf.GetDistance(wx - LEFT_MARGIN, wy - TOP_MARGIN, x2, y2)
			if dist <= PERSON_DRAW_WIDTH then
				if v.isSelected then
					v:remove("isSelected")		--! small bug - need to check if this is the last selected and then remove it
					VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1
				else
					v:ensure("isSelected")
					VILLAGERS_SELECTED = VILLAGERS_SELECTED + 1
				end
			end
		end
	end
end

function love.mousemoved( x, y, dx, dy, istouch )

	if y <= 150 and x <= 450 then
		DISPLAY_GRAPH = true
	else
		DISPLAY_GRAPH = false
	end

	if x <= 150 then
		DISPLAY_INSTRUCTIONS = true
	else
		DISPLAY_INSTRUCTIONS = false
	end

	if x >= GAME_LOG_DRAWX then
		DISPLAY_GAME_LOG = true
	else
		DISPLAY_GAME_LOG = false
	end

	if love.mouse.isDown(3) then
		TRANSLATEX = TRANSLATEX - dx
		TRANSLATEY = TRANSLATEY - dy
	end
end

function love.keypressed( key, scancode, isrepeat )

	local translatefactor = 5 * (ZOOMFACTOR * 2)		-- screen moves faster when zoomed in

	local leftpressed = love.keyboard.isDown("left")
	local rightpressed = love.keyboard.isDown("right")
	local uppressed = love.keyboard.isDown("up")
	local downpressed = love.keyboard.isDown("down")
	local shiftpressed = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")	-- either shift key will work

	-- adjust translatex/y based on keypress combinations
	if shiftpressed then translatefactor = translatefactor * 2 end	-- ensure this line is above the lines below
	if leftpressed then TRANSLATEX = TRANSLATEX - translatefactor end
	if rightpressed then TRANSLATEX = TRANSLATEX + translatefactor end
	if uppressed then TRANSLATEY = TRANSLATEY - translatefactor end
	if downpressed then TRANSLATEY = TRANSLATEY + translatefactor end
end

function love.wheelmoved(x, y)
	if y > 0 then
		-- wheel moved up. Zoom in
		ZOOMFACTOR = ZOOMFACTOR + 0.05
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if ZOOMFACTOR < 0.8 then ZOOMFACTOR = 0.8 end
	if ZOOMFACTOR > 3 then ZOOMFACTOR = 3 end
end

function love.load()

	love.window.setMode(800,600,{fullscreen=true, display=1, resizable=true, borderless=false})
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	love.window.setMode(SCREEN_WIDTH,SCREEN_HEIGHT,{fullscreen=false, display=1, resizable=true, borderless=false})

	res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)

	TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels

	TILE_SIZE = 50
    NUMBER_OF_ROWS = (cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 2
    NUMBER_OF_COLS = (cf.round(SCREEN_WIDTH / TILE_SIZE)) - 1

	LEFT_MARGIN = TILE_SIZE / 2
    TOP_MARGIN = TILE_SIZE / 2
	GAME_LOG_DRAWX = SCREEN_WIDTH - 275

	print("There are " .. NUMBER_OF_ROWS .. " rows and " .. NUMBER_OF_COLS .. " columns.")

    love.window.setTitle("Autarky " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)

	cf.AddScreen("World", SCREEN_STACK)

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)

	bt.EstablishTree(TREE)

    fun.loadImages()
    fun.initialiseMap()     -- initialises 2d map with nils
	fun.loadAudio()

    ecsfunctions.init()	    -- loads all the components etc
    WORLD:emit("init")      -- triggers the init functions which load arrays and tables
end

function love.draw()
    res.start()
	cam:attach()
    WORLD:emit("draw")
	draw.Animations()
	cam:detach()
	draw.HUD()
    res.stop()
end

function love.update(dt)

    WORLD:emit("update", dt)

	NEW_VILLAGER_TIMER = NEW_VILLAGER_TIMER + dt
	if NEW_VILLAGER_TIMER > NEW_VILLAGER_THRESHOLD then
		NEW_VILLAGER_TIMER = 0
		local villager = concord.entity(WORLD)
		:give("drawable")
		:give("position")
		:give("uid")
		:give("isPerson")
		table.insert(VILLAGERS, villager)
		AUDIO[enum.audioNewVillager]:play()
		fun.playAudio(enum.audioNewVillager, false, true)
	end

	PRICE_UPDATE_TIMER = PRICE_UPDATE_TIMER + dt
	if PRICE_UPDATE_TIMER > 30 then
		PRICE_UPDATE_TIMER = 0
	    -- log the transaction for future graphing
	    local nextindex = #STOCK_HISTORY[enum.stockFruit] + 1
	    STOCK_HISTORY[enum.stockFruit][nextindex] = fun.getAvgSellPrice(enum.stockFruit)
		fun.addGameLog("Fruit now sells for $" .. STOCK_HISTORY[enum.stockFruit][nextindex])
		if #STOCK_HISTORY[enum.stockFruit] > 100 then
			table.remove(STOCK_HISTORY[enum.stockFruit], 1)
		end

		nextindex = #STOCK_HISTORY[enum.stockWood] + 1
		STOCK_HISTORY[enum.stockWood][nextindex] = fun.getAvgSellPrice(enum.stockWood)
		fun.addGameLog(" Wood now sells for $" .. STOCK_HISTORY[enum.stockWood][nextindex])
		if #STOCK_HISTORY[enum.stockWood] > 100 then
			table.remove(STOCK_HISTORY[enum.stockWood], 1)
		end

		nextindex = #STOCK_HISTORY[enum.stockHealingHerbs] + 1
		STOCK_HISTORY[enum.stockHealingHerbs][nextindex] = fun.getAvgSellPrice(enum.stockHealingHerbs)
		fun.addGameLog("  Herbs now sells for $" .. STOCK_HISTORY[enum.stockHealingHerbs][nextindex])
		if #STOCK_HISTORY[enum.stockHealingHerbs] > 100 then
			table.remove(STOCK_HISTORY[enum.stockHealingHerbs], 1)
		end
	end

	for i = #DRAWQUEUE, 1, -1 do
		DRAWQUEUE[i].start = DRAWQUEUE[i].start - dt
		DRAWQUEUE[i].stop = DRAWQUEUE[i].stop - dt
		if DRAWQUEUE[i].stop <= 0 then
			table.remove(DRAWQUEUE, i)
		end
	end

	fun.PlayAmbientMusic()

	cam:setPos(TRANSLATEX,	TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)
	res.update()
end
