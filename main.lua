math.randomseed(os.time())

function love.load()
    love.physics.setMeter(64)

    class = require("middleclass")
    require("json")
    require("constants")
    require("utils")
    require("event")
    require("entity")
    require("circle-entity")
    require("static-debris")
    require("trigger")
    require("bullet-impact")
    require("bullet")
    require("shield")
    require("base-ai")
    require("pont")
    require("bute")
    require("entity-spawner")
    require("map")
    require("ship")

    --== Interface ==--

        fonts = {}
        fonts.droidsans = {}
        fonts.droidsans[14] = love.graphics.newFont("fonts/DroidSans.ttf", 14)
        fonts.droidsans[16] = love.graphics.newFont("fonts/DroidSans.ttf", 16)
        fonts.droidsansbold = {}
        fonts.droidsansbold[14] = love.graphics.newFont("fonts/DroidSans-Bold.ttf", 14)
        fonts.droidsansbold[24] = love.graphics.newFont("fonts/DroidSans-Bold.ttf", 24)
        fonts.droidsansbold[48] = love.graphics.newFont("fonts/DroidSans-Bold.ttf", 48)

    -------------------

    --== Game ==--

        game = {}
        game.time = 0
        game.over = false
        game.world = love.physics.newWorld(0, 0, true)
        game.mousepressed = {}
        game.mousereleased = {}
        game.afterWorldUpdate = {}
        setmetatable(game.afterWorldUpdate, {
            __call = function (self, func)
                table.insert(game.afterWorldUpdate, func)
            end
        })

        game.points = 0

        game.camerax = 0
        game.cameray = 0
        game.zoom = 1
        game.zoomtarget = 1

        --== Objects ==--

            game.objects = {}
            game.nextObjectId = 1

            game.addObject = function (obj)

                local id = game.nextObjectId
                game.nextObjectId = game.nextObjectId + 1
                game.objects[id] = obj
                return id

            end

        -----------------

        --== Particles ==--

            game.particles = {}
            game.nextParticleId = 1

            game.addParticle = function (part)

                local id = game.nextParticleId
                game.nextParticleId = game.nextParticleId + 1
                game.particles[id] = part
                return id

            end

        -------------------

        --== Background ==--

            game.background = {}

            for i = 1, 5000 do

                table.insert(game.background,
                {
                    parallax = math.random(1, 300) / 10000,
                    x = math.random(-3000, 3000),
                    y = math.random(-2000, 2000),
                    r = math.random(200, 255),
                    g = math.random(200, 255),
                    b = math.random(200, 255)
                })

            end

        --------------------

        game.map = Map:new()
        game.map:loadMap(arg[2] or "menu")

        game.ship = Ship:new(0, 0)

        game.world:setCallbacks(function (fix1, fix2, contact) -- beginContact

            local ent1, ent2 = game.objects[(fix1:getUserData())], game.objects[(fix2:getUserData())]

            if not ent1 or not ent2 then return end -- this never happened ok?

            if ent1.impact and not fix2:isSensor() then ent1:impact(ent2, contact) end
            if ent2.impact and not fix1:isSensor() then ent2:impact(ent1, contact) end

        end, function (fix1, fix2, contact) -- endContact

            local ent1, ent2 = game.objects[(fix1:getUserData())], game.objects[(fix2:getUserData())]

            if not ent1 or not ent2 then return end -- this never happened ok?

            if ent1.impactEnd and not fix2:isSensor() then ent1:impactEnd(ent2, contact) end
            if ent2.impactEnd and not fix1:isSensor() then ent2:impactEnd(ent1, contact) end

        end --[[ preSolve ]] --[[ postSolve ]] )

    --------------

    --== Sounds ==--

        local soundsToLoad = { {"player_shoot", "ogg", "static"}, {"enemy_hit", "ogg", "static"}, {"bullet_hit", "ogg", "static"}, {"player_hit", "ogg", "static"} }
        sounds = {}

        for k,v in pairs(soundsToLoad) do
            sounds[v[1]] = love.audio.newSource("sounds/"..v[1].."."..v[2], v[3])
        end

        function sounds.play(name)

            sounds[name]:rewind()
            sounds[name]:play()

        end

    ----------------

    love.graphics.setLineWidth(1.1)

end


function love.update(dt)

    if love.mouse.isDown("r") then dt = dt * 1.5 end


    if game.over then return end

    game.time = game.time + dt

    game.zoom = game.zoom + (game.zoomtarget - game.zoom) / 10
    game.camerax = game.camerax + ((0 - game.ship.body:getX()) * game.zoom - game.camerax) * dt * 10
    game.cameray = game.cameray + ((0 - game.ship.body:getY()) * game.zoom - game.cameray) * dt * 10
    game.mousex, game.mousey = utils.screenToWorld(love.mouse.getX(), love.mouse.getY())

    game.world:update(dt)
    for i,v in ipairs(game.afterWorldUpdate) do
        v()
    end
    for k,v in pairs(game.afterWorldUpdate) do game.afterWorldUpdate[k] = nil end

    game.map:update(dt)

    for k,v in pairs(game.particles) do
        v:update(dt)
    end

    for k,v in pairs(game.objects) do
        v:update(dt)
    end

end


function love.draw()

    if game.over then

        love.graphics.setColor(210, 220, 250)

        love.graphics.setFont(fonts.droidsansbold[48])
        love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")

        love.graphics.setFont(fonts.droidsansbold[24])
        love.graphics.printf("You are dead", 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")

        love.graphics.printf("Score: " .. game.points, 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")

        return

    end

    love.graphics.setFont(fonts.droidsans[16])

    for k,v in pairs(game.background) do

        local x = game.camerax * v.parallax - v.x
        local y = game.cameray * v.parallax - v.y
        if x > 0 and y > 0 and x < love.window:getWidth() and y < love.window:getHeight() then

            love.graphics.setColor(v.r, v.g, v.b, v.parallax * 8000)
            love.graphics.point(x, y)

        end

    end


    love.graphics.push()
    love.graphics.translate(math.floor(game.camerax + love.window:getWidth() / 2) + .5, math.floor(game.cameray + love.window:getHeight()/2) + .5)
    love.graphics.scale(game.zoom)

        for k,v in pairs(game.particles) do
            love.graphics.setLineWidth(1)
            love.graphics.setColor(255, 255, 255)
            v:draw()
        end

        for k,v in pairs(game.objects) do
            love.graphics.setLineWidth(1)
            love.graphics.setColor(255, 255, 255)
            v:draw()
        end

        game.map:draw()

    love.graphics.pop()


    love.graphics.setColor(200, 230, 255, 200)
    love.graphics.print("Score: " .. game.points, 10, love.window.getHeight() - 25)


    --=# Cleanup #=--

    for k,v in pairs(game.mousepressed) do
        game.mousepressed[k] = false
    end

    for k,v in pairs(game.mousereleased) do
        game.mousereleased[k] = false
    end


    love.graphics.print(love.timer.getFPS(), 0, 0)

end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
        return
    end
end


function love.mousepressed(x, y, but)
    game.mousepressed[but] = true

    -- Zoom is broken; don't use it
    -- if but == "wu" then
    --     game.zoomtarget = game.zoomtarget * 1.05
    -- elseif but == "wd" then
    --     game.zoomtarget = game.zoomtarget * 0.95
    -- end
end


function love.mousereleased(x, y, but)
    game.mousereleased[but] = true
end
