gstrGameVersion = "0.02"

inspect = require 'inspect'
-- https://github.com/kikito/inspect.lua

TLfres = require "tlfres"
-- https://love2d.org/wiki/TLfres

ft = require "foxtree"
bt = require "behaviortree"
cobjs = require "createobjects"
dobjs = require "drawobjects"
fun = require "randomfunctions"
enum = require "enum"
cf = require "commonfunctions"

gintScreenWidth = 1440-- 1920
gintScreenHeight = 900-- 1080
garrCurrentScreen = {}			-- screen stack

gintAgentRadius = 10


Agents = {}						-- these are physics objects
Zones = {}				-- area's of interest to agents
tree = {}

gstatFullness = 0
gstatHydration = 0
gstatStamina = 0
gstatHappiness = 0
gstatFoodStock = 0

gbolPaused = false

gtmrBalancePriorities = enum.timerBalancePriorities
gtmrGetStats = enum.timerGetStats
gtmrSpawnAgents = enum.timerSpawnAgents
gtmrKillThings = enum.timerKillThings

ginthousewoodcost = 200 --!200


local function MoveAgent(v)
-- moves a single bot towards tx,ty
-- v = a single agent

	if v.targetx ~= nil and v.targety ~= nill then
		-- determine vector to get to next waypoint
		local xdistance = v.targetx - v.body:getX()		-- x axis set above
		local ydistance = v.targety - v.body:getY()		-- y axis
		
		local xvector = xdistance
		local yvector = ydistance

		-- need to scale to 'walking' pace
		xvector, yvector = fun.NormaliseVectors(xvector, yvector)
		
		-- move at half speed if tired
		if v.stamina <= 0 then
			xvector, yvector = cf.ScaleVector(xvector,yvector,0.4)
		end
		
		v.body:setLinearVelocity(xvector, yvector)
	end
end

local function UpdateTaskTimer(v, dt)
-- v = single bot
	v.nexttasktimer = v.nexttasktimer - dt
	if v.nexttasktimer <= 0 then 
		-- set up for the next task
		v.nexttasktimer = 0
		v.targetx = nil
		v.targety = nil
		v.currenttask = nil
		v.targetzone = nil
	end	
end

