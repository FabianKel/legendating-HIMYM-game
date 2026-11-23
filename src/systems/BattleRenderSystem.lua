-- Dibuja la escena Battle en sus fases (scouting, interaction, asking,
-- success/fail). Presentacion estilo Pokemon: rombos de player/chica,
-- barra de Interest como si fuera HP, panel de challenge y cuadro de
-- dialogo. Presentacion pura: solo lee battle/girl/challenge/run --
-- nunca los cambia (eso es trabajo de BattleInputSystem).

local Screen = require("src.Screen")
local Widgets = require("src.ui.Widgets")

local BattleRenderSystem = { name = "battleRender" }

local headerFont, nameFont, bodyFont, dialogueFont, hintFont, outcomeFont

function BattleRenderSystem.setup(scene)
    headerFont   = love.graphics.newFont(16)
    nameFont     = love.graphics.newFont(15)
    bodyFont     = love.graphics.newFont(11)
    dialogueFont = love.graphics.newFont(13)
    hintFont     = love.graphics.newFont(12)
    outcomeFont  = love.graphics.newFont(22)
end

function BattleRenderSystem.unload(scene)
    headerFont, nameFont, bodyFont, dialogueFont, hintFont, outcomeFont = nil, nil, nil, nil, nil, nil
end

local CHALLENGE_BOX = { x = 16, y = 46, w = 190, h = 100 }
local GIRL_TEXT_X = 400
local GIRL_DIAMOND = { x = 596, y = 80, size = 56 }
local PLAYER_DIAMOND = { x = 90, y = 205, size = 70 }

