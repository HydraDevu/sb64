gRaceShells = {}

gLevelData = gLevelDataTable[-1]
E_MODEL_LPKART = smlua_model_util_get_id("kartBilly_geo")
E_MODEL_Max = smlua_model_util_get_id("kartMaxime_geo")
E_MODEL_Vb = smlua_model_util_get_id("kartVillebre_geo")
E_MODEL_Squeezie = smlua_model_util_get_id("kartSqueezie_geo")
E_MODEL_Mv = smlua_model_util_get_id("kartMister_geo")
E_MODEL_Theodor = smlua_model_util_get_id("kartTheo_geo")
E_MODEL_Box = smlua_model_util_get_id("itemBox_geo")
E_MODEL_Donut = smlua_model_util_get_id("itemBox_geo")
local checkForAPress = true


smlua_text_utils_dialog_replace(DIALOG_000,1,6,30,200, "--ATTENTION--\
DES BOMBES TOMBENT SUR\
LE GP EXPLORER \
TU DOIS SURVIVRE ET TROUVER\
LE DONUTS SUCRE AU SUCRE !'")

function erase_unwanted_entities(objList)
    local obj = obj_get_first(objList)
    while obj ~= nil do
        local behaviorId = get_id_from_behavior(obj.behavior)
        if gLevelData.erase[behaviorId] ~= nil then
            obj.activeFlags = ACTIVE_FLAG_DEACTIVATED
        end

        -- iterate
        obj = obj_get_next(obj)
    end
end

function check_for_a_press_once()
    if checkForAPress then
        local m = gMarioStates[0]
        if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            disable_time_stop()
            checkForAPress = false
        end
    end
end

function on_level_init()
    -- set level data
    local level = gNetworkPlayers[0].currLevelNum
    if gLevelDataTable[level] ~= nil then
        gLevelData = gLevelDataTable[level]
    else
        gLevelData = gLevelDataTable[-1]
    end

    if gNetworkPlayers[0].currLevelNum == LEVEL_BOB then
        enable_time_stop()
        local dialogueResponse = cutscene_object_with_dialog(CUTSCENE_DIALOG, gMarioStates[0].marioObj, DIALOG_000)
        checkForAPress = true
    end
    
    -- spawn all of the racing shells
    for i = 0, (MAX_PLAYERS - 1) do
        gRaceShells[i] = spawn_non_sync_object(
            id_bhvRaceShell,
            E_MODEL_LPKART,
            0, 0, 0,
            function (obj) obj.heldByPlayerIndex = i end
        )
    end

    -- spawn all of the waypoints
    for i in pairs(gLevelData.waypoints) do
        local waypoint = get_waypoint(i)
        spawn_non_sync_object(
            id_bhvRaceRing,
            E_MODEL_WATER_RING,
            waypoint.x, waypoint.y, waypoint.z,
            function (obj) obj.oWaypointIndex = i end
        )
    end

    -- spawn level-specific platforms
    for i in pairs(gLevelData.platforms) do
        local p = gLevelData.platforms[i]
        spawn_non_sync_object(
            id_bhvStaticCheckeredPlatform,
            E_MODEL_CHECKERBOARD_PLATFORM,
            p.pos.x, p.pos.y, p.pos.z,
            function (obj)
                obj.oOpacity = 255
                obj.oFaceAnglePitch = p.rot.x
                obj.oFaceAngleYaw = p.rot.y
                obj.oFaceAngleRoll = p.rot.z
                obj_scale_xyz(obj, p.scale.x, p.scale.y, p.scale.z)
            end)
    end

  
    spawn_non_sync_object(
        id_bhvKoopa,
        E_MODEL_Squeezie,
        6683, 1888, -9347,
        function (obj) obj.oWaypointIndex = 1 end
        )

    spawn_non_sync_object(
        id_bhvKoopa,
        E_MODEL_Theodor,
        8800, 1879, -10036,
        function (obj) obj.oWaypointIndex = 1 end
        )

        spawn_non_sync_object(
            id_bhvKoopa,
            E_MODEL_Max,
            8339, 1879, -10036,
            function (obj) obj.oWaypointIndex = 1 end
            )
        spawn_non_sync_object(
                id_bhvKoopa,
                E_MODEL_Mv,
                7910, 1880, -9386,
                function (obj) obj.oWaypointIndex = 1 end
                )
        spawn_non_sync_object(
            id_bhvKoopa,
            E_MODEL_Vb,
            7110, 1879, -9997,
            function (obj) obj.oWaypointIndex = 1 end
            )

        spawn_non_sync_object(
                id_bhvStar,
                E_MODEL_Donut,
                6510, 1879, -9997,
                function (obj) obj.oWaypointIndex = 1 end
         )

   

    -- reset the local player's data
    local s = gPlayerSyncTable[0]
    s.waypoint = 1
    s.lap = 0
    s.finish = 0
    for i = 0, 2 do
        s.powerup[i] = POWERUP_NONE
    end

    -- reset the custom level objects
    for i in pairs(gLevelData.powerups) do
        gLevelData.powerups[i].obj = nil
    end

    for i = 0, (MAX_PLAYERS - 1) do
        for j = 0, 2 do
            gPowerups[i][j] = nil
        end
    end
    

    -- erase specified level entities
    erase_unwanted_entities(OBJ_LIST_GENACTOR)
    erase_unwanted_entities(OBJ_LIST_LEVEL)
    erase_unwanted_entities(OBJ_LIST_SURFACE)

    -- reset rankings
    race_clear_rankings()

    -- lower water level on castle grounds
    if gNetworkPlayers[0].currLevelNum == LEVEL_BOB then
        set_environment_region(1, -800)
        set_environment_region(2, -800)
    end
end

function spawn_custom_level_objects()
    -- only handle powerups if we're the server
    if not network_is_server() then
        return
    end

    -- only handle powerups if we're sync valid
    np = gNetworkPlayers[0]
    if (not np.currAreaSyncValid) or (not np.currLevelSyncValid) then
        return
    end

    -- spawn missing powerups
    for i in pairs(gLevelData.powerups) do
        if gLevelData.powerups[i].obj == nil then
            local pos = gLevelData.powerups[i].pos
            gLevelData.powerups[i].obj = spawn_sync_object(
                id_bhvItemBox,
                E_MODEL_Box,
                pos.x, pos.y, pos.z,
                function (obj)
                    --obj.oMoveAngleYaw = m.faceAngle.y
                end
            )
        end
    end
end

function on_object_unload(obj)
    -- react to powerups getting unloaded
    for i = 0, (MAX_PLAYERS - 1) do
        for j = 0, 2 do
            if obj == gPowerups[i][j] then
                gPowerups[i][j] = nil
            end
        end
    end

    -- react to level objects getting unloaded
    for i in pairs(gLevelData.powerups) do
        if gLevelData.powerups[i].obj == obj then
            gLevelData.powerups[i].obj = nil
        end
    end
end

hook_event(HOOK_ON_LEVEL_INIT, on_level_init)
hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)
