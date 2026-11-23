local Interest = require("src.rules.Interest")
local GirlGenerator = require("src.generation.GirlGenerator")
local ChallengeDeck = require("src.generation.ChallengeDeck")
local Cards = require("src.data.cards")
local events = require("src.data.events")

local function girl(overrides)
    local g = { name = "Test", beauty = 6, intelligence = 5, rareza = 5, mood = "Happy" }
    for k, v in pairs(overrides or {}) do g[k] = v end
    return g
end

local player = { awesomeness = 0, speech = 6, energy = 8, maxEnergy = 10 }

return function(test, seededRandom)
    test("weird challenge favors weird girls (initial interest)", function()
        local weird = { style = "weird" }
        local high = Interest.initial(girl({ rareza = 10 }), player, weird, 1)
        local low = Interest.initial(girl({ rareza = 1 }), player, weird, 1)
        assert(high > low, ("rareza 10: %d vs rareza 1: %d"):format(high, low))
    end)

    test("initial interest stays in 5..60 and drops with the night", function()
        local formal = { style = "formal" }
        for _, r in ipairs({ 1, 5, 10 }) do
            local v = Interest.initial(girl({ rareza = r }), player, formal, 7)
            assert(v >= 5 and v <= 60)
        end
        local n1 = Interest.initial(girl(), player, { style = "casual" }, 1)
        local n7 = Interest.initial(girl(), player, { style = "casual" }, 7)
        assert(n1 > n7)
    end)

    test("charm synergy: sad girl likes it, smart girl does not", function()
        local drink = Cards.instance("drink")
        local sad = Interest.cardGain(drink, girl({ mood = "Sad" }), player)
        local smart = Interest.cardGain(drink, girl({ mood = "Happy", intelligence = 9 }), player)
        assert(sad > smart, ("sad %d vs smart %d"):format(sad, smart))
    end)

    test("challenge style limits the approach plays", function()
        for _, play in ipairs(Interest.allowedPlays("weird")) do
            assert(play.style == "weird" or play.style == "any", play.name .. " leaked into weird")
        end
        local lorenzoAllowed = false
        for _, play in ipairs(Interest.allowedPlays("weird")) do
            if play.id == "lorenzo" then lorenzoAllowed = true end
        end
        assert(not lorenzoAllowed, "no Lorenzo Von Matterhorn in a trash bag")
    end)

    test("ask chance: 100 interest always works, energy helps", function()
        assert(Interest.askChance(100, player) == 1)
        local tired = { energy = 0, maxEnergy = 10 }
        local rested = { energy = 10, maxEnergy = 10 }
        assert(Interest.askChance(50, rested) > Interest.askChance(50, tired))
    end)

    test("girl generator: count by night, unique spots and names", function()
        for night = 1, 7 do
            local girls = GirlGenerator.night(night, seededRandom(night))
            assert(#girls == GirlGenerator.countForNight(night))
            local spots, names = {}, {}
            for _, entry in ipairs(girls) do
                assert(not spots[entry.spot], "repeated spot")
                assert(not names[entry.girl.name], "repeated name")
                spots[entry.spot], names[entry.girl.name] = true, true
                local g = entry.girl
                assert(g.beauty >= 1 and g.beauty <= 10 and g.rareza >= 1 and g.rareza <= 10)
            end
        end
    end)

    test("girl generator never brings back a conquered girl", function()
        local exclude = {}
        for night = 1, 7 do
            local girls = GirlGenerator.night(night, seededRandom(night * 3), exclude)
            for _, entry in ipairs(girls) do
                assert(not exclude[entry.girl.name], entry.girl.name .. " came back")
            end
            exclude[girls[1].girl.name] = true -- "conquista" a la primera
        end
    end)

    test("challenge deck: 3 distinct cards, includes the night's top tier", function()
        for night = 1, 7 do
            local hand = ChallengeDeck.draw(night, seededRandom(night * 13))
            assert(#hand == 3)
            local seen, hasTop = {}, false
            for _, c in ipairs(hand) do
                assert(not seen[c.id], "repeated challenge")
                seen[c.id] = true
                assert(c.tier <= ChallengeDeck.maxTier(night))
                if c.tier == ChallengeDeck.maxTier(night) then hasTop = true end
            end
            assert(hasTop, "night " .. night .. " has no top-tier challenge")
        end
    end)

    test("factor X events all return a delta and a message", function()
        for _, event in ipairs(events) do
            local delta, text = event.apply(girl(), player)
            assert(type(delta) == "number" and type(text) == "string", event.id)
        end
    end)
end
