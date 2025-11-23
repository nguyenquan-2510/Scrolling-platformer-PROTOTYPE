function love.load()
    screenW = love.graphics.getWidth()
    screenH = love.graphics.getHeight()

    wf = require 'windfield'
    camera = require 'camera'
    sti = require 'sti'

    cam = camera()

    player = {
        x = 100,
        y = 100
    }

    world = wf.newWorld(0, 1000)

    player.collider = world:newRectangleCollider(player.x, player.y, 32, 32)
    player.collider:setPosition(100, 100)
    player.collider:setFixedRotation(false)
    player.collider:setRestitution(0)

    walls = {}

    ---[[
    polygon = sti("polygon.lua")

    if polygon.layers["objects"] then
        for i, obj in pairs(polygon.layers["objects"].objects) do
            local coords = {}
            for _, xy in ipairs(obj.polygon) do
                table.insert(coords, xy.x)
                table.insert(coords, xy.y)
            end
            local col = world:newPolygonCollider(coords)
            col:setType("static")

            table.insert(walls, col)
        end
    end

    -- Polygon demo
    --[[
    ground = world:newPolygonCollider({0+0, 0+384, 960+0, 0+384, 960+0, 96+384, 0+0, 96+384})
    ground:setType("static")

    slope = world:newPolygonCollider({480, 384, 480+64, 384-64, 64+480, 384})
    slope:setType("static")
    --]]



end

function love.keypressed(key)
    local vx, vy = player.collider:getLinearVelocity()
    if (key == "up" or key == "w" ) and math.abs(vy) < 1 then
        player.collider:applyLinearImpulse(0, -1200)
    end

    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    pre_x, pre_y = player.x, player.y
    if player.y > 2000 then player.y = 100
    player.x = 100
    player.vx = 0
    player.vy = 0
    player.collider:setX(player.x)
    player.collider:setY(player.y)
    player.collider:setLinearVelocity(player.vx, player.vy)
    end

    if love.keyboard.isDown("left", "a") then
        player.collider:applyLinearImpulse(-300, 0)
    end

    if love.keyboard.isDown("right", "d") then
        player.collider:applyLinearImpulse(300, 0)
    end

    world:update(dt)

    local vx, vy = player.collider:getLinearVelocity()
    if vx > 300 then
        vx = 300
    end
    if vx < -300 then
        vx = -300
    end
    if vy > 600 then
        vy = 600
    end
    if vy < -600 then
        vy = -600
    end
    player.collider:setLinearVelocity(vx, vy)

    player.x = player.collider:getX()
    player.y = player.collider:getY()
    cam:lookAt(player.x, player.y)


    if pre_x ~= player.x or pre_y ~= player.y then
        -- print(string.format([[
        -- ----------------------------------------------------
        -- Player X: %.2f | Player Y: %.2f
        -- Player vX: %.2f | Player vY: %.2f
        -- ----------------------------------------------------
        -- ]], player.x, player.y, vx, vy))
    end
end

function love.draw()
    cam:attach()
    world:draw()
    cam:detach()

    -- love.graphics.rectangle("fill", screenW/2, screenH/2, 32, 32)

end