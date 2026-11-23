-- Genera a las chicas de una noche (INPUT randomness: se sortea ANTES
-- de que el jugador decida, y el jugador ve sus stats en el Scouting
-- para planear). Pura: recibe la funcion random.
--
--   * cantidad: 4 las primeras 3 noches, 3 desde la noche 4
--   * cada una en un lugar distinto del bar (marcadores 1-7)
--   * stats al azar; en noches altas la belleza tiende a subir (y las
--     chicas muy bellas son mas dificiles, ver Interest.initial)

local pools = require("src.data.girls")

local GirlGenerator = {}

GirlGenerator.SPOTS = { "1", "2", "3", "4", "5", "6", "7" }

function GirlGenerator.countForNight(night)
    return night <= 3 and 4 or 3
end

local function shuffled(list, random)
    local copy = {}
    for i, v in ipairs(list) do copy[i] = v end
    for i = #copy, 2, -1 do
        local j = random(1, i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    return copy
end

function GirlGenerator.girl(night, random, name)
    local minBeauty = math.min(7, 3 + math.floor(night / 2))
    return {
        name = name or pools.names[random(1, #pools.names)],
        profile = pools.profiles[random(1, #pools.profiles)],
        beauty = random(minBeauty, 10),
        intelligence = random(1, 10),
        rareza = random(1, 10),
        mood = pools.moods[random(1, #pools.moods)],
        age = random(21, 55),
        look = { hair = random(1, 6), dress = random(1, 6), skin = random(1, 4) },
    }
end

-- exclude = { [nombre] = true } para las que ya conquistaste: el reto
-- son 7 mujeres DIFERENTES, asi que nunca vuelven a aparecer.
function GirlGenerator.night(night, random, exclude)
    local spots = shuffled(GirlGenerator.SPOTS, random)
    local available = {}
    for _, name in ipairs(pools.names) do
        if not (exclude and exclude[name]) then available[#available + 1] = name end
    end
    local names = shuffled(available, random)
    local girls = {}
    for i = 1, GirlGenerator.countForNight(night) do
        girls[i] = { spot = spots[i], girl = GirlGenerator.girl(night, random, names[i]) }
    end
    return girls
end

return GirlGenerator
