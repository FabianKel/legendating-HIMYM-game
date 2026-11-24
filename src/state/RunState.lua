-- RunState: el UNICO estado que sobrevive entre escenas (y en el save).
--
-- Regla de datos planos: solo numeros, strings, booleanos y tablas de
-- eso. Nada de imagenes de LOVE, funciones, sistemas ni referencias a
-- escenas -- por eso SaveFile puede escribirlo tal cual y cada escena
-- lo recibe como payload del switchRequest, igual que en el engine.
--
-- Cada escena lo guarda como recurso "runState" en su registry; los
-- sistemas lo leen/escriben ahi y la escena siguiente lo recibe en el
-- payload. Nunca hay dos copias vivas a la vez.

local Cards = require("src.data.cards")

local RunState = {}

RunState.NIGHTS = 7

-- Copia profunda de datos planos (para no compartir tablas de data/).
function RunState.copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do
        result[k] = RunState.copy(v)
    end
    return result
end

function RunState.new(seed)
    local collection = {}
    for i, id in ipairs(Cards.starterDeck) do
        collection[i] = Cards.instance(id)
    end

    return {
        night = 1,           -- 1..7: la noche que se va a jugar
        hour = 10,           -- reloj del dia (10:00 -> 20:00)
        seed = seed or os.time(),
        player = {
            awesomeness = 0,   -- -1 rareza .. 0 casual .. 1 formal
            speech      = 5,   -- 1..10
            energy      = 10,  -- tanque lleno: la noche 1 ya es dura sola, que no sea ademas sin energia
            maxEnergy   = 10,
            economy     = 100, -- siempre 100: Barney siempre tiene dinero
        },
        -- cuantas veces se hizo cada TIPO de actividad hoy: la regla de
        -- los sobres del Play Book lee esto (ver PackGenerator)
        dayLog = {},
        packOpened = false,    -- ya se abrio el sobre de este dia?
        collection = collection, -- el Play Book: cartas de conversacion
        conquests = {},        -- { {night=1, name="Robin"} , ... }
    }
end

-- Limites de cada stat: el unico lugar donde viven.
local LIMITS = {
    awesomeness = { -1, 1 },
    speech      = { 1, 10 },
    maxEnergy   = { 4, 15 },
}

function RunState.clampPlayer(player)
    for stat, range in pairs(LIMITS) do
        player[stat] = math.max(range[1], math.min(range[2], player[stat]))
    end
    player.energy = math.max(0, math.min(player.maxEnergy, player.energy))
    player.economy = 100 -- el chiste: nunca cambia
end

-- Aplica { stat = delta, ... } a los stats del jugador.
function RunState.applyEffects(player, effects)
    for stat, delta in pairs(effects or {}) do
        if player[stat] ~= nil then
            player[stat] = player[stat] + delta
        end
    end
    RunState.clampPlayer(player)
end

-- Arranca un dia nuevo: reloj a las 10:00 y bitacora limpia.
function RunState.startDay(runState)
    runState.hour = 10
    runState.dayLog = {}
    runState.packOpened = false
    runState.challenge = nil
    runState.nightState = nil
end

-- Arranca la noche en McLaren's. `girls` = lista de { spot = "1".."7",
-- girl = {datos} }. El estado de la noche vive en el RunState (y no
-- en la escena del mapa) porque sobrevive a ir y volver de cada
-- encuentro: que chicas siguen en el bar, la hora, donde estaba Barney.
function RunState.startNight(runState, challenge, girls)
    runState.challenge = RunState.copy(challenge)
    runState.nightState = {
        hour = 21,         -- 21:00 -> 02:00 (26)
        girls = RunState.copy(girls),
        playerX = nil,     -- nil = el inicio del mapa (marcador P)
        playerY = nil,
        drinks = 0,
        gangTalked = false,
        mirrorUsed = false,
        speechBonus = 0,   -- bonos temporales de esta noche
    }
end

-- Quita a una chica de la noche (te rechazo y se fue del bar).
function RunState.removeGirl(runState, index)
    table.remove(runState.nightState.girls, index)
end

return RunState
