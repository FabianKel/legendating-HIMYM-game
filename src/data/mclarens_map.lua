-- McLaren's Pub, visto desde arriba. 48x25 tiles de 16 px (768x400 px):
-- mas ancho que la pantalla (640), asi que la camara sigue a Barney.
--
-- Tiles (los SOLIDOS bloquean el paso):
--   #  pared (solido)          .  piso
--   K  repisa de botellas (s)  _  detras de la barra (s)
--   B  barra (solido)          s  banco de barra (decorativo)
--   b  sillon del booth (s)    T  mesa (solido)
--   d  pista / zona jukebox    D  puerta de salida (s)
--   W  espejo en la pared (s)
--
-- Marcadores (se dibujan como piso; crean entidades al cargar):
--   P  inicio de Barney        C  Carl, el bartender (POI)
--   G  el booth del grupo (POI) M  espejo del bano (POI)
--   X  la puerta (POI)         1-7 lugares donde se sientan las chicas

return {
    tileSize = 16,
    rows = {
        "################################################",
        "#KKKKKKKKKKKKKKKKKK#...........#bbbbbbbbbbbbbbb#",
        "#__________________#...........#b.............b#",
        "#BBBBBBBBBBBBBBBBBB#...........#b...TTTTTTT...b#",
        "#..................#...........#b...TTTTTTT...b#",
        "#..s..s..s..s..s...............#b.............b#",
        "#.........C....................#bbbbbb.G.bbbbbb#",
        "#..............................................#",
        "#..............................................#",
        "#...TT.......TT.........TT.........TT..........#",
        "#...TT1......TT2........TT3........TT4.........#",
        "#..............................................#",
        "#..............................................#",
        "#........TT..........TT..........TT............#",
        "#........TT5.........TT6.........TT7...........#",
        "#..............................................#",
        "#..............................................#",
        "#......dddddddddd..................#####.#######",
        "#......dddddddddd..................#...........#",
        "#......dddddddddd..................#...........#",
        "#......dddddddddd..................#...........#",
        "#..................................#...........#",
        "#..P...............................#...........#",
        "#..X...............................#.....M.....#",
        "###D#####################################W######",
    },
    -- que significa cada marcador de POI
    pois = {
        C = { kind = "carl",   label = "Carl the bartender", action = "Order a drink" },
        G = { kind = "gang",   label = "The gang's booth",   action = "Talk to the gang" },
        M = { kind = "mirror", label = "Bathroom mirror",    action = "Check yourself out" },
        X = { kind = "exit",   label = "Exit",               action = "Leave McLaren's" },
    },
}
