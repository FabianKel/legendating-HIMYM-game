# UI Handoff — Legend... wait for it... Dating!

Alcance de esta entrega: **solo UI**. No hay lógica de juego real
balanceada — los stats, challenges, chicas y cartas de conversación son
datos de ejemplo (`src/data/ExampleData.lua`) para que las 3 pantallas
se vean pobladas y sean interactuables de principio a fin.

Cada sistema de UI está implementado como un **par de sistemas ECS**
(`*InputSystem` + `*RenderSystem`), no un solo archivo con las tres
funciones mezcladas. Esto sigue el principio de "sistemas atómicos" del
`CLAUDE.md` del engine base (uno por responsabilidad) y el patrón que
ya trae el repo (`MenuInputSystem` / `MenuRenderSystem` en
`06-UIToolkit`). Leído como conjunto, cada par sigue exactamente
**Setup → Update → Render**:

- **Setup** vive en la escena (`src/scenes/*.lua`, que crea las
  entidades y recursos) y en `RenderSystem.setup` (que crea las
  fuentes).
- **Update** vive en `InputSystem.update` (lee `keyPressed`, muta el
  estado de la UI, dispara eventos/cambios de escena).
- **Render** vive en `RenderSystem.draw` (pinta lo que el Update dejó
  en el registry; nunca lo modifica).

## 1. Main Menu UI

**Archivos:** `src/scenes/MenuScene.lua`,
`src/systems/MainMenuInputSystem.lua`,
`src/systems/MainMenuRenderSystem.lua`

### Descripción breve
La pantalla de título: logo "LEGEND... WAIT FOR IT... DATING!", un menú
de 3 opciones (Play / Settings / Exit) con cursor, un botón de ayuda
"?" y un panel de settings placeholder. Es la escena de entrada del
juego y también la escena a la que se vuelve si el jugador pierde el
reto de las 7 noches.

### Implementación
- **Setup:** `MenuScene.lua` crea una entidad `mainMenu` (opciones +
  cursor) y dos recursos booleanos (`helpVisible`, `settingsVisible`).
  `MainMenuRenderSystem.setup` crea las 4 fuentes que usa la pantalla.
- **Update:** `MainMenuInputSystem.update` lee los eventos `keyPressed`
  del frame: arriba/abajo mueven el cursor, `H` muestra/oculta el panel
  de ayuda, `ENTER` confirma la opción actual (Play dispara un
  `switchRequest` a la escena `bar` con el estado inicial del jugador;
  Settings abre su panel; Exit llama `love.event.quit()`), y
  `Backspace` cierra el panel de settings cuando está abierto.
- **Render:** `MainMenuRenderSystem.draw` dibuja el logo, los 3 botones
  (resaltando el seleccionado), el botón de ayuda, el hint inferior, y
  — condicionalmente — el panel de ayuda o de settings encima de todo,
  según los recursos de visibilidad.

### Conexión con el juego
Es el punto de entrada y de salida del loop de 7 noches: arranca un
run nuevo (Play) y es adonde cae el jugador cuando una chica lo
rechaza y la noche se pierde, cerrando el ciclo `Menu → Bar → Battle →
(éxito: Bar siguiente noche | fracaso: Menu)` que pide el diseño.

## 2. Bar HUD + Challenge Selection UI

**Archivos:** `src/scenes/BarScene.lua`,
`src/systems/BarInputSystem.lua`, `src/systems/BarRenderSystem.lua`

### Descripción breve
La pantalla de "arranca la noche" en McLaren's: header con la hora, el
número de noche (`NIGHT n/7`) y estrellas de dificultad; un HUD con el
rombo del jugador y sus stats (Awesomeness / Speech / Energy, con
color rojo/amarillo/verde según el valor — igual a la anotación del
boceto); y, encima del bar, las 3 cartas de challenge de la noche para
elegir.

### Implementación
- **Setup:** `BarScene.lua` guarda un recurso `run` (noche, dificultad,
  stats del jugador que vienen del Menu o de la Battle anterior), crea
  una entidad `challengeCard` por cada challenge de la noche
  (`ExampleData.challengesForNight`), y un recurso `cardSelection`
  (cursor + estado de confirmación).
- **Update:** `BarInputSystem.update` mueve el cursor entre las 3
  cartas con izquierda/derecha; `ENTER` marca la carta elegida y arranca
  un temporizador de 0.8s (para mostrar "Challenge Accepted!"); cuando
  el temporizador llega a 0, aplica el efecto del challenge a los stats
  del jugador y dispara el `switchRequest` a la escena `battle` con la
  chica de esa noche y el challenge elegido como payload.
