-- Game Loop

-- Functions
local set_lighting_dir = set_lighting_dir
local set_lighting_color = set_lighting_color
local spawn_non_sync_object = spawn_non_sync_object
local vec3f_normalize = vec3f_normalize
local vec3f_set = vec3f_set
local vec3f_dist = vec3f_dist
local tonumber = tonumber

local djui_hud_render_texture = djui_hud_render_texture
local djui_hud_set_color = djui_hud_set_color

gServerSettings.enablePlayerList = false

ROUND_STATE_MENU = 0
ROUND_STATE_START = 1
ROUND_STATE_RACE = 2
ROUND_STATE_FINISHED = 3

gGlobalSyncTable.roundState = ROUND_STATE_MENU

gGlobalSyncTable.level = LEVEL_CASTLE_GROUNDS
gGlobalSyncTable.startTimer = 5*30
gGlobalSyncTable.endTimer = -10*30

MENU_CHARACTER = 0
MENU_KART = 1
MENU_WAIT = 2

menu = MENU_CHARACTER

init = true
local function mario_lighting_direction(r, g, b, x, y, z)
    local mPos = gLakituState.focus
    local lakPos = gLakituState.pos

    local mPosX = mPos.x
    local mPosY = mPos.y
    local mPosZ = mPos.z
    
    local lakPosX = lakPos.x
    local lakPosY = lakPos.y
    local lakPosZ = lakPos.z

    local camDir = {x = mPosX-lakPosX,
                    y = mPosY-lakPosY,
                    z = mPosZ-lakPosZ}

    lightingDirX = x
    lightingDirY = y
    lightingDirZ = z
    
    camDir.x = camDir.x * (lightingDirX)
    camDir.y = camDir.y * (lightingDirY)
    camDir.z = camDir.z * (lightingDirZ)--, camDir, lightingDir)

    vec3f_normalize(camDir)

    set_lighting_dir(0, camDir.x)
    set_lighting_dir(1, camDir.y)
    set_lighting_dir(2, camDir.z)
    set_lighting_color(0, r)
    set_lighting_color(1, g)
    set_lighting_color(2, b)
end
hard = false
function get_checkpoint(i)
    local currCheck
    if i >= #checkpointTbl then
        currCheck = checkpointTbl[1]
    else
        currCheck = checkpointTbl[i]
    end
    return currCheck
end

function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

--[[
SURFACE INFO

SURFACE_HARD: Finish Line
SURFACE_HARD_NOT_SLIPPERY: Glider Panel


]]

local function cross_finish_line(m)
    local e = gStateExtras[m.playerIndex]
    local s = gPlayerSyncTable[m.playerIndex]
    if m.floor.type == SURFACE_HARD then
        if not hard then
            if e.checkpoint < #checkpointTbl-5 then
                hard = true
            else
                e.checkpoint = 1
                s.lap = s.lap + 1
                hard = true
            end
        end
    else
        hard = false
    end
end

local function calculate_race_score(m)
    local e = gStateExtras[m.playerIndex]
    local currCheck = get_checkpoint(e.checkpoint)--checkpointTbl[e.checkpoint]
    local nextCheck = get_checkpoint(e.checkpoint+1)--checkpointTbl[e.checkpoint+1]
    local maxCheckDist = vec3f_dist({x = currCheck[1], y = currCheck[2], z = currCheck[3]}, {x = nextCheck[1], y = nextCheck[2], z = nextCheck[3]})

    local dist = vec3f_dist(m.pos, {x = nextCheck[1], y = nextCheck[2], z = nextCheck[3]})
    local dScore = clamp(1-(dist/maxCheckDist), 0, 1)

    gPlayerSyncTable[0].score = gPlayerSyncTable[0].lap*10000+e.checkpoint*100+dScore - gNetworkPlayers[m.playerIndex].globalIndex
end
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '}\n '
    else
       return tostring(o)
    end
 end

gRankings = {}
function race_clear_rankings()
    for k,v in pairs(gRankings) do gRankings[k]=nil end