local function EnsureTargetSet(z, v,targetzonetype)
-- v = single agent
-- targetzonetype = the type of zone to look for

	if v.targetx == nil then
		-- find a zone
		local rndnum
		repeat
			rndnum = love.math.random(1, #z)
		until z.zonetype == targetzonetype

		z[rndnum].
		v.targetx = z[rndnum].x + (z[rndnum].width / 2)
		v.targety = z[rndnum].y + (z[rndnum].height / 2)
		v.targetzone = q		
	end	
end

local function StopIfAtTarget(v)
-- returns a boolean AND stops the agent moving
-- v = single agent

	if cf.GetDistance(v.body:getX(), v.body:getY(),v.targetx,v.targety) < 25 then
		-- arrived. Remember we have arrived
		v.nexttasktimer = enum.timerNextTask
		local vx, vy = v.body:getLinearVelocity( )
		v.body:setLinearVelocity(vx / 2, vy / 2)
		return true
	end
	return false

end

local function CheckIdleAgents(agt,dt)
-- agt = Agents

	for k,v in ipairs(agt) do
		v.nexttasktimer = v.nexttasktimer - dt
		if v.nexttasktimer <= 0 then v.nexttasktimer = 0 end

		-- see who is idle
		if v.currenttask == nil and v.nexttasktimer <= 0 then
		
			nextaction = ft.DetermineAction(tree, v)
			
			--print("next action = " .. nextaction)
			v.currenttask = nextaction
			
			if nextaction == enum.goalRest then
				v.currenttasklabel = "Resting"
			end
			if nextaction == enum.goalBuildFarm then
				v.currenttasklabel = "Building farm"
			end		
			if nextaction == enum.goalWork then
				v.currenttasklabel = "Working"
			end				
			if nextaction == enum.goalEat then
				v.currenttasklabel = "Eating"
			end	
			if nextaction == enum.goalDrinkWater then
				v.currenttasklabel = "Drinking water"
			end				
			if nextaction == enum.goalBuildHealer then
				v.currenttasklabel = "Building healer"
			end	
			if nextaction == enum.goalHeal then
				v.currenttasklabel = "Healing"
			end			
			if nextaction == enum.goalBuildLumberyard then
				v.currenttasklabel = "Building lumberyard"
			end		
			if nextaction == enum.goalBuyWood then
				v.currenttasklabel = "Buying wood"
			end	
			if nextaction == enum.goalBuildHouseFoundation then
				v.currenttasklabel = "Starting house"
			end			
			if nextaction == enum.goalBuildHouse then
				v.currenttasklabel = "Finishing house"
			end				
		end
	end
end

function DegradeStats(agt, dt)
-- adjust vital stats every tick
-- agt = Agents

	for k,v in ipairs(agt) do
		-- check if moving
		local x, y = v.body:getLinearVelocity( )
		if x > 1 or y > 1 then	
			-- moving
			v.hydration = v.hydration - (dt / 2)
			v.happiness = v.happiness - (dt / 6)
			v.fullness = v.fullness - (dt / 2)
			v.stamina = v.stamina - (dt / 2 )
		else
			-- not moving
			v.hydration = v.hydration - (dt / 4)
			-- v.happiness = v.happiness - (dt / 2)
			v.fullness = v.fullness - (dt / 5)		
			v.stamina = v.stamina - (dt / 8)
		end
        
        if v.stamina <= 0 then
			v.happiness = v.happiness - (1 *dt)
		end    
        if v.fullness <= 0 then
			v.happiness = v.happiness - (1* dt)
			
		end 
        if v.hydration <= 0 then
			v.happiness = v.happiness - (1 * dt)
		end 	
		if v.stamina > 75 then
			v.happiness = v.happiness + (0.5 * dt)
		end
		if v.fullness > 75 then
			v.happiness = v.happiness + (0.5 * dt)
		end		
		
		if v.hydration > 75 then
			v.happiness = v.happiness + (0.5 * dt)
		end		
	
		if v.hydration < 0 then v.hydration = 0 end
		if v.happiness < 0 then v.happiness = 0 end
		if v.fullness < 0 then v.fullness = 0 end
		if v.stamina < 0 then v.stamina = 0 end
        
        
	end
end

function CheckStatBounds(agt)
-- simple check for zero's and 100's

	for k,v in ipairs(agt) do
		if v.health >= 100 then v.health = 100 end
		if v.hydration >= 100 then v.hydration = 100 end
		if v.happiness >= 100 then v.happiness = 100 end
		if v.fullness >= 100 then v.fullness = 100 end
		if v.stamina >= 100 then v.stamina = 100 end

		if v.health <= 0 then v.health = 0 end
		if v.hydration <= 0 then v.hydration = 0 end
		if v.happiness <= 0 then v.happiness = 0 end
		if v.wealth <= 0 then v.wealth = 0 end
		if v.fullness <= 0 then v.fullness = 0 end
		if v.stamina <= 0 then v.stamina = 0 end		
	end
end

function GetStats(Zns, agt, dt)

	gtmrGetStats = gtmrGetStats - dt
	if gtmrGetStats <= 0 then
		gtmrGetStats = enum.timerGetStats
		
		gstatFullness = 0
		gstatHydration = 0
		gstatStamina = 0
		gstatHappiness = 0	
		gstatFoodStock = 0
		
		for k,v in ipairs(agt) do
			gstatFullness = gstatFullness + v.fullness
			gstatHydration = gstatHydration + v.hydration
			gstatStamina = gstatStamina + v.stamina
			gstatHappiness = gstatHappiness + v.happiness
		end
		
		local intZoneCount = 0
		for k,v in ipairs(Zns) do 
			if v.zonetype == enum.zonetypeFood then
				gstatFoodStock = gstatFoodStock + v.stocklevel
				intZoneCount = intZoneCount + 1
			end
		end
		
		gstatFullness = gstatFullness / #agt
		gstatHydration = gstatHydration / #agt
		gstatStamina = gstatStamina / #agt
		gstatHappiness = gstatHappiness / #agt
		gstatFoodStock = gstatFoodStock / intZoneCount

	end

end

local function PerformRestImmediately(v, dt)
-- v = single agent

	if v.nexttasktimer <= 0 then	-- we have a task but the task timer is not yet zero
		-- remember the target if necessary
		if v.targetx == nil then
			-- pick a random spot nearby

			local x = v.body:getX()
			local y = v.body:getY()			

			v.targetx = x + love.math.random (-100, 100)
			v.targety = y + love.math.random (-100, 100)
			v.targetzone = nil
		end	
		-- move towards target
		MoveAgent(v)
		
		if StopIfAtTarget(v) then
			-- rest
			v.health = v.health + 0.25
			v.happiness = v.happiness + 2
			v.stamina = v.stamina + 8
			
		
		end	
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)
	end

