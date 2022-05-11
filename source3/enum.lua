module(...,package.seeall)

-- images (not quads)
imagesGrassDry = 1
imagesGrassGreen = 2
imagesGrassTeal = 3
imagesWell = 4
imagesFarm = 5
imagesWoodsman = 6
imagesMud = 99

-- quads/sprites
spriteBlueMan = 1
spriteRedMan = 2

-- terrain types
terrainGrassDry = 1
terrainGrassGreen = 2
terrainTeal = 3

-- improvement types ## ensure these numbers align to the image enum above
-- NOTE: ensure these numbers align to the image enum above
improvementWell = 4
improvementFarm = 5 -- job, improvement and image should be the same integer value
improvementWoodsman = 6


-- goals/activities/queue items/actions
goalRest = 1
goalWork = 2
goalEat = 3
goalBuy = 4     -- parent goal
goalBuyWood = 5

-- jobs/occupations
-- NOTE: ensure these occupations align ti the improvement type (which aligns to the image!)
jobFarmer = 5
jobWoodsman = 6



-- stock types
-- NOTE: ensure this lines up with the improvement type that sells this stock
stockFruit = 5
stockWood = 6


-- jumper stuff
tileWalkable = 0    -- should be a constant


-- audio/music  ## ensure they have their own sequence without overlaps
audioYawn = 1
audioWork = 2
audioEat = 3
audioNewVillager = 4

musicCityofMagic = 11
musicOvertheHills = 12
musicSpring = 13
musicMedievalFiesta = 14
musicFuji = 15
musicHiddenPond = 16
musicDistantMountains = 17

musicBirds = 21
musicBirdsinForest = 22
