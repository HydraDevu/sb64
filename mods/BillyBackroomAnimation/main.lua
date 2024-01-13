gGlobalSyncTable.frame = 1
local frames = {}
local prevLevelNum = -1  -- Initialize with an invalid level number
local comboSequence = {L_TRIG, R_TRIG, A_BUTTON, X_BUTTON, Y_BUTTON, B_BUTTON}
local comboStep = 1
local currentFrameIndex = 1
local frameCounter = 0
local animationCompleted = false  -- Flag to indicate if the animation has completed
-- Global variables for zoom and frame control
local zoomLevel = 1.0  -- Starting zoom level (1.0 means no zoom)
local zoomRate = 0.0005  -- Adjust this to slow down the zooming in each frame
local frame013Counter = 0  -- Counter for how long frame-003 should be zoomed

local billyScary = audio_stream_load('billyScary.mp3')


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
for i = 1, 17 do
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
         -- Check if the current frame is frame-003
         if currentFrameInfo == "frame-013" then
            -- Only process frame-003 once and then continue with the next frames
            if frame013Counter == 0 then
                frame013Counter = 1  -- Begin the zoom effect
            end
        else
            -- Ensure frame013Counter doesn't increment when not on frame-003
            if frame013Counter > 0 then
                frame013Counter = frame013Counter + 1
            end
            if frame013Counter > 330 then
                -- Reset zoom and counter after 150 frames
                zoomLevel = 1.0
                frame013Counter = 0
            end
        end
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
        if frameIndex and frameIndex <= 17 then
            local screenH = djui_hud_get_screen_height()
            local screenW = djui_hud_get_screen_width()

            -- Apply zoom if frame-003 was recently displayed
            if frame013Counter > 0 and frame013Counter <= 330 then
                zoomLevel = zoomLevel + zoomRate  -- Increment the zoom level
            end

            -- Calculate the scale and offset for the zoom effect
            local scaleX, scaleY = screenW / 1024 * zoomLevel, screenH / 1024 * zoomLevel
            local offsetX, offsetY = (screenW - screenW * zoomLevel) / 2, (screenH - screenH * zoomLevel) / 2

            -- Render the texture with the adjusted scale and centered position
            djui_hud_render_texture(frames[frameIndex], offsetX, offsetY, scaleX, scaleY)
        end
    end
end

function so_retro()
    gGlobalSyncTable.frame = "frame-001"
    stop_background_music()
    --enable_time_stop()
    enable_time_stop_including_mario()
    --set_time_stop_flags(TIME_STOP_ENABLED)
    audio_stream_play(billyScary, true, 10)
    return true
end

if currentFrameIndex > #frameDurationMapping then
    animationCompleted = true  -- Stop the animation after the last frame
    currentFrameIndex = #frameDurationMapping  -- Keep the last frame displayed
    --audio_stream_stop(frameSound)  -- Stop the sound if needed
end

if network_is_server() then
    hook_event(HOOK_UPDATE, update)
    hook_chat_command("retro_gif", " ", so_retro)
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)














----------working animation : --------------

-- gGlobalSyncTable.frame = 1
-- local frames = {}
-- local prevLevelNum = -1  -- Initialize with an invalid level number
-- local comboSequence = {L_TRIG, R_TRIG, A_BUTTON, X_BUTTON, Y_BUTTON, B_BUTTON}
-- local comboStep = 1
-- local currentFrameIndex = 1
-- local frameCounter = 0
-- local animationCompleted = false  -- Flag to indicate if the animation has completed
-- local billyScary = audio_stream_load('billyScary.mp3')


-- local frameDurationMapping = {
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-001", 6}, {"frame-002", 6},
--     {"frame-003", 90}, {"frame-004", 15},
--     {"frame-005", 15}, {"frame-006", 15},
--     {"frame-007", 15}, {"frame-003", 30},
--     {"frame-008", 15}, {"frame-009", 15},
--     {"frame-010", 15}, {"frame-011", 15},
--     {"frame-012", 90}, {"frame-013", 90},
--     {"frame-008", 90}, {"frame-003", 150},
--     {"frame-014", 3}, {"frame-015", 3},
--     {"frame-014", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}, {"frame-016", 3},
--     {"frame-017", 3}
-- }

-- -- Load frames
-- for i = 1, 17 do
--     local frame_name = string.format("frame-%03d", i)
--     table.insert(frames, get_texture_info(frame_name))
-- end

-- -- warp_to_level(LEVEL_BOB, 1, 1)

-- function update(m)
--     if not animationCompleted then
--         frameCounter = frameCounter + 1
--         local currentFrameInfo = frameDurationMapping[currentFrameIndex]

--         if frameCounter >= currentFrameInfo[2] then
--             frameCounter = 0
--             currentFrameIndex = currentFrameIndex + 1
--             if currentFrameIndex > #frameDurationMapping then
--                 animationCompleted = true  -- Stop the animation after the last frame
--                 currentFrameIndex = #frameDurationMapping  -- Keep the last frame displayed
--             end
--         end

--         gGlobalSyncTable.frame = currentFrameInfo[1]
--     else 
--         disable_time_stop_including_mario()
--     end

--     mario_update(m)
--     prevLevelNum = gNetworkPlayers[0].currLevelNum
-- end

-- function mario_update(m)
--     if gNetworkPlayers[0].currLevelNum == LEVEL_BOB then
--         if prevLevelNum ~= LEVEL_BOB or animationCompleted then
--             if comboStep <= #comboSequence then
--                 local currentButton = comboSequence[comboStep]
--                 if (m.controller.buttonDown & currentButton) ~= 0 then
--                     if (m.controller.buttonDown == currentButton) then
--                         comboStep = comboStep + 1
--                         if comboStep > #comboSequence then
--                             -- Combo completed, reset animation
--                             animationCompleted = false
--                             currentFrameIndex = 1
--                             frameCounter = 0
--                             so_retro()
--                             comboStep = 1
--                         end
--                     else
--                         comboStep = 1
--                     end
--                 end
--             end
--         end
--     end
-- end

-- function hud_render()
--     if gNetworkPlayers[0].currLevelNum == LEVEL_BOB and not animationCompleted then
--         --set_time_stop_flags(1)
--         enable_time_stop_including_mario()
--         local frameIndex = tonumber(gGlobalSyncTable.frame:sub(7))
--         if frameIndex and frameIndex <= 17 then
--             local screenH = djui_hud_get_screen_height()
--             local screenW = djui_hud_get_screen_width()
--             djui_hud_render_texture(frames[frameIndex], 0, 0, screenW / 1024, screenH / 1024)
--         end
--     end
-- end

-- function so_retro()
--     gGlobalSyncTable.frame = "frame-001"
--     stop_background_music()
--     --enable_time_stop()
--     enable_time_stop_including_mario()
--     --set_time_stop_flags(TIME_STOP_ENABLED)
--     audio_stream_play(billyScary, true, 10)
--     return true
-- end

-- if currentFrameIndex > #frameDurationMapping then
--     animationCompleted = true  -- Stop the animation after the last frame
--     currentFrameIndex = #frameDurationMapping  -- Keep the last frame displayed
--     audio_stream_stop(frameSound)  -- Stop the sound if needed
-- end

-- if network_is_server() then
--     hook_event(HOOK_UPDATE, update)
--     hook_chat_command("retro_gif", " ", so_retro)
-- end

-- hook_event(HOOK_ON_HUD_RENDER, hud_render)
-- hook_event(HOOK_MARIO_UPDATE, mario_update)