end
function active_player(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex == 0 then
        return true
    end
    if not np.connected then
        return false
    end
    return is_player_active(m)
end

local function calculate_race_ranks()
    local rankTbl = {
        {score = -1, playerIndex = -1}
    }
    for i=0, MAX_PLAYERS-1 do
        rankTbl[i+1] = {score = gPlayerSyncTable[i].score, playerIndex = i}
    end
    table.sort(rankTbl, function (v1, v2) return v1.score > v2.score end)

    race_clear_rankings()

    gRankings = rankTbl
end

local function menu_movement(m)
    if not is_in_menu() then
        return
    end
    if menu == MENU_CHARACTER then
        if (m.controller.buttonPressed & L_JPAD) ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuTbl[1].x = menuTbl[1].x - 1
            if menuTbl[1].x < 0 then menuTbl[1].x = menuTbl[1].mX end
        end
        if (m.controller.buttonPressed & R_JPAD) ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuTbl[1].x = menuTbl[1].x + 1
            if menuTbl[1].x > menuTbl[1].mX then menuTbl[1].x = 0 end
        end
        if (m.controller.buttonPressed & U_JPAD) ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuTbl[1].y = menuTbl[1].y - 1
            if menuTbl[1].y < 0 then menuTbl[1].y = menuTbl[1].mY end
        end
        if (m.controller.buttonPressed & D_JPAD) ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuTbl[1].y = menuTbl[1].y + 1
            if menuTbl[1].y > menuTbl[1].mY then menuTbl[1].y = 0 end
        end
    elseif menu == MENU_KART then
        if (m.controller.buttonPressed & L_JPAD) ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuTbl[3].x = 0
        end
        if (m.controller.buttonPressed & R_JPAD) ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuTbl[3].x = 1
        end

        if m.controller.buttonPressed & U_JPAD ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            if menuTbl[3].x == 0 then
                if menuTbl[3].k > 0 then
                    menuTbl[3].k = menuTbl[3].k - 1
                end
            end
            if menuTbl[3].x == 1 then
                if menuTbl[3].w > 0 then
                    menuTbl[3].w = menuTbl[3].w - 1
                end
            end
        end
        if m.controller.buttonPressed & D_JPAD ~= 0 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            if menuTbl[3].x == 0 then
                if menuTbl[3].k < KART_MAX-1 then
                    menuTbl[3].k = menuTbl[3].k + 1
                end
            end
            if menuTbl[3].x == 1 then
                if menuTbl[3].w < WHEEL_MAX-1 then
                    menuTbl[3].w = menuTbl[3].w + 1
                end
            end
        end
        gPlayerSyncTable[0].kart = menuTbl[3].k
        gPlayerSyncTable[0].wheel = menuTbl[3].w
    elseif menu == MENU_WAIT then
        if network_is_server() then
            if (m.controller.buttonPressed & U_JPAD) ~= 0 then
                play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
                menuTbl[4].y = menuTbl[4].y - 1
                if menuTbl[4].y < 0 then menuTbl[4].y = menuTbl[4].mY end
            end
            if (m.controller.buttonPressed & D_JPAD) ~= 0 then
                play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
                menuTbl[4].y = menuTbl[4].y + 1
                if menuTbl[4].y > menuTbl[4].mY then menuTbl[4].y = 0 end
            end
    
            if (m.controller.buttonPressed & R_JPAD) ~= 0 then
                play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, m.marioObj.header.gfx.cameraToObject)
                if menuTbl[4].y == 0 then
                    menuTbl[4].spd = menuTbl[4].spd + 1
                else
                    menuTbl[4].items = menuTbl[4].items + 1
                end
            end
            if (m.controller.buttonPressed & L_JPAD) ~= 0 then
                play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, m.marioObj.header.gfx.cameraToObject)
                if menuTbl[4].y == 0 then
                    menuTbl[4].spd = menuTbl[4].spd - 1
                else
                    menuTbl[4].items = menuTbl[4].items - 1
                end
            end
            menuTbl[4].spd = clamp(menuTbl[4].spd, SPD_50CC, SPD_200CC)
            menuTbl[4].items = clamp(menuTbl[4].items, ITEMS_DISABLED, ITEMS_FRANTIC)
            gGlobalSyncTable.speedSetting = menuTbl[4].spd
            gGlobalSyncTable.itemSetting = menuTbl[4].items
        end
    end

    if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
        if menu == MENU_CHARACTER then
            menu = MENU_KART
        elseif menu == MENU_KART then
            menu = MENU_WAIT
        elseif menu == MENU_WAIT and menuTbl[4].y == menuTbl[4].mY then
            if network_is_server() then
                race_start()--gGlobalSyncTable.level = LEVEL_BOB--warp_to_level(LEVEL_BOB, 1, 1)
            end
        end
    end
    if (m.controller.buttonPressed & B_BUTTON) ~= 0 then
        if menu == MENU_WAIT then
            menu = MENU_KART
        elseif menu == MENU_KART then
            menu = MENU_CHARACTER
        end
    end
end

