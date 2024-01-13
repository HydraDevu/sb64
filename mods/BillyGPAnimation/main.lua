----------working animation : --------------

gGlobalSyncTable.frame = 1
local frames = {}
local prevLevelNum = -1  -- Initialize with an invalid level number
local comboSequence = {L_TRIG, R_TRIG, A_BUTTON, X_BUTTON, Y_BUTTON, B_BUTTON}
local comboStep = 1
local currentFrameIndex = 1
local frameCounter = 0
local animationCompleted = false  -- Flag to indicate if the animation has completed
local commentary = audio_stream_load('commentary.mp3')


local frameDurationMapping = {
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-001", 6}, {"frame-002", 6},
    {"frame-003", 90}, {"frame-004", 15},
    {"frame-005", 15}, {"frame-006", 15},
    {"frame-007", 15}, {"frame-003", 30},
    {"frame-008", 15}, {"frame-009", 15},
    {"frame-010", 15}, {"frame-011", 15},
    {"frame-012", 90}, {"frame-013", 90},
    {"frame-008", 90}, {"frame-003", 150},
    {"frame-014", 3}, {"frame-015", 3},
    {"frame-014", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}, {"frame-016", 3},
    {"frame-017", 3}
}

-- Load frames
for i = 1, 16 do
    local frame_name = string.format("frame-%03d", i)
    table.insert(frames, get_texture_info(frame_name))
end

-- warp_to_level(LEVEL_BOB, 1, 1)

function update(m)
    if not animationCompleted then
        frameCounter = frameCounter + 1
        local currentFrameInfo = frameDurationMapping[currentFrameIndex]

        if frameCounter >= currentFrameInfo[2] then
            frameCounter = 0
            currentFrameIndex = currentFrameIndex + 1
            if currentFrameIndex > #frameDurationMapping then
                animationCompleted = true  -- Stop the animation after the last frame
                currentFrameIndex = #frameDurationMapping  -- Keep the last frame displayed
            end
        end

        gGlobalSyncTable.frame = currentFrameInfo[1]
    else 
        disable_time_stop_including_mario()
    end

    mario_update(m)
    prevLevelNum = gNetworkPlayers[0].currLevelNum
end

function mario_update(m)
    if gNetworkPlayers[0].currLevelNum == LEVEL_BOB then
        if prevLevelNum ~= LEVEL_BOB or animationCompleted then
            if comboStep <= #comboSequence then
                local currentButton = comboSequence[comboStep]
                if (m.controller.buttonDown & currentButton) ~= 0 then
                    if (m.controller.buttonDown == currentButton) then
                        comboStep = comboStep + 1
                        if comboStep > #comboSequence then
                            -- Combo completed, reset animation
                            animationCompleted = false
                            currentFrameIndex = 1
                            frameCounter = 0
                            so_retro()
                            comboStep = 1
                        end
                    else
                        comboStep = 1
                    end
                end
            end
        end
    end
end

function hud_render()
    if gNetworkPlayers[0].currLevelNum == LEVEL_BOB and not animationCompleted then
        --set_time_stop_flags(1)
        enable_time_stop_including_mario()
        local frameIndex = tonumber(gGlobalSyncTable.frame:sub(7))
        if frameIndex and frameIndex <= 16 then
            local screenH = djui_hud_get_screen_height()
            local screenW = djui_hud_get_screen_width()
            djui_hud_render_texture(frames[frameIndex], 0, 0, screenW / 1024, screenH / 1024)
        end
    end
end

function so_retro()
    gGlobalSyncTable.frame = "frame-001"
    stop_background_music()
    --enable_time_stop()
    enable_time_stop_including_mario()
    --set_time_stop_flags(TIME_STOP_ENABLED)
    audio_stream_play(commentary, true, 10)
    return true
end

if currentFrameIndex > #frameDurationMapping then
    animationCompleted = true  -- Stop the animation after the last frame
    currentFrameIndex = #frameDurationMapping  -- Keep the last frame displayed
    audio_stream_stop(frameSound)  -- Stop the sound if needed
end

if network_is_server() then
    hook_event(HOOK_UPDATE, update)
    hook_chat_command("retro_gif", " ", so_retro)
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)








