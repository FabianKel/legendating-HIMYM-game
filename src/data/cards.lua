-- Cartas de conversacion de "The Play Book" (datos puros).
--
-- Cada carta tiene un TIPO (afinidad). El tipo decide dos cosas:
--   * que actividades del dia hacen mas probable obtenerla
--     (ver data/activities.lua y generation/PackGenerator.lua)
--   * con que chicas hace sinergia (ver data/synergy.lua)
--
-- power = cuanto Interest mueve (x5 puntos); cost = energia que gasta.

local Cards = {}

Cards.TYPES = { "charm", "story", "trick", "nerd", "classy" }

Cards.TYPE_INFO = {
    charm  = { label = "Charm",  color = { 0.95, 0.45, 0.6 },
               hint = "Great on SAD girls. Very smart girls see through it." },
    story  = { label = "Story",  color = { 0.45, 0.7, 0.95 },
               hint = "Great on BORED girls. Smart girls enjoy a good story." },
    trick  = { label = "Trick",  color = { 0.95, 0.65, 0.25 },
               hint = "Great on HAPPY girls. Weird girls like the show." },
    nerd   = { label = "Nerd",   color = { 0.55, 0.85, 0.45 },
               hint = "Great on WEIRD girls. Normal girls find it lame." },
    classy = { label = "Classy", color = { 0.8, 0.7, 0.95 },
               hint = "Great on beautiful girls and when you look formal." },
}

Cards.templates = {
    -- charm
    { id = "drink",      type = "charm",  power = 3, cost = 1, name = "Buy Her a Drink",
      text = "Works on sad girls. Smart ones see right through it." },
    { id = "metted",     type = "charm",  power = 2, cost = 1, name = "Have You Met Ted?",
      text = "Introduce your wingman. Instant icebreaker." },
    { id = "eyes",       type = "charm",  power = 2, cost = 1, name = "Compliment Her Eyes",
      text = "Cheesy, but sincere enough." },
    -- story
    { id = "lasertag",   type = "story",  power = 2, cost = 1, name = "Laser Tag Anecdote",
      text = "The day you were undefeated champion." },
    { id = "pilot",      type = "story",  power = 3, cost = 2, name = "I Was a Pilot",
      text = "A totally true story. Totally." },
    { id = "brocode",    type = "story",  power = 2, cost = 1, name = "Bro Code Wisdom",
      text = "Article 1: Bros before... you know." },
    -- trick
    { id = "fire",       type = "trick",  power = 3, cost = 2, name = "Fire Magic Trick",
      text = "Flames from your hands. Happy girls love it." },
    { id = "coin",       type = "trick",  power = 2, cost = 1, name = "Disappearing Coin",
      text = "Classic sleight of hand." },
    { id = "cardtrick",  type = "trick",  power = 2, cost = 1, name = "Pick a Card",
      text = "Any card... was it the queen of hearts?" },
    -- nerd
    { id = "starwars",   type = "nerd",   power = 2, cost = 1, name = "Star Wars Quote",
      text = "A weird girl will quote it back." },
    { id = "archfacts",  type = "nerd",   power = 1, cost = 1, name = "Architecture Facts",
      text = "Ted's move. Rarely works." },
    { id = "saberduel",  type = "nerd",   power = 3, cost = 2, name = "Lightsaber Duel",
      text = "Two straws. Pure chaos. Rare girls adore it." },
    -- classy
    { id = "champagne",  type = "classy", power = 3, cost = 2, name = "Champagne Toast",
      text = "Only the finest. Economy: still 100." },
    { id = "suitpraise", type = "classy", power = 2, cost = 1, name = "Suit Talk",
      text = "Explain why suits are awesome." },
    { id = "dinner",     type = "classy", power = 4, cost = 3, name = "Fancy Dinner Invite",
      text = "The big play. Costs a lot of energy." },
}

Cards.byId = {}
for _, template in ipairs(Cards.templates) do
    Cards.byId[template.id] = template
end

-- La mano inicial de cada partida.
Cards.starterDeck = { "drink", "lasertag", "fire", "suitpraise" }

-- Una carta "viva" de la coleccion: copia plana de la plantilla (para
-- que modificar una no modifique data/) mas sus propios campos.
function Cards.instance(id, extra)
    local template = assert(Cards.byId[id], "unknown card: " .. tostring(id))
    local card = {}
    for k, v in pairs(template) do card[k] = v end
    for k, v in pairs(extra or {}) do card[k] = v end
    return card
end

function Cards.ofType(cardType)
    local result = {}
    for _, template in ipairs(Cards.templates) do
        if template.type == cardType then result[#result + 1] = template end
    end
    return result
end

return Cards
