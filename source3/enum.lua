module(...,package.seeall)

-- images (not quads)
imagesGrassDry = 1
imagesGrassGreen = 2
imagesGrassTeal = 3
imagesWell = 4
imagesFarm = 5          -- tree
imagesWoodsman = 6      -- logs
imagesHouseFrame = 7

imagesMud = 101
imagesHouse = 103
imagesEmoteSleeping = 121
imagesEmoteTalking = 122

-- quads/sprites
spriteBlueMan = 1
spriteRedMan = 2
spriteBlueWoman = 3
spriteRedWoman = 4

-- terrain types
terrainGrassDry = 1
terrainGrassGreen = 2
terrainTeal = 3

-- improvement types ## ensure these numbers align to the image enum above
-- NOTE: ensure these numbers align to the image enum above
improvementWell = 4
improvementFarm = 5 -- job, improvement and image should be the same integer value
improvementWoodsman = 6
improvementHouseFrame = 7
improvementHouse = 103

-- jobs/occupations
-- NOTE: ensure these occupations align to the improvement type (which aligns to the image!)
jobFarmer = 5
jobWoodsman = 6
jobCarpenter = 201      -- this is a service - not a primary producer


-- stock types
-- NOTE: ensure this lines up with the improvement type that sells this stock
stockFruit = 5
stockWood = 6
stockHouseFrame = 7

-- occupation icons
-- NOTE: ensure this lines up with the job
iconsApple = 5
iconsAxe = 6
iconsHammer = 201



-- goals/activities/queue items/actions
goalRest = 1
goalWork = 2    -- producers produce, service ppl service
goalEat = 3
goalBuy = 4     -- parent goal
goalBuyWood = 5 -- child goal
goalStartHouse = 6  -- build the frame only



-- jumper stuff
tileWalkable = 0    -- should be a constant


-- audio/music  ## ensure they have their own sequence without overlaps
audioYawn = 1
audioWork = 2
audioEat = 3
audioNewVillager = 4
audioRustle = 5
audioSawWood = 6


musicCityofMagic = 11
musicOvertheHills = 12
musicSpring = 13
musicMedievalFiesta = 14
musicFuji = 15
musicHiddenPond = 16
musicDistantMountains = 17

musicBirds = 21
musicBirdsinForest = 22

-- gender
genderMale = 1
genderFemale = 2
