local drawobjects = {}


local function DrawGraph()

	love.graphics.setColor(0,0,0,0.5)
	
	local x = 250
	local y = 25
	local w = 500
	local h = 50
	
	love.graphics.rectangle("fill",x,y,w,h)

	-- draw food graph
	if #garrFoodGraph > 0 then
		local loopcount = #garrFoodGraph
		for i = 1, loopcount do
			local drawx = x + i
			local score = (garrFoodGraph[i] / enum.constFoodTarget)	-- gives a %
			if score > 1 then score = 1 end
			local drawy = y + 50 - (score * h)

			love.graphics.setColor(0,1,0,1)
			love.graphics.points(drawx, drawy)
		end
	end

	-- draw happy graph
	if #garrHappyGraph > 0 then
		local loopcount = #garrHappyGraph
		for i = 1, loopcount do
			local drawx = x + i
			local score = (garrHappyGraph[i] / enum.constHappyTarget)	-- gives a %
			if score > 1 then score = 1 end
			local drawy = y + 50 - (score * h)

			love.graphics.setColor(238/255,210/255,28/255,1)
			love.graphics.points(drawx, drawy)
		end
	end
	
	-- draw health graph
	if #garrHealthGraph > 0 then
		local loopcount = #garrHealthGraph
		for i = 1, loopcount do
			local drawx = x + i
			local score = (garrHealthGraph[i] / 100)	-- gives a %
			if score > 1 then score = 1 end
			local drawy = y + 50 - (score * h)

			love.graphics.setColor(218/255,73/255,73/255,1)
			love.graphics.points(drawx, drawy)
		end
	end	
	-- draw cotton graph
	if #garrCottonGraph > 0 then
		local loopcount = #garrCottonGraph
		for i = 1, loopcount do
			local drawx = x + i
			local score = (garrCottonGraph[i] / 100)	-- gives a % assuming 100 is an ideal average stock level
			if score > 1 then score = 1 end
			local drawy = y + 50 - (score * h)

			love.graphics.setColor(223/255,233/255,233/255,1)
			love.graphics.points(drawx, drawy)
		end
	end	

	
end

 function drawobjects.DrawInstructions()
 
	local tmpstr = ""
	
	tmpstr = tmpstr .. "Use mouse to select villager" .. "\n"
	tmpstr = tmpstr .. "'F' to make a farmer" .. "\n"
	tmpstr = tmpstr .. "'B' to make a builder" .. "\n"
	-- tmpstr = tmpstr .. "'H' to make a healer" .. "\n"
	-- tmpstr = tmpstr .. "'J' to make a lumberjack" .. "\n"
	-- tmpstr = tmpstr .. "'C' to make a cotton farmer" .. "\n"
	-- tmpstr = tmpstr .. "'W' to make a weaver" .. "\n"
	-- tmpstr = tmpstr .. "'S' to make a soldier" .. "\n"
	
	-- tmpstr = tmpstr .. "<space> to pause" .. "\n"
	
	love.graphics.print(tmpstr, 28,75)
  
 end


return drawobjects