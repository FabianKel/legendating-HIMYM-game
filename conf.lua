local Screen = require("src.Screen") -- the game's resolution, one source

function love.conf(t)
    -- nombra el directorio de guardado del juego (love.filesystem
    -- escribe ahi y solo ahi) -- sin esto, LOVE usaria el nombre de la
    -- carpeta, y renombrar el proyecto huerfanaria cualquier save
    t.identity = "legendating-himym"
    t.window.title = "Legend... wait for it... Dating!"
    t.window.width = Screen.w
    t.window.height = Screen.h
    t.version = "11.5"
end
