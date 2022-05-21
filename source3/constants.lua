constants = {}

function constants.load()

    NUMBER_OF_VILLAGERS = 8
    VILLAGE_WEALTH = 0

    ZOOMFACTOR = 1
    MUSIC_TOGGLE = true
    SOUND_TOGGLE = true

    SCREEN_STACK = {}

    IMAGES = {}
    QUADS = {}
    SPRITES = {}
    DRAWQUEUE = {}			-- a list of things to be drawn during love.draw()
    AUDIO = {}

    UPPER_TERRAIN_HEIGHT = 6

    PERSON_DRAW_WIDTH = 10

    MAP = {}			-- a 2d table of tiles
    VILLAGERS = {}
    TREE = {}			-- a tree that holds all possible behaviours for a person
    WALKING_SPEED = 50

    DEBUG = false
    NEW_VILLAGER_TIMER = 0
    VILLAGERS_SELECTED = 0          -- a count of selected villagers

    -- jumper stuff
    TILEWALKABLE = 0




    -- Economy stuff

    TIME_SCALE = 0.025
    GST_RATE = 0.10             -- 10%

    FRUIT_PRODUCTION_RATE = 1 * TIME_SCALE   -- produce 1 per time period
    FRUIT_SELL_PRICE = 1

    WOOD_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE / 3
    WOOD_SELL_PRICE = FRUIT_SELL_PRICE * 3

    HERB_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE / 6
    HERB_SELL_PRICE = FRUIT_SELL_PRICE * 6

    CARPENTER_BUILD_RATE = FRUIT_PRODUCTION_RATE * 100    -- how much time the carpenter spends on one wood
    CARPENTER_INCOME_PER_JOB = 8
    CARPENTER_WAGE = (FRUIT_SELL_PRICE * CARPENTER_INCOME_PER_JOB) / CARPENTER_BUILD_RATE      -- needs to be $5 for 5 seconds + the 3 second penalty to buy the wood = $8

    HOUSE_WEAR = CARPENTER_BUILD_RATE / 20       -- how fast a house wears down
    HEALTH_GAIN_FROM_WOOD = 3.1

    TAXCOLLECTOR_WAGE = 0.10        -- they earn 10% of the taxes they collect

end


return constants