function use_item()
    local m = gMarioStates[0]
    local s = gPlayerSyncTable[m.playerIndex]
    local e = gStateExtras[0]
    if (m.controller.buttonPressed & R_TRIG) ~= 0 then
        local backThrow = 0
        if (m.controller.stickY < 0) then
            backThrow = 0x8000
        end
        if s.item[1] ~= ITEM_NONE then
            charTbl[s.character].char_sound_item(m)
            if (s.item[1] == ITEM_BULLET_BILL) then
                set_mario_action(m, ACT_KART_BULLET, 0)
                s.item[1] = ITEM_NONE
            elseif (s.item[1] == ITEM_GREEN_SHELL) then
                s.item[1] = ITEM_NONE
                spawn_sync_object(id_bhvItemGround, E_MODEL_GREEN_SHELL, m.pos.x+sins(m.faceAngle.y+backThrow)*200, m.pos.y, m.pos.z+coss(m.faceAngle.y+backThrow)*200, function(obj) obj.oFaceAngleYaw = m.faceAngle.y+backThrow obj.oForwardVel = math.max(e.speed + 40, 100) obj.oHealth = 10 end)
            elseif (s.item[1] == ITEM_DOUBLE_GREEN_SHELL) then
                s.item[1] = ITEM_GREEN_SHELL
                spawn_sync_object(id_bhvItemGround, E_MODEL_GREEN_SHELL, m.pos.x+sins(m.faceAngle.y+backThrow)*200, m.pos.y, m.pos.z+coss(m.faceAngle.y+backThrow)*200, function(obj) obj.oFaceAngleYaw = m.faceAngle.y+backThrow obj.oForwardVel = math.max(e.speed + 40, 100) obj.oHealth = 10 end)
            elseif (s.item[1] == ITEM_TRIPLE_GREEN_SHELL) then
                s.item[1] = ITEM_DOUBLE_GREEN_SHELL
                spawn_sync_object(id_bhvItemGround, E_MODEL_GREEN_SHELL, m.pos.x+sins(m.faceAngle.y+backThrow)*200, m.pos.y, m.pos.z+coss(m.faceAngle.y+backThrow)*200, function(obj) obj.oFaceAngleYaw = m.faceAngle.y+backThrow obj.oForwardVel = math.max(e.speed + 40, 100) obj.oHealth = 10 end)
            elseif (s.item[1] == ITEM_BLUE_SHELL) then
                s.item[1] = ITEM_NONE
                spawn_sync_object(id_bhvItemGround, E_MODEL_BLUE_SHELL, m.pos.x+sins(m.faceAngle.y+backThrow)*200, m.pos.y, m.pos.z+coss(m.faceAngle.y+backThrow)*200, function(obj) obj.oFaceAngleYaw = m.faceAngle.y+backThrow obj.oForwardVel = 365 obj.oAction = e.checkpoint+1 obj.oHealth = -6 end)
            elseif (s.item[1] == ITEM_RED_SHELL) then
                s.item[1] = ITEM_NONE
                spawn_sync_object(id_bhvItemGround, E_MODEL_RED_SHELL, m.pos.x+sins(m.faceAngle.y+backThrow)*200, m.pos.y, m.pos.z+coss(m.faceAngle.y+backThrow)*200, function(obj) obj.oFaceAngleYaw = m.faceAngle.y+backThrow obj.oForwardVel = 365 obj.oAction = e.checkpoint+1 obj.oHealth = -5 end)
            elseif (s.item[1] == ITEM_DOUBLE_RED_SHELL) then
                s.item[1] = ITEM_RED_SHELL
                spawn_sync_object(id_bhvItemGround, E_MODEL_RED_SHELL, m.pos.x+sins(m.faceAngle.y+backThrow)*200, m.pos.y, m.pos.z+coss(m.faceAngle.y+backThrow)*200, function(obj) obj.oFaceAngleYaw = m.faceAngle.y+backThrow obj.oForwardVel = 365 obj.oAction = e.checkpoint+1 obj.oHealth = -5 end)
            elseif (s.item[1] == ITEM_TRIPLE_RED_SHELL) then
                s.item[1] = ITEM_DOUBLE_RED_SHELL
                spawn_sync_object(id_bhvItemGround, E_MODEL_RED_SHELL, m.pos.x+sins(m.faceAngle.y+backThrow)*200, m.pos.y, m.pos.z+coss(m.faceAngle.y+backThrow)*200, function(obj) obj.oFaceAngleYaw = m.faceAngle.y+backThrow obj.oForwardVel = 365 obj.oAction = e.checkpoint+1 obj.oHealth = -5 end)
            elseif (s.item[1] == ITEM_MUSHROOM) then
                s.item[1] = ITEM_NONE
                e.boostState = BOOST_ITEM
                e.boostTimer = 45
                e.boostSpd = 80
            elseif (s.item[1] == ITEM_DOUBLE_MUSHROOM) then
                s.item[1] = ITEM_MUSHROOM
                e.boostState = BOOST_ITEM
                e.boostTimer = 45
                e.boostSpd = 80
            elseif (s.item[1] == ITEM_TRIPLE_MUSHROOM) then
                s.item[1] = ITEM_DOUBLE_MUSHROOM
                e.boostState = BOOST_ITEM
                e.boostTimer = 45
                e.boostSpd = 80
            end
    
            
            --s.item[1] = ITEM_NONE
            
        end
    end
end
players = 1

local function finished_race()
    for i=0, players-1 do
        local s = gPlayerSyncTable[i]
        if s.lap > 3 then
            return true
        end
    end
    return false
end

