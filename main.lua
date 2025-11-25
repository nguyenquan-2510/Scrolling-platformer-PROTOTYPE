MAP_WIDTH = 960
map_templates = {"polygon.lua", "ploygon2.lua"}
-- remember which template was used per logical map index so we can
-- regenerate the same map when the player returns
map_template_for_idx = {}

function remove_map(idx)
    if not idx then return end
    if walls and walls[idx] then
        for _, col in ipairs(walls[idx]) do
            if col and col.destroy then
                col:destroy()
            end
        end
        walls[idx] = nil
    end
    if draw_map and draw_map[idx] then draw_map[idx] = nil end
    if map and map[idx] then map[idx] = nil end
    -- NOTE: we intentionally do NOT clear map_template_for_idx[idx]
    -- so when the player returns the same template will be reloaded.
end

function spawn_map(idx)
    if not idx then return end
    if map and map[idx] then return end
    local tpl = map_template_for_idx[idx]
    if not tpl then
        tpl = map_templates[math.random(1, #map_templates)]
        map_template_for_idx[idx] = tpl
    end
    map[idx] = sti(tpl)
    draw_map[idx] = true
    -- draw only this map with the correct offset
    util.draw_platform({[idx]=map[idx]}, {[idx]=true}, walls, (idx - 1) * MAP_WIDTH)
end

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
        -- remove the current map so it will regenerate fresh
        remove_map(current_map)
    end

    function player:isGrounded()
        self.query = world:queryLine(self.x, self.y, self.x, self.y + 5 + math.ceil(32 * math.sqrt(2)))
        return #self.query > 0
    end

    walls = {}
    map = {}
    draw_map = {}

    temp_walls = {}

    util = require 'draw_platform'

    -- spawn initial nearby maps (1 and 2)
    spawn_map(1)
    spawn_map(2)
end

function love.update(dt)

    current_map = math.ceil((player.x) / MAP_WIDTH)

    -- ensure current and neighbouring maps exist
    spawn_map(current_map - 1)
    spawn_map(current_map)
    spawn_map(current_map + 1)

    -- remove maps that are too far away (keep a window of prev,current,next)
    for k, _ in pairs(map) do
        if k < (current_map - 1) or k > (current_map + 1) then
            remove_map(k)
        end
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