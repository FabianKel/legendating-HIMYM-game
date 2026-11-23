-- Animacion por TIEMPO del sprite de Barney: mientras camina alterna
-- los cuadros de su sprite sheet a FPS fijos (independiente del
-- framerate del juego); quieto, vuelve al cuadro de reposo.

local SpriteAnimationSystem = { name = "spriteAnimation" }

local WALK_FRAMES = { 1, 2, 3, 2 }
local WALK_FPS = 8

function SpriteAnimationSystem.update(scene, dt)
    for _, sprite, mover in scene.registry:each("sprite", "mover") do
        if mover.moving then
            sprite.timer = sprite.timer + dt
            local index = math.floor(sprite.timer * WALK_FPS) % #WALK_FRAMES + 1
            sprite.frame = WALK_FRAMES[index]
        else
            sprite.timer = 0
            sprite.frame = 1
        end
    end
end

return SpriteAnimationSystem
