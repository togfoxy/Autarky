local drawobjects = {}

function drawobjects.DrawWorld()

	for k,v in ipairs(Zones) do
	
		if v.zonetype == enum.zonetypeFood then
			love.graphics.setColor(0,1,0,1)
			love.graphics.rectangle("line", v.x,v.y,v.width + 15,v.height)
			
			love.graphics.print("Stock: " .. cf.round(v.stocklevel,0), v.x + 2, v.y + 7)
			love.graphics.print("Fruit shop", v.x+2, v.y + 30)
		end
		if v.zonetype == enum.zonetypeWater then
			love.graphics.setColor(33/255,182/255,219/255,1)
			love.graphics.rectangle("fill", v.x,v.y,v.width,v.height)
		end
		if v.zonetype == enum.zonetypeLumberyard then
			love.graphics.setColor(208/255,156/255,52/255,1)
			love.graphics.rectangle("line", v.x,v.y,v.width + 25,v.height)
			love.graphics.print("Stock: " .. cf.round(v.stocklevel,0), v.x + 2, v.y + 7)
			love.graphics.print("Lumber", v.x+2, v.y + 30)
		end
		if v.zonetype == enum.zonetypeHouseFoundation then
			love.graphics.setColor(28/255,60/255,117/255,1)
			love.graphics.rectangle("line", v.x,v.y,v.width + 15,v.height)
		end		
		if v.zonetype == enum.zonetypeHouse then
			love.graphics.setColor(45/255,100/255,193/255,1)
			love.graphics.rectangle("line", v.x,v.y,v.width + 15,v.height)
			love.graphics.setColor(26/255,67/255,138/255,1)
			love.graphics.rectangle("fill", v.x + 1,v.y + 1,v.width - 2 + 15,v.height - 2)
			love.graphics.setColor(1,1,1,1)
			love.graphics.print("House", v.x+2, v.y + 30)
			
			
		end				
		if v.zonetype == enum.zonetypeHeal then
			love.graphics.setColor(218/255,73/255,73/255,1)
			love.graphics.rectangle("line", v.x,v.y,v.width + 15,v.height)
			love.graphics.print("Stock: " .. cf.round(v.stocklevel,0), v.x + 2, v.y + 7)
			love.graphics.print("Healer", v.x+2, v.y + 30)
		end		
	end
	
	if gbolPaused then
		love.graphics.setColor(1,1,1,1)
		love.graphics.print("Paused", 950, 550)
	end
end

function drawobjects.DrawAgents(agt)
-- agt = Agents

	for k, v in ipairs(agt) do
	
		local x = v.body:getX()
		local y = v.body:getY()
	
		love.graphics.setColor(v.red,v.green,v.blue,1)
		
		love.graphics.circle("fill", x,y, gintAgentRadius )		
		
		if v.isselected then
			love.graphics.setColor(1,0,0,0.5)
			love.graphics.circle("fill", x,y, gintAgentRadius / 2 )			
		end
		
		-- display their ID
		love.graphics.setColor(219/255,45/255,45/255,1)
		love.graphics.print(v.ID,x-5,y-7 )			-- the -5 is to centre the text
		
		-- display meta-data for debugging
		local tmpstr = ""
		
		tmpstr = tmpstr .. "Action: "
		if v.currenttasklabel ~= nil then
			tmpstr = tmpstr .. v.currenttasklabel
		end
		tmpstr = tmpstr .. "\n"
		
		love.graphics.setColor(1,1,1,1)
		tmpstr = tmpstr .. "Health: " .. cf.round(v.health,0) .. "\n"
		tmpstr = tmpstr .. "Fullness: " .. cf.round(v.fullness,0) .. "\n"
		tmpstr = tmpstr .. "Hydration: " .. cf.round(v.hydration,0) .. "\n"
		tmpstr = tmpstr .. "Stamina: " .. cf.round(v.stamina,0) .. "\n"
		tmpstr = tmpstr .. "Happiness: " .. cf.round(v.happiness,0) .. "\n"
		tmpstr = tmpstr .. "Wealth: " .. cf.round(v.wealth,0) .. "\n"
		tmpstr = tmpstr .. "Wood: " .. cf.round(v.woodstock,0) .. "\n"
		
		love.graphics.print(tmpstr, x+10,y+5 )

	end

end

function drawobjects.DrawStats()

	local tmpstr = ""
	
	tmpstr = "Fullness: " .. cf.round(gstatFullness,0) .. "\n"
	tmpstr = tmpstr .. "Hydration: " .. cf.round(gstatHydration,0) .. "\n"
	tmpstr = tmpstr .. "Stamina: " .. cf.round(gstatStamina,0) .. "\n"
	tmpstr = tmpstr .. "Happiness: " .. cf.round(gstatHappiness,0) .. "\n"
	tmpstr = tmpstr .. "Avail. food: " .. cf.round(gstatFoodStock,0) .. "\n"
	
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.print(tmpstr, 10,10)

end

function drawobjects.DrawPriorities()
  
  	local tmpstr = ""
	
	tmpstr = "Eat food #1: " .. cf.round(tree.child[4].priority(Agents[1]),0) .. "\n"
	-- tmpstr = tmpstr .. "Eat water: " .. tree.child[1].child[2].priority .. "\n"
	-- tmpstr = tmpstr .. "Rest: " .. tree.child[1].priority .. "\n"
	-- tmpstr = tmpstr .. "Work: " .. tree.child[2].priority .. "\n"
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.print(tmpstr, 10,160)
    
 end
 
 function drawobjects.DrawInstructions()
 
	local tmpstr = ""
	
	tmpstr = tmpstr .. "Use mouse to select villager" .. "\n"
	tmpstr = tmpstr .. "'F' to make a farmer" .. "\n"
	tmpstr = tmpstr .. "'H' to make a healer" .. "\n"
	tmpstr = tmpstr .. "'J' to make a lumberjack" .. "\n"
	
	tmpstr = tmpstr .. "<space> to pause" .. "\n"
	
	love.graphics.print(tmpstr, 10,200)
 
 
 end


return drawobjects