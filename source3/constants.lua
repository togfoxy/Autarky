constants = {}

function constants.load()

    NUMBER_OF_VILLAGERS = 7
    VILLAGE_WEALTH = 0
    NEW_VILLAGER_THRESHOLD = 300   --!        -- seconds it takes for a new villager

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


    DEBUG = false
    NEW_VILLAGER_TIMER = 0
    VILLAGERS_SELECTED = 0          -- a count of selected villagers

    -- jumper stuff
    TILEWALKABLE = 0




    -- Economy stuff

    WALKING_SPEED = 900
    TIME_SCALE = 0.05          --0.025
    GST_RATE = 0.10             -- 10%
    INJURY_RATE = 40             -- higher numbers = more injuries
    STAMINA_USE_RATE = 17
    STAMINA_RECOVERY_RATE = STAMINA_USE_RATE * 3

    FRUIT_PRODUCTION_RATE = 1 * TIME_SCALE   -- produce 1 per time period
    FRUIT_SELL_PRICE = 1

    WOOD_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE / 3
    WOOD_SELL_PRICE = FRUIT_SELL_PRICE * 3

    HERB_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE / 2
    HERB_SELL_PRICE = FRUIT_SELL_PRICE * 2
    HERB_HEAL_AMOUNT = cf.round(HERB_SELL_PRICE / 4, 4)      -- heal 1 health per 4 wealth earned

    CARPENTER_BUILD_RATE = FRUIT_PRODUCTION_RATE * 100    -- how much time the carpenter spends on one wood
    CARPENTER_INCOME_PER_JOB = 5
    CARPENTER_WAGE = (FRUIT_SELL_PRICE * CARPENTER_INCOME_PER_JOB) / CARPENTER_BUILD_RATE      -- needs to be $5 for 5 seconds

    HOUSE_WEAR = CARPENTER_BUILD_RATE / 40       -- how fast a house wears down
    HEALTH_GAIN_FROM_WOOD = 3.1

    WELFARE_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE

    TAXCOLLECTOR_WAGE = 0.10        -- they earn 10% of the taxes they collect

end


return constants
