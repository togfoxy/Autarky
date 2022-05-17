constants = {}

function constants.load()

    NUMBER_OF_VILLAGERS = 8

    ZOOMFACTOR = 1

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

    -- cost for things like services
    CARPENTER_HOUSEFRAME = 8
    WOOD_FULLHOUSE = 5
    BUILD_HOUSE_TIMER = 60

    -- production rates
    RATE_FRUIT = 0.0267
    RATE_WOOD = 0.0089
    RATE_HERBS = 0.0267


end


return constants
