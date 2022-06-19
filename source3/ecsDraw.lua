ecsDraw = {}

local function getImageNumberFromFacing(facing)
    if facing == "N" then return 21 end
    if facing == "NE" then return 26 end
    if facing == "E" then return 31 end
    if facing == "SE" then return 36 end
    if facing == "S" then return 1 end
    if facing == "SW" then return 6 end
    if facing == "W" then return 11 end
    if facing == "NW" then return 16 end
    error("Unknown facing")
end

local function determineFacing(e)
    local prevx = (e.position.previousx)
    local prevy = (e.position.previousy)
    local currentx = (e.position.x)
    local currenty = (e.position.y)

    if prevx == currentx and prevy == currenty then
        -- not moving
        return "S"
    end
    if prevx == currentx and prevy > currenty then
        -- moving up
        return "N"
    end
    if prevx == currentx and prevy < currenty then
        -- moving down
        return "S"
    end
    if prevx > currentx and prevy == currenty then
        -- moving left
        return "W"
    end
    if prevx < currentx and prevy == currenty then
        -- moving right
        return "E"
    end
    if prevx < currentx and prevy > currenty then
        -- moving up and right
        return "NE"
    end
    if prevx < currentx and prevy < currenty then
        -- moving down and right
        return "SE"
    end
    if prevx > currentx and prevy < currenty then
        -- moving down and left
        return "SW"
    end
    if prevx > currentx and prevy > currenty then
        -- moving up and left
        return "NW"
    end
    error("Entity has unknown facing")
end

