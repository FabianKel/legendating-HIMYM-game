-- El sobre nocturno de "The Play Book": convierte el dia de Barney en
-- cartas. Logica PURA: no sabe nada de LOVE ni de la UI, recibe una
-- funcion random inyectable (los tests le pasan una con semilla).
--
-- LA REGLA (lo que el jugador puede aprender):
--   1. Cada tipo de carta empieza con 1 boleto de rifa.
--   2. Cada actividad del dia de ese tipo le suma 3 boletos.
--      (Laser Tag x2 => "story" tiene 7 boletos contra 1 de los demas)
--   3. Se sortea el tipo y luego una carta de ese tipo.
--   4. Speech alto da chance de carta LEGENDARY (+1 power):
--      probabilidad = speech / 40  (speech 10 => 25%).

local Cards = require("src.data.cards")

local PackGenerator = {}

PackGenerator.PACK_SIZE = 3
PackGenerator.BASE_TICKETS = 1
PackGenerator.TICKETS_PER_ACTIVITY = 3

local function defaultRandom(...)
    return love.math.random(...)
end

function PackGenerator.weights(dayLog)
    local weights, total = {}, 0
    for _, cardType in ipairs(Cards.TYPES) do
        local done = (dayLog and dayLog[cardType]) or 0
        weights[cardType] = PackGenerator.BASE_TICKETS
            + PackGenerator.TICKETS_PER_ACTIVITY * done
        total = total + weights[cardType]
    end
    return weights, total
end

-- Una sola tirada sobre las "tiras de boletos" de cada tipo.
local function pickType(weights, total, random)
    local target = random() * total
    local cumulative = 0
    for _, cardType in ipairs(Cards.TYPES) do
        cumulative = cumulative + weights[cardType]
        if target < cumulative then return cardType end
    end
    return Cards.TYPES[#Cards.TYPES] -- defensivo: random() == 1
end

function PackGenerator.legendaryChance(speech)
    return math.max(0, math.min(1, speech / 40))
end

function PackGenerator.card(dayLog, speech, random)
    random = random or defaultRandom
    local weights, total = PackGenerator.weights(dayLog)
    local cardType = pickType(weights, total, random)
    local pool = Cards.ofType(cardType)
    local template = pool[random(1, #pool)]

    local legendary = random() < PackGenerator.legendaryChance(speech)
    local card = Cards.instance(template.id, { legendary = legendary })
    if legendary then
        card.power = card.power + 1
    end
    return card
end

function PackGenerator.pack(dayLog, speech, random, size)
    size = size or PackGenerator.PACK_SIZE
    local cards = {}
    for i = 1, size do
        cards[i] = PackGenerator.card(dayLog, speech, random)
    end
    return cards
end

return PackGenerator
