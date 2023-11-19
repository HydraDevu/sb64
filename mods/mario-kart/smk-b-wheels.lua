-- Wheels

local obj_set_model_extended = obj_set_model_extended
local signum_positive = signum_positive
local cur_obj_scale = cur_obj_scale
local sins = sins

local function bhv_wheel_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE

    if gPlayerSyncTable[obj.oHealth].spectating then
        obj_mark_for_deletion(obj)
    end
end

local function bhv_wheel_loop(obj)
    local m = gMarioStates[obj.oHealth]

    if not gNetworkPlayers[obj.oHealth].connected or m.action == ACT_KART_BULLET then
        cur_obj_disable_rendering()
        return
    else
        obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
    end
    

    if (obj.header.gfx.node.flags & GRAPH_RENDER_ACTIVE) ~= 0 then
        local player = m.marioObj
        local e = gStateExtras[obj.oHealth]
        local s = gPlayerSyncTable[m.playerIndex]
        local kart = s.kart
        local wheel = s.wheel

        local wheelPosY = wheelTbl[wheel].yOffset
        local wheelPosZ = wheelTbl[wheel].zOffset
        local pitch = player.oFaceAnglePitch
        local yaw = player.oFaceAngleYaw
        local roll = player.oFaceAngleRoll
        local pPosX = player.oPosX
        local pPosY = player.oPosY
        local pPosZ = player.oPosZ

        obj_set_model_extended(obj, wheelTbl[s.wheel].model)
        -- Back Wheels
        if math.abs(obj.oAction) == 2 then
            local wheelInfo = kartTbl[kart].wheel_b
            if wheelInfo.z == 0 then
                wheelPosZ = 0
            end
            local posTbl = {
                x = (wheelInfo.z+wheelPosZ)*signum_positive(obj.oAction), y = wheelInfo.y+wheelPosY, z = -wheelInfo.x
            }

            vec3f_rotate_zxy(posTbl, {x = pitch, y = yaw, z = roll})

            cur_obj_scale(wheelInfo.size)

            obj.oFaceAnglePitch = pitch + obj.oFaceAnglePitch + e.speed*80
            obj.oFaceAngleYaw = yaw
            obj.oFaceAngleRoll = roll
            --vec3f_rotate_zxy(posTbl, {x = roll, y = yaw+0x4000, z = pitch})

            obj.oPosX = pPosX + posTbl.x
            obj.oPosY = pPosY + posTbl.y
            obj.oPosZ = pPosZ + posTbl.z
        else -- Front Wheels
            local wheelInfo = kartTbl[kart].wheel_f
            if wheelInfo.z == 0 then
                wheelPosZ = 0
            end
            local posTbl = {
                x = (wheelInfo.z+wheelPosZ)*signum_positive(obj.oAction), y = wheelInfo.y+wheelPosY, z = wheelInfo.x
            }

            vec3f_rotate_zxy(posTbl, {x = pitch, y = yaw, z = roll})

            cur_obj_scale(wheelInfo.size)

            obj.oFaceAnglePitch = -pitch + obj.oFaceAnglePitch + e.speed*80
            obj.oFaceAngleYaw = yaw - e.turnTargetX*80
            obj.oFaceAngleRoll = roll

            obj.oPosX = pPosX + posTbl.x
            obj.oPosY = pPosY + posTbl.y
            obj.oPosZ = pPosZ + posTbl.z
        end
    end
end

id_bhvWheel = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_wheel_init, bhv_wheel_loop)

local function bhv_glider_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

local function bhv_glider_loop(obj)
    local m = gMarioStates[obj.oHealth]

    if not gNetworkPlayers[obj.oHealth].connected or m.action == ACT_KART_BULLET or m.action ~= ACT_KART_GLIDE then
        cur_obj_disable_rendering()
        return
    else
        obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
    end
    

    if (obj.header.gfx.node.flags & GRAPH_RENDER_ACTIVE) ~= 0 then
        local player = m.marioObj
        local s = gPlayerSyncTable[m.playerIndex]
        local kart = s.kart

        local pitch = player.oFaceAnglePitch
        local yaw = player.oFaceAngleYaw
        local roll = player.oFaceAngleRoll
        local pPosX = player.oPosX
        local pPosY = player.oPosY
        local pPosZ = player.oPosZ

        local posTbl = {
            x = 0, y = 20, z = kartTbl[kart].gliderZ
        }

        vec3f_rotate_zxy(posTbl, {x = pitch, y = yaw, z = roll})

        obj.header.gfx.scale.y = 1 + sins(get_network_area_timer()*0x4000)*0.02
        
        obj.oFaceAnglePitch = pitch
        obj.oFaceAngleYaw = yaw
        obj.oFaceAngleRoll = roll

        obj.oPosX = pPosX + posTbl.x
        obj.oPosY = pPosY + posTbl.y
        obj.oPosZ = pPosZ + posTbl.z
    end
end

id_bhvGlider = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_glider_init, bhv_glider_loop)