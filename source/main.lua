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
gintScreenHeight = 800-- 1080
garrCurrentScreen = {}			-- screen stack

gintAgentRadius = 10
gintNextZoneID = 1
gintNumAgents = 9
gintTaxRate = 5		-- this is 1%
gintZoneSize = 50		-- pixels


Agents = {}						-- these are physics objects
Zones = {}				-- area's of interest to agents
tree = {}
garrGrid = {}			-- track which grid contains which zone
garrImage = {}
garrGlobals = {}		-- making a table means we can save it
garrGlobals.coffer = 0

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
gtmrTaxTime = enum.timerTaxTime

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
		if v.stamina <= 0 and v.friendly == true then
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

local function StopIfAtTarget(v)
-- returns a boolean AND stops the agent moving
-- v = single agent

	if cf.GetDistance(v.body:getX(), v.body:getY(),v.targetx,v.targety) < 45 then
		-- arrived. Remember we have arrived
		v.nexttasktimer = enum.timerNextTask
		local vx, vy = v.body:getLinearVelocity( )
		v.body:setLinearVelocity(vx / 2, vy / 2)
		return true
	end
	return false

end

local function GetClosestAgent(agts, seeker, bolFriendly)
-- return the closest enemy agent (object) or return nil
-- agts is the whole array
-- seeker is the single agent (obj) that is seeking an enemy
-- bolFriendly = true or false for the sort of person you're looking for
-- eg bolFriendly == true if you are seeking a friendly person (i.e seeker = enemy)

	local closesttarget = nil
	local closestdistance = 999
	
	for k,v in pairs(agts) do
		if v.friendly == bolFriendly and v.health > 0 then
		
			local x1 = seeker.body:getX()		-- x axis
			local y1 = seeker.body:getY()		-- y axis
			local x2 = v.body:getX()			-- x axis
			local y2 = v.body:getY()			-- y axis

			local dist = cf.GetDistance(x1, y1, x2, y2)
			if dist < closestdistance then
				closesttarget = v
				closestdistance = dist
			end
		end
	end
	
	return closesttarget

end

local function CheckIdleAgents(agt,dt)
-- agt = Agents

	for k,v in ipairs(agt) do
		v.nexttasktimer = v.nexttasktimer - dt
		if v.nexttasktimer <= 0 then v.nexttasktimer = 0 end

		-- see who is idle
		if v.currenttask == nil and v.nexttasktimer <= 0 then
			if v.friendly == true then
				if v.occupation == enum.jobSoldier and GetClosestAgent(agt, v, false) ~= nil then
						v.currenttask = enum.goalDefend
						v.currenttasklabel = "Defending village!"
						v.nexttasktimer = 5	
				else

					nextaction = ft.DetermineAction(tree, v)
					
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
					if nextaction == enum.goalBuyCotton then
						v.currenttasklabel = "Buying cotton"
					end				
					if nextaction == enum.goalBuyCloth then
						v.currenttasklabel = "Buying cloth"
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
					if nextaction == enum.goalBuildCotton then
						v.currenttasklabel = "Building cotton farm"
					end
					if nextaction == enum.goalBuildWeaver then
						v.currenttasklabel = "Building weaver shop"
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
			else
				v.currenttask = enum.goalAttack
				v.currenttasklabel = "Attacking village!"
				v.nexttasktimer = 5
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
			v.fullness = v.fullness - (dt / 4)
			v.stamina = v.stamina - (dt / 2 )
		else
			-- not moving
			v.hydration = v.hydration - (dt / 4)
			-- v.happiness = v.happiness - (dt / 2)
			v.fullness = v.fullness - (dt / 10)		
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

