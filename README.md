# Legend... wait for it... Dating!

Dating sim + card battler en **Lua + LÖVE 11.5**, construido sobre el engine ECS
del curso CC3096 Game Engine Architecture (UVG).

Eres Barney y tienes *The Play Book*: conquista a 7 mujeres distintas en 7
noches seguidas en McLaren's.

## Cómo se juega

1. **Día (10:00-20:00):** elige actividades. Cambian tus stats y deciden qué cartas trae el sobre de la noche.
2. **The Play Book:** abre el sobre (3 cartas) y revisa tu colección.
3. **Bar:** elige 1 de 3 challenges. Cambia tus stats y limita tus Plays de apertura.
4. **McLaren's (21:00-02:00):** recorre el bar. Carl te da energía, el grupo del booth te da ánimos y el espejo te prepara. Acércate a una chica para empezar el encuentro.
5. **Encuentro:** lee sus stats, elige un Play de apertura y juega hasta 3 cartas (cada una muestra cuánto Interest te da con *ella*). Luego pide su número. En las noches 2, 5 y 7 puede pasar un **Factor X**.
6. Si te da su número, HIGH FIVE y a la siguiente noche. Si te rechaza, pierdes energía y sigues con las demás. Si se acaban las chicas o el bar cierra, es *walk of shame* y el reto se reinicia.

## Cómo correrlo

```sh
love .                     # jugar
love . --debug             # jugar dentro del editor de debug (F1 paneles, F9 pausa, F10 un frame)
love . --test              # tests de lógica
love . --smoke gameplay    # juega solo y toma capturas (progression, map, gameplay, win, lose)
lua tests/simulate.lua 3000  # simulador de balance (cualquier Lua 5.1 / LuaJIT)
```

## Controles

Flechas / WASD para moverse y elegir · `ENTER`/`ESPACIO` para confirmar ·
`E` para interactuar en el mapa · `Q` para pedir el número antes de jugar las 3 cartas ·
`ESC` para salir.

## Branches (una por entrega)

Cada branch parte de la anterior. `git diff A..B` muestra lo que agregó cada entrega.

| Branch | Entrega |
|---|---|
| `main` | Juego completo (igual a `04-gameplay`) |
| `01-sistemas-ui` | Sistemas de UI: menú, HUD del bar y selección de challenge, encuentro |
| `02-progression-cycle` | Progression cycle: día de Barney (stats) → sobres del Play Book (colección) |
| `03-map-systems` | Map systems: McLaren's explorable con cámara, colisiones y puntos de interés |
| `04-gameplay` | Juego completo: reloj de la noche, chicas generadas, sinergias, Factor X, 7 noches, guardado, simulador |

## Estructura

```
src/ecs/         Registry y Scene (engine)
src/Game.lua     cambio de escenas diferido (engine)
src/debug/       overlay / editor de debug (engine)
src/state/       RunState (estado compartido), SaveFile, serialize
src/data/        datos del juego: cartas, actividades, challenges, plays, sinergias, eventos, mapa
src/rules/       fórmulas puras del encuentro (Interest)
src/generation/  generadores puros: sobres, manos, chicas, challenges
src/map/         TileMap (parseo, colisiones, BFS)
src/scenes/      menu, day, playbook, bar, map, battle, result
src/systems/     sistemas ECS por escena (common, day, playbook, map, battle, result)
src/ui/          widgets, cache de fuentes e imágenes, personajes en pixel art
tests/           tests, smoke tests, simulador de balance
assets/sprites/  sprite original de Barney
```