end

local function PerformBuildFarm(zs, v, dt)
	-- create farm
	if v.nexttasktimer <= 0 then	-- a value > 0 means we not yet arrived	
		if v.targetx == nil then
			v.targetx = love.math.random(100, gintScreenWidth - 100)			-- this is top left corner
			v.targety = love.math.random(100, gintScreenHeight - 100)			-- the 100 bit stops it spawning off the screen
			v.targetzone = nil
		end
		MoveAgent(v)
		if StopIfAtTarget(v) then
			-- create food zones
			myzone = {}
			myzone.ID = #zs + 1
			myzone.x = v.targetx
			myzone.y = v.targety
			myzone.width = 50
			myzone.height = 50
			myzone.zonetype = enum.zonetypeFood
			myzone.stocklevel = 0
			myzone.worker = v.ID
			table.insert(zs, myzone)

			v.workzone = myzone.ID	
			v.stamina = v.stamina - 10
			v.happiness = v.happiness - 10	
			v.hydration = v.hydration - 10
			
			v.nexttasktimer = 0
			v.targetx = nil
			v.targety = nil
			v.currenttask = nil
			v.targetzone = nil	
			
			-- small chance of being injured at worker
			if love.math.random(1,100) <= 5 then
				-- ouch
				v.health = v.health - (love.math.random(5,10))
			end
		end
	else
		-- arrived some time previously
		v.currenttask = nil
		v.nexttasktimer = 0
		v.targetx = nil
		v.targety = nil
		v.currenttask = nil
		v.targetzone = nil			
		UpdateTaskTimer(v, dt)	
	end
end

local function PerformBuildHealer(zs, v, dt)
	-- create healer
	if v.nexttasktimer <= 0 then	-- a value > 0 means we not yet arrived	
		if v.targetx == nil then
			v.targetx = love.math.random(100, gintScreenWidth - 100)			-- this is top left corner
			v.targety = love.math.random(100, gintScreenHeight - 100)			-- the 100 bit stops it spawning off the screen
			v.targetzone = nil
		end
-- print("hotel " .. v.targetx)
		MoveAgent(v)
		if StopIfAtTarget(v) then
			-- create healer
			myzone = {}
			myzone.ID = #zs + 1
			myzone.x = v.targetx
			myzone.y = v.targety
			myzone.width = 50
			myzone.height = 50
			myzone.zonetype = enum.zonetypeHeal
			myzone.stocklevel = 0
			myzone.worker = v.ID
			table.insert(zs, myzone)
			
			v.workzone = myzone.ID	
			v.stamina = v.stamina - 10
			v.happiness = v.happiness - 10	
			v.hydration = v.hydration - 10
			
			v.nexttasktimer = 0
			v.targetx = nil
			v.targety = nil
			v.currenttask = nil
			v.targetzone = nil	

			-- small chance of being injured at worker
			if love.math.random(1,100) <= 5 then
				-- ouch
				v.health = v.health - (love.math.random(5,10))
			end
		end
	else
		-- arrived some time previously
		v.currenttask = nil
		v.nexttasktimer = 0
		v.targetx = nil
		v.targety = nil
		v.currenttask = nil
		v.targetzone = nil			
		UpdateTaskTimer(v, dt)	
	end
		
			
end

local function PerformBuildLumberyard(zs, v, dt)
	if v.nexttasktimer <= 0 then	-- a value > 0 means we not yet arrived	
		if v.targetx == nil then
			v.targetx = love.math.random(100, gintScreenWidth - 100)			-- this is top left corner
			v.targety = love.math.random(100, gintScreenHeight - 100)			-- the 100 bit stops it spawning off the screen
			v.targetzone = nil
		end
		MoveAgent(v)
		if StopIfAtTarget(v) then
			-- create lumberyard
			myzone = {}
			myzone.ID = #zs + 1
			myzone.x = v.targetx
			myzone.y = v.targety
			myzone.width = 50
			myzone.height = 50
			myzone.zonetype = enum.zonetypeLumberyard
			myzone.stocklevel = 0
			myzone.worker = v.ID
			table.insert(zs, myzone)
			
			v.workzone = myzone.ID	
			v.stamina = v.stamina - 10
			v.happiness = v.happiness - 10	
			v.hydration = v.hydration - 10
			
			v.nexttasktimer = 0
			v.targetx = nil
			v.targety = nil
			v.currenttask = nil
			v.targetzone = nil	

			-- small chance of being injured at worker
			if love.math.random(1,100) <= 5 then
				-- ouch
				v.health = v.health - (love.math.random(5,10))
			end
		end
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end

