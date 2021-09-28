local behaviortree = {}


function behaviortree.EstablishTree()
	
	
	tree = {}

	tree.goal = "root"
	tree.priority = function(bot)
								return 1
					end
	
	
	tree.child = {}
	tree.child[1] = {}
	tree.child[1].goal = enum.goalRest
	tree.child[1].priority = function(bot)
								return cf.round(((100 - bot.stamina) / 25) + 1,0)
							end
	tree.child[1].activate = function(bot)
								if bot.stamina < 75 then
									return true
								else
									return false
								end
							 end
	
	tree.child[2] = {}
	tree.child[2].goal = enum.goalBuildFarm
	tree.child[2].priority = function(bot)
								return 5
							end
	tree.child[2].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobFarmer then
									return true
								else
									return false
								end
							 end
	tree.child[3] = {}
	tree.child[3].goal = enum.goalWork
	tree.child[3].priority = function(bot)
								return 5
							end
	tree.child[3].activate = function(bot)
								if bot.workzone == nil or bot.stamina < 5 then
									return false
								else
									return true
								end
							 end
	tree.child[4] = {}
	tree.child[4].goal = enum.goalEat
	tree.child[4].priority = function(bot)
								return cf.round(((100 - bot.fullness) / 25) + 1,0)
							end
	tree.child[4].activate = function(bot)
								if bot.fullness < 75 and bot.wealth > 0 then
									return true
								else
									return false
								end
							 end
	tree.child[5] = {}
	tree.child[5].goal = enum.goalDrinkWater
	tree.child[5].priority = function(bot)
								return cf.round(((100 - bot.hydration) / 25) + 1,0)
							end
	tree.child[5].activate = function(bot)
								if bot.hydration < 75 then
									return true
								else
									return false
								end
							 end
	tree.child[6] = {}
	tree.child[6].goal = enum.goalBuildHealer
	tree.child[6].priority = function(bot)
								return 5
							end
	tree.child[6].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobHealer then
									return true
								else
									return false
								end
							 end
	tree.child[7] = {}
	tree.child[7].goal = enum.goalHeal
	tree.child[7].priority = function(bot)
								return cf.round(((100 - bot.health) / 25) + 1,0)
							end
	tree.child[7].activate = function(bot)
								if bot.health < 90 and bot.wealth > 0 then
									return true
								else
									return false
								end
							 end
	tree.child[8] = {}
	tree.child[8].goal = enum.goalBuildLumberyard
	tree.child[8].priority = function(bot)
								return 5
							end
	tree.child[8].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobLumberjack then
									return true
								else
									return false
								end
							 end
	tree.child[9] = {}
	tree.child[9].goal = enum.goalBuyWood
	tree.child[9].priority = function(bot)
								return 3
							end
	tree.child[9].activate = function(bot)
								if bot.woodstock < ginthousewoodcost and bot.wealth > 0 and bot.housezone == nil then
									return true
								else
									return false
								end
							 end							 
	tree.child[10] = {}
	tree.child[10].goal = enum.goalBuildHouseFoundation
	tree.child[10].priority = function(bot)
								return 5
							end
	tree.child[10].activate = function(bot)
								if bot.housezone == nil and bot.woodstock >= ginthousewoodcost and bot.wealth >= 10 then
									return true
								else
									return false
								end
							 end							 
	tree.child[11] = {}
	tree.child[11].goal = enum.goalBuildHouse
	tree.child[11].priority = function(bot)
								return 3
							end
	tree.child[11].activate = function(bot)
								if bot.occupation == enum.jobLumberjack then
									return true
								else
									return false
								end
							 end							 
							 
							 
							 
							 