local function PerformBuild(zs,zonetype,v,dt)
-- generic build function
	if v.nexttasktimer <= 0 then	-- a value > 0 means we not yet arrived	
		if v.targetx == nil then
			v.targetzone = nil

			rndrow, rndcol = fun.GetClearBuildingSite()
			
			v.targetx = garrGrid[rndrow][rndcol].x
			v.targety = garrGrid[rndrow][rndcol].y
			garrGrid[rndrow][rndcol].zonetype = zonetype
	
		end
		MoveAgent(v)
		if StopIfAtTarget(v) then
			myzone = {}
			myzone = cobjs.CreateGenericZone(v,zonetype)
			table.insert(zs, myzone)
			v.workzone = myzone.ID	
			v.workzonex = v.x
			v.workzoney = v.y
			v.stamina = v.stamina - 10
			v.happiness = v.happiness - 10	
			v.hydration = v.hydration - 10	
			v.nexttasktimer = 0
			v.targetx = nil
			v.targety = nil
			v.currenttask = nil
			v.targetzone = nil
			
			-- small chance of being injured at work
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

local function AdjustStock(zs,v, qty, wealth)
-- zs = single zone
-- v = single agent
-- stock quantity to effect
-- wealth to assign to shopkeeper

	-- stock the shop
	zs.stocklevel = zs.stocklevel + qty
	v.wealth = v.wealth + wealth
	v.stamina = v.stamina - 4
	v.happiness = v.happiness - 4
	
	-- small chance of being injured at work
	if love.math.random(1,100) <= 5 then
		-- ouch
		v.health = v.health - (love.math.random(5,10))
	end	


end

local function PerformWork(zs, v, dt)

	local thiszone
	if v.nexttasktimer <= 0 then	-- a value > 0 means we not yet arrived
		-- a workzone is already allocated
		myzoneID = v.workzone
		
		for k,z in pairs(zs) do
			if z.ID == myzoneID then
				thiszone = z
			end
		end
	
		assert(thiszone ~= nil)
		
		v.targetx = thiszone.x + (thiszone.width / 2)
		v.targety = thiszone.y + (thiszone.height / 2)
		v.targetzsone = myzone		

		MoveAgent(v)	-- assumes targetx and targety are set
		
		if StopIfAtTarget(v) then
			if v.stamina > 0 then
				if thiszone.zonetype == enum.zonetypeFood then		
					-- stock the shop
					thiszone.stocklevel = thiszone.stocklevel + 6
					v.wealth = v.wealth + 6
					v.stamina = v.stamina - 4
					v.happiness = v.happiness - 4
					
					-- small chance of being injured at work
					if love.math.random(1,100) <= 5 then
						-- ouch
						v.health = v.health - (love.math.random(5,10))
					end	
				end
				if thiszone.zonetype == enum.zonetypeHeal then
					-- stock the medkits
					thiszone.stocklevel = thiszone.stocklevel + 1
					v.wealth = v.wealth + 10
					v.stamina = v.stamina - 6
					v.happiness = v.happiness - 2
				end	
				if thiszone.zonetype == enum.zonetypeLumberyard then
					-- stock the medkits
					thiszone.stocklevel = thiszone.stocklevel + 6
					v.wealth = v.wealth + 6
					v.stamina = v.stamina - 4
					v.happiness = v.happiness - 4
					-- small chance of being injured at work
					if love.math.random(1,100) <= 5 then
						-- ouch
						v.health = v.health - (love.math.random(5,10))
					end	
				end	
				if thiszone.zonetype == enum.zonetypeCotton then
					AdjustStock(thiszone,v,6,6)
				end
				if thiszone.zonetype == enum.zonetypeWeaverShop then
					if v.cottonstock > 5 then
						AdjustStock(thiszone,v,6,12)
						v.cottonstock = v.cottonstock - 6
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
				
				if amt > 25 then amt = 25 end
				
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
				v.targetzone = intBestZone		--** need to remember that zones don't use ID but are just a sequence	--!not sure this is right
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

