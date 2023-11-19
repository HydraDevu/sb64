---@diagnostic disable: param-type-mismatch
-- Kart Objects

E_MODEL_MINI_TURBO = smlua_model_util_get_id("mini_turbo_geo")

SURFACE_FINISH_LINE = 0x0064

local function bhv_kart_init(obj)
    local np = gNetworkPlayers[obj.heldByPlayerIndex]
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    if not np.connected or gPlayerSyncTable[obj.heldByPlayerIndex].spectating then
        obj_mark_for_deletion(obj)
    end
    
    if np ~= nil then
        obj.globalPlayerIndex = np.globalIndex
    end
end

local function bhv_kart_loop(obj)
    if not gNetworkPlayers[obj.heldByPlayerIndex].connected then
        cur_obj_disable_rendering()
        return
    else
        obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
    end
    local m = gMarioStates[obj.heldByPlayerIndex]
    local player = m.marioObj
    local s = gPlayerSyncTable[m.playerIndex]
    local wheel = s.wheel

    cur_obj_scale(1.0)

    obj_copy_pos(obj, player)
    obj.oPosY = obj.oPosY + wheelTbl[wheel].yOffset
    obj.oFaceAnglePitch = player.header.gfx.angle.x
    obj.oFaceAngleYaw = player.header.gfx.angle.y
    obj.oFaceAngleRoll = player.header.gfx.angle.z
    if m.action ~= ACT_KART_BULLET then
        obj_set_model_extended(obj, kartTbl[s.kart].model)
    else
        cur_obj_scale(0.4)
        obj_set_model_extended(obj, E_MODEL_BULLET_BILL)
    end
end

id_bhvKart = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_kart_init, bhv_kart_loop)

local function bhv_mini_turbo_init(obj)
    if not gNetworkPlayers[obj.heldByPlayerIndex].connected then
        obj_mark_for_deletion(obj)
    end
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(obj)
end

local function bhv_mini_turbo_loop(obj)
    if not gNetworkPlayers[obj.heldByPlayerIndex].connected then
        return
    end
    local index = obj.heldByPlayerIndex
    local e = gStateExtras[index]
    if not e.drifting then
        cur_obj_scale(0)
        return
    end
    local player = gMarioStates[index].marioObj
    local yaw = player.oFaceAngleYaw
    obj.oAnimState = e.driftTimer-1
    if math.floor(e.driftTimer) == 0 then
        cur_obj_scale(0)
    else
        cur_obj_scale((math.sin(get_network_area_timer()*2)+8)*0.15 + math.floor(e.driftTimer-1)*0.2)    
        obj_copy_pos(obj, player)
        obj.oPosX = obj.oPosX + 100*-sins(yaw) + 75 * coss(yaw)*obj.oAction
        obj.oPosZ = obj.oPosZ + 100*-coss(yaw) + 75 * -sins(yaw)*obj.oAction
    end
end

id_bhvMiniTurbo = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_mini_turbo_init, bhv_mini_turbo_loop)

