-- Las 3 cartas de challenge de la noche. La dificultad sube con la
-- noche: el tier maximo crece (1 -> 2 -> 3) y al menos una carta es de
-- ese tier maximo. Las 3 son distintas. Pura: recibe random.

local challenges = require("src.data.challenges")

local ChallengeDeck = {}

function ChallengeDeck.maxTier(night)
    if night <= 2 then return 1 elseif night <= 4 then return 2 end
    return 3
end

function ChallengeDeck.draw(night, random)
    local maxTier = ChallengeDeck.maxTier(night)
    local top, rest = {}, {}
    for _, challenge in ipairs(challenges) do
        if challenge.tier == maxTier then
            top[#top + 1] = challenge
        elseif challenge.tier < maxTier then
            rest[#rest + 1] = challenge
        end
    end

    local hand = {}
    local function take(pool)
        local i = random(1, #pool)
        hand[#hand + 1] = table.remove(pool, i)
    end
    take(top)
    -- el resto sale de todo lo permitido (top que quedo + tiers menores)
    local pool = {}
    for _, c in ipairs(top) do pool[#pool + 1] = c end
    for _, c in ipairs(rest) do pool[#pool + 1] = c end
    while #hand < 3 and #pool > 0 do take(pool) end
    return hand
end

return ChallengeDeck