local function PerformBuyCotton(zs, v, dt)

	if v.nexttasktimer <= 0 then	-- a value > 0 means journey is started but not yet arrived
		
		local intMostCotton
		local intBestZone
		if v.targetx == nil then
			-- find a wood zone with the most wood
			intMostCotton = 0
			intBestZone = -1
			for q,w in ipairs(zs) do
				if w.zonetype == enum.zonetypeCotton then
					if w.stocklevel > intMostCotton then
						intMostCotton = w.stocklevel
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
				v.targetzone = intBestZone		--** need to remember that zones don't use ID but are just a sequence	--!not sure this is right
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
				local amt = math.min(maxstock, maxwealth)
				
				if amt > 10 then amt = 10 end
				
				v.cottonstock = v.cottonstock + amt
				v.wealth = v.wealth - amt
				zs[v.targetzone].stocklevel = zs[v.targetzone].stocklevel - amt
				-- v.happiness = v.happiness + (5 * amt/10)
				-- v.stamina = v.stamina + (5 * amt/10)	
			end
		end
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end		


end

local function PerformBuyCloth(zs, v, dt)

	if v.nexttasktimer <= 0 then	-- a value > 0 means journey is started but not yet arrived
		
		local intMostCloth
		local intBestZone
		if v.targetx == nil then
			-- find a wood zone with the most wood
			intMostCloth = 0
			intBestZone = -1
			for q,w in ipairs(zs) do
				if w.zonetype == enum.zonetypeWeaverShop then
					if w.stocklevel > intMostCloth then
						intMostCloth = w.stocklevel
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
				v.targetzone = intBestZone		--** need to remember that zones don't use ID but are just a sequence	--!not sure this is right
				assert(v.targetzone ~= 0)	
			end
		end

		MoveAgent(v)
		
		assert(v.targetzone ~= nil)
		assert(v.targetzone ~= 0)

		if StopIfAtTarget(v) then
			if zs[v.targetzone] ~= nil then
				local maxstock = zs[v.targetzone].stocklevel
				local maxwealth = v.wealth / 2		-- cloth costs 2 coin and not 1
				local amt = math.min(maxstock, maxwealth)
				
				if amt > 10 then amt = 10 end
				
				v.happiness = v.happiness + (amt * 2)
				v.wealth = v.wealth - (amt * 2)
				zs[v.targetzone].stocklevel = zs[v.targetzone].stocklevel - amt
			end
		end
	else
		-- arrived some time previously
		UpdateTaskTimer(v, dt)	
	end		


end

local function PerformAttack(Zns, agts, enemy,dt)

	enemy.nexttasktimer = enemy.nexttasktimer - dt

	local closesttarget = nil		-- this is an actual agent
	
	closesttarget = GetClosestAgent(agts, enemy, true)
		
	enemy.targetx = closesttarget.body:getX()
	enemy.targety = closesttarget.body:getY()
	enemy.targetzone = 1		-- irrelevant but needs to be non-zero
	
	MoveAgent(enemy)
	
	--print(enemy.body:getLinearVelocity( ))

	if cf.GetDistance(enemy.body:getX(), enemy.body:getY(),closesttarget.body:getX(),closesttarget.body:getY()) < 35 then
		-- arrived
		local vx, vy = enemy.body:getLinearVelocity( )
		enemy.body:setLinearVelocity(vx / 2, vy / 2)
		
		if enemy.nexttasktimer <= 0 then
			enemy.nexttasktimer = 1	-- seconds
		
			enemy.health = enemy.health - 5
			
			if closesttarget.occupation == enum.jobSoldier then
				closesttarget.health = closesttarget.health - 5
			else
				closesttarget.health = closesttarget.health - 10
			end
			
			-- villager dead
			if closesttarget.health <= 0 then
			
				enemy.targetx = nil
				enemy.targety = nil
				enemy.targetzone = nil		-- irrelevant but needs to be non-zero
			
				local deadID = closesttarget.ID
				
				-- remove house and workplace
				for q,w in ipairs(Zns) do
					if w.worker == deadID or w.homeowner == deadID then
						table.remove(Zns, q)
					end
				end
				-- remove villager from array
				for k,v in pairs(agts) do
					if v.ID == deadID then
						table.remove(agts, k)
						break
					end
				end
			end
			
			-- enemy dead
			if enemy.health <= 0 then
				local deadID = enemy.ID
				-- remove enemy from array
				for k,v in pairs(agts) do
					if v.ID == deadID then
						table.remove(agts, k)
						break
					end
				end				
			end

		else
			-- can't attack till timer runs down
		end
	end

