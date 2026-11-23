-- Datos de ejemplo (jugador, challenges, chicas, cartas de
-- conversacion) para poblar la UI mientras no existe logica real de
-- juego. Nada aqui decide quien gana una noche: son solo los valores
-- que las pantallas necesitan para dibujarse con datos creibles. El
-- wording visible en pantalla se deja en ingles a proposito (ver
-- game_info.md / instrucciones de la tarea); estos comentarios son
-- nuevos, por eso van en espanol.

local ExampleData = {}

-- Barney arranca cada partida con los mismos stats base. awesomeness
-- va de -1 (rareza total) a 1 (formal); speech y energy son 0-10;
-- economy siempre es 100 (chiste del personaje: siempre tiene dinero).
ExampleData.defaultPlayer = {
    awesomeness = 0,
    speech      = 6,
    energy      = 8,
    economy     = 100,
}

-- Pool de 3 challenges. En el juego real la dificultad deberia subir
-- con la noche; para esta tarea de UI basta un pool fijo que se repite.
ExampleData.challenges = {
    {
        name = "The Scuba Diver",
        description = "Full scuba gear. You can only\nplay casual Plays.",
        icon = "S",
        statEffects = { awesomeness = -0.6, speech = 0 },
    },
    {
        name = "The Lorenzo Von Matterhorn",
        description = "Flawless suit, fake Swedish\ntycoon backstory. Unlocks\nformal Plays.",
        icon = "L",
        statEffects = { awesomeness = 0.8, speech = 1 },
    },
    {
        name = "The Dolphin",
        description = "You can only talk in dolphin\nsounds until she laughs.",
        icon = "D",
        statEffects = { awesomeness = -0.9, speech = -1 },
    },
}

-- Chicas disponibles en McLaren's. rareza alta = perdona mas lo raro
-- del challenge elegido (usado por BattleScene para el interes
-- inicial); mood queda de ejemplo para una futura sinergia de cartas.
ExampleData.girls = {
    { name = "Robin", profile = "Night reporter",        beauty = 9, intelligence = 8, rareza = 4, mood = "Bored", age = 29 },
    { name = "Nora",  profile = "Kindergarten teacher",   beauty = 7, intelligence = 6, rareza = 2, mood = "Happy", age = 26 },
    { name = "Zoey",  profile = "Neighborhood activist",  beauty = 8, intelligence = 7, rareza = 7, mood = "Sad",   age = 31 },
    { name = "Quinn", profile = "Exotic dancer",          beauty = 9, intelligence = 5, rareza = 9, mood = "Happy", age = 27 },
}

-- Las 3 cartas de "Habilidad al Hablar" que se juegan durante la
-- interaccion. delta = cuanto sube (o baja) el Interest al jugarla;
-- valor de ejemplo, sin balancear.
ExampleData.conversationCards = {
    { name = "Fire Trick",      description = "A fire magic trick.",   delta = 2 },
    { name = "Laser Tag Story", description = "A laser-tag story.",    delta = 1 },
    { name = "Buy a Drink",     description = "You buy her a drink.",  delta = 3 },
}

-- El "Factor X" del GDD del juego: en las noches 2, 5 y 7 puede pasar
-- algo del entorno del bar antes de pedir el numero. Un solo evento de
-- ejemplo alcanza para esta tarea de UI.
ExampleData.wingmanEvent = {
    name = "Ted ruins the mood",
    description = "He starts talking about architecture again.",
    delta = -2,
}

-- Devuelve las 3 cartas de challenge para una noche dada. Por ahora el
-- pool es el mismo todas las noches (dificultad real: fuera de
-- alcance de esta tarea de UI).
function ExampleData.challengesForNight(night)
    return ExampleData.challenges
end

-- Devuelve una chica "nueva" para la noche/turno actual, ciclico sobre
-- el pool de ejemplo.
function ExampleData.girlForNight(night)
    local index = ((night - 1) % #ExampleData.girls) + 1
    return ExampleData.girls[index]
end

return ExampleData
