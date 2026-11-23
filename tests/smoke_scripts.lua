-- Guiones para tests/smoke.lua. Cada paso es uno de:
--   { key = "return", times = n, wait = s }  presionar tecla(s)
--   { wait = s }                             esperar
--   { shot = "nombre" }                      screenshot
--   { expect = "scene" }                     afirmar la escena actual
--   { run = function(Game) ... end }         codigo arbitrario (asserts)

local scripts = {}

scripts.progression = {
    { wait = 0.5 }, { shot = "01-menu" },
    { key = "return", wait = 0.5 }, { expect = "day" },
    { wait = 1.0 }, { shot = "02-day" },
    -- Laser Tag (3) x2, Practice Magic (3), Study (5), Nap (7)
    { key = "down", times = 1 }, { key = "return", wait = 0.6 }, { shot = "03-day-feedback" },
    { wait = 1.2 }, { key = "return", wait = 1.8 },
    { key = "down" }, { key = "return", wait = 1.8 },
    { key = "down", times = 2 }, { key = "return", wait = 1.8 },
    { key = "down", times = 2 }, { key = "return", wait = 1.8 },
    { key = "return", wait = 1.8 }, -- otra siesta: 20:00
    { wait = 2.0 }, { expect = "playbook" },
    { wait = 0.5 }, { shot = "04-pack" },
    { key = "return", wait = 1.4 }, { shot = "05-reveal" },
    { wait = 1.5 }, { key = "left", times = 2 }, { wait = 0.8 }, { shot = "06-collection" },
    { run = function(Game)
        local run = Game.current().registry:resource("runState")
        assert(#run.collection == 7, "collection should have 4 + 3 cards, has " .. #run.collection)
        assert(run.packOpened)
    end },
    { key = "return", wait = 1.5 }, { expect = "bar" },
}

-- helpers para los guiones del mapa ---------------------------------
local function goTo(sceneName, runState)
    return { run = function(Game)
        local RunState = require("src.state.RunState")
        Game.current().registry:spawn({
            switchRequest = { to = sceneName, payload = { runState = runState or RunState.new(7) } },
        })
    end }
end

local function playerPos(Game)
    local registry = Game.current().registry
    return registry:get(registry:first("player"), "position")
end

-- pone a Barney junto al POI de ese tipo (dx: corrimiento en x)
local function teleportTo(kind, dx)
    return { run = function(Game)
        local registry = Game.current().registry
        for _, pos, poi in registry:each("position", "poi") do
            if poi.kind == kind then
                local p = playerPos(Game)
                p.x, p.y = pos.x + (dx or 0), pos.y
                return
            end
        end
        error("no POI of kind " .. kind)
    end }
end

scripts.map = {
    { wait = 0.3 }, goTo("bar"), { wait = 0.3 }, { expect = "bar" },
    { key = "return", wait = 1.3 }, { expect = "map" },
    { wait = 0.6 }, { shot = "01-entrance" },
    { hold = "up", wait = 1.2 }, { hold = "right", wait = 2.5 }, { release = true },
    { wait = 0.4 }, { shot = "02-walking" },
    teleportTo("carl"), { wait = 0.5 }, { key = "e", wait = 1.5 }, { shot = "03-carl" },
    teleportTo("gang"), { wait = 0.6 }, { shot = "04-gang" },
    teleportTo("mirror"), { wait = 0.6 }, { shot = "05-mirror" },
    -- colision: pegado a la pared izquierda, caminar a la izquierda no la atraviesa
    { run = function(Game) local p = playerPos(Game); p.x, p.y = 24, 150 end },
    { hold = "left", wait = 0.8 }, { release = true },
    { run = function(Game)
        local p = playerPos(Game)
        assert(p.x >= 21, "walked into the wall: x=" .. p.x)
    end },
    teleportTo("girl", 14), { wait = 0.6 }, { shot = "06-girl" },
    { key = "e", wait = 0.6 }, { expect = "battle" },
    { key = "return" }, { key = "return" }, { key = "return" }, { key = "return" },
    { key = "return", wait = 0.3 }, { key = "return", wait = 0.3 }, { shot = "07-battle-result" },
    { key = "return", wait = 0.6 },
    { run = function(Game)
        local name = Game.current().name
        assert(name == "map" or name == "day" or name == "menu", "unexpected scene " .. name)
    end },
    { wait = 0.5 }, { shot = "08-after-battle" },
}

return scripts