end

local function PerformDefend(Zns, agts, agt, dt)
-- -- agts is the array
-- -- agt is a single agent

	agt.nexttasktimer = agt.nexttasktimer - dt
	if agt.nexttasktimer <= 0 then
		agt.currenttask = nil
	end
	

	local closesttarget = nil		-- this is an actual agent
	
	closesttarget = GetClosestAgent(agts, agt, false)
	
	if closesttarget ~= nil then
		agt.targetx = closesttarget.body:getX()
		agt.targety = closesttarget.body:getY()
		agt.targetzone = -1		-- irrelevant but needs to be non-zero
		
		MoveAgent(agt)

		if cf.GetDistance(agt.body:getX(), agt.body:getY(),closesttarget.targetx,closesttarget.targety) < 35 then
			-- arrived
			local vx, vy = agt.body:getLinearVelocity( )
			agt.body:setLinearVelocity(vx / 2, vy / 2)

			if agt.nexttasktimer <= 0 then
				agt.nexttasktimer = 1	-- seconds
			
				agt.health = agt.health - 5
				
				if closesttarget.friendly == false then
					closesttarget.health = closesttarget.health - 5
				end
				
				-- enemy dead
				if closesttarget.health <= 0 then
				
					agt.targetx = nil
					agt.targety = nil
					agt.targetzone = nil		-- irrelevant but needs to be non-zero
				
					local deadID = closesttarget.ID
					
					-- remove villager from array
					for k,v in pairs(agts) do
						if v.ID == deadID then
							table.remove(agts, k)
							break
						end
					end
				end
				
				-- agent dead
				if agt.health <= 0 then
					local deadID = agt.ID
					-- remove agt from array
					for k,v in pairs(agts) do
						if v.ID == deadID then
							table.remove(agts, k)
							break
						end
					end				
				end
			end
		end
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
			-- PerformBuildFarm(znes, v,dt)
			PerformBuild(znes,enum.zonetypeFood,v,dt)
		end	
		if v.currenttask == enum.goalBuildCotton then
			PerformBuild(znes,enum.zonetypeCotton,v,dt)
		end			
		if v.currenttask == enum.goalWork then
			if v.occupation ~= enum.jobSoldier then
				PerformWork(znes, v,dt)
			end
		end	
		if v.currenttask == enum.goalEat then
			PerformEat(znes, v,dt)
		end	
		if v.currenttask == enum.goalDrinkWater then
			PerformDrinkWater(znes, v,dt)
		end			
		if v.currenttask == enum.goalBuildHealer then
			-- PerformBuildHealer(znes, v,dt)
			PerformBuild(znes,enum.zonetypeHeal,v,dt)
		end	
		if v.currenttask == enum.goalBuildWeaver then
			-- PerformBuildHealer(znes, v,dt)
			PerformBuild(znes,enum.zonetypeWeaverShop,v,dt)
		end	
		if v.currenttask == enum.goalHeal then
			PerformHeal(znes, v,dt)
		end	
		if v.currenttask == enum.goalBuildLumberyard then
			-- PerformBuildLumberyard(znes, v,dt)
			PerformBuild(znes,enum.zonetypeLumberyard,v,dt)
		end	
		if v.currenttask == enum.goalBuyWood then
			PerformBuyWood(znes, v,dt)
		end	
		if v.currenttask == enum.goalBuyCotton then
			PerformBuyCotton(znes, v,dt)
		end			
		if v.currenttask == enum.goalBuyCloth then
			PerformBuyCloth(znes, v,dt)
		end			
		if v.currenttask == enum.goalBuildHouseFoundation then
			PerformBuildHouseFoundation(znes, v,dt)
		end			
		if v.currenttask == enum.goalBuildHouse then
			PerformBuildHouse(znes, v,dt)
		end	
		if v.currenttask == enum.goalAttack then
			PerformAttack(znes, agt,v,dt)
		end
		if v.currenttask == enum.goalDefend then
			PerformDefend(znes, agt,v,dt)
		end	
		if v.currenttask == enum.goalPatrol then
			PerformRestImmediately(v,dt)
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