local function mario_update(m)
    local e = gStateExtras[m.playerIndex]
    local s = gPlayerSyncTable[m.playerIndex]
    local wheel = s.wheel
    local turnSpd = 12
    m.marioObj.hookRender = 1

    --[[if (gNetworkPlayers[0].currLevelNum ~= gGlobalSyncTable.level) then
        warp_to_level(gGlobalSyncTable.level, 1, 1)
    end]]

    if m.action == ACT_KART_GLIDE then
        turnSpd = 8
    end
    if e.drifting then
        turnSpd = 10
    end
    e.turnTargetX = approach_f32(e.turnTargetX, m.controller.stickX, turnSpd, turnSpd)
    e.turnTargetY = approach_f32(e.turnTargetY, m.controller.stickY, turnSpd, turnSpd)
    --if (gNetworkPlayers[0].currLevelNum ~= MENU)
    if m.action ~= ACT_KART_START and init then
        m.pos.y = m.floorHeight
        set_mario_action(m, ACT_KART_START, 0)
        init = false
    end
    if is_in_menu() then
        players = MAX_PLAYERS--network_player_connected_count()
        m.marioObj.hitboxRadius = 0
    else
        m.marioObj.hitboxRadius = 80+e.speed*0.1
        
    end
    gNetworkPlayers[m.playerIndex].overrideModelIndex = charTbl[s.character].ct

    e.wobble = approach_f32(e.wobble, 0, 0x50, 0x50)
    --e.targetYaw = e.targetYaw + 0x1000*sins(get_network_area_timer())
    if m.playerIndex == 0 then
        if s.spectating == 0 then
            s.score = -1
        end
        --[[if gGlobalSyncTable.endTimer <= 0 and not gGlobalSyncTable.endTimer == -10*30 and not is_in_menu() then
            s.lap = 4
        end
        if is_in_menu() then
            s.lap = 1
        end]]
        
        
        camera_freeze()
        -- race functions
        if not is_in_menu() then
            if network_is_server() then
                gGlobalSyncTable.startTimer = gGlobalSyncTable.startTimer - 1
            end
            if s.lap <= 3 then
                cross_finish_line(m)
    
                calculate_race_score(m)
    
                calculate_race_ranks()
            else
                s.score = s.score + 1
            end

            use_item()
            local dist = cameraRot*0.05
            cameraRot = cameraRot * 0.98
            if s.spectating then
                local leadM = gMarioStates[gRankings[1].playerIndex]
                vec3f_set(gLakituState.pos, leadM.pos.x*0.8, leadM.pos.y+2000, leadM.pos.z*0.8)
                vec3f_set(gLakituState.focus, leadM.pos.x, leadM.pos.y, leadM.pos.z)
            else
                vec3f_set(gLakituState.pos, m.pos.x-(900-dist+e.speed*2)*sins(m.faceAngle.y), m.pos.y+300-m.vel.y, m.pos.z-(900-dist+e.speed*2)*coss(m.faceAngle.y))
                vec3f_set(gLakituState.focus, m.pos.x+200*sins(m.faceAngle.y)-m.vel.x, m.pos.y+100+m.vel.y, m.pos.z+200*coss(m.faceAngle.y)-m.vel.z)
            end
        else
            vec3f_set(gLakituState.pos, -450, 500, 900)
            vec3f_set(gLakituState.focus, -350, m.pos.y+100, m.pos.z)
            set_mario_action(m, ACT_KART_MENU, 0)
            local mX = menuTbl[1].x+1
            local mY = menuTbl[1].y+1
            s.character = menuTbl[2][mY][mX]
        end
    else
        if is_in_menu() then
            cur_obj_hide()
        end
    end
    obj_set_model_extended(m.marioObj, charTbl[s.character].model)
    --m.marioObj.header.gfx.pos.y = m.pos.y + 20 + wheelTbl[wheel].yOffset + charTbl[s.character].yOffset + kartTbl[s.kart].yOffset
end

kartActTbl = {
    [ACT_KART_AIR] = true,
    [ACT_KART_GROUND] = true,
    [ACT_KART_BULLET] = true,
    [ACT_KART_GLIDE] = true,
    [ACT_KART_MENU] = true,
    [ACT_KART_SPIN] = true,
    [ACT_KART_START] = true,
    [ACT_KART_SPECTATE] = true,
}

local function before_set_mario_action(m, action)
    if not kartActTbl[action] then
        return m.action
    end 
end

function on_object_render(obj)
    if get_id_from_behavior(obj.behavior) ~= id_bhvMario then
        return
    end

    for i=0, players-1 do
        local m = gMarioStates[i]
        if obj == m.marioObj then
            local s = gPlayerSyncTable[m.playerIndex]
            local wheel = s.wheel
            m.marioObj.header.gfx.pos.y = m.pos.y + 20 + wheelTbl[wheel].yOffset + charTbl[s.character].yOffset + kartTbl[s.kart].yOffset
        end
    end

    --djui_chat_message_create("owo")
end

