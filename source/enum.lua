module(...,package.seeall)

-- goals from tree

goalRest = 1
goalBuildFarm = 2
goalWork = 3
goalEat = 4
goalDrinkWater = 5
goalBuildHealer = 6
goalHeal = 7
goalBuildLumberyard = 8
goalBuyWood = 9
goalBuildHouseFoundation = 10
goalBuildHouse = 11

-- zone types
zonetypeFood = 1
zonetypeWater = 2
zonetypeWood = 3
zonetypeHouse = 4
zonetypeHeal = 5
zonetypeLumberyard = 6
zonetypeHouseFoundation = 7

-- jobs/occupations
jobFarmer = 1
jobHealer = 2
jobLumberjack = 3

-- these are seconds
timerNextTask = 5
timerBalancePriorities = 300
timerGetStats = 5
timerSpawnAgents = 60
timerKillThings = 30



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
-- add a "build workplace" if necessary
-- add a new goal enum for build
-- update PerformWork()
-- update DrawWorld() so the new zone is drawn
-- add behavior tree for build (see Add a new goal)

-- add a new zone
--=====================
-- add a new zone type
-- update DrawWorld






