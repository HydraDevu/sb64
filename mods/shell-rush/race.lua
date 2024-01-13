gRankings = {}
E_MODEL_Meteor = smlua_model_util_get_id("meteor_geo")

GAME_STATE_INACTIVE = 0
GAME_STATE_RACE_COUNTDOWN = 1
GAME_STATE_RACE_ACTIVE = 2
GAME_STATE_RACE_FINISH = 3

gGlobalSyncTable.maxLaps = 12
gGlobalSyncTable.gameState = GAME_STATE_INACTIVE
gGlobalSyncTable.gotoLevel = -1
gGlobalSyncTable.raceStartTime = 0
gGlobalSyncTable.raceQuitTime = 0
gGlobalSyncTable.bombsActive = false
gGlobalSyncTable.skyboxChanged = false



local gGlobalTimer = 0
local D_8032F420 = { 1.9, 2.4, 4.0, 4.8 }

gGlobalSyncTable.oFallingVel = 75
gGlobalSyncTable.bombNum = 15

--- @param o Object
local function id_bhv_bowser_shock_wave_init(o)
    o.oFlags = (OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oOpacity = 255
end

--- @param o Object
local function id_bhv_bowser_shock_wave_loop(o)
    local m = gMarioStates[0]
    local sp2C = 0
    local sp28 = 0
    local sp24 = 0
    local sp20 = 0
    local sp1E = 70
    o.oBowserShockWaveUnkF4 = o.oTimer * 10
    cur_obj_scale(o.oBowserShockWaveUnkF4)
    if gGlobalTimer % 3 ~= 0 then
        o.oOpacity = o.oOpacity - 1
    end
    if o.oTimer > sp1E then
        o.oOpacity = o.oOpacity - 5
    end
    if o.oOpacity <= 0 then
        obj_mark_for_deletion(o)
    end
    if o.oTimer < sp1E and m.pos.y > o.oPosY - 30 and m.pos.y < o.oPosY + 30 then
        sp2C = o.oBowserShockWaveUnkF4 * D_8032F420[1]
        sp28 = o.oBowserShockWaveUnkF4 * D_8032F420[2]
        sp24 = o.oBowserShockWaveUnkF4 * D_8032F420[3]
        sp20 = o.oBowserShockWaveUnkF4 * D_8032F420[4]
        if (sp2C < o.oDistanceToMario and o.oDistanceToMario < sp28)
            or (sp24 < o.oDistanceToMario and o.oDistanceToMario < sp20) then
            gMarioStates[0].marioObj.oInteractStatus = gMarioStates[0].marioObj.oInteractStatus | INT_STATUS_HIT_BY_SHOCKWAVE
        end
    end
end

local id_bhvBowserShockWave = hook_behavior(id_bhvBowserShockWave, OBJ_LIST_DEFAULT, true, id_bhv_bowser_shock_wave_init, id_bhv_bowser_shock_wave_loop)

local sBombHitbox = {
    interactType = INTERACT_DAMAGE,
    downOffset = 0,
    damageOrCoinValue = 1,
    health = 0,
    numLootCoins = 0,
    radius = 100,
    height = 64,
    hurtboxRadius = 0,
    hurtboxHeight = 0,
}

local function obj_set_hitbox(obj, hitbox)
    if obj == nil or hitbox == nil then return end
    if (obj.oFlags & OBJ_FLAG_30) == 0 then
        obj.oFlags = obj.oFlags | OBJ_FLAG_30

        obj.oInteractType = hitbox.interactType
        obj.oDamageOrCoinValue = hitbox.damageOrCoinValue
        obj.oHealth = hitbox.health
        obj.oNumLootCoins = hitbox.numLootCoins

        cur_obj_become_tangible()
    end

    obj.hitboxRadius = obj.header.gfx.scale.x * hitbox.radius
    obj.hitboxHeight = obj.header.gfx.scale.y * hitbox.height
    obj.hurtboxRadius = obj.header.gfx.scale.x * hitbox.hurtboxRadius
    obj.hurtboxHeight = obj.header.gfx.scale.y * hitbox.hurtboxHeight
    obj.hitboxDownOffset = obj.header.gfx.scale.y * hitbox.downOffset
end

local function falling_bomb_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_hitbox(o, sBombHitbox)
end

local function falling_bomb_loop(o)
    o.oPosY = o.oPosY - gGlobalSyncTable.oFallingVel
    object_step()
    cur_obj_update_floor()
    if o.oPosX == nil or o.oPosY == nil or o.oPosZ == nil or o.oFloor == nil then
        o.oPosX = math.random(-8200,8200)
        o.oPosY = 10000
        o.oPosZ = math.random(-8200,8200)
    end
    if o.oPosY <= o.oFloorHeight then
        spawn_non_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, o.oPosX, o.oFloorHeight, o.oPosZ, nil)
        spawn_non_sync_object(id_bhvBowserShockWave, E_MODEL_BOWSER_WAVE, o.oPosX, o.oFloorHeight, o.oPosZ, nil)
        o.oPosX = math.random(-8200,8200)
        o.oPosY = 10000
        o.oPosZ = math.random(-8200,8200)
    end