local function TaxTime(Agts, dt)
-- tax each citizen

	gtmrTaxTime = gtmrTaxTime - dt
	if gtmrTaxTime <= 0 then
		gtmrTaxTime = enum.timerTaxTime

		for k,v in pairs(Agts) do
			local taxpayment = v.wealth * (gintTaxRate / 100)
			v.wealth = v.wealth - taxpayment
			garrGlobals.coffer = garrGlobals.coffer + taxpayment
			
			if v.occupation == enum.jobSoldier then
				if garrGlobals.coffer >= 100 then
					v.wealth = v.wealth + 100
					garrGlobals.coffer = garrGlobals.coffer - 100
				else
					-- soldier not paid
					table.remove(Agts, k)
				end
			end
		end
	end
end

local function InitialiseGrid()
-- this is for simple tracking and fast lookup
	local rows,cols
	local maxrows,maxcols

	maxrows = cf.round((gintScreenHeight - gintZoneSize) / gintZoneSize,0)
	maxcols = cf.round((gintScreenWidth - gintZoneSize) / gintZoneSize,0)
	
	-- nice to keep things off the edge
	maxrows = maxrows - 1
	maxcols = maxcols - 1
	
-- print(gintScreenHeight,gintZoneSize)


	-- establish a 2D array
	for rows = 1,maxrows do
		garrGrid[rows] = {}
	end	
	
	for rows = 1, maxrows  do
		for cols = 1, maxcols  do
			garrGrid[rows][cols] = {}
			garrGrid[rows][cols].x = cols * gintZoneSize
			garrGrid[rows][cols].y = rows * gintZoneSize
			garrGrid[rows][cols].zonetype = 0
		end
	end
	
--print(maxrows,maxcols)	
--print(inspect(garrGrid))

end

function love.mousepressed( x, y, button, istouch, presses )

	local mousex,mousey = TLfres.getMousePosition(gintScreenWidth, gintScreenHeight)    -- lets you pretend screen is 1920 * 1080

	if button == 1 then
		for k,v in ipairs(Agents) do
			local x2 = v.body:getX()		-- x axis set above
			local y2 = v.body:getY()		-- y axis
			local dist = cf.GetDistance(mousex, mousey, x2, y2)

			if dist <= gintAgentRadius and v.occupation == nil and v.friendly == true then
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
	if key == "c" then		-- cotton
		for k,v in ipairs(Agents) do
			if v.isselected and v.occupation == nil then
				v.occupation = enum.jobCotton
				v.isselected = false
				v.red = 223/255
				v.green = 223/255
				v.blue = 223/255
			end
		end
	end
	if key == "w" then		-- weaver
		for k,v in ipairs(Agents) do
			if v.isselected and v.occupation == nil then
				v.occupation = enum.jobWeaver
				v.isselected = false
				v.red = 169/255
				v.green = 169/255
				v.blue = 169/255
				v.wealth = v.wealth - 50
				v.cottonstock = v.cottonstock + 50
			end
		end
	end		
	if key == "s" then		-- soldier
		for k,v in ipairs(Agents) do
			if v.isselected and v.occupation == nil then
				v.occupation = enum.jobSoldier
				v.isselected = false
				v.red = 134/255
				v.green = 22/255
				v.blue = 22/255
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
	
	garrImage[1] = love.graphics.newImage("assets/grass.jpg")
	
	InitialiseGrid()		-- must be called before CreateWorld
	
	cobjs.CreateWorld(Zones)
	
	for i = 1,gintNumAgents do
		cobjs.CreateAgent(true)
	end
	
	cobjs.CreateAgent(false)

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
		
		TaxTime(Agents, dt)
		
		SpawnAgents(dt)
		
		--BalancePriorities(Agents, dt)
		world:update(dt) --this puts the world into motion
	end
end