--=====================
	-- tree.child = {}
	-- tree.child[1] = {}
	-- tree.child[1].goal = enum.goalRest
	-- tree.child[1].priority = 3
	-- tree.child[1].activate = function(bot)
								-- if bot.stamina < 75 then
									-- return true
								-- else
									-- return false
								-- end
							 -- end
	
	-- tree.child[2] = {}
	-- tree.child[2].goal = enum.goalBuildFarm
	-- tree.child[2].priority = 5
	-- tree.child[2].activate = function(bot)
								-- if bot.workzone == nil and bot.occupation == enum.jobFarmer then
									-- return true
								-- else
									-- return false
								-- end
							 -- end
	-- tree.child[3] = {}
	-- tree.child[3].goal = enum.goalWork
	-- tree.child[3].priority = 3
	-- tree.child[3].activate = function(bot)
								-- if bot.workzone == nil then
									-- return false
								-- else
									-- return true
								-- end
							 -- end
	-- tree.child[4] = {}
	-- tree.child[4].goal = enum.goalEat
	-- tree.child[4].priority = 3
	-- tree.child[4].activate = function(bot)
								-- if bot.fullness < 75 and bot.wealth > 0 then
									-- return true
								-- else
									-- return false
								-- end
							 -- end
	-- tree.child[5] = {}
	-- tree.child[5].goal = enum.goalDrinkWater
	-- tree.child[5].priority = 3
	-- tree.child[5].activate = function(bot)
								-- if bot.hydration < 75 then
									-- return true
								-- else
									-- return false
								-- end
							 -- end
	-- tree.child[6] = {}
	-- tree.child[6].goal = enum.goalBuildHealer
	-- tree.child[6].priority = 5
	-- tree.child[6].activate = function(bot)
								-- if bot.workzone == nil and bot.occupation == enum.jobHealer then
									-- return true
								-- else
									-- return false
								-- end
							 -- end
	-- tree.child[7] = {}
	-- tree.child[7].goal = enum.goalHeal
	-- tree.child[7].priority = 3
	-- tree.child[7].activate = function(bot)
								-- if bot.health < 90 and bot.wealth > 0 then
									-- return true
								-- else
									-- return false
								-- end
							 -- end


--=====================



	-- tree.child[2] = {}
	-- tree.child[2].goal = enum.goalWork
	-- tree.child[2].priority = 3
	-- tree.child[2].activate = function(bot)
								-- if bot.stamina <= 10 then
									-- return false
								-- else
									-- return true
								-- end
							-- end
	-- tree.child[3] = {}
	-- tree.child[3].goal = enum.goalRest
	-- tree.child[3].priority = 3
	-- tree.child[3].activate = nil
	
	-- tree.child[4] = {}
	-- tree.child[4].goal = enum.goalGetResources
	-- tree.child[4].priority = 2
	-- tree.child[4].activate = nil	
	-- tree.child[5] = {}
	-- tree.child[5].goal = enum.goalHeal
	-- tree.child[5].priority = 3
	-- tree.child[5].activate = function(bot)
								-- if bot.health > 99 or bot.wealth < 10 then
									-- return false
								-- else
									-- return true
								-- end
							-- end		
	

	-- tree.child[1].child = {}
	-- tree.child[1].child[1] = {}
	-- tree.child[1].child[1].goal = enum.goalEatEatFood
	-- tree.child[1].child[1].priority = 2
	-- tree.child[1].child[1].activate = function(bot)
										-- if bot.fullness >= 75 or bot.wealth <= 0 then
											-- return false
										-- else
											-- return true
										-- end
									-- end
	-- tree.child[1].child[2] = {}
	-- tree.child[1].child[2].goal = enum.goalEatEatWater
	-- tree.child[1].child[2].priority = 2
	-- tree.child[1].child[2].activate = nil
	-- tree.child[1].child[2].activate = function(bot)
										-- if bot.hydration >= 75 then
											-- return false
										-- else
											-- return true
										-- end
									-- end	
	-- tree.child[3].child = {}
	-- tree.child[3].child[1] = {}
	-- tree.child[3].child[1].goal = enum.goalRestRestImmediately
	-- tree.child[3].child[1].priority = 2	
	-- tree.child[3].child[1].activate = nil
	-- tree.child[3].child[2] = {}
	-- tree.child[3].child[2].goal = enum.goalRestRestInHouse
	-- tree.child[3].child[2].priority = 4	
	-- tree.child[3].child[2].activate = function(bot)
										-- if bot.housezone == nil then
											-- return false
										-- else
											-- return true
										-- end
									-- end		
	
	-- tree.child[4].child = {}
	-- tree.child[4].child[1] = {}
	-- tree.child[4].child[1].goal = enum.goalGetResourcesGetWood
	-- tree.child[4].child[1].priority = 3	
	-- tree.child[4].child[1].activate = function(bot)
										-- if bot.housezone ~= nil then
											-- return false
										-- else
											-- return true
										-- end
									-- end		
	-- tree.child[4].child[2] = {}
	-- tree.child[4].child[2].goal = enum.goalGetResourcesBuildHouse
	-- tree.child[4].child[2].priority = 3	
	-- tree.child[4].child[2].activate = function(bot)
										-- if bot.woodstock < 150 then
											-- return false
										-- else
											-- return true
										-- end
									-- end	
	

	
end

return behaviortree