end

local function PerformWork(zs, v, dt)

	if v.nexttasktimer <= 0 then	-- a value > 0 means we not yet arrived
		-- a workzone is already allocated
		myzone = v.workzone
		
-- print(v.targetx)
-- print(myzone)
-- print(zs[myzone].x)
-- print(zs[myzone].width)
-- print("~~~")

		for k,b in pairs(zs) do
			if b.ID == myzone then
			
				v.targetx = b.x + (b.width / 2)
				v.targety = b.y + (b.height / 2)
				v.targetzsone = myzone		

				MoveAgent(v)	-- assumes targetx and targety are set
				if StopIfAtTarget(v) then
					if v.stamina > 0 then
						if zs[myzone].zonetype == enum.zonetypeFood then		
							-- stock the shop
							zs[myzone].stocklevel = zs[myzone].stocklevel + 6
							v.wealth = v.wealth + 6
							v.stamina = v.stamina - 4
							v.happiness = v.happiness - 4
							
							-- small chance of being injured at work
							if love.math.random(1,100) <= 5 then
								-- ouch
								v.health = v.health - (love.math.random(5,10))
							end	
						end
						if zs[myzone].zonetype == enum.zonetypeHeal then
							-- stock the medkits
							zs[myzone].stocklevel = zs[myzone].stocklevel + 1
							v.wealth = v.wealth + 10
							v.stamina = v.stamina - 6
							v.happiness = v.happiness - 2
						end	
						if zs[myzone].zonetype == enum.zonetypeLumberyard then
							-- stock the medkits
							zs[myzone].stocklevel = zs[myzone].stocklevel + 6
							v.wealth = v.wealth + 6
							v.stamina = v.stamina - 4
							v.happiness = v.happiness - 4
						end					
					end
				end
			end
		
		end				
				
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end		
end

local function PerformEat(zs, v, dt)

	if v.nexttasktimer <= 0 then	-- a value > 0 means journey is started but not yet arrived
		
		local intMostFood
		local intBestZone
		if v.targetx == nil then
			--print("charlie")
			-- find a food zone with the most food
			intMostFood = 0
			intBestZone = -1
			for q,w in ipairs(zs) do
				if w.zonetype == enum.zonetypeFood then
					if w.stocklevel > intMostFood then
						intMostFood = w.stocklevel
						intBestZone = q
					end
				end
			end
			if intBestZone == -1 then
				v.nexttasktimer = 0
				v.targetx = nil
				v.targety = nil
				v.currenttask = nil
				v.targetzone = nil			
				return 
			else
				v.targetx = zs[intBestZone].x + (zs[intBestZone].width / 2)
				v.targety = zs[intBestZone].y + (zs[intBestZone].height / 2)
				v.targetzone = intBestZone		--** need to remember that zones don't use ID but are just a sequence
				assert(v.targetzone ~= 0)	
			end
		end

		MoveAgent(v)
		
		assert(v.targetzone ~= nil)
		assert(v.targetzone ~= 0)

		if StopIfAtTarget(v) then
		
			if zs[v.targetzone] ~= nil then
		
				local maxstock = zs[v.targetzone].stocklevel
				local maxwealth = v.wealth
				local maxfullness = 100 - v.fullness
				local amt = math.min(maxstock, maxwealth, maxfullness)
				
				if amt > 10 then amt = 10 end
				
				v.fullness = v.fullness + amt
				v.wealth = v.wealth - amt
				zs[v.targetzone].stocklevel = zs[v.targetzone].stocklevel - amt
				v.happiness = v.happiness + (5 * amt/10)
				v.stamina = v.stamina + (5 * amt/10)
			end
			
		end
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end		
end

