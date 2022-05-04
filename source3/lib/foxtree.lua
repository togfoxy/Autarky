local foxtree = {}

local function GetNextLevel(t)
    local myarray = {}

    for k,v in ipairs(t.child) do
        table.insert(myarray, v)
        -- print("Possisble action/priority: " .. v.goal, v.priority())
    end
    return myarray
end

function foxtree.DetermineAction(t, bot)
    -- returns an enum.goal (integer) based on rndnum and the BT

    local nextlevel = {}
    nextlevel = GetNextLevel(t)

    local totalchance = 0
    for k,v in ipairs(nextlevel) do
		-- print("g: " .. v.goal)
		if v.activate == nil then
			totalchance = totalchance + v.priority(bot)
		else
			-- activate is not nil (but could be false)
			if v.activate(bot) == true then

				totalchance = totalchance + v.priority(bot)
				-- print(bot.workzone, bot.occupation)
			else
				-- node is deactivated so don't consider it's priority
			end
		end
    end

    local rndnum = love.math.random(1, totalchance)
    -- print("random action: " .. rndnum .. " from a total priority count of " .. totalchance)

    for k,v in ipairs(nextlevel) do
		if v.activate == nil or v.activate(bot) == true then		-- skips over nodes that are not active
			if rndnum <= v.priority(bot) then
				if v.child == nill then
					-- print("Returning goal: " .. v.goal .. " for bot #" .. bot.ID)
					return v.goal
				else
					return foxtree.DetermineAction(v, bot)	-- v is a node
				end
			else
				rndnum = rndnum - v.priority(bot)
			end
		end
    end

end

return foxtree
