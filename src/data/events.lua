-- El "Factor X": eventos del entorno de McLaren's que pasan justo antes
-- de pedir el numero en las noches 2, 5 y 7 (game_info.md). Pueden
-- ayudar (wingman) o arruinarlo todo (Ted, tu ex).
-- apply(girl, player) -> delta de Interest y texto del resultado.

return {
    { id = "ted", name = "Ted's architecture lecture",
      text = "Ted sits down and starts explaining load-bearing walls.",
      apply = function(girl)
          if girl.mood == "Bored" then return -15, "She was already bored. Now she's asleep." end
          return -5, "She politely nods. The mood drops a bit."
      end },
    { id = "ex", name = "Your ex walks in",
      text = "Your ex walks into the bar and stares at you.",
      apply = function(girl)
          if girl.rareza >= 7 then return 10, "She loves the drama!" end
          return -10, "Awkward. Very awkward."
      end },
    { id = "wingman", name = "Wingman to the rescue",
      text = "Your best bro appears and tells her how awesome you are.",
      apply = function(girl, player)
          return 10 + player.speech, "Textbook wingman work."
      end },
    { id = "wingwoman", name = "The wingwoman",
      text = "A friend of yours sits with her and talks you up.",
      apply = function(girl)
          if girl.mood == "Sad" then return 15, "She feels heard. You look great." end
          return 8, "A good word goes a long way."
      end },
    { id = "karaoke", name = "Karaoke night",
      text = "Someone starts singing a cheesy 80s song.",
      apply = function(girl)
          if girl.mood == "Happy" then return 10, "She sings along with you!" end
          return -5, "She winces."
      end },
}
