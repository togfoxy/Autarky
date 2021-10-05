module(...,package.seeall)

-- goals from tree

goalRest = 1
goalWork = 3
goalDrinkWater = 5

goalBuy = 14		-- a parent node
goalEat = 4
goalBuyWood = 9
goalHeal = 7
goalBuyCotton = 15
goalBuyCloth = 17

goalBuild = 13	-- a parent node
goalBuildHealer = 6
goalBuildLumberyard = 8
goalBuildFarm = 2
goalBuildHouseFoundation = 10
goalBuildHouse = 11
goalBuildCotton = 12
goalBuildWeaver = 16

goalAttack = 18
goalDefend = 19
goalPatrol = 20




-- zone types
zonetypeFood = 1
zonetypeWater = 2
zonetypeWood = 3
zonetypeHouse = 4
zonetypeHeal = 5
zonetypeLumberyard = 6
zonetypeHouseFoundation = 7
zonetypeCotton = 8
zonetypeWeaverShop = 9
zonetypeSoldier = 10

-- stock types
-- stocktypeFood = 1
-- stocktypeMedkits = 2
-- stocktypeLumber = 3


-- jobs/occupations
jobFarmer = 1
jobHealer = 2
jobLumberjack = 3
jobCotton = 4
jobWeaver = 5
jobSoldier = 6
jobEnemy = 7

-- these are seconds
timerNextTask = 5
timerBalancePriorities = 300
timerGetStats = 5
timerSpawnAgents = 180
timerKillThings = 30
timerTaxTime = 300



-- Add a new goal
--===============
-- add goal enum
-- update CheckIdleAgents
-- update PerformTasks
-- create new 'perform' function 
-- add behavior tree



-- Add a new occupation
--=====================
-- add a job enum
-- add a new zone type
-- update keyreleased()
-- add a new goal enum for build the shop
-- update DrawWorld() so the new zone is drawn
-- add behavior tree for build (see Add a new goal)
-- update dobjs.DrawInstructions

-- add a new zone
--=====================
-- add a new zone type
-- update DrawWorld






