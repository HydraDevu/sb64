-- name: screamerdeath
-- description: A timer will start at a number between 1-300.\n\nOnce that timer reaches 0, everyone gets jumpscared with Wega.\n\nThen, the timer will restart.
-- name: Random Wega Jumpscare
-- description: When the character enters LEVEL_BM, they get jumpscared with Wega.
local wega = get_texture_info('wega')
local wegaSound = audio_stream_load('scream.mp3')
gGlobalSyncTable.wegaOpacity = 0

function update()
    if gNetworkPlayers[0].currLevelNum == LEVEL_BM then
        gGlobalSyncTable.wegaOpacity = 255
        audio_stream_play(wegaSound, true, 0.5)
    else
        if gGlobalSyncTable.wegaOpacity > 0 then
            gGlobalSyncTable.wegaOpacity = gGlobalSyncTable.wegaOpacity - 2.5
        end
    end
end

function hud_render()
    local screenH = djui_hud_get_screen_height()
    local screenW = djui_hud_get_screen_width()
    djui_hud_set_color(255, 255, 255, gGlobalSyncTable.wegaOpacity)
    djui_hud_render_texture(wega, 0, 0, screenW / 128, screenH / 128)
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
