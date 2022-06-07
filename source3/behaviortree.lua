local behaviortree = {}

-- a simple module that initialises the behavior tree specific to this project


function behaviortree.EstablishTree()
	-- these functions take a 'agent' which is a table with properties e.g. agent.stamina
	-- functions will activate if some agent property meets a specified condition

	-- low priority (e.g. 1) = less chance of occuring
	-- high priroty (e.g. 10) = more chance of occuring

	TREE = {}	-- works on global tree but should be fixed one day

	TREE.goal = "root"
	TREE.priority = function(agent)
						return 1
					end

	TREE.child = {}
	TREE.child[1] = {}
	TREE.child[1].goal = enum.goalRest
	TREE.child[1].priority = function(agent)
								return 5
							end
	TREE.child[1].activate = function(agent)
								return true	-- resting is the default action and must always be an option
							 end

 	TREE.child[2] = {}
 	TREE.child[2].goal = enum.goalWork
 	TREE.child[2].priority = function(agent)
								-- if DEBUG then print("Work priority is 5") end
 								return 5
 							end
 	TREE.child[2].activate = function(agent)
								if agent:has("occupation") and agent.isPerson.health >= 25 then
									return true
								else
									return false
								end
							end

	TREE.child[3] = {}
 	TREE.child[3].goal = enum.goalEatFruit
 	TREE.child[3].priority = function(agent)
								return 5
 							end
 	TREE.child[3].activate = function(agent)
								-- deactivate if person is full or broke and not a farmer
								if agent.isPerson.fullness > 70 or agent.isPerson.wealth < fun.getAvgSellPrice(enum.stockFruit) then
									return false
								else
									return true
								end
							end

	TREE.child[4] = {}
	TREE.child[4].goal = enum.goalGetWelfare
	TREE.child[4].priority = function(agent)
										return 5
									end
	TREE.child[4].activate = function(agent)
										if agent.isPerson.wealth < fun.getAvgSellPrice(enum.stockFruit) then
											return true
										else
											return false
										end
									end

	TREE.child[5] = {}
	TREE.child[5].goal = enum.goalBuyWood
	TREE.child[5].priority = function(agent)
										return 5
									end
	TREE.child[5].activate = function(agent)
										if agent.isPerson.wealth >= fun.getAvgSellPrice(enum.stockWood) and agent:has("occupation") then
											return true
										else
											return false
										end
									end


	TREE.child[6] = {}
	TREE.child[6].goal = enum.goalStockHouse			-- includes initiating a house
	TREE.child[6].priority = function(agent)
								return 7
							end
	TREE.child[6].activate = function(agent)
								if (agent.isPerson.stockInv[enum.stockWood] >= 1) then
									return true
								else
									return false
								end
							end

	TREE.child[7] = {}
	TREE.child[7].goal = enum.goalHeal
	TREE.child[7].priority = function(agent)
								return 5
							end
	TREE.child[7].activate = function(agent)
								if agent.isPerson.wealth >= fun.getAvgSellPrice(enum.stockHealingHerbs) and agent.isPerson.health < 60 then
									return true
								else
									return false
								end
							end


end

return behaviortree
