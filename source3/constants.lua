constants = {}

function constants.load()

    NUMBER_OF_VILLAGERS = 7
    VILLAGE_WEALTH = 0
    NEW_VILLAGER_THRESHOLD = 150   --!        -- seconds it takes for a new villager

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

    PERSON_DRAW_WIDTH = 10          -- used to detect mouse clicks on villagers
    DISPLAY_GRAPH = false

    MAP = {}			-- a 2d table of tiles
    VILLAGERS = {}
    TREE = {}			-- a tree that holds all possible behaviours for a person
    STOCK_HISTORY = {}  -- tracks actual transaction prices for each commodity


    NUMBER_OF_STOCK_TYPES = 9   --## must equal the highest number (or more). It is NOT a count!!

    DEBUG = false
    NEW_VILLAGER_TIMER = 0
    PRICE_UPDATE_TIMER = 0
    VILLAGERS_SELECTED = 0          -- a count of selected villagers

    -- jumper stuff
    TILEWALKABLE = 0




    -- Economy stuff

    WALKING_SPEED = 900
    TIME_SCALE = 0.05          --0.025
    GST_RATE = 0.25             -- 10%
    INJURY_RATE = 20             -- higher numbers = more injuries
    STAMINA_USE_RATE = 17
    STAMINA_RECOVERY_RATE = STAMINA_USE_RATE * 3

    FRUIT_PRODUCTION_RATE = 1 * TIME_SCALE   -- produce 1 per time period
    FRUIT_SELL_PRICE = 1


    WOOD_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE / 3
    WOOD_SELL_PRICE = FRUIT_SELL_PRICE * 3

    HERB_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE / 2
    HERB_SELL_PRICE = FRUIT_SELL_PRICE * 2
    HERB_HEAL_AMOUNT = 7

    CARPENTER_BUILD_RATE = FRUIT_PRODUCTION_RATE * 100    -- how much time the carpenter spends on one wood
    CARPENTER_INCOME_PER_JOB = 5
    CARPENTER_WAGE = (FRUIT_SELL_PRICE * CARPENTER_INCOME_PER_JOB) / CARPENTER_BUILD_RATE      -- needs to be $5 for 5 seconds

    HOUSE_WEAR = CARPENTER_BUILD_RATE / 40       -- how fast a house wears down
    HEALTH_GAIN_FROM_WOOD = 1.5                     -- how much a house gains from a piece of wood
    HEALTH_GAIN_PER_WOOD = 25                       -- each wood adds at most this much health to each house

    WELFARE_PRODUCTION_RATE = FRUIT_PRODUCTION_RATE

    TAXCOLLECTOR_INCOME_PER_JOB = 0.2     -- arbitrary. No such thing as a 'job'. Public servants don't pay tax so keep this lower than normal

    WELLFAREOFFICER_INCOME_PER_JOB = TAXCOLLECTOR_INCOME_PER_JOB + (TAXCOLLECTOR_INCOME_PER_JOB * GST_RATE)  -- arbitrary. No such thing as a 'job'. Public servants don't pay tax so keep this lower than normal
end


return constants