function ecsDraw.draw()

    systemDraw = concord.system({
        pool = {"position", "drawable"}
    })
    -- define same systems
    function systemDraw:draw()
        love.graphics.setColor(1,1,1,1)
        for _, e in ipairs(self.pool) do
            if e.isTile then
                local row, col = e.position.row, e.position.col
                -- draw tile image
                local img
                local imgnumber

                -- NOTE: This is NOT the improvement
                local img = IMAGES[e.isTile.tileType]
                local drawx, drawy = LEFT_MARGIN + e.position.x, TOP_MARGIN + e.position.y
                local imagewidth = img:getWidth()
                local imageheight = img:getHeight()
                local drawscalex = (TILE_SIZE / imagewidth)
                local drawscaley = (TILE_SIZE / imageheight)
                local offsetx = imagewidth / 2
                local offsety = imageheight / 2

                -- draw the tile
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(img, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)

                -- draw the mud
                local mudalpha = cf.round((e.isTile.mudLevel / 255),3)
                love.graphics.setColor(1,1,1,mudalpha)
                love.graphics.draw(IMAGES[enum.imagesMud], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)

                -- draw the random decoration - if there is one
                -- if MAP[row][col].decoration ~= nil then
                if e.isTile.decorationType ~= nil then
                    local imagenum = e.isTile.decorationType
                    local sprite = SPRITES[enum.spriteRandomTree]
                    local quad = QUADS[enum.spriteRandomTree][imagenum]
                    local imagewidth, imageheight = 50,50       -- Note: needs to line up with the size in LOADIMAGES()
                    local drawscalex = (TILE_SIZE / imagewidth)
                    local drawscaley = (TILE_SIZE / imageheight)

                    local offsetx = imagewidth / 2
                    local offsety = imageheight / 2

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.draw(sprite, quad, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                end

                -- draw contour lines

                -- check if top neighbour is different to current cell
                if row > 1 then
                    if MAP[row-1][col].height ~= MAP[row][col].height then
                        -- draw line
                        local x1, y1 = fun.getXYfromRowCol(row, col)
                        local x2, y2 = x1 + TILE_SIZE, y1
                        local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
                        x1 = x1 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y1 = y1 - (TILE_SIZE / 2) + TOP_MARGIN
                        x2 = x2 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y2 = y2 - (TILE_SIZE / 2) + TOP_MARGIN
                        -- love.graphics.setColor(1,1,1,alpha)
                        -- love.graphics.line(x1, y1, x2, y2)
                    end
                end
                -- left side
                if col > 1 then
                    if MAP[row][col-1].height ~= MAP[row][col].height then
                        -- draw line
                        local x1, y1 = fun.getXYfromRowCol(row, col)
                        local x2 = x1
                        local y2 = y1 + TILE_SIZE
                        local alpha = MAP[row][col].height / UPPER_TERRAIN_HEIGHT
                        x1 = x1 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y1 = y1 - (TILE_SIZE / 2) + TOP_MARGIN
                        x2 = x2 - (TILE_SIZE / 2) + LEFT_MARGIN
                        y2 = y2 - (TILE_SIZE / 2) + TOP_MARGIN
                        -- love.graphics.setColor(1,1,1,alpha)
                        -- love.graphics.line(x1, y1, x2, y2)
                    end
                end

                local imptype
                if MAP[row][col].entity.isTile.improvementType ~= nil then imptype = e.isTile.improvementType end

                -- draw the improvement
                local sprite, quad
                if imptype ~= nil then
                    local imagenumber = imptype
                    local imagewidth, imageheight

                    if imptype == enum.improvementFarm then
                        -- determine which image from spritesheet
                        imagenum = cf.round(e.isTile.stockLevel * 4) + 1
                        if imagenum > 5 then imagenum = 5 end
                        sprite = SPRITES[enum.spriteAppleTree]
                        quad = QUADS[enum.spriteAppleTree][imagenum]
                        imagewidth, imageheight = 37,50     --! need to not hardcode this
                    end
                    if imptype == enum.improvementWoodsman then
                        -- determine which image from spritesheet
                        imagenum = math.floor(e.isTile.stockLevel) + 1
                        if imagenum > 6 then imagenum = 6 end
                        sprite = SPRITES[enum.spriteWoodPile]
                        quad = QUADS[enum.spriteWoodPile][imagenum]
                        imagewidth, imageheight = 50,50     --! need to not hardcode this
                    end
                    if imptype == enum.improvementHouse then
                        local househealth = MAP[row][col].entity.isTile.tileOwner.residence.health
                        imagenum = math.floor(househealth / 25) + 1
                        if imagenum > 5 then imagenum = 5 end
                        sprite = SPRITES[enum.spriteHouse]
                        quad = QUADS[enum.spriteHouse][imagenum]
                        imagewidth, imageheight = 50,104     --! need to not hardcode this
                    end

                    if imagewidth == nil then
                        imagewidth = IMAGES[imagenumber]:getWidth()
                        imageheight = IMAGES[imagenumber]:getHeight()
                    end

                    local drawscalex = (TILE_SIZE / imagewidth)
                    local drawscaley = (TILE_SIZE / imageheight)

                    local offsetx = imagewidth / 2
                    local offsety = imageheight / 2

                    love.graphics.setColor(1,1,1,1)

                    if imptype == enum.improvementFarm or imptype == enum.improvementWoodsman or imptype == enum.improvementHouse then
                        love.graphics.draw(sprite, quad, drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                    else
                        love.graphics.draw(IMAGES[imagenumber], drawx, drawy, 0, drawscalex, drawscaley, offsetx, offsety)
                    end

                    -- health bar
                    if imptype == enum.improvementHouse then
                        -- draw health bar after the house so that it sits on top of the house
                        -- draw the health of the improvement as a bar

                        -- draw maxhealth first
                        local maxhealth = MAP[row][col].entity.isTile.tileOwner.residence.unbuiltMaxHealth
                        local barheight = TILE_SIZE * (maxhealth / 100)       -- can exceed 100!
                        local drawx2 = drawx + (TILE_SIZE / 2)      -- The '5' avoids blocking by the house
                        local drawy2 = drawy + (TILE_SIZE / 2)
                        local drawy3 = drawy2 - barheight
                        love.graphics.setColor(1,0,0,1)
                        love.graphics.line(drawx2, drawy2, drawx2, drawy3)

                        -- real house health
                        local househealth = MAP[row][col].entity.isTile.tileOwner.residence.health
                        local barheight = TILE_SIZE * (househealth / 100)       -- house health can exceed 100!
                        local drawx2 = drawx + (TILE_SIZE / 2)      -- The '5' avoids blocking by the house
                        local drawy2 = drawy + (TILE_SIZE / 2)
                        local drawy3 = drawy2 - barheight
                        love.graphics.setColor(0,1,0,1)
                        love.graphics.line(drawx2, drawy2, drawx2, drawy3)
                    end
                end

                -- draw stocklevels for each tile
                if MAP[row][col].entity.isTile.stockLevel > 0 then
                    love.graphics.setColor(0/255,0/255,115/255,1)
                    love.graphics.print(cf.round(MAP[row][col].entity.isTile.stockLevel,1), drawx, drawy, 0, 1, 1, 20, -10)
                end

                -- debugging
                -- draw mud levels for each tile
                -- if MAP[row][col].entity.isTile.mudLevel > 0 then
                --     love.graphics.setColor(1,1,1,1)
                --     love.graphics.print(cf.round(MAP[row][col].entity.isTile.mudLevel,4), drawx, drawy, 0, 1, 1, 20, 20)
                -- end
            end

            if e.isPerson then
                if e.isSelected then
                    love.graphics.setColor(0,1,0,1)
                else
                    love.graphics.setColor(1,1,1,1)
                end

                local drawwidth = PERSON_DRAW_WIDTH
                local drawx, drawy = LEFT_MARGIN + e.position.x, TOP_MARGIN + e.position.y

                -- draw occupation icon
                if e:has("occupation") then
                    local imgnumber = e.occupation.value + 30       -- there is an offset to avoid clashes. See enum.lua
                    love.graphics.draw(IMAGES[imgnumber], drawx, drawy, 0, 0.25, 0.25, 0, 130)
                end

                -- draw if sleeping
                local imgrotation = 0
                if e.isPerson.queue[1] ~= nil then
                    if e.isPerson.queue[1].action == "rest" then
                        imgrotation = math.rad(90)
                    end
                end

                -- draw the villager
                local facing = determineFacing(e)      -- gets the cardinal facing of the entity. Is a string
                local imagenum = getImageNumberFromFacing(facing)
                local imagenumoffset = cf.round(e.position.movementDelta / 0.5)
                imagenum = imagenum + imagenumoffset

                local sprite, quad
                if e.isPerson.gender == enum.genderMale and e:has("occupation") then
                    if e.occupation.value == enum.jobFarmer then
                        sprite = SPRITES[enum.spriteFarmerMan]
                        quad = QUADS[enum.spriteFarmerMan][imagenum]
                    else
                        sprite = SPRITES[enum.spriteBlueMan]
                        quad = QUADS[enum.spriteBlueMan][imagenum]
                    end
                end
                if e.isPerson.gender == enum.genderFemale and e:has("occupation") then
                    sprite = SPRITES[enum.spriteBlueWoman]
                    quad = QUADS[enum.spriteBlueWoman][imagenum]
                end
                if e.isPerson.gender == enum.genderMale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedMan]
                    quad = QUADS[enum.spriteRedMan][imagenum]
                end
                if e.isPerson.gender == enum.genderFemale and not e:has("occupation") then
                    sprite = SPRITES[enum.spriteRedWoman]
                    quad = QUADS[enum.spriteRedWoman][imagenum]
                end
                love.graphics.draw(sprite, quad, drawx, drawy, imgrotation, 1, 1, 10, 25)

                -- display the log
                local maxindex = #e.isPerson.log
                if e:has("isSelected") and VILLAGERS_SELECTED == 1 then
                    img = IMAGES[enum.imagesVillagerLog]
                    local imageheight = img:getHeight()
                    local drawboxy = SCREEN_HEIGHT - imageheight - 100

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.draw(img, 50, drawboxy, 0, 1.5, 1)
                    local texty = drawboxy + 7


                    for i = maxindex, maxindex - 4, -1 do
                        if i < 1 then break end
                        love.graphics.setColor(47/255,11/255,50/255,1)
                        love.graphics.print(e.isPerson.log[i].text, 57, texty)
                        texty = texty + 12
                    end
                end

                -- draw villager debug information
                local txt = ""
                if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
                    -- display some debugging information
                    if e.isPerson.queue[1] ~= nil then
                        txt = "action: " .. e.isPerson.queue[1].action .. "\n"
                        if e.isPerson.queue[1].timeleft ~= nil then
                            txt = txt .. "timer: " .. cf.round(e.isPerson.queue[1].timeleft) .. "\n"
                        end
                    end
                    txt = txt .. "health: " .. cf.round(e.isPerson.health) .. "\n"
                    txt = txt .. "stamina: " .. cf.round(e.isPerson.stamina) .. "\n"
                    txt = txt .. "fullness: " .. cf.round(e.isPerson.fullness) .. "\n"
                    txt = txt .. "wealth: " .. cf.round(e.isPerson.wealth,1) .. "\n"
                    txt = txt .. "wood: " .. cf.round(e.isPerson.stockInv[enum.stockWood]) .. "\n"
                    txt = txt .. "tax owed: " .. cf.round(e.isPerson.taxesOwed, 1) .. "\n"

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 60)

                    -- stock belief
                    txt = cf.round(e.isPerson.stockBelief[enum.stockFruit][2], 1) .. "\n"
                    txt = txt .. cf.round(e.isPerson.stockBelief[enum.stockFruit][1], 1) .. "\n"
                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, 30, 30)     -- positive x = move left
                elseif love.keyboard.isDown("ralt") then
                    txt = "Worked: " .. cf.round(e.isPerson.timeWorking) .. "\n"
                    txt = txt .. "Rested: " .. cf.round(e.isPerson.timeResting) .. "\n"

                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 60)
                else
                    if e.isPerson.health < 25 then
                        txt = txt .. "health: " .. cf.round(e.isPerson.health) .. "\n"
                    end
                    -- if e.isPerson.stamina < 25 then
                    --     txt = txt .. "stamina: " .. cf.round(e.isPerson.stamina) .. "\n"
                    -- end
                    if e.isPerson.fullness < 25 then
                        txt = txt .. "fullness: " .. cf.round(e.isPerson.fullness) .. "\n"
                    end
                    if e.isPerson.wealth < 1 then
                        txt = txt .. "wealth: " .. cf.round(e.isPerson.wealth,1) .. "\n"
                    end
                    love.graphics.setColor(1,1,1,1)
                    love.graphics.print(txt, drawx, drawy, 0, 1, 1, -15, 25)
                end
            end

            if e.isMonster then
                local drawwidth = PERSON_DRAW_WIDTH
                local drawx, drawy = LEFT_MARGIN + e.position.x, TOP_MARGIN + e.position.y

                local sprite, quad
                sprite = SPRITES[enum.spriteMonster1]
                quad = QUADS[enum.spriteMonster1][5]
                love.graphics.draw(sprite, quad, drawx, drawy, 0, 1, 1, 25, 20)
            end
        end
    end
end
return ecsDraw
