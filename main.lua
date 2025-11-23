function love.load()
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

    function player:reset()
        self.x = 64
        self.y = -64
        self.vx = 0
        self.vy = 0
        self.collider:setX(self.x)
        self.collider:setY(self.y)
        self.collider:setLinearVelocity(self.vx, self.vy)
    end

    function player:isGrounded()
        self.query = world:queryLine(self.x, self.y, self.x, self.y + math.ceil(32 * math.sqrt(2)))
        return #self.query > 0
    end

    walls = {}

    map = {
        [1] = sti("polygon.lua"),
        [2] = sti("ploygon2.lua")
    }

    draw_map = {true, true}
    map_offset_x = 0
    for i, platform in ipairs(map) do
        if draw_map[i] then
            if platform.layers["objects"] then
                for _, obj in pairs(platform.layers["objects"].objects) do
                    local coords = {}
                    for _, xy in ipairs(obj.polygon) do
                        table.insert(coords, xy.x + map_offset_x)
                        table.insert(coords, xy.y)
                    end

                    local col = world:newPolygonCollider(coords)
                    col:setType("static")
                    table.insert(walls, col)
                end
            else
                print(string.format("Map no.%d does not have any objects ! Skipping"), i)
            end
            map_offset_x = map_offset_x + 32*30
        end
    end
end

function love.keypressed(key)
    local vx, vy = player.collider:getLinearVelocity()
    if (key == "up" or key == "w" ) and player:isGrounded() then
        player.collider:applyLinearImpulse(0, -1200)
    end

    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    pre_x, pre_y = player.x, player.y
    if player.y > 2000 then
        player:reset()
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

end

function love.draw()
    cam:attach()
    world:draw()
    cam:detach()
end