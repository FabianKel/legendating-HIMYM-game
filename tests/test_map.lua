local TileMap = require("src.map.TileMap")
local mapData = require("src.data.mclarens_map")

return function(test)
    local map = TileMap.new(mapData)

    test("map rows parse with a constant width", function()
        assert(map.width == 48 and map.height == 25)
    end)

    test("map has a start, the 4 POIs and 7 girl spots", function()
        assert(map:findMarker("P"), "missing player start")
        for char in pairs(mapData.pois) do
            assert(map:findMarker(char), "missing POI " .. char)
        end
        for i = 1, 7 do
            assert(map:findMarker(tostring(i)), "missing girl spot " .. i)
        end
    end)

    test("every marker is reachable from the start (BFS)", function()
        local start = map:findMarker("P")
        local reachable = map:reachableFrom(start.tx, start.ty)
        for _, marker in ipairs(map.markers) do
            assert(reachable(marker.tx, marker.ty),
                ("marker %s at %d,%d is walled in"):format(marker.char, marker.tx, marker.ty))
        end
    end)

    test("collision: walls block, floor does not", function()
        assert(map:rectHitsSolid(0, 0, 10, 10), "top-left wall should block")
        local start = map:findMarker("P")
        assert(not map:rectHitsSolid(start.x - 4, start.y - 4, 8, 8), "start should be free")
        assert(map:rectHitsSolid(-50, 100, 10, 10), "outside the map counts as solid")
    end)
end
