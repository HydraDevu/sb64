-- description: Backroom Animation Billy.\n\nThe host can use /retro_gif to make the worst GIF ever made pop up on everyone's screen.


-- gGlobalSyncTable.frame = 1
-- local frames = {}

-- -- Load only 26 frames
-- for i = 1, 27 do
--     local frame_name = string.format("ezgif-frame-%03d", i)
--     table.insert(frames, get_texture_info(frame_name))
-- end

-- function update()
--     -- Adjust frame increment rate if needed
--     gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.25
-- end

-- function hud_render()
--     -- if gNetworkPlayers[0].currLevelNum == LEVEL_BM then
--         -- Check for frame range up to 26
--         if math.ceil(gGlobalSyncTable.frame) < 27 then
--             local screenH = djui_hud_get_screen_height()
--             local screenW = djui_hud_get_screen_width()
--             djui_hud_render_texture(frames[math.ceil(gGlobalSyncTable.frame)], 0, 0, screenW / 1024, screenH / 1024)
--         end
--     -- end
-- end

-- function so_retro()
--     gGlobalSyncTable.frame = 1
--     return true
-- end

-- if network_is_server() then
--     hook_event(HOOK_UPDATE, update)
--     hook_chat_command("retro_gif", " ", so_retro)
-- end
-- hook_event(HOOK_ON_HUD_RENDER, hud_render)


-- This mods works but get stuck at frame 10 

-- gGlobalSyncTable.frame = 1
-- local frames = {}
-- local timer = 0 -- Timer for the frame pause

-- -- Load 26 frames
-- for i = 1, 36 do
--     local frame_name = string.format("frame-%03d", i)
--     table.insert(frames, get_texture_info(frame_name))
-- end

-- function update()
--     if math.ceil(gGlobalSyncTable.frame) == 10 and timer == 0 then
--         -- Start the timer when frame 10 is reached for the first time
--         timer = 5 * 30 -- Assuming the update function is called 60 times per second
--     elseif timer > 0 then
--         -- Decrement the timer
--         timer = timer - 1
--     else
--         -- Update the frame as normal
--         gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.25
--     end
-- end

-- function hud_render()
--     -- if gNetworkPlayers[0].currLevelNum == LEVEL_BM then
--         if math.ceil(gGlobalSyncTable.frame) < 36 then
--             local screenH = djui_hud_get_screen_height()
--             local screenW = djui_hud_get_screen_width()
--             djui_hud_render_texture(frames[math.ceil(gGlobalSyncTable.frame)], 0, 0, screenW / 1024, screenH / 1024)
--         end
--     -- end
-- end

-- function so_retro()
--     gGlobalSyncTable.frame = 1
--     timer = 0 -- Reset the timer
--     return true
-- end

-- if network_is_server() then
--     hook_event(HOOK_UPDATE, update)
--     hook_chat_command("retro_gif", " ", so_retro)
-- end
-- hook_event(HOOK_ON_HUD_RENDER, hud_render)











-- Works well before trying to zoom

-- gGlobalSyncTable.frame = 1
-- local frames = {}
-- local timer = 0 -- Timer for the frame pause

-- -- Load 36 frames
-- for i = 1, 36 do
--     local frame_name = string.format("frame-%03d", i)
--     table.insert(frames, get_texture_info(frame_name))
-- end

-- function update()
--     if math.ceil(gGlobalSyncTable.frame) == 10 then
--         if timer == 0 then
--             -- Start the timer when frame 10 is reached for the first time
--             timer = 2 * 30 -- Assuming the update function is called 60 times per second
--         elseif timer > 0 then
--             -- Decrement the timer
--             timer = timer - 1
--             if timer == 0 then
--                 -- Increment frame to move past frame 10 once the timer is up
--                 gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.25
--             end
--         end
--     elseif timer <= 0 then
--         -- Update the frame as normal
--         gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.25
--         if math.ceil(gGlobalSyncTable.frame) > 36 then
--             -- Reset to the first frame after reaching the last frame
--             gGlobalSyncTable.frame = 1
--         end
--     end
-- end

