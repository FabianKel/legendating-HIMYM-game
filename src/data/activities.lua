-- Las actividades del dia de Barney (pantalla de progresion).
--
-- hours   = cuanto reloj consume (el dia va de 10:00 a 20:00)
-- effects = cambios a los stats del jugador
-- type    = tipo de carta que esta actividad favorece en el sobre de la
--           noche (nil = no favorece ninguno)
-- text    = feedback que aparece al elegirla

return {
    {
        id = "suit", label = "Suit Shopping", icon = "S", hours = 2,
        effects = { awesomeness = 0.25 }, type = "classy",
        text = "New suit. It's gonna be legen... wait for it...",
    },
    {
        id = "lasertag", label = "Laser Tag", icon = "L", hours = 2,
        effects = { speech = 1, energy = -1 }, type = "story",
        text = "Undefeated again. New stories to tell.",
    },
    {
        id = "magic", label = "Practice Magic", icon = "M", hours = 2,
        effects = { speech = 1, energy = -1 }, type = "trick",
        text = "You finally nailed the fire trick. Eyebrows intact.",
    },
    {
        id = "nerd", label = "Star Wars Marathon", icon = "W", hours = 2,
        effects = { awesomeness = -0.25, energy = 1 }, type = "nerd",
        text = "Six movies later... you feel weirder. Good weird.",
    },
    {
        id = "playbook", label = "Study The Play Book", icon = "P", hours = 2,
        effects = { speech = 1 }, type = "charm",
        text = "You reread the classics. Smooth talk loaded.",
    },
    {
        id = "gym", label = "Hit the Gym", icon = "G", hours = 2,
        effects = { maxEnergy = 1, energy = -1 }, type = nil,
        text = "Stamina up. Max energy +1.",
    },
    {
        id = "nap", label = "Power Nap", icon = "Z", hours = 1,
        effects = { energy = 2 }, type = nil,
        text = "A legendary nap. Energy +2.",
    },
}
