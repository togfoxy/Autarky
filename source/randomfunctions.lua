local randomfunctions = {}

function randomfunctions.AddScreen(strNewScreen)
	table.insert(garrCurrentScreen, strNewScreen)
end

function randomfunctions.RemoveScreen()
	table.remove(garrCurrentScreen)
	if #garrCurrentScreen < 1 then
	
		print(inspect(tree))
		success, message = love.filesystem.write( "tree.txt", inspect(tree))
		if success then
			love.event.quit()       --! this doesn't dothe same as the EXIT button
		end
	end
end

function randomfunctions.AdjustVector(component)
-- adjusts a single vector component - the x-component or y-component - not both!!!
-- component = a number

	if component < -50 then component = -50 end
	if component < 0 and component > -50 then component = -50 end
	if component > 0 and component < 50 then component = 50 end
	if component > 50 then component = 50 end

	return component

end

function randomfunctions.NormaliseVectors(xv, yv)

	local myx = math.abs(xv)
	local myy = math.abs(yv)
	local mymax = math.max(myx,myy)
	
	local newscale = 1
	if mymax > 50 then
		newscale = 50 / mymax
	end

	return cf.ScaleVector(xv,yv,newscale)
end

function randomfunctions.GetClearBuildingSite()
-- return a 'tile' that can be used/built on

	local rndrow, rndcol 
	repeat
		rndrow = love.math.random(1,#garrGrid)
		rndcol = love.math.random(1,#garrGrid[rndrow])
	until garrGrid[rndrow][rndcol].zonetype == 0
	
	return rndrow, rndcol


end

return randomfunctions


