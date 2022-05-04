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
    nextlevel = GetNextLevel(t)     -- gets all the children below the current 'level'

    -- cycle through all nodes, check if the node is active, and if it is, 'sum' it's priority for later use
    local totalchance = 0
    for k,v in ipairs(nextlevel) do     -- cycle through all the nodes in nextlevel - which is really the children of the previous parents
		-- print("g: " .. v.goal)
		if v.activate == nil then
			totalchance = totalchance + v.priority(bot)
		else
			-- activate is not nil (but could be false)
			if v.activate(bot) == true then

				totalchance = totalchance + v.priority(bot)
			else
				-- node is deactivated so don't consider it's priority
			end
		end
    end

    -- the sum of all priorities is now determined. "Roll the dice" and see which node is actually selected.
    local rndnum = love.math.random(1, totalchance)
    -- print("random action: " .. rndnum .. " from a total priority count of " .. totalchance)

    for k,node in ipairs(nextlevel) do
		if node.activate == nil or node.activate(bot) == true then		-- skips over nodes that are not active
			if rndnum <= node.priority(bot) then
				if node.child == nil then
					-- print("Returning goal: " .. node.goal .. " for agent " .. bot.uid.value)   -- for debugging. Comment out if not needed
					return node.goal
				else
					return foxtree.DetermineAction(node, bot)	-- node is a node but it is known it has child nodes so recursively repeat the process for them
				end
			else
				rndnum = rndnum - node.priority(bot)
			end
		end
    end

end

return foxtree
