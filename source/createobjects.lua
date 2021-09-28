local createobjects = {}

local function intGetNextAgentID()
-- find the highest ID and return the one after that

	local highestID = 0
	for k, v in ipairs(Agents) do
		if v.ID ~= nil then
			if v.ID >= highestID then
				highestID = v.ID
			end
		end		
	end
	return highestID + 1
	
end

function createobjects.CreateAgent()
	-- initialises agents and bots
	-- Agents (non-physics)
	bot = {}
	bot.ID = intGetNextAgentID()
	bot.health = 100
	bot.hydration = 50
	bot.happiness = 50
	bot.wealth = 100
	bot.fullness = 74
	bot.stamina = 50
	bot.woodstock = 0
	bot.red = 1
	bot.green = 1
	bot.blue = 1
	bot.targetx = nil
	bot.targety = nil
	bot.targetzone = nil
	bot.currenttask = nil
	bot.currenttasklabel = nil
	bot.nexttasktimer = 2
	bot.workzone = nil			-- where to work
	bot.housezone = nil		-- where to live
	bot.occupation = nil		-- skillset
	bot.isselected = false		-- skillset

	-- physics stuff
	x = love.math.random(100, gintScreenWidth - 100)
	y = love.math.random(100, gintScreenHeight - 100)
	bot.body = love.physics.newBody(world,x,y,"dynamic")
	bot.body:setLinearDamping(0.5)
	bot.body:setMass(love.math.random(60,120))
	bot.shape = love.physics.newCircleShape(gintAgentRadius)
	bot.fixture = love.physics.newFixture(bot.body, bot.shape, 1)		-- the 1 is the density
	bot.fixture:setRestitution(1.5)
	bot.fixture:setSensor(true)
	bot.fixture:setUserData(botindex)
	
	bot.linearvelocityx = 0
	bot.linearvelocityy = 0
	
	table.insert(Agents, bot)

end

function createobjects.CreateGenericZone(v,zonetype,stocktype)
-- returns a generic zone
	myzone = {}
	myzone.ID = #zs + 1
	myzone.x = v.targetx
	myzone.y = v.targety
	myzone.width = 50
	myzone.height = 50
	myzone.zonetype = zonetype
	myzone.stocktype = stocktype
	myzone.stocklevel = 0
	myzone.worker = v.ID
	
	return myzone
end

function createobjects.CreateWorld(Zne)
	-- water zone
	myzone = {}
	myzone.ID = #Zne + 1	--**
	myzone.x = love.math.random(300, gintScreenWidth - 300)			-- this is top left corner
	myzone.y = love.math.random(300, gintScreenHeight - 300)			-- the 100 bit stops it spawning off the screen
	myzone.width = 50
	myzone.height = 50
	myzone.zonetype = enum.zonetypeWater
	myzone.stocklevel = nil
	myzone.worker = nil			-- the allocated agent to work here (if a work zone.)
	myzone.homeowner = nil
	table.insert(Zne, myzone)	
end



return createobjects