end

local id_bhvFallingBomb = hook_behavior(id_bhvFallingBomb, OBJ_LIST_LEVEL, true, falling_bomb_init, falling_bomb_loop)

local function update()
    if gGlobalSyncTable.bombsActive then
    gGlobalTimer = gGlobalTimer + 1
    if count_objects_with_behavior(get_behavior_from_id(id_bhvFallingBomb)) > gGlobalSyncTable.bombNum then return false end
    spawn_non_sync_object(id_bhvFallingBomb, E_MODEL_Meteor, math.random(-8200,8200), 10000, math.random(-8200,8200), nil)
    end
end

function race_start(level)
    gGlobalSyncTable.gotoLevel = level
    gGlobalSyncTable.gameState = GAME_STATE_RACE_COUNTDOWN
    gGlobalSyncTable.raceStartTime = 0
    gGlobalSyncTable.raceQuitTime = 0


    for i = 0, (MAX_PLAYERS - 1) do
        local s = gPlayerSyncTable[i]
        s.random = math.random()
        s.finish = 0
    end
end

function race_clear_rankings()
    for k,v in pairs(gRankings) do gRankings[k]=nil end
end

function race_increment_lap()
    local s = gPlayerSyncTable[0]
    s.lap = s.lap + 1
    if s.lap > gGlobalSyncTable.maxLaps then
        s.lap = gGlobalSyncTable.maxLaps
        if s.finish == 0 then
            s.finish = get_network_area_timer()
            play_race_fanfare()
        end
    end
   if s.lap >= 1 then  -- Activez les bombes au deuxième tour par exemple
        gGlobalSyncTable.bombsActive = true
        set_override_skybox(BACKGROUND_PURPLE_SKY)
        gGlobalSyncTable.skyboxChanged = true
    end
end

function race_update_rankings()
    -- order players by score
    ordered = {}
    for i = 0, (MAX_PLAYERS - 1) do
        local m = gMarioStates[i]
        local s = gPlayerSyncTable[i]
        if active_player(m) then
            local score = 0
            if s.finish > 0 then
                score = (gGlobalSyncTable.maxLaps + 2) * 10000 + (10000 / s.finish)
            else
                -- figure out distance score
                local maxDist = vec3f_dist(get_waypoint(s.waypoint - 1), get_waypoint(s.waypoint))
                if maxDist == 0 then maxDist = 1 end
                local dist = vec3f_dist(m.pos, get_waypoint(s.waypoint))
                local distScore = clamp(1 - (dist/maxDist), 0, 1)

                -- figure out entire score
                local lastWaypoint = get_waypoint_index(s.waypoint - 1)
                score = s.lap * 10000 + lastWaypoint * 100 + distScore
                if s.lap == 0 then score = 0 end
            end
            if score > 0 then
                table.insert(ordered, { score = score, m = m })
            end
        end
    end

    table.sort(ordered, function (v1, v2) return v1.score > v2.score end)

    -- clear rankings
    race_clear_rankings()

    -- set rankings
    for i,v in ipairs(ordered) do
        table.insert(gRankings, v.m)
    end
end

function race_start_line()
    local index = 0
    for i = 0, (MAX_PLAYERS - 1) do
        local s = gPlayerSyncTable[i]
        if network_is_server() then
            s.finish = 0
        end
        if active_player(gMarioStates[i]) and s.random < gPlayerSyncTable[0].random then
            index = index + 1
        end
    end

    local lineIndex = (index % 2) + 1
    local lineBackIndex = index - (index % 2)

    local m = gMarioStates[0]
    local spawnLine = gLevelData.spawn[lineIndex]
    local point = vec3f_tween(spawnLine.a, spawnLine.b, lineBackIndex / MAX_PLAYERS)
    local waypoint = get_waypoint(1)

    m.pos.x = point.x
    m.pos.y = point.y
    m.pos.z = point.z

    m.marioObj.oIntangibleTimer = 5
    set_mario_action(m, ACT_RIDING_SHELL_GROUND, 0)
    m.vel.x = 0
    m.vel.y = 0
    m.vel.z = 0
    m.slideVelX = 0
    m.slideVelZ = 0
    m.forwardVel = 0
    m.faceAngle.x = 0
    m.faceAngle.y = atan2s(waypoint.z - m.pos.z, waypoint.x - m.pos.x)
    m.faceAngle.z = 0
end

