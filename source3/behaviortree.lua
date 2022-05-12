local behaviortree = {}

-- a simple module that initialises the behavior tree specific to this project


function behaviortree.EstablishTree()
	-- these functions take a 'agent' which is a table with properties e.g. agent.stamina
	-- functions will activate if some agent property meets a specified condition

	-- low priority (e.g. 1) = less chance of occuring
	-- high priroty (e.g. 10) = more chance of occuring

	TREE = {}	--! works on global tree but should be fixed

	TREE.goal = "root"
	TREE.priority = function(agent)
						return 1
					end

	TREE.child = {}
	TREE.child[1] = {}
	TREE.child[1].goal = enum.goalRest
	TREE.child[1].priority = function(agent)
								local priority = cf.round((100 - agent.isPerson.stamina) / 10)
								if priority < 1 then priority = 1 end
								-- if DEBUG then print("Rest priority is " .. priority) end
								return priority
							end
	TREE.child[1].activate = function(agent)
								return true	-- resting is the default action and must always be an option
							 end

 	TREE.child[2] = {}
 	TREE.child[2].goal = enum.goalWork
 	TREE.child[2].priority = function(agent)
								-- if DEBUG then print("Work priority is 5") end
 								return 3
 							end
 	TREE.child[2].activate = function(agent)
								if agent:has("occupation") then
									return true
								else
									return false
								end
							end

	TREE.child[3] = {}
 	TREE.child[3].goal = enum.goalEat
 	TREE.child[3].priority = function(agent)
								if agent.isPerson.fullness < 35 then
									return 50
								else
									local priority = cf.round((100 - agent.isPerson.fullness) / 10)
									if priority < 1 then priority = 1 end
									-- if DEBUG then print("Eat priority is " .. priority) end
									return priority
								end
 							end
 	TREE.child[3].activate = function(agent)
								-- deactivate if person is full or broke and not a farmer
								if agent.isPerson.fullness > 70 then
									return false
								elseif agent.isPerson.wealth < 1 and agent:has("occupation") then
									if agent.occupation.value == enum.jobFarmer then
										return true
									else
										return false
									end
								else
									if agent.isPerson.wealth >= 1 then
										return true
									else
										return false
									end
								end
							end

	TREE.child[4] = {}
	TREE.child[4].goal = enum.goalBuy
	TREE.child[4].priority = function(agent)
								return 3
							end
	TREE.child[4].activate = function(agent)
								if agent.isPerson.wealth >= 3 then
									return true
								else
									return false
								end
							end

	TREE.child[4].child = {}
	TREE.child[4].child[1] = {}
	TREE.child[4].child[1].goal = enum.goalBuyWood
	TREE.child[4].child[1].priority = function(agent)
										return 5
									end
	TREE.child[4].child[1].activate = function(agent)
										if not agent:has("residenceFrame") and not agent:has("residence") then
											return true
										else
											return false
										end
									end

	TREE.child[5] = {}
	TREE.child[5].goal = enum.goalStartHouse
	TREE.child[5].priority = function(agent)
								return 3
							end
	TREE.child[5].activate = function (agent)
								if agent.isPerson.stockInv[enum.stockWood] >= 5 and not agent:has("residenceFrame") and not agent:has("residence") then
									return true
								else
									return false
								end
							end




end

return behaviortree