- **Render:** `BarRenderSystem.draw` pinta el header, el rombo y stats
  del jugador (usando `Widgets.statColor` para el semáforo de color),
  las 3 cartas (resaltando la seleccionada) y, mientras se confirma, un
  banner "Challenge Accepted!" encima de todo.

### Conexión con el juego
Es el HUD "de entrada" a cada noche: muestra de un vistazo en qué
condiciones llega el jugador (sus stats acumulados de noches
anteriores) y convierte la elección de challenge — la decisión central
del loop, según `game_info.md` — en la interacción principal de la
pantalla. El challenge elegido viaja como payload a la Battle y de
verdad modifica los stats con los que se pelea esa noche.

## 3. Battle (Pokémon-style encounter) UI

**Archivos:** `src/scenes/BattleScene.lua`,
`src/systems/BattleInputSystem.lua`,
`src/systems/BattleRenderSystem.lua`

### Descripción breve
La pantalla que aparece cuando llega una chica nueva, con la
composición de una batalla Pokémon: rombos de Player y Girl, una barra
de **Interest** (equivalente a la barra de HP), un panel con los datos
de la chica y del challenge activo, un cuadro de diálogo, y las cartas
de conversación como "movimientos". Atraviesa 4 fases dentro de la
misma pantalla — `scouting → interaction → asking → success/fail` —
tal como el boceto de referencia muestra varias variantes de una misma
escena.

### Implementación
- **Setup:** `BattleScene.lua` calcula el Interest inicial de ejemplo
  (según si el challenge es "raro" o "formal" contra la rareza de la
  chica), y guarda los recursos `girl`, `challenge` y `battle` (fase,
  interest, diálogo, cartas jugadas). Crea una entidad
  `conversationCard` por cada carta de la mano.
- **Update:** `BattleInputSystem.update` avanza la fase según la tecla
  y el estado: en `scouting`, ENTER pasa a `interaction`; en
  `interaction`, izquierda/derecha mueven el cursor entre las cartas
  sin usar y ENTER "juega" la seleccionada (sube el Interest, la marca
  `used` para que Render dej de dibujarla, y actualiza el diálogo); si
  el Interest llega a 10 ella misma pide el número (éxito inmediato);
  si se acaban las 3 cartas pasa a `asking`; ahí, en noches 2/5/7 la
  primera confirmación dispara el evento "Factor X" (ejemplo: Ted
  arruina el ambiente) y la segunda resuelve si consigue el número
  (probabilidad ligada al Interest); en `success`/`fail`, ENTER dispara
  el `switchRequest` de salida — a `bar` (siguiente noche) si ganó, a
  `menu` si perdió, como pide el diseño.
- **Render:** `BattleRenderSystem.draw` dibuja el header, la barra de
  Interest, el rombo y panel de la chica, el rombo del jugador, el
  panel del challenge activo, las cartas de conversación **solo**
  durante `interaction` (las usadas se ocultan), el cuadro de diálogo
  siempre visible, y — en `success`/`fail` — una pantalla de resultado
  a pantalla completa ("Challenge Accomplished!" / "Challenge Failed!"
  con el evento de rechazo), igual a los dos paneles finales del
  boceto.

### Conexión con el juego
Es el corazón del loop de conquista: traduce el "Approach + Interacción
+ Pedir número" del `game_info.md` en una sola pantalla que un jugador
puede leer de un vistazo (barra de Interest = qué tan cerca está del
éxito) y jugar con el teclado (elegir cartas = las decisiones de
conversación). El resultado (éxito/fracaso) es lo que decide si el
`RunState` avanza a la siguiente noche o si el reto de 7 noches
termina — es la pantalla donde de verdad se gana o se pierde la
partida.

## Notas generales

- Toda la UI corre a **640×400**, sin cámara — coincide con que el
  juego es prácticamente estático (ver `src/Screen.lua`).
- El estado que cruza de escena en escena (noche, dificultad, stats del
  jugador, challenge elegido, chica actual) viaja como **payload de
  `switchRequest`**, el mismo mecanismo que ya usa el engine base — no
  se agregó una capa nueva de estado global.
- `src/ui/Widgets.lua` no es un sistema: son funciones de dibujo
  compartidas (rombo, estrellas, barra, color de stat) para que los 3
  `RenderSystem` no reimplementen lo mismo.
- Pendiente fuera de esta tarea: arte real (todo es geometría plana a
  propósito), balance de stats/probabilidades, guardado de partida, y
  las pantallas de mapa/colección que menciona el engine base pero que
  este juego no pidió.
