-- Mueve a quien tenga intent + position + body, basado en dt, con
-- colisiones contra el tilemap y contra entidades `blocker` (las
-- chicas sentadas).
--
-- Resolucion por EJES separados: primero X, luego Y. Si el paso en X
-- choca se descarta solo ese eje, asi Barney "resbala" a lo largo de
-- una pared en diagonal en vez de quedarse pegado. La diagonal se
-- normaliza para no ir mas rapido que en linea recta.

local PlayerMovementSystem = { name = "playerMovement" }

local function overlaps(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end

-- el cuerpo es un rectangulo en los PIES (position = centro de los pies)
local function bodyRect(x, y, body)
    return x - body.w / 2, y - body.h, body.w, body.h
end

local function blocked(registry, map, x, y, body)
    local rx, ry, rw, rh = bodyRect(x, y, body)
    if map:rectHitsSolid(rx, ry, rw, rh) then return true end
    for _, pos, blocker in registry:each("position", "blocker") do
        if overlaps(rx, ry, rw, rh,
            pos.x - blocker.w / 2, pos.y - blocker.h, blocker.w, blocker.h) then
            return true
        end
    end
    return false
end

PlayerMovementSystem.blocked = blocked

function PlayerMovementSystem.update(scene, dt)
    local registry = scene.registry
    local map = registry:resource("tilemap")

    for _, pos, intent, body, mover in registry:each("position", "intent", "body", "mover") do
        local dx, dy = intent.dx, intent.dy
        local length = math.sqrt(dx * dx + dy * dy)
        mover.moving = length > 0
        if length > 0 then
            dx, dy = dx / length, dy / length
            if dx ~= 0 then mover.facing = dx > 0 and 1 or -1 end

            local nx = pos.x + dx * mover.speed * dt
            if not blocked(registry, map, nx, pos.y, body) then pos.x = nx end
            local ny = pos.y + dy * mover.speed * dt
            if not blocked(registry, map, pos.x, ny, body) then pos.y = ny end
        end
    end
end

return PlayerMovementSystem
