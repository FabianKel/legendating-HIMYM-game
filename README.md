# Legend... wait for it... Dating!

Dating sim + card battler en **Lua + LÖVE 11.5**, construido sobre el engine ECS
del curso CC3096 Game Engine Architecture (UVG).

Eres Barney y tienes *The Play Book*: conquista a 7 mujeres distintas en 7
noches seguidas en McLaren's.

## Cómo correrlo

```sh
love .           # jugar
love . --debug   # jugar con el overlay de debug (desde 02-progression-cycle)
love . --test    # correr los tests de lógica (desde 02-progression-cycle)
```

## Branches (una por entrega)

Cada branch parte de la anterior. `git diff A..B` muestra lo que agregó cada entrega.

| Branch | Entrega |
|---|---|
| `main` | Estado más reciente del juego |
| `01-sistemas-ui` | Sistemas de UI: menú, HUD del bar y selección de challenge, encuentro |
| `02-progression-cycle` | Progression cycle: día de Barney (stats) → sobres del Play Book (colección) |
| `03-map-systems` | Map systems: McLaren's explorable con colisiones y puntos de interés |
| `04-gameplay` | Juego completo: reloj de la noche, cola de chicas, sinergias, Factor X, 7 noches, guardado |

## Controles

Flechas / WASD para moverse y elegir · `ENTER`/`ESPACIO` para confirmar ·
`E` para interactuar en el mapa · `ESC` para salir.