function BattleRenderSystem.draw(scene)
    local registry = scene.registry
    local run = registry:resource("run")
    local girl = registry:resource("girl")
    local challenge = registry:resource("challenge")
    local battle = registry:resource("battle")

    love.graphics.setColor(0.1, 0.12, 0.16)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    BattleRenderSystem.drawHeader(run)

    love.graphics.setFont(bodyFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Interest", 160, 22)
    Widgets.drawBar(160, 36, 320, 16, battle.interest / 10, 0.85, 0.35, 0.55)

    BattleRenderSystem.drawGirl(girl)
    Widgets.drawDiamond(PLAYER_DIAMOND.x, PLAYER_DIAMOND.y, PLAYER_DIAMOND.size, "Player")
    BattleRenderSystem.drawChallenge(challenge)

    if battle.phase == "interaction" then
        BattleRenderSystem.drawCards(registry, battle)
    end
    BattleRenderSystem.drawDialogue(battle)

    if battle.phase == "success" or battle.phase == "fail" then
        BattleRenderSystem.drawOutcome(battle, challenge, run.player)
    end

    love.graphics.setFont(hintFont)
    love.graphics.setColor(0.75, 0.75, 0.75)
    local hint = (battle.phase == "success" or battle.phase == "fail")
        and "Press ENTER to continue"
        or "Press ENTER to continue - <- -> to pick a card"
    love.graphics.printf(hint, 0, Screen.h - 22, Screen.w - 12, "right")
end

function BattleRenderSystem.drawHeader(run)
    love.graphics.setFont(headerFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("5:00", 16, 12)
    love.graphics.printf("NIGHT " .. run.night .. "/7", 0, 12, Screen.w, "center")
    Widgets.drawStars(Screen.w - 16 - 5 * 14, 14, run.difficulty, 5)
end

function BattleRenderSystem.drawGirl(girl)
    Widgets.drawDiamond(GIRL_DIAMOND.x, GIRL_DIAMOND.y, GIRL_DIAMOND.size, "Girl")

    love.graphics.setFont(nameFont)
    love.graphics.setColor(0.85, 0.35, 0.75)
    love.graphics.print(girl.name, GIRL_TEXT_X, 50)
    love.graphics.setFont(bodyFont)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(girl.profile, GIRL_TEXT_X, 68)

    local stats = {
        { label = "Beauty",    value = girl.beauty },
        { label = "Intel.",    value = girl.intelligence },
        { label = "Rareness",  value = girl.rareza },
    }
    for i, stat in ipairs(stats) do
        local y = 86 + (i - 1) * 14
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(stat.label .. ":", GIRL_TEXT_X, y)
        love.graphics.setColor(Widgets.statColor(stat.value, 10))
        love.graphics.print(tostring(stat.value), GIRL_TEXT_X + 70, y)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Mood: " .. girl.mood, GIRL_TEXT_X, 132)
end

function BattleRenderSystem.drawChallenge(challenge)
    local box = CHALLENGE_BOX
    love.graphics.setColor(0.2, 0.2, 0.24)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h, 6, 6)

    love.graphics.setFont(nameFont)
    love.graphics.printf("Challenge: " .. challenge.name, box.x + 8, box.y + 8, box.w - 16, "left")
    love.graphics.setFont(bodyFont)
    love.graphics.printf(challenge.description, box.x + 8, box.y + 32, box.w - 16, "left")

    local effects = challenge.statEffects or {}
    local line = string.format("Awesomeness %+.1f  Speech %+d",
        effects.awesomeness or 0, effects.speech or 0)
    love.graphics.printf(line, box.x + 8, box.y + box.h - 18, box.w - 16, "left")
end

function BattleRenderSystem.drawCards(registry, battle)
    local cards = registry:query("conversationCard")
    local y = Screen.h - 130
    local cardW, gap = 150, 16
    local visibleIndex = 0

    for _, entity in ipairs(cards) do
        local card = registry:get(entity, "conversationCard")
        if not card.used then
            visibleIndex = visibleIndex + 1
            local x = 40 + (visibleIndex - 1) * (cardW + gap)
            local selected = (visibleIndex == battle.cursor)

            if selected then
                love.graphics.setColor(0.95, 0.75, 0.2)
            else
                love.graphics.setColor(0.4, 0.4, 0.45)
            end
            love.graphics.rectangle(selected and "fill" or "line", x, y, cardW, 60, 6, 6)

            love.graphics.setColor(selected and 0 or 1, selected and 0 or 1, selected and 0 or 1)
            love.graphics.setFont(bodyFont)
            love.graphics.printf(card.name, x + 8, y + 8, cardW - 16, "left")
            love.graphics.printf(card.description, x + 8, y + 26, cardW - 16, "left")
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function BattleRenderSystem.drawDialogue(battle)
    local x, y, w, h = 16, Screen.h - 60, Screen.w - 32, 36
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h, 6, 6)
    love.graphics.setFont(dialogueFont)
    love.graphics.printf(battle.dialogue, x + 10, y + 9, w - 20, "left")
end

function BattleRenderSystem.drawOutcome(battle, challenge, player)
    love.graphics.setColor(0, 0, 0, 0.88)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    local success = battle.phase == "success"
    if success then
        love.graphics.setColor(0.4, 0.85, 0.4)
    else
        love.graphics.setColor(0.9, 0.3, 0.3)
    end
    love.graphics.setFont(outcomeFont)
    love.graphics.printf(success and "You got the number" or "She said no",
        0, Screen.h / 2 - 60, Screen.w, "center")
    love.graphics.printf(success and "Challenge Accomplished!" or "Challenge Failed!",
        0, Screen.h / 2 - 28, Screen.w, "center")

    love.graphics.setFont(bodyFont)
    if not success then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("Rejection event: she leaves with Ted.", 0, Screen.h / 2, Screen.w, "center")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(challenge.name, 0, Screen.h / 2 + 30, Screen.w, "center")
    love.graphics.printf(
        "Awesomeness: " .. tostring(player.awesomeness)
        .. "  Speech: " .. tostring(player.speech)
        .. "  Energy: " .. tostring(player.energy),
        0, Screen.h / 2 + 46, Screen.w, "center")
end

return BattleRenderSystem
