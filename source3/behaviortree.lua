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
	tree.child[2].goal = enum.goalBuild
	tree.child[2].priority = function(bot)
								return 5
							end
	tree.child[2].activate = function(bot)
								if bot.workzone == nil and bot.occupation ~= nil then
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
								if (bot.workzone == nil or bot.stamina < 10) then
									return false
								else
									return true
								end
							 end
	tree.child[4] = {}
	tree.child[4].goal = enum.goalDrinkWater
	tree.child[4].priority = function(bot)
								return cf.round(((100 - bot.hydration) / 25) + 1,0)
							end
	tree.child[4].activate = function(bot)
								if bot.hydration < 33 then
									return true
								else
									return false
								end
							 end
	tree.child[5] = {}
	tree.child[5].goal = enum.goalBuy
	tree.child[5].priority = function(bot)
								return 5
							end
	tree.child[5].activate = function(bot)
								if bot.wealth < 10 then
									return false
								else
									return true
								end
							 end




	tree.child[2].child = {}
	tree.child[2].child[1] = {}
	tree.child[2].child[1].goal = enum.goalBuildCotton
	tree.child[2].child[1].priority = function(bot)
								return 5
							end
	tree.child[2].child[1].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobCotton then
									return true
								else
									return false
								end
							 end
	--tree.child[2].child = {}		-- only do this for the first instance
	tree.child[2].child[2] = {}
	tree.child[2].child[2].goal = enum.goalBuildFarm
	tree.child[2].child[2].priority = function(bot)
								return 5
							end
	tree.child[2].child[2].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobFarmer then
									return true
								else
									return false
								end
							 end
	--tree.child[2].child = {}		-- only do this for the first instance
	tree.child[2].child[3] = {}
	tree.child[2].child[3].goal = enum.goalBuildHealer
	tree.child[2].child[3].priority = function(bot)
								return 5
							end
	tree.child[2].child[3].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobHealer then
									return true
								else
									return false
								end
							 end
	--tree.child[2].child = {}		-- only do this for the first instance
	tree.child[2].child[4] = {}
	tree.child[2].child[4].goal = enum.goalBuildLumberyard
	tree.child[2].child[4].priority = function(bot)
								return 5
							end
	tree.child[2].child[4].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobLumberjack then
									return true
								else
									return false
								end
							 end
	--tree.child[2].child = {}		-- only do this for the first instance
	tree.child[2].child[5] = {}
	tree.child[2].child[5].goal = enum.goalBuildHouseFoundation
	tree.child[2].child[5].priority = function(bot)
								return 5
							end
	tree.child[2].child[5].activate = function(bot)
								if bot.housezone == nil and bot.woodstock >= ginthousewoodcost and bot.wealth >= 10 then
									return true
								else
									return false
								end
							 end
	--tree.child[2].child = {}		-- only do this for the first instance
	tree.child[2].child[6] = {}
	tree.child[2].child[6].goal = enum.goalBuildHouse
	tree.child[2].child[6].priority = function(bot)
								return 5
							end
	tree.child[2].child[6].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobLumberjack then
									return true
								else
									return false
								end
							 end
	--tree.child[2].child = {}		-- only do this for the first instance
	tree.child[2].child[7] = {}
	tree.child[2].child[7].goal = enum.goalBuildWeaver
	tree.child[2].child[7].priority = function(bot)
								return 5
							end
	tree.child[2].child[7].activate = function(bot)
								if bot.workzone == nil and bot.occupation == enum.jobWeaver then
									return true
								else
									return false
								end
							 end

	tree.child[5].child = {}		-- only do this for the first instance
	tree.child[5].child[1] = {}
	tree.child[5].child[1].goal = enum.goalHeal
	tree.child[5].child[1].priority = function(bot)
								return cf.round(((100 - bot.health) / 25) + 1,0)
							end
	tree.child[5].child[1].activate = function(bot)
								if bot.health < 75 and bot.wealth > 0 then
									return true
								else
									return false
								end
							 end
	--tree.child[5].child = {}		-- only do this for the first instance
	tree.child[5].child[2] = {}
	tree.child[5].child[2].goal = enum.goalBuyWood
	tree.child[5].child[2].priority = function(bot)
								return 3
							end
	tree.child[5].child[2].activate = function(bot)
								if bot.woodstock < ginthousewoodcost and bot.wealth > 0 and bot.housezone == nil and bot.occupation ~= enum.jobSoldier then
									return true
								else
									return false
								end
							 end
	--tree.child[5].child = {}		-- only do this for the first instance
	tree.child[5].child[3] = {}
	tree.child[5].child[3].goal = enum.goalEat
	tree.child[5].child[3].priority = function(bot)
								if bot.fullness < 25 then
									return 10
								else
									return cf.round(((100 - bot.fullness) / 25) + 1,0)
								end
							end
	tree.child[5].child[3].activate = function(bot)
								if bot.fullness < 50 and bot.wealth > 0 then
									return true
								else
									return false
								end
							 end
	--tree.child[5].child = {}		-- only do this for the first instance
	tree.child[5].child[4] = {}
	tree.child[5].child[4].goal = enum.goalBuyCotton
	tree.child[5].child[4].priority = function(bot)
								return 7
							end
	tree.child[5].child[4].activate = function(bot)
								if bot.occupation == enum.jobWeaver and bot.wealth > 0 and bot.cottonstock <= 50 then
									return true
								else
									return false
								end
							 end
	--tree.child[5].child = {}		-- only do this for the first instance
	tree.child[5].child[5] = {}
	tree.child[5].child[5].goal = enum.goalBuyCloth
	tree.child[5].child[5].priority = function(bot)
								return 5
							end
	tree.child[5].child[5].activate = function(bot)
								if bot.happiness < 75 and bot.wealth > 0 then
									return true
								else
									return false
								end
							 end

end

return behaviortree
