module(...,package.seeall)

-- images (not quads)
imagesGrassDry = 1
imagesGrassGreen = 2
imagesGrassTeal = 3
imagesWell = 4
imagesFarm = 5
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


-- goals/activities/queue items/actions
goalRest = 1
goalWork = 2
goalEat = 3

-- jobs/occupations
-- NOTE: ensure these occupations align ti the improvement type (which aligns to the image!)
jobFarmer = 5



-- stock types
-- NOTE: ensure this lines up with the improvement type that sells this stock
stockFruit = 5


-- jumper stuff
tileWalkable = 0    -- should be a constant


-- audio
audioYawn = 1
audioWork = 2
audioEat = 3
audioNewVillager = 4

musicCityofMagic = 1
musicOvertheHills = 2
musicSpring = 3
musicMedievalFiesta = 4
musicFuji = 5
musicHiddenPond = 6
musicDistantMountains = 7

musicBirds = 21
musicBirdsinForest = 22