local function PerformBuyWood(zs, v, dt)
	if v.nexttasktimer <= 0 then	-- a value > 0 means journey is started but not yet arrived
		
		local intMostWood
		local intBestZone
		if v.targetx == nil then
			-- find a wood zone with the most wood
			intMostWood = 0
			intBestZone = -1
			for q,w in ipairs(zs) do
				if w.zonetype == enum.zonetypeLumberyard then
					if w.stocklevel > intMostWood then
						intMostWood = w.stocklevel
						intBestZone = q
					end
				end
			end
			if intBestZone == -1 then
				v.nexttasktimer = 0
				v.targetx = nil
				v.targety = nil
				v.currenttask = nil
				v.targetzone = nil			
				return 
			else
				v.targetx = zs[intBestZone].x + (zs[intBestZone].width / 2)
				v.targety = zs[intBestZone].y + (zs[intBestZone].height / 2)
				v.targetzone = intBestZone		--** need to remember that zones don't use ID but are just a sequence
				assert(v.targetzone ~= 0)	
			end
		end

		MoveAgent(v)
		
		assert(v.targetzone ~= nil)
		assert(v.targetzone ~= 0)

		if StopIfAtTarget(v) then
			if zs[v.targetzone] ~= nil then
				local maxstock = zs[v.targetzone].stocklevel
				local maxwealth = v.wealth
				local maxwood = 200 - v.woodstock
				local amt = math.min(maxstock, maxwealth, maxwood)
				
				if amt > 10 then amt = 10 end
				
				v.woodstock = v.woodstock + amt
				v.wealth = v.wealth - amt
				zs[v.targetzone].stocklevel = zs[v.targetzone].stocklevel - amt
				v.happiness = v.happiness + (5 * amt/10)
				-- v.stamina = v.stamina + (5 * amt/10)	
			end
		end
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end		


end

local function PerformDrinkWater(zs, v, dt)

	if v.nexttasktimer <= 0 then	-- a value > 0 means journey is started but not yet arrived
		-- remember the target if necessary
		if v.targetx == nil then
			-- find a water zone
			for q,w in ipairs(zs) do
				if w.zonetype == enum.zonetypeWater then
					-- record this as the place to be
					v.targetx = w.x + (w.width / 2)
					v.targety = w.y + (w.height / 2)
					v.targetzone = q
					break
				end
			end
		end	
		-- move towards target
		MoveAgent(v)
		
		if StopIfAtTarget(v) then
			-- drink water
			v.hydration = v.hydration + 30
			v.happiness = v.happiness + 6
		end
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end			
end

local function PerformHeal(zs, v, dt)

	if v.nexttasktimer <= 0 then	-- a value > 0 means journey is started but not yet arrived
		local intMostHeal
		local intBestZone
		if v.targetx == nil then
			-- find a food zone with the most food
			intMostHeal = -1
			intBestZone = -1
			for q,w in ipairs(zs) do
				if w.zonetype == enum.zonetypeHeal then
					if w.stocklevel > intMostHeal then
						intMostHeal = w.stocklevel
						intBestZone = q
					end
				end
			end
			if intBestZone == -1 then
				v.nexttasktimer = 0
				v.targetx = nil
				v.targety = nil
				v.currenttask = nil
				v.targetzone = nil			
				return 
			else
				v.targetx = zs[intBestZone].x + (zs[intBestZone].width / 2)
				v.targety = zs[intBestZone].y + (zs[intBestZone].height / 2)
				v.targetzone = intBestZone		--** need to remember that zones don't use ID but are just a sequence
				assert(v.targetzone ~= 0)	
			end
		end
		MoveAgent(v)
		
		assert(v.targetzone ~= nil)
		assert(v.targetzone ~= 0)
		-- print("alpha " , v.targetzone)

		if StopIfAtTarget(v) then
			if zs[v.targetzone] ~= nil then
				local maxstock = zs[v.targetzone].stocklevel
				local maxwealth = v.wealth
				local maxhealth = 100 - v.health
				local amt = math.min(maxstock, maxwealth, maxhealth)
				
				if amt > 10 then amt = 10 end
				
				v.health = v.health + amt
				v.wealth = v.wealth - (amt * 10)
				zs[v.targetzone].stocklevel = zs[v.targetzone].stocklevel - amt
				v.happiness = v.happiness + (5 * amt/10)
			end
		end
		
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end	
end