function race_update()
    -- automatically start race
    if gGlobalSyncTable.gameState == GAME_STATE_INACTIVE and network_player_connected_count() > 1 then
        race_start(LEVEL_SL)
    end

   -- update_bombs()

    local np = gNetworkPlayers[0]
    if gGlobalSyncTable.gotoLevel ~= -1 and np.currAreaSyncValid and np.currLevelSyncValid then
        if np.currLevelNum ~= gGlobalSyncTable.gotoLevel then
            if gGlobalSyncTable.gotoLevel == LEVEL_BOB then
                warp_to_castle(LEVEL_VCUTM)
            else
                warp_to_level(gGlobalSyncTable.gotoLevel, 1, 16)
            end
        end
    end

    -- make sure this is a valid level
    if gLevelData == gLevelDataTable[-1] then
        return
    end

    if gGlobalSyncTable.gameState == GAME_STATE_RACE_COUNTDOWN then
        race_start_line()
        race_clear_rankings()
        if network_is_server() then
            if gGlobalSyncTable.raceStartTime == 0 then
                if np.currAreaSyncValid then
                    gGlobalSyncTable.raceStartTime = get_network_area_timer() + 30 * 5
                    gGlobalSyncTable.raceQuitTime = 0
                end
            elseif gGlobalSyncTable.raceStartTime > get_network_area_timer() + 30 * 5 then
                gGlobalSyncTable.raceStartTime = get_network_area_timer() + 30 * 5
                gGlobalSyncTable.raceQuitTime = 0
            elseif gGlobalSyncTable.raceStartTime > 0 and get_network_area_timer() >= gGlobalSyncTable.raceStartTime then
                gGlobalSyncTable.gameState = GAME_STATE_RACE_ACTIVE
            end
        end

    elseif gGlobalSyncTable.gameState == GAME_STATE_RACE_ACTIVE then
        race_update_rankings()
        if network_is_server() then
            if gGlobalSyncTable.raceQuitTime == 0 then
                -- check for race finish
                local foundFinisher = false
                for i = 0, (MAX_PLAYERS - 1) do
                    local m = gMarioStates[i]
                    local s = gPlayerSyncTable[i]
                    if active_player(m) and s.finish > 0 then
                        foundFinisher = true
                    end
                end
                if foundFinisher then
                    -- set a timer until the race is finished
                    gGlobalSyncTable.raceQuitTime = get_network_area_timer() + 30 * 20
                end
            elseif gGlobalSyncTable.raceQuitTime > 0 and get_network_area_timer() > gGlobalSyncTable.raceQuitTime then
                -- race is finished, start a new one
                if gLevelData == gLevelDataTable[LEVEL_BOB] then     
                    race_start(LEVEL_BOB)
                elseif gLevelData == gLevelDataTable[LEVEL_BOB] then
                    race_start(LEVEL_SL)
                elseif gLevelData == gLevelDataTable[LEVEL_SL] then
                    race_start(LEVEL_TTM)
                elseif gLevelData == gLevelDataTable[LEVEL_TTM] then
                    race_start(LEVEL_CCM)
                elseif gLevelData == gLevelDataTable[LEVEL_CCM] then
                    race_start(LEVEL_CASTLE_GROUNDS)
                end
            end
        end
    end
end

function on_race_command(msg)
    if not network_is_server() then
        djui_chat_message_create('Only the server can change this setting!')
        return true
    end
    if msg == 'CG' then
        race_start(LEVEL_BOB)
        return true
    end
    if msg == 'BOB' then
        race_start(LEVEL_BOB)
        return true
    end
    if msg == 'SL' then
        race_start(LEVEL_SL)
        return true
    end
    if msg == 'TTM' then
        race_start(LEVEL_TTM)
        return true
    end
    if msg == 'CCM' then
        race_start(LEVEL_CCM)
    end
    return false
end

function on_laps_command(msg)
    if not network_is_server() then
        djui_chat_message_create('Only the server can change this setting!')
        return true
    end
    if tonumber(msg) > 0 then
        gGlobalSyncTable.maxLaps = math.floor(tonumber(msg))
        return true
    end
    return false
end

function on_game_state_changed(tag, oldVal, newVal)
    local m = gMarioStates[0]
    if oldVal ~= newVal then
        if newVal == GAME_STATE_RACE_ACTIVE then
            play_sound(SOUND_GENERAL_RACE_GUN_SHOT, m.marioObj.header.gfx.cameraToObject)
        end
    end
end

if network_is_server() then
    hook_chat_command('race', "[CG|BOB|SL|TTM|CCM]", on_race_command)
    hook_chat_command('laps', "[number]", on_laps_command)
end
hook_on_sync_table_change(gGlobalSyncTable, 'gameState', i, on_game_state_changed)
-- Placer les hook_events en bas du fichier
hook_event(HOOK_UPDATE, update)