local function on_interact(m, obj, intee)
    if is_in_menu() then
        return
    end
    local s = gPlayerSyncTable[m.playerIndex]
    if intee == INTERACT_PLAYER then
        for i=0, players-1 do
            if m.playerIndex == 0 and gStateExtras[0].wobble == 0 then-- == gMarioStates[0] then
                if obj == gMarioStates[i].marioObj then
                    play_sound(SOUND_ACTION_BONK, m.marioObj.header.gfx.cameraToObject)
                    local ang = obj_angle_to_object(m.marioObj, obj)
                    local bounceSpd = -(16+math.abs(gStateExtras[i].speed*0.5))
                    --djui_chat_message_create(tostring(bounceSpd))
                    gStateExtras[i].wobble = 0x1000
                    gStateExtras[0].wobble = 0x1000
                    m.vel.x = m.vel.x + sins(ang)*bounceSpd
                    m.vel.z = m.vel.z + coss(ang)*bounceSpd

                    m.invincTimer = 5
                end
            end
        end
    end
end

local function on_level_init()
    init = true
    cameraRot = 64000
    menu = MENU_CHARACTER
    volA = 1
    volB = 0
    volC = 0

    for i = 0, MAX_PLAYERS-1 do
        local e = gStateExtras[i]
    
        e.drifting = false
        e.driftDir = 0
        e.speed = 0
        e.targetVelX = 0
        e.targetVelZ = 0
        e.driftTimer = 0
        e.driftPower = 0
        e.boostSpd = 0
        e.boostTimer = 0

        e.turnTargetX = 0
        e.turnTargetY = 0

        e.angleX = 0
        e.checkpoint = 1

        e.boostState = BOOST_NONE

        e.glideMomentum = 0

        e.targetYaw = 0

        e.wobble = 0
    end

    if network_is_server() then
        reset_game()
    end
    -- spawn skybox
    local skyboxModel = E_MODEL_SKYBOX_MENU
    mario_lighting_direction(220, 230, 255, 1, -1, -1)
    if not is_in_menu() then
        skyboxModel = E_MODEL_SKYBOX_CIRCUIT
        mario_lighting_direction(255, 253, 132, -1, 1, 1)
    end
    spawn_non_sync_object(id_bhvSkyBox, skyboxModel, 0, 0, 0, function(obj) end)
    -- spawn all of the karts
    for i = 0, (players-1) do
        local m = gMarioStates[i]
        -- Karts

        spawn_non_sync_object(
            id_bhvKart,
            E_MODEL_B_DASHER,
            0, 0, 0,
            function (obj) obj.heldByPlayerIndex = i end
        )

        -- Item Displays

        for o=1, 3 do
            spawn_non_sync_object(
                id_bhvItem,
                E_MODEL_SPINY,
                0, 0, 0,
                function (obj) obj.heldByPlayerIndex = i obj.oHealth = o end
            )
        end
        
        -- Left
        spawn_non_sync_object(id_bhvMiniTurbo, E_MODEL_MINI_TURBO, m.pos.x, m.pos.y, m.pos.z, function (obj) obj.oAction = 1 obj.heldByPlayerIndex = i end)
        -- Right
        spawn_non_sync_object(id_bhvMiniTurbo, E_MODEL_MINI_TURBO, m.pos.x, m.pos.y, m.pos.z, function (obj) obj.oAction = -1 obj.heldByPlayerIndex = i end)

        -- Wheels
        spawn_non_sync_object(id_bhvWheel, E_MODEL_STANDARD_WHEEL, m.pos.x, m.pos.y, m.pos.z, function (obj) obj.oAction = 1 obj.oHealth = i end)
        spawn_non_sync_object(id_bhvWheel, E_MODEL_STANDARD_WHEEL, m.pos.x, m.pos.y, m.pos.z, function (obj) obj.oAction = -1 obj.oHealth = i end)
        spawn_non_sync_object(id_bhvWheel, E_MODEL_STANDARD_WHEEL, m.pos.x, m.pos.y, m.pos.z, function (obj) obj.oAction = 2 obj.oHealth = i end)
        spawn_non_sync_object(id_bhvWheel, E_MODEL_STANDARD_WHEEL, m.pos.x, m.pos.y, m.pos.z, function (obj) obj.oAction = -2 obj.oHealth = i end)
        
        -- Unused but functional, removed from current release due to lack of gliding sections.
        --spawn_non_sync_object(id_bhvGlider, E_MODEL_STANDARD_GLIDER, m.pos.x, m.pos.y, m.pos.z, function (obj) obj.oHealth = i end)

        if is_in_menu() then
            return
        end
    end
end