local function PerformBuildHouseFoundation(zs, v, dt)

	if v.nexttasktimer <= 0 then	-- a value > 0 means we not yet arrived	
		if v.targetx == nil then
			v.targetx = love.math.random(100, gintScreenWidth - 100)			-- this is top left corner
			v.targety = love.math.random(100, gintScreenHeight - 100)			-- the 100 bit stops it spawning off the screen
			v.targetzone = nil
		end
		MoveAgent(v)
		if StopIfAtTarget(v) then
			-- create lumberyard
			myzone = {}
			myzone.ID = #zs + 1
			myzone.x = v.targetx
			myzone.y = v.targety
			myzone.width = 50
			myzone.height = 50
			myzone.zonetype = enum.zonetypeHouseFoundation
			myzone.stocklevel = 0
			myzone.worker = nil
			myzone.homeowner = v.ID
			table.insert(zs, myzone)
			
			v.housezone = myzone.ID	
			v.stamina = v.stamina - 10
			v.happiness = v.happiness - 10	
			v.hydration = v.hydration - 10
			v.woodstock = v.woodstock - ginthousewoodcost
			v.wealth = v.wealth - 10
			
			v.currenttask = nil
			v.nexttasktimer = 0
			v.targetx = nil
			v.targety = nil
			v.currenttask = nil
			v.targetzone = nil				

			-- small chance of being injured at worker
			if love.math.random(1,100) <= 5 then
				-- ouch
				v.health = v.health - (love.math.random(5,10))
			end
		end
	else
		-- arrived some time previously
		v.currenttask = nil
		v.nexttasktimer = 0
		v.targetx = nil
		v.targety = nil
		v.currenttask = nil
		v.targetzone = nil			
		
		UpdateTaskTimer(v, dt)	
	end


end

local function PerformBuildHouse(zs, v, dt)
-- lumberjack builds someone elses house
	
	if v.nexttasktimer <= 0 then	-- a value > 0 means journey is started but not yet arrived
		local intBestZone
		if v.targetx == nil then
			-- find a food zone with the most food
			intBestZone = -1
			for q,w in ipairs(zs) do
				if w.zonetype == enum.zonetypeHouseFoundation then
					intBestZone = q
				end
			end
			if intBestZone == -1 then
				v.nexttasktimer = 0
				v.targetx = nil
				v.targety = nil
				v.currenttask = nil
				v.targetzone = nil			
				return 
			else
				v.targetx = zs[intBestZone].x + (zs[intBestZone].width / 2)
				v.targety = zs[intBestZone].y + (zs[intBestZone].height / 2)
				v.targetzone = intBestZone		--** need to remember that zones don't use ID but are just a sequence
				assert(v.targetzone ~= 0)	
			end
		end
		MoveAgent(v)
		if StopIfAtTarget(v) then
			
			if zs[v.targetzone] ~= nil then
				if zs[v.targetzone].zonetype == enum.zonetypeHouseFoundation then
					zs[v.targetzone].zonetype = enum.zonetypeHouse
					v.stamina = v.stamina - 10
					v.wealth = v.wealth + 10
				end
			end
		end
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end	
		

end

local function PerformTasks(znes, agt, dt)
-- do things
-- zne = Zones

	for k,v in ipairs(agt) do
		if v.currenttask == enum.goalRest then
			PerformRestImmediately(v,dt)
		end	
		if v.currenttask == enum.goalBuildFarm then
			PerformBuildFarm(znes, v,dt)
		end	
		if v.currenttask == enum.goalWork then
			PerformWork(znes, v,dt)
		end	
		if v.currenttask == enum.goalEat then
			PerformEat(znes, v,dt)
		end	
		if v.currenttask == enum.goalDrinkWater then
			PerformDrinkWater(znes, v,dt)
		end			
		if v.currenttask == enum.goalBuildHealer then
			PerformBuildHealer(znes, v,dt)
		end	
		if v.currenttask == enum.goalHeal then
			PerformHeal(znes, v,dt)
		end	
		if v.currenttask == enum.goalBuildLumberyard then
			PerformBuildLumberyard(znes, v,dt)
		end	
		if v.currenttask == enum.goalBuyWood then
			PerformBuyWood(znes, v,dt)
		end	
		if v.currenttask == enum.goalBuildHouseFoundation then
			PerformBuildHouseFoundation(znes, v,dt)
		end			
		if v.currenttask == enum.goalBuildHouse then
			PerformBuildHouse(znes, v,dt)
		end	
		
	end
end

