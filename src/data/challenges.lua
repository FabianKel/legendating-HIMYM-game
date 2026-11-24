-- Los challenges que Barney grita al empezar la noche ("Challenge
-- Accepted!"). Cada uno tiene un ESTILO que decide dos cosas:
--   * que Plays de apertura puede usar esa noche (data/plays.lua)
--   * con que chicas arranca con ventaja (Interest.initial)
-- tier = dificultad; las noches altas sacan challenges de tier alto.
-- effects = cambios a los stats del jugador al aceptarlo.

return {
    -- tier 1
    { id = "lorenzo", tier = 1, style = "formal", name = "The Lorenzo Von Matterhorn",
      description = "Fake Swedish tycoon. There's even a website.",
      effects = { awesomeness = 0.4, speech = 1 } },
    { id = "classic", tier = 1, style = "casual", name = "Have You Met Barney?",
      description = "No gimmicks. Just the classic intro.",
      effects = { speech = 1 } },
    { id = "scuba", tier = 1, style = "weird", name = "The Scuba Diver",
      description = "Full scuba gear, all night long.",
      effects = { awesomeness = -0.5 } },
    { id = "champagnepop", tier = 1, style = "formal", name = "The Champagne Pop",
      description = "Pop a bottle the second you walk in. Works every time.",
      effects = { awesomeness = 0.3 } },
    { id = "layup", tier = 1, style = "casual", name = "The Lay-Up",
      description = "Low-key intro. Let the reputation do the talking.",
      effects = { speech = 0.5 } },
    { id = "soccerstar", tier = 1, style = "weird", name = "The Soccer Star",
      description = "You're a famous Brazilian footballer tonight. Prove it.",
      effects = { awesomeness = -0.3, speech = 0.5 } },
    -- tier 2
    { id = "dolphin", tier = 2, style = "weird", name = "The Dolphin",
      description = "Talk only in dolphin noises until she laughs.",
      effects = { awesomeness = -0.7, speech = -1 } },
    { id = "trashbag", tier = 2, style = "weird", name = "The Trash Bag Suit",
      description = "Your suit tonight is... a trash bag.",
      effects = { awesomeness = -0.6 } },
    { id = "prince", tier = 2, style = "formal", name = "The Royal Prince",
      description = "Claim to be minor royalty. Accent included.",
      effects = { awesomeness = 0.6, speech = -1 } },
    { id = "nerdnight", tier = 2, style = "weird", name = "Nerd Night",
      description = "Only talk about sci-fi and comic books.",
      effects = { awesomeness = -0.4, speech = 1 } },
    { id = "astronaut", tier = 2, style = "weird", name = "The Astronaut",
      description = "NASA flight suit. You just got back from the ISS.",
      effects = { awesomeness = -0.6, speech = 1 } },
    { id = "senator", tier = 2, style = "formal", name = "The Senator",
      description = "You're running for office tonight. Kiss some babies.",
      effects = { awesomeness = 0.7, speech = -0.5 } },
    -- tier 3
    { id = "mime", tier = 3, style = "weird", name = "The Mime",
      description = "No words allowed. At all.",
      effects = { awesomeness = -0.8, speech = -2 } },
    { id = "tuxedo", tier = 3, style = "formal", name = "The Tuxedo Toast",
      description = "Full tux and a toast for every stranger.",
      effects = { awesomeness = 0.8, speech = -1 } },
    { id = "honest", tier = 3, style = "casual", name = "The Honest Barney",
      description = "Tell only the truth. Terrifying.",
      effects = { speech = -2 } },
    { id = "stinsfire", tier = 3, style = "weird", name = "Mrs. Stinsfire",
      description = "A ventriloquist dummy does all the talking for you.",
      effects = { awesomeness = -0.9, speech = -1 } },
    { id = "hangingchad", tier = 3, style = "casual", name = "The Hanging Chad",
      description = "Impossible to read. Nobody knows if you're serious.",
      effects = { speech = -1.5 } },
}
