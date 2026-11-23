-- Sinergias de las cartas de conversacion con la chica (fase de
-- Interaccion). Una funcion por TIPO de carta: recibe la chica y el
-- jugador y devuelve puntos extra de Interest y la razon que se le
-- muestra al jugador (transparencia: siempre sabe POR QUE funciono).
--
-- Resumen (tambien aparece en el Play Book como "Works best"):
--   charm  : +10 triste       / -15 si es muy inteligente (>= 8)
--   story  : +10 aburrida     / +5 si es inteligente (>= 6)
--   trick  : +10 feliz        / +5 si es rara (>= 6)
--   nerd   : +10 muy rara (>= 7) / +5 muy inteligente / -10 si es muy normal (<= 3)
--   classy : +5 bella (>= 8)  / +5 si vas formal (awesomeness >= 0.3) / -5 muy rara (>= 8)

local function add(total, reasons, points, reason)
    if points ~= 0 then
        reasons[#reasons + 1] = reason
    end
    return total + points
end

return {
    charm = function(girl, player)
        local total, reasons = 0, {}
        if girl.mood == "Sad" then total = add(total, reasons, 10, "she needed that") end
        if girl.intelligence >= 8 then total = add(total, reasons, -15, "she sees right through it") end
        return total, reasons
    end,
    story = function(girl, player)
        local total, reasons = 0, {}
        if girl.mood == "Bored" then total = add(total, reasons, 10, "finally, something fun") end
        if girl.intelligence >= 6 then total = add(total, reasons, 5, "she enjoys a good story") end
        return total, reasons
    end,
    trick = function(girl, player)
        local total, reasons = 0, {}
        if girl.mood == "Happy" then total = add(total, reasons, 10, "she's having a blast") end
        if girl.rareza >= 6 then total = add(total, reasons, 5, "she likes weird stuff") end
        return total, reasons
    end,
    nerd = function(girl, player)
        local total, reasons = 0, {}
        if girl.rareza >= 7 then total = add(total, reasons, 10, "a fellow nerd!") end
        if girl.intelligence >= 8 then total = add(total, reasons, 5, "she gets the reference") end
        if girl.rareza <= 3 then total = add(total, reasons, -10, "she finds it lame") end
        return total, reasons
    end,
    classy = function(girl, player)
        local total, reasons = 0, {}
        if girl.beauty >= 8 then total = add(total, reasons, 5, "she likes the finer things") end
        if player.awesomeness >= 0.3 then total = add(total, reasons, 5, "you look sharp") end
        if girl.rareza >= 8 then total = add(total, reasons, -5, "too stuffy for her") end
        return total, reasons
    end,
}