local function command_kart_parts(msg)
    if tonumber(msg) ~= nil then
        msg = clamp(tonumber(msg), 0, #kartTbl)
        gPlayerSyncTable[0].kart = msg
        return true
    end
    return 0
end

local function command_wheel_parts(msg)
    if tonumber(msg) ~= nil then
        msg = clamp(tonumber(msg), 0, #wheelTbl)
        gPlayerSyncTable[0].wheel = msg
        return true
    end
    return 0
end

local function command_character(msg)
    if tonumber(msg) ~= nil then
        msg = clamp(tonumber(msg), 0, #charTbl-1)
        gPlayerSyncTable[0].character = msg
        return true
    end
    return 0
end

local function render_leaderboard()
    djui_hud_set_font(FONT_NORMAL)
    local xOffset = 0
    local yOffset = 0
    if gGlobalSyncTable.endTimer > 0 then
        djui_hud_print_text("WAITING TO FINISH...", djui_hud_get_screen_width()*0.5-djui_hud_measure_text("WAITING TO FINISH...")*0.5, 16, 0.5)
    end
    for i=1, #gRankings do
        if i > network_player_connected_count() then
            return
        end
        local np = gNetworkPlayers[gRankings[i].playerIndex]
        local val = 150-(i%2)*50
        local s = gPlayerSyncTable[np.localIndex]
        
        local name = np.name
        local scrStr = s.points
        if s.spectating then
            --name = ""
            --scrString = -1
            --return
        end
        local scrStrW = djui_hud_measure_text(tostring(scrStr))*0.5
        djui_hud_set_color(val, val, val, 100)
        if gRankings[i].playerIndex == 0 then
            djui_hud_set_color(255, 93, 28, 200)
        end
        yOffset = yOffset + 18
        djui_hud_render_rect(46+xOffset, 16+yOffset,(djui_hud_get_screen_width()-92)*0.5,18)
        djui_hud_set_color(255, 255, 255, 255)
        if s.spectating then
            djui_hud_set_color(180, 180, 180, 255)
        end
        djui_hud_print_text(string.format("%d) %s", i, name), 48+xOffset, 16+yOffset, 0.5)
        djui_hud_print_text(string.format("%d", scrStr), 40+xOffset+(djui_hud_get_screen_width()-92)*0.5-scrStrW, 16+yOffset, 0.5)
        if i == 8 then
            xOffset = (djui_hud_get_screen_width()-92)*0.5
            yOffset = 0
        end
    end
end

local function render_menu_character(s)
    local boxY = 80
    local windowH = djui_hud_get_screen_width()
    local windowV = djui_hud_get_screen_height()
        for xp=0, 3 do
            for yp=0, 1 do
                djui_hud_render_texture(texCharBox, 24+xp*50,boxY+yp*50, 1, 1)
                djui_hud_render_texture_tile(texCharacterIcons, 26+xp*50,boxY+4+yp*50, 1, 1, xp*64, yp*64,42, 42)
            end
        end
        local np = gNetworkPlayers[0]
        local color = { r = 255, g = 255, b = 255 }
        network_player_palette_to_color(np, CAP, color)
        djui_hud_set_color(color.r, color.g, color.b, 255)

        djui_hud_render_texture(texCharSelect, 22+menuTbl[1].x*50, boxY-2+menuTbl[1].y*50, 1, 1)

        local charPosX = 12
        local charName = string.lower(charTbl[s.character].name)
        local messageLength = string.len(charName)
        local xOffset = 0
        for i in string.gmatch(charName, "i") do
            xOffset = xOffset+2
            
        end 
        djui_hud_set_color(50, 20, 20, 255)
        render_text("select a character", 0, charPosX+2, 18)
        for i=0, 3 do
            local x = coss(i*0x4000)
            local y = sins(i*0x4000)
            djui_hud_set_color(150, 80, 80, 255)
            render_text("select a character", 0, charPosX+math.ceil(x), 16+math.ceil(y))
            
            render_text(charName, 0, windowH-((messageLength*0.5)*8)-96+xOffset-44+math.ceil(x), windowV-64+math.ceil(y))
        end

        djui_hud_set_color(255, 255, 255, 255)
        render_text("select a character", 0, charPosX, 16)
        render_text(charName, 0, windowH-((messageLength*0.5)*8)-96+xOffset-44, windowV-64)
end

local function render_menu_kart(s)
    local windowH = djui_hud_get_screen_width()
    local windowV = djui_hud_get_screen_height()

    partTbl = kartTbl[menuTbl[3].k]
    if menuTbl[3].x == 1 then
        partTbl = wheelTbl[menuTbl[3].w]
    end
    local partName = string.lower(partTbl.name)
    local messageLength = string.len(partName)
    local xOffset = 0
    for i in string.gmatch(partName, "i") do
        xOffset = xOffset+2
    end 

    djui_hud_set_color(50, 20, 20, 255)
    render_text("select a kart", 0, 12+2, 18)
    for i=0, 3 do
        local x = coss(i*0x4000)
        local y = sins(i*0x4000)
        djui_hud_set_color(150, 80, 80, 255)
        render_text("select a kart", 0, 12+math.ceil(x), 16+math.ceil(y))
        render_text(partName, 0, windowH-((messageLength*0.75)*8)-96+xOffset-44+math.ceil(x), windowV-64+math.ceil(y))
    end

    djui_hud_set_color(255, 255, 255, 255)
    render_text("select a kart", 0, 12, 16)
    render_text(partName, 0, windowH-((messageLength*0.75)*8)-96+xOffset-44, windowV-64)
    for i = -1, 1 do
        local kartCol = 255
        local wheelCol = 100
        if menuTbl[3].x == 1 then
            kartCol = 100
            wheelCol = 255
        end
        djui_hud_set_color(kartCol, kartCol, kartCol, 255)
        if i ~= 0 then
            djui_hud_set_color(kartCol, kartCol, kartCol, 128)
        end
        local kartNum = menuTbl[3].k+i
        local wheelNum = menuTbl[3].w+i
        local column = kartNum%4
        local row = math.floor(kartNum/4)
        djui_hud_render_texture_tile(texVehicleIcons, 48, (60*i)-16+windowV*0.5, 1, 1, column*64, row*64, 64, 64)

        local column = wheelNum%4
        local row = math.floor(wheelNum/4)+2

        djui_hud_set_color(wheelCol, wheelCol, wheelCol, 255)
        if i ~= 0 then
            djui_hud_set_color(wheelCol, wheelCol, wheelCol, 128)
        end
        djui_hud_render_texture_tile(texVehicleIcons, 48+66, (60*i)-16+windowV*0.5, 1, 1, column*64, row*64, 64, 64)
    end
    render_kart_stats(48+windowH*0.5, 32)
end

local function render_menu_wait(s)
    local yOffset = 0
    for i=1, 3 do
        local val = 150-(i%2)*50
        djui_hud_set_color(val, val, val, 100)
        if menuTbl[4].y+1 == i and network_is_server() then
            djui_hud_set_color(255, 93, 28, 200)
        end
        yOffset = yOffset + 18
        djui_hud_render_rect(46, 16+yOffset,(djui_hud_get_screen_width()-92)*0.5,18)
    end
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(string.format("SPEED: %s", speedStringTbl[gGlobalSyncTable.speedSetting]), 48, 16+18, 0.5)
    djui_hud_print_text(string.format("ITEMS: %s", itemStringTbl[gGlobalSyncTable.itemSetting]), 48, 16+36, 0.5)
    djui_hud_print_text("START RACE", 96, 16+54, 0.5)
end

local function on_hud_render()
    local s = gPlayerSyncTable[0]
    hud_hide()
    local lap = s.lap
    djui_hud_set_resolution(RESOLUTION_N64)
    local windowH = djui_hud_get_screen_width()
    local windowV = djui_hud_get_screen_height()

    if gPlayerSyncTable[0].spectating then
        djui_hud_set_color(255, 255, 255, 255)
        local text = "SPECTATING"
        local textW = djui_hud_measure_text(text)
        djui_hud_print_text(text, windowH*0.5-textW*0.25, 16, 0.5)
        return
    end

    if lap > 3 or (gGlobalSyncTable.endTimer < 0 and gGlobalSyncTable.endTimer ~= -10*30) then
        render_leaderboard()
        return
    end

    if not is_in_menu() then
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_set_font(FONT_MENU)
        local text = math.ceil(gGlobalSyncTable.startTimer/30)
        local renderText = tostring(text)
        if text <= 0 then
            renderText = "GO!"
        end
        local textW = djui_hud_measure_text(renderText)
        if text > -1 and text <= 3 then
            djui_hud_print_text(renderText, windowH*0.5-textW*0.5, windowV*0.5-32, 1)
        end

        if gGlobalSyncTable.endTimer ~= -10*30 then
            text = math.ceil(gGlobalSyncTable.endTimer/30)
            renderText = tostring(text)
            textW = djui_hud_measure_text(renderText)
            djui_hud_print_text(renderText, windowH*0.5-textW*0.5, 32, 1)
        end

        djui_hud_set_color(50, 20, 20, 255)
        render_text(string.format("lap %d/3",lap), 0, windowH-122, 26)
        for i=0, 3 do
            local x = coss(i*0x4000)
            local y = sins(i*0x4000)
            djui_hud_set_color(150, 80, 80, 255)
            render_text(string.format("lap %d/3",lap), 0, windowH-124+math.ceil(x), 24+math.ceil(y))
        end

        djui_hud_set_color(255, 255, 255, 255)
        render_text(string.format("lap %d/3",lap), 0, windowH-124, 24)


        
        --djui_hud_render_texture(texItemWheel, 16,8,1,1)
        djui_hud_render_texture(texMapMarioCircuit3, windowH-128,windowV-128,1,1)
        
        for i = 0, MAX_PLAYERS-1 do
            local m = gMarioStates[MAX_PLAYERS-1-i]
            local size = 2
            if m.playerIndex == 0 then
                size = 3
            end
            
            local np = gNetworkPlayers[MAX_PLAYERS-1-i]
            if np.connected then
                local color = { r = 255, g = 255, b = 255 }
                network_player_palette_to_color(np, CAP, color)
                djui_hud_set_color(color.r, color.g, color.b, 255)
                local worldSize = 19400*2
                local relativeX = m.pos.x/worldSize
                local relativeY = m.pos.z/worldSize
                
                djui_hud_render_rect(windowH-64+math.floor(relativeX*128)-size, windowV-64+math.floor(relativeY*128)-size, size*2, size*2)
            end
        end

        djui_hud_set_color(255, 255, 255, 255)
        
        local rankNum = -1
        for i=1, #gRankings do
            if gRankings[i].playerIndex == 0 then
                rankNum = i
            end
            --djui_hud_print_text(tostring(gPlayerSyncTable[i-1].score), 32,16+16*i, 1)
        end
        dump(gRankings)
        djui_hud_set_font(FONT_MENU)
        
        if hudTbl[rankNum] ~= nil then
            hudTbl[rankNum].rend(8, windowV-64)
        end
    else
        if menu == MENU_CHARACTER then
            render_menu_character(s)
        elseif menu == MENU_KART then
            render_menu_kart(s)
        else
            render_menu_wait(s)
        end
    end
    if (gMarioStates[0].controller.buttonDown & X_BUTTON) ~= 0 and lap <= 3 then
        render_leaderboard()
    end
end

function on_death(m)
    if m.playerIndex ~= 0 then return end
    local e = gStateExtras[0]
    init_single_mario(m)
    camera_unfreeze()
    vec3f_set(m.pos, checkpointTbl[e.checkpoint][1], checkpointTbl[e.checkpoint][2]+100, checkpointTbl[e.checkpoint][3])
    set_mario_action(m, ACT_KART_AIR, 1)
    vec3f_set(gLakituState.pos, m.pos.x-(900+e.speed*2)*sins(m.faceAngle.y), m.marioBodyState.headPos.y+200, m.pos.z-(900+e.speed*2)*coss(m.faceAngle.y))
    vec3f_set(gLakituState.focus, m.pos.x+200*sins(m.faceAngle.y), m.marioBodyState.headPos.y, m.pos.z+200*coss(m.faceAngle.y))
    
    e.speed = 0
    e.targetVelX = 0
    e.targetVelZ = 0
    m.vel.x = 0
    m.vel.y = 0
    m.vel.z = 0
    return false

end

function on_player_connected(m)
    -- only run on server
    if not network_is_server() then
        return
    end

    local s = gPlayerSyncTable[m.playerIndex]

    s.spectating = true
    s.points = 0--gNetworkPlayers[m.playerIndex].globalIndex
end

function on_pause_exit(exitToCastle)
    return false
end

function race_start()
    gGlobalSyncTable.roundState = ROUND_STATE_START

    gGlobalSyncTable.level = LEVEL_BOB
    gGlobalSyncTable.startTimer = 7*30
    gGlobalSyncTable.endTimer = -10*30
end

local function menu_controller()
    menu_movement(gMarioStates[0])
end

local function race_controller()
    local np = gNetworkPlayers[0]
    local gotoLevel = gGlobalSyncTable.level
    if gGlobalSyncTable.roundState ~= ROUND_STATE_MENU then
        if np.currLevelNum ~= gotoLevel then
            warp_to_level(gotoLevel, 1, 1)
        end
    end

    if network_is_server() then
        if gGlobalSyncTable.endTimer == 0 then--(20*30)-1 then
            for i=0, MAX_PLAYERS-1 do
                local sS = gPlayerSyncTable[i]
                local rankNum = -1
                for o=1, #gRankings do
                    if gRankings[o].playerIndex == i then
                        rankNum = o
                    end
                end
                if not sS.spectating then
                    sS.points = sS.points + math.floor((16-rankNum)*1.35)
                end
            end
        end
        if is_in_menu() then
            for i=0, MAX_PLAYERS-1 do
                gPlayerSyncTable[i].lap = 1
                gPlayerSyncTable[i].score = 0
                for o = 1, 1 do
                    gPlayerSyncTable[i].item[o] = ITEM_NONE
                end
                if is_player_active(gMarioStates[i]) then
                    gPlayerSyncTable[i].spectating = false
                else
                    gPlayerSyncTable[i].spectating = true
                end
            end
        end
        if finished_race() then
            gGlobalSyncTable.roundState = ROUND_STATE_FINISHED
            if gGlobalSyncTable.endTimer == -10*30 then
                gGlobalSyncTable.endTimer = 15*30
            else
                gGlobalSyncTable.endTimer = gGlobalSyncTable.endTimer - 1
            end
            if gGlobalSyncTable.endTimer <= -5*30 and gGlobalSyncTable.level ~= LEVEL_CASTLE_GROUNDS then
                reset_game()
                gGlobalSyncTable.level = LEVEL_CASTLE_GROUNDS
            end
        end
    end
end

local function update()
    menu_controller()
    race_controller()
    music()
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
hook_event(HOOK_ON_LEVEL_INIT, on_level_init)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_INTERACT, on_interact)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ON_OBJECT_RENDER, on_object_render)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)

--[[
hook_chat_command("kart", "0 | 1 | 2|", command_kart_parts)
hook_chat_command("wheel", "0 | 1 | 2|", command_wheel_parts)
hook_chat_command("character", "0 | 1 | 2|", command_character)]]