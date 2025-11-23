function love.load()
    math.randomseed(os.time())

    screenW = love.graphics.getWidth()
    screenH = love.graphics.getHeight()

    wf = require 'windfield'
    camera = require 'camera'
    sti = require 'sti'

    cam = camera()

    player = {
        x = 64,
        y = -64,
        vx = 0,
        vy = 0
    }

    world = wf.newWorld(0, 1000)

    player.collider = world:newRectangleCollider(player.x, player.y, 30, 30)
    player.collider:setPosition(100, 100)
    player.collider:setFixedRotation(false)
    player.collider:setRestitution(0)

    player.collider:setPosition(player.x, player.y)

    function player:reset(current_map)
        self.x = 64
        self.y = -64
        self.vx = 0
        self.vy = 0
        self.collider:setX(self.x)
        self.collider:setY(self.y)
        self.collider:setLinearVelocity(self.vx, self.vy)
        draw_map[current_map] = false
        walls[current_map] = nil
    end

    function player:isGrounded()
        self.query = world:queryLine(self.x, self.y, self.x, self.y + 5 + math.ceil(32 * math.sqrt(2)))
        return #self.query > 0
    end

    walls = {}

    maps = {
        [1] = sti("polygon.lua"),
        [2] = sti("ploygon2.lua")
    }

    map = {}
    draw_map = {}


    temp_walls = {}

    util = require 'draw_platform'
end

function love.update(dt)

    current_map = math.ceil((player.x)/ 960)
    previous_map = current_map - 1
    previous_right_boundary = 960 * (previous_map)

    if not map[current_map] or not draw_map[current_map] then
        map[current_map] = maps[math.random(1, 2)]
        draw_map[current_map] = true
        util.draw_platform(map, draw_map, walls)
    end

    pre_x = player.x
    if player.y > 2000 then
        player:reset(current_map)
    end

    if love.keyboard.isDown("left", "a") then
        player.collider:applyLinearImpulse(-300, 0)
    end

    if love.keyboard.isDown("right", "d") then
        player.collider:applyLinearImpulse(300, 0)
    end

    world:update(dt)

    local vx, vy = player.collider:getLinearVelocity()
    if vx > 200 then
        vx = 200
    end
    if vx < -200 then
        vx = -200
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

    if pre_x ~= player.x then
        print(string.format([[
        X: %.2f
        Current map: %d
        Map existence: %s
        Has been drawn:  %s
        ]],
        player.x,
        current_map,
        tostring(map[current_map] ~= nil),
        tostring(draw_map[current_map])))
    end

end

function love.keypressed(key)
    if (key == "up" or key == "w" ) and player:isGrounded() then
        player.collider:applyLinearImpulse(0, -1200)
    end

    if key == "escape" then
        love.event.quit()
    end
    if key == "x" then
        print(walls[1], walls[2])
    end
end

function love.draw()
    cam:attach()
    world:draw()
    cam:detach()
end