-- function hud_render()
--     if math.ceil(gGlobalSyncTable.frame) <= 36 then
--         local screenH = djui_hud_get_screen_height()
--         local screenW = djui_hud_get_screen_width()
--         djui_hud_render_texture(frames[math.ceil(gGlobalSyncTable.frame)], 0, 0, screenW / 1024, screenH / 1024)
--     end
-- end

-- function so_retro()
--     gGlobalSyncTable.frame = 1
--     timer = 0 -- Reset the timer
--     return true
-- end

-- if network_is_server() then
--     hook_event(HOOK_UPDATE, update)
--     hook_chat_command("retro_gif", " ", so_retro)
-- end
-- hook_event(HOOK_ON_HUD_RENDER, hud_render)






-- Try to zoom, smooth but not centered and applied 3 times


-- gGlobalSyncTable.frame = 1
-- local frames = {}
-- local timer = 0 -- Timer for the frame pause
-- local zoomFactor = 1 -- Zoom factor for frame 10

-- -- Load 36 frames
-- for i = 1, 36 do
--     local frame_name = string.format("frame-%03d", i)
--     table.insert(frames, get_texture_info(frame_name))
-- end

-- function update()
--     if math.ceil(gGlobalSyncTable.frame) == 10 then
--         if timer == 0 then
--             -- Start the timer when frame 10 is reached for the first time
--             timer = 2 * 30 -- Assuming the update function is called 60 times per second
--             zoomFactor = 1 -- Reset zoom factor at the start
--         elseif timer > 0 then
--             -- Decrement the timer
--             timer = timer - 1
--             -- Update zoom factor during the 5-second display
--             zoomFactor = 1 + (1 - timer / (2 * 30))
--             if timer == 0 then
--                 -- Increment frame to move past frame 10 once the timer is up
--                 gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.25
--                 zoomFactor = 1 -- Reset zoom factor after frame 10
--             end
--         end
--     elseif timer <= 0 then
--         -- Update the frame as normal
--         gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.25
--         if math.ceil(gGlobalSyncTable.frame) > 36 then
--             -- Reset to the first frame after reaching the last frame
--             gGlobalSyncTable.frame = 1
--         end
--     end
-- end

-- function hud_render()
--     if math.ceil(gGlobalSyncTable.frame) <= 36 then
--         local screenH = djui_hud_get_screen_height()
--         local screenW = djui_hud_get_screen_width()
--         local scaleX, scaleY = screenW / 1024 * zoomFactor, screenH / 1024 * zoomFactor
--         djui_hud_render_texture(frames[math.ceil(gGlobalSyncTable.frame)], 0, 0, scaleX, scaleY)
--     end
-- end

-- function so_retro()
--     gGlobalSyncTable.frame = 1
--     timer = 0 -- Reset the timer
--     zoomFactor = 1 -- Reset zoom factor
--     return true
-- end

-- if network_is_server() then
--     hook_event(HOOK_UPDATE, update)
--     hook_chat_command("retro_gif", " ", so_retro)
-- end
-- hook_event(HOOK_ON_HUD_RENDER, hud_render)





--Try to zoom center and smooth : 


-- gGlobalSyncTable.frame = 1
-- local frames = {}
-- local timer = 0 -- Timer for the frame pause
-- local zoomFactor = 1 -- Zoom factor for frame 10

-- -- Load 36 frames
-- for i = 1, 36 do
--     local frame_name = string.format("frame-%03d", i)
--     table.insert(frames, get_texture_info(frame_name))
-- end

-- function update()
--     if math.ceil(gGlobalSyncTable.frame) == 10 then
--         if timer == 0 then
--             -- Start the timer when frame 10 is reached for the first time
--             timer = 2 * 30 -- Assuming the update function is called 60 times per second
--             zoomFactor = 1
--         elseif timer > 0 then
--             -- Decrement the timer
--             timer = timer - 1
--             -- Smoothly increase zoom factor during the 5-second display
--             zoomFactor = 1 + (1 - timer / (2 * 30)) * 0.5 -- Change the multiplier for a more or less pronounced zoom
--             if timer == 0 then
--                 -- Increment frame to move past frame 10 once the timer is up
--                 gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.5
--                 zoomFactor = 1 -- Reset zoom factor after frame 10
--             end
--         end
--     elseif timer <= 0 then
--         -- Update the frame as normal
--         gGlobalSyncTable.frame = gGlobalSyncTable.frame + 0.5
--         if math.ceil(gGlobalSyncTable.frame) > 36 then
--             -- Reset to the first frame after reaching the last frame
--             gGlobalSyncTable.frame = 1
--         end
--     end
-- end

-- function hud_render()
--     if math.ceil(gGlobalSyncTable.frame) <= 36 then
--         local screenH = djui_hud_get_screen_height()
--         local screenW = djui_hud_get_screen_width()
--         local frameIndex = math.ceil(gGlobalSyncTable.frame)
--         local scaleX, scaleY = screenW / 1024 * zoomFactor, screenH / 1024 * zoomFactor
--         local offsetX, offsetY = (screenW - screenW * zoomFactor) / 2, (screenH - screenH * zoomFactor) / 2
--         djui_hud_render_texture(frames[frameIndex], offsetX, offsetY, scaleX, scaleY)
--     end
-- end

-- function so_retro()
--     gGlobalSyncTable.frame = 1
--     timer = 0 -- Reset the timer
--     zoomFactor = 1 -- Reset zoom factor
--     return true
-- end

-- if network_is_server() then
--     hook_event(HOOK_UPDATE, update)
--     hook_chat_command("retro_gif", " ", so_retro)
-- end
-- hook_event(HOOK_ON_HUD_RENDER, hud_render)


--Again zoom 

gGlobalSyncTable.frame = 1
local frames = {}
local timer = 0 -- Timer for the frame pause
local zoomFactor = 1 -- Zoom factor for frame 10
local zoomApplied = false -- Flag to indicate if zoom has been applied

-- Load 36 frames
for i = 1, 36 do
    local frame_name = string.format("frame-%03d", i)
    table.insert(frames, get_texture_info(frame_name))
end

function update()
    local frameIncrement = 0.5 -- Adjust as needed for frame display duration

    if math.ceil(gGlobalSyncTable.frame) == 10 then
        if not zoomApplied then
            -- Start the timer when frame 10 is reached for the first time
            timer = 5 * 60 -- 5 seconds at 60 updates per second
            zoomFactor = 1
            zoomApplied = true -- Mark zoom as applied
        end

        if timer > 0 then
            -- Decrement the timer and update zoom factor
            timer = timer - 1
            zoomFactor = 1 + (1 - timer / (5 * 60)) * 0.5
        end

        if timer == 0 then
            -- Ensure the frame moves past 10 once the timer is up
            gGlobalSyncTable.frame = gGlobalSyncTable.frame + frameIncrement
            zoomFactor = 1 -- Reset zoom factor
            zoomApplied = false -- Reset the zoom applied flag
        end
    else
        -- Update the frame as normal
        gGlobalSyncTable.frame = gGlobalSyncTable.frame + frameIncrement
    end

    -- Reset to the first frame after reaching the last frame
    if math.ceil(gGlobalSyncTable.frame) > 36 then
        gGlobalSyncTable.frame = 1
    end
end

function hud_render()
    if math.ceil(gGlobalSyncTable.frame) <= 36 then
        local screenH = djui_hud_get_screen_height()
        local screenW = djui_hud_get_screen_width()
        local frameIndex = math.ceil(gGlobalSyncTable.frame)
        local scaleX, scaleY = screenW / 1024 * zoomFactor, screenH / 1024 * zoomFactor
        local offsetX, offsetY = (screenW - screenW * zoomFactor) / 2, (screenH - screenH * zoomFactor) / 2
        djui_hud_render_texture(frames[frameIndex], offsetX, offsetY, scaleX, scaleY)
    end
end

function so_retro()
    gGlobalSyncTable.frame = 1
    timer = 0 -- Reset the timer
    zoomFactor = 1 -- Reset zoom factor
    zoomApplied = false -- Reset the zoom applied flag
    return true
end

if network_is_server() then
    hook_event(HOOK_UPDATE, update)
    hook_chat_command("retro_gif", " ", so_retro)
end
hook_event(HOOK_ON_HUD_RENDER, hud_render)