local function SpawnAgents(dt)
-- spawn a new agent if conditions are good
	
	gtmrSpawnAgents = gtmrSpawnAgents - dt
	
	if gtmrSpawnAgents <= 0 then
		gtmrSpawnAgents = enum.timerSpawnAgents
	
		--!do things
		if gstatFoodStock > 75 and gstatHappiness > 66 then
			
			gintNumAgents = gintNumAgents + 1
			cobjs.CreateAgent(gintNumAgents)
		end
	end
end

local function KillThings(Zns, Agts, dt)
	gtmrKillThings = gtmrSpawnAgents - dt
	
	if gtmrKillThings <= 0 then
		gtmrKillThings = enum.timerKillThings
		
		for k,v in ipairs(Agts) do
			if v.health <= 0 or v.hydration <= 0 or v.fullness <= 0 then
				-- ack!
				local deadID = v.ID
				
				-- remove house and workplace
				for q,w in ipairs(Zns) do
					if w.worker == deadID or w.homeowner == deadID then
						table.remove(Zns, q)
					end
				end
	
				table.remove(Agts, k)
			end
		end
	end
end

function love.mousepressed( x, y, button, istouch, presses )

	local mousex,mousey = TLfres.getMousePosition(gintScreenWidth, gintScreenHeight)    -- lets you pretend screen is 1920 * 1080

	if button == 1 then
		for k,v in ipairs(Agents) do
			local x2 = v.body:getX()		-- x axis set above
			local y2 = v.body:getY()		-- y axis
			local dist = cf.GetDistance(mousex, mousey, x2, y2)

			if dist <= gintAgentRadius and v.occupation == nil then
				v.isselected = not v.isselected
			end
		end
	end
end

function love.keyreleased( key, scancode )
	if key == "escape" then
		fun.RemoveScreen()
	end
	if key == "space" then
		gbolPaused = not gbolPaused
	end
	
	if key == "f" then
		-- turn selected bots into farmers
		for k,v in ipairs(Agents) do
			if v.isselected and v.occupation == nil then
				v.occupation = enum.jobFarmer
				v.isselected = false
				v.red = 0
				v.green = 1
				v.blue = 0
			end
		end
	end
	if key == "h" then
		-- turn selected bots into healers
		for k,v in ipairs(Agents) do
			if v.isselected and v.occupation == nil then
				v.occupation = enum.jobHealer
				v.isselected = false
				v.red = 218/255
				v.green = 73/255
				v.blue = 73/255
			end
		end
	end
	if key == "j" then
		-- turn selected bots into lumberjacks
		for k,v in ipairs(Agents) do
			if v.isselected and v.occupation == nil then
				v.occupation = enum.jobLumberjack
				v.isselected = false
				v.red = 208/255
				v.green = 156/255
				v.blue = 52/255
			end
		end
	end		
	
end

function love.load()

    if love.filesystem.isFused( ) then
        void = love.window.setMode(gintScreenWidth, gintScreenHeight,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(gintScreenWidth, gintScreenHeight,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end
	
	love.window.setTitle("PersonConomy " .. gstrGameVersion)
	
	love.physics.setMeter(1)
	world = love.physics.newWorld(0,0,false)	
	
	cobjs.CreateWorld(Zones)
	--cobjs.CreateWorld(Zones)
	gintNumAgents = 5
	for i = 1,gintNumAgents do
		cobjs.CreateAgent(i)
	end

	fun.AddScreen("World")

	bt.EstablishTree()
    
end

function love.draw()

	
	TLfres.beginRendering(gintScreenWidth,gintScreenHeight)
	-- sketchy:draw(world)
	dobjs.DrawWorld()
	dobjs.DrawAgents(Agents)
	
	dobjs.DrawInstructions()
	
	if not love.filesystem.isFused( ) then
		
		dobjs.DrawStats()
		dobjs.DrawPriorities()
	end
	TLfres.endRendering({0, 0, 0, 1})

end

function love.update(dt)

	if not gbolPaused then
		CheckIdleAgents(Agents,dt)
		PerformTasks(Zones, Agents, dt)
		CheckStatBounds(Agents)

		DegradeStats(Agents, dt)
		-- GrowThings(Zones,dt)
		KillThings(Zones, Agents, dt)
		
		GetStats(Zones, Agents, dt)
		
		SpawnAgents(dt)
		
		--BalancePriorities(Agents, dt)
		world:update(dt) --this puts the world into motion
	end
end







