module(...,package.seeall)

-- images (not quads)
imagesGrassDry = 1
imagesGrassGreen = 2
imagesGrassTeal = 3
imagesWell = 4
spriteAppleTree = 5     -- tree
spriteWoodPile = 6      -- logs
spriteHouse = 7
imagesHealingHouse = 8

imagesMud = 101
imagesHouseFrame = 102
imagesVillagerLog = 104

imagesEmoteSleeping = 121
imagesEmoteTalking = 122
imagesEmoteCash = 123


-- quads/sprites
spriteBlueMan = 100
spriteRedMan = 102
spriteBlueWoman = 103
spriteRedWoman = 104
spriteFarmerMan = 105



-- terrain types
terrainGrassDry = 1
terrainGrassGreen = 2
terrainTeal = 3

-- improvement types ## ensure these numbers align to the image enum above
-- NOTE: ensure these numbers align to the image enum above
improvementWell = 4
improvementFarm = 5 -- job, improvement and image should be the same integer value
improvementWoodsman = 6
improvementHouse = 7
improvementHealer = 8

-- jobs/occupations
-- NOTE: ensure these occupations align to the improvement type (which aligns to the image!)
jobFarmer = 5
jobWoodsman = 6
jobCarpenter = 201      -- this is a service - not a primary producer
jobHealer = 8           -- produces healing herbs
jobTaxCollector = 202


-- stock types
-- NOTE: ensure this lines up with the improvement type that sells this stock
stockFruit = 5
stockWood = 6
stockHouse = 7
stockHealingHerbs = 8

-- occupation icons
-- NOTE: ensure this lines up with the job + 30 for offset to avoid clashes
iconsApple = 35
iconsAxe = 36
iconsHammer = 231
iconsHealer = 38
iconsCoin = 232



-- goals/activities/queue items/actions
goalRest = 1
goalWork = 2    -- producers produce, service ppl service
goalEat = 3
goalBuy = 4     -- parent goal
goalBuyWood = 5 -- child goal
goalStockHouse = 6
goalHeal = 7


-- audio/music  ## ensure they have their own sequence without overlaps
audioYawn = 1
audioWork = 2
audioEat = 3
audioNewVillager = 4
audioRustle = 5
audioSawWood = 6
audioBandage = 7


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
