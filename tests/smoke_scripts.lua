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
    { key = "return", wait = 0.3 }, { key = "return", wait = 1.2 }, { shot = "07-battle-result" },
    { key = "return", wait = 0.6 },
    { run = function(Game)
        local name = Game.current().name
        assert(name == "map" or name == "result", "unexpected scene " .. name)
    end },
    { wait = 0.5 }, { shot = "08-after-battle" },
}

-- juego completo ----------------------------------------------------

local function resource(Game, name)
    return Game.current().registry:resource(name)
end

-- un dia rapido: se adelanta el reloj a las 19:00 y se toma una siesta
local function quickDay()
    return {
        { expect = "day" },
        { run = function(Game) resource(Game, "runState").hour = 19 end },
        { key = "up", wait = 0.1 }, -- el cursor da la vuelta: Power Nap (ultima)
        { key = "return", wait = 3.4 }, { expect = "playbook" },
        { key = "return", wait = 0.5 }, { key = "return", wait = 0.3 },
        { key = "return", wait = 1.2 }, { expect = "bar" },
    }
end

-- una noche ganada a la fuerza: Interest a 99 antes de la primera carta
local function forcedWin(night, shots)
    local steps = {}
    local function add(list) for _, s in ipairs(list) do steps[#steps + 1] = s end end
    add(quickDay())
    add({
        { key = "return", wait = 1.3 }, { expect = "map" },
        teleportTo("girl", 14), { wait = 0.2 }, { key = "e", wait = 0.4 }, { expect = "battle" },
        { key = "return" }, { key = "return", wait = 0.2 },
        { run = function(Game) resource(Game, "battle").interest = 99 end },
        { key = "return", wait = 1.2 },
        { run = function(Game)
            assert(resource(Game, "battle").outcome == "success", "forced win did not succeed")
        end },
        { key = "return", wait = 0.4 }, { expect = "result" },
        { run = function(Game) -- 7 mujeres DIFERENTES
            local seen = {}
            for _, c in ipairs(resource(Game, "runState").conquests) do
                assert(not seen[c.name], "conquered " .. c.name .. " twice")
                seen[c.name] = true
            end
        end },
    })
    if shots then add({ { wait = 0.8 }, { shot = ("night%d-result"):format(night) } }) end
    add({ { wait = 0.8 }, { key = "return", wait = 0.4 } })
    return steps
end

scripts.gameplay = (function()
    local steps = {
        { wait = 0.3 }, { key = "return", wait = 0.5 },
    }
    local function add(list) for _, s in ipairs(list) do steps[#steps + 1] = s end end
    -- noche 1 jugada "a mano" con capturas de cada fase
    add({ { expect = "day" }, { wait = 0.6 }, { shot = "01-day" } })
    add(quickDay())
    add({
        { wait = 0.3 }, { shot = "02-bar" },
        { key = "return", wait = 1.3 }, { expect = "map" }, { wait = 0.5 }, { shot = "03-map" },
        teleportTo("carl"), { key = "e", wait = 0.6 }, { shot = "04-carl" },
        teleportTo("gang"), { key = "e", wait = 0.4 },
        teleportTo("mirror"), { key = "e", wait = 0.4 },
        { run = function(Game)
            local night = resource(Game, "runState").nightState
            assert(night.drinks == 1 and night.gangTalked and night.mirrorBonus == 10)
            assert(night.hour > 21.5, "actions should cost time")
        end },
        teleportTo("girl", 14), { wait = 0.3 }, { key = "e", wait = 0.6 }, { expect = "battle" },
        { wait = 0.5 }, { shot = "05-scouting" },
        { key = "return", wait = 0.4 }, { shot = "06-approach" },
        { key = "return", wait = 0.6 }, { shot = "07-interaction" },
        { key = "return", wait = 0.3 }, { key = "return", wait = 0.3 },
        { run = function(Game)
            local battle = resource(Game, "battle")
            assert(battle.phase == "interaction" or battle.phase == "result", battle.phase)
        end },
        { key = "return", wait = 0.6 }, { shot = "08-asking" },
        { key = "return", wait = 1.2 }, { shot = "09-result" },
        { key = "return", wait = 0.5 },
        { run = function(Game)
            local name = Game.current().name
            assert(name == "map" or name == "result", "unexpected scene " .. name)
        end },
        { wait = 0.5 }, { shot = "10-after" },
    })
    return steps
end)()

-- las 7 noches seguidas (ganadas a la fuerza) hasta LEGEN-DARY
scripts.win = (function()
    local steps = { { wait = 0.3 }, { key = "return", wait = 0.5 } }
    for night = 1, 7 do
        local list = forcedWin(night, night == 1 or night == 7)
        for _, s in ipairs(list) do steps[#steps + 1] = s end
    end
    steps[#steps + 1] = { expect = "menu" }
    steps[#steps + 1] = { run = function()
        assert(not love.filesystem.getInfo("save.lua"), "the save should be cleared after winning")
    end }
    return steps
end)()

-- noche 2 con Factor X y una derrota por reloj
scripts.lose = (function()
    local steps = { { wait = 0.3 }, { key = "return", wait = 0.5 } }
    for _, s in ipairs(forcedWin(1, false)) do steps[#steps + 1] = s end
    for _, s in ipairs(quickDay()) do steps[#steps + 1] = s end
    local rest = {
        { key = "return", wait = 1.3 }, { expect = "map" },
        teleportTo("girl", 14), { key = "e", wait = 0.4 }, { expect = "battle" },
        { key = "return" }, { key = "return", wait = 0.2 },
        { key = "q", wait = 0.6 }, -- pedir el numero ya: noche 2 = Factor X
        { run = function(Game)
            assert(resource(Game, "battle").phase == "factorx", "night 2 should trigger Factor X")
        end },
        { shot = "factorx" },
        { key = "return", wait = 1.2 }, { key = "return", wait = 0.5 },
        { run = function(Game)
            local name = Game.current().name
            if name == "map" then resource(Game, "runState").nightState.hour = 25.99 end
        end },
        { wait = 0.8 }, { expect = "result" }, { wait = 1.0 }, { shot = "walkofshame" },
        { key = "return", wait = 0.5 }, { expect = "menu" },
    }
    for _, s in ipairs(rest) do steps[#steps + 1] = s end
    return steps
end)()

return scripts
