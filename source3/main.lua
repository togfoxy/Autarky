GAME_VERSION = "0.12"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

concord = require 'lib.concord'
-- https://github.com/Tjakka5/Concord

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'	-- Returns the Camera class.
-- https://notabug.org/pgimeno/cam11

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
		if VILLAGERS_SELECTED == 1 then	-- can only be one welfare officer
			local numofwelfareofficers = fun.getJobCount(enum.jobWelfareOfficer)
			for k,v in pairs(VILLAGERS) do
				if v:has("isSelected") and (not v:has("occupation")) and numofwelfareofficers < 1 then
					v:ensure("occupation", enum.jobWelfareOfficer, stockWelfare, false, true, false)	-- jobtype, stocktype, bolProducer, bolService, bolConverter)
				end
				v:remove("isSelected")
			end
		end
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
	if key == "s" then
		SOUND_TOGGLE = not SOUND_TOGGLE
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

	if y <= 150 then 
		DISPLAY_GRAPH = true
	else
		DISPLAY_GRAPH = false
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
