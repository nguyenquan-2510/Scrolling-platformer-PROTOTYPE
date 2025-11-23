local m = {}

function m.draw_platform(map_list, bool_draw_list, collider_storage, offset_x)
    local off_x = offset_x or 0
    for i, platform in pairs(map_list) do
        if collider_storage[i] == nil then
            collider_storage[i] = {}
        end
        
        if bool_draw_list[i] then
            if platform.layers["objects"] then
                for _, obj in pairs(platform.layers["objects"].objects) do
                    local coords = {}
                    for _, vertex in ipairs(obj.polygon) do
                        table.insert(coords, vertex.x + off_x)
                        table.insert(coords, vertex.y)
                    end

                    local col = world:newPolygonCollider(coords)
                    col:setType("static")
                    table.insert(collider_storage[i], col)
                end
            else
                print(string.format("Map no.%d does not have any objects ! Skipping"), i)
            end
            off_x = off_x + 32*30
        end
    end
end

return m