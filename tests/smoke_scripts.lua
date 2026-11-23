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

return scripts
