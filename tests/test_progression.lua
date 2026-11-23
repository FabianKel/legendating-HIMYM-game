local PackGenerator = require("src.generation.PackGenerator")
local HandGenerator = require("src.generation.HandGenerator")
local RunState = require("src.state.RunState")
local serialize = require("src.state.serialize")
local Cards = require("src.data.cards")

return function(test, seededRandom)
    test("pack size and valid cards", function()
        local pack = PackGenerator.pack({}, 5, seededRandom(1))
        assert(#pack == PackGenerator.PACK_SIZE)
        for _, card in ipairs(pack) do
            assert(Cards.byId[card.id], "unknown card " .. tostring(card.id))
        end
    end)

    test("activities skew the pack distribution", function()
        -- 3 actividades "story": 10 boletos vs 1 de cada otro tipo (14 total)
        local dayLog = { story = 3 }
        local random = seededRandom(3096)
        local counts, n = {}, 5000
        for _ = 1, n do
            local card = PackGenerator.card(dayLog, 1, random)
            counts[card.type] = (counts[card.type] or 0) + 1
        end
        local weights, total = PackGenerator.weights(dayLog)
        local expected = weights.story / total
        local observed = counts.story / n
        assert(math.abs(observed - expected) < 0.03,
            ("story drifted: %.3f vs %.3f"):format(observed, expected))
    end)

    test("legendary chance grows with speech", function()
        assert(PackGenerator.legendaryChance(10) > PackGenerator.legendaryChance(2))
        assert(PackGenerator.legendaryChance(40) == 1)
    end)

    test("hand draws without repeats and without mutating", function()
        local collection = {}
        for i = 1, 8 do collection[i] = Cards.instance("drink", { uid = i }) end
        local hand = HandGenerator.draw(collection, 3, seededRandom(7))
        local seen = {}
        for _, card in ipairs(hand) do
            assert(not seen[card.uid], "repeated card in hand")
            seen[card.uid] = true
            card.used = true
        end
        for _, card in ipairs(collection) do
            assert(not card.used, "hand mutated the collection")
        end
    end)

    test("run state is plain data (serializable round trip)", function()
        local run = RunState.new(42)
        local text = serialize.encode({ runState = run })
        local back = serialize.decode(text)
        assert(back.runState.seed == 42)
        assert(#back.runState.collection == #Cards.starterDeck)
    end)

    test("stats are clamped", function()
        local run = RunState.new(1)
        RunState.applyEffects(run.player, { awesomeness = 5, speech = -20, energy = 99 })
        assert(run.player.awesomeness == 1)
        assert(run.player.speech == 1)
        assert(run.player.energy == run.player.maxEnergy)
        assert(run.player.economy == 100)
    end)
end
