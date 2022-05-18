constants = {}

function constants.load()

    NUMBER_OF_VILLAGERS = 8

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

    -- wealth cost for each item
    PRICE_FRUIT = 1
    PRICE_WOOD = 3
    PRICE_HERBS = 3
    PRICE_CARPENTER = 0.05

    -- cost for things like services
    CARPENTER_HOUSEFRAME = 8
    WOOD_FULLHOUSE = 5
    HOUSE_GAIN_PER_WOOD = 10        -- percent
    SECONDS_SPENT_PER_WOOD = 10
    BUILD_HOUSE_TIMER = 60


    -- production rates
    RATE_FRUIT = 0.0267
    RATE_WOOD = 0.0089
    RATE_HERBS = 0.0267

    HOUSE_WEAR = 0.01       -- how fast a house wears down


end


return constants
