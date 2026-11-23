-- Los Plays de apertura de "The Play Book" (fase Approach).
-- style: el challenge de la noche solo deja usar Plays de SU estilo,
-- mas los de estilo "any" (vestido de bolsa de basura no puedes hacer
-- el Lorenzo Von Matterhorn).
-- power x5 = Interest base; cost = energia.
-- bonus(girl) -> puntos extra y la razon (si aplica).

return {
    { id = "metted", style = "any", name = "Have You Met Ted?", power = 1, cost = 1,
      text = "Always works a little.",
      bonus = function(girl) return 0 end },
    { id = "lorenzo", style = "formal", name = "The Lorenzo Von Matterhorn", power = 3, cost = 2,
      text = "She googles you. +10 if she's not too smart.",
      bonus = function(girl)
          if girl.intelligence <= 6 then return 10, "She googled you. She's impressed." end
          return 0
      end },
    { id = "tuxentrance", style = "formal", name = "The Tuxedo Entrance", power = 3, cost = 2,
      text = "Slow-motion entrance. +10 on beautiful girls.",
      bonus = function(girl)
          if girl.beauty >= 8 then return 10, "She appreciates the effort." end
          return 0
      end },
    { id = "champagne", style = "formal", name = "The Champagne Drop", power = 2, cost = 1,
      text = "Send a bottle over. Reliable.",
      bonus = function(girl) return 5, "Free champagne never fails." end },
    { id = "tedmosby", style = "casual", name = "The Ted Mosby", power = 2, cost = 1,
      text = "Pose as a sensitive architect. +10 if she's sad.",
      bonus = function(girl)
          if girl.mood == "Sad" then return 10, "She needed someone sensitive." end
          return 0
      end },
    { id = "lostpuppy", style = "casual", name = "The Lost Puppy", power = 2, cost = 1,
      text = "Pretend you're lost. +10 if she's bored.",
      bonus = function(girl)
          if girl.mood == "Bored" then return 10, "Finally something interesting." end
          return 0
      end },
    { id = "scubaplay", style = "weird", name = "The Scuba Diver", power = 3, cost = 2,
      text = "Flippers and all. +15 on very weird girls.",
      bonus = function(girl)
          if girl.rareza >= 7 then return 15, "She LOVES it." end
          if girl.rareza <= 3 then return -10, "She's mortified." end
          return 0
      end },
    { id = "dolphinwhisper", style = "weird", name = "The Dolphin Whisperer", power = 2, cost = 1,
      text = "Eee-eee! +10 if she's happy.",
      bonus = function(girl)
          if girl.mood == "Happy" then return 10, "She laughs. Like, a lot." end
          return 0
      end },
    { id = "cosplay", style = "weird", name = "The Sci-Fi Cosplay", power = 2, cost = 2,
      text = "Full costume. +10 if she's smart.",
      bonus = function(girl)
          if girl.intelligence >= 7 then return 10, "She gets every reference." end
          return 0
      end },
}
