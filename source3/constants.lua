constants = {}

function constants.load()

    NUMBER_OF_VILLAGERS = 8

    SCREEN_WIDTH = 1920
    SCREEN_HEIGHT = 1080
    ZOOMFACTOR = 1
    TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels
    SCREEN_STACK = {}


    IMAGES = {}
    QUADS = {}
    SPRITES = {}
    DRAWQUEUE = {}			-- a list of things to be drawn during love.draw()
    AUDIO = {}

    TILE_SIZE = 50
    NUMBER_OF_ROWS = (cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 2
    NUMBER_OF_COLS = (cf.round(SCREEN_WIDTH / TILE_SIZE)) - 1
    LEFT_MARGIN = TILE_SIZE / 2
    TOP_MARGIN = TILE_SIZE / 2

    UPPER_TERRAIN_HEIGHT = 6

    PERSON_DRAW_WIDTH = 10

    MAP = {}			-- a 2d table of tiles
    VILLAGERS = {}
    TREE = {}			-- a tree that holds all possible behaviours for a person
    WALKING_SPEED = 50

    DEBUG = false
    NEW_VILLAGER_TIMER = 0

    -- jumper stuff
    TILEWALKABLE = 0

    -- wealth cost for each item
    PRICE_FRUIT = 1
    PRICE_WOOD = 3
    PRICE_HERBS = 3

    -- cost for things like services
    CARPENTER_HOUSEFRAME = 8
    WOOD_HOUSEFRAME = 5
    BUILD_HOUSE_TIMER = 60

    -- production rates
    RATE_FRUIT = 0.0267
    RATE_WOOD = 0.0089
    RATE_HERBS = 0.0267


end


return constants
