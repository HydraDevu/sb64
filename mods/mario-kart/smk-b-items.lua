-- Items

E_MODEL_ITEM_BOX = smlua_model_util_get_id("item_box_geo")

E_MODEL_GREEN_SHELL = smlua_model_util_get_id("shell_green_geo")
E_MODEL_RED_SHELL = smlua_model_util_get_id("shell_red_geo")
E_MODEL_BLUE_SHELL = smlua_model_util_get_id("shell_blue_geo")

local function bhv_item_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

local function bhv_item_spin(obj)
    local pos = {x = 0, y = 0, z = 0}
    local m = gMarioStates[obj.heldByPlayerIndex]

    local t = get_network_area_timer()*0x800

    t = t + (0x5555) * obj.oHealth
    pos.x = 140*coss(t)
    pos.z = 140*-sins(t)

    obj.oPosX = m.pos.x + pos.x
    obj.oPosY = m.pos.y + pos.y
    obj.oPosZ = m.pos.z + pos.z
end

local function bhv_item_trail(obj)
    local m = gMarioStates[obj.heldByPlayerIndex]
    local spd = 0.5 + (3-obj.oHealth) * 0.15
    obj.oPosX = lerp(obj.oPosX, m.pos.x-sins(m.faceAngle.y)*(50 + obj.oHealth*100), spd)
    obj.oPosY = lerp(obj.oPosY, m.pos.y, spd)
    obj.oPosZ = lerp(obj.oPosZ, m.pos.z-coss(m.faceAngle.y)*(50 + obj.oHealth*100), spd)
end

local function bhv_item_loop(obj)
    if not gNetworkPlayers[obj.heldByPlayerIndex].connected then
        cur_obj_disable_rendering()
        return
    else
        obj.header.gfx.node.flags = obj.header.gfx.node.flags &~ GRAPH_RENDER_BILLBOARD
        obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
    end

    local m = gMarioStates[obj.heldByPlayerIndex]
    local s = gPlayerSyncTable[m.playerIndex]
    local itemID = obj.oHealth

    local model = E_MODEL_NONE
    cur_obj_scale(1)

    if s.item[1] == ITEM_GREEN_SHELL then
        if itemID == 1 then
            model = E_MODEL_GREEN_SHELL
        end
    elseif s.item[1] == ITEM_DOUBLE_GREEN_SHELL then
        if itemID <= 2 then
            model = E_MODEL_GREEN_SHELL
        end
    elseif s.item[1] == ITEM_TRIPLE_GREEN_SHELL then
        model = E_MODEL_GREEN_SHELL
    elseif s.item[1] == ITEM_BLUE_SHELL then
        if itemID == 1 then
            model = E_MODEL_BLUE_SHELL
        end
    elseif s.item[1] == ITEM_RED_SHELL then
        if itemID == 1 then
            model = E_MODEL_RED_SHELL
        end
    elseif s.item[1] == ITEM_DOUBLE_RED_SHELL then
        if itemID <= 2 then
            model = E_MODEL_RED_SHELL
        end
    elseif s.item[1] == ITEM_TRIPLE_RED_SHELL then
        model = E_MODEL_RED_SHELL
    elseif s.item[1] == ITEM_MUSHROOM then
        if itemID == 1 then
            model = E_MODEL_1UP
        end
    elseif s.item[1] == ITEM_DOUBLE_MUSHROOM then
        if itemID <= 2 then
            model = E_MODEL_1UP
        end
    elseif s.item[1] == ITEM_TRIPLE_MUSHROOM then
        model = E_MODEL_1UP
    elseif s.item[1] == ITEM_BULLET_BILL then
        if itemID == 1 then
            model = E_MODEL_BULLET_BILL
            cur_obj_scale(0.1)
        end
    end
    if model ~= ITEM_NONE then
        bhv_item_spin(obj)
        obj_set_model_extended(obj, model)
        if model == E_MODEL_BULLET_BILL or model == E_MODEL_1UP then
            obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_BILLBOARD
            obj.oPosY = obj.oPosY + 40
        end
    else
        cur_obj_disable_rendering()
    end
end

id_bhvItem = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_item_init, bhv_item_loop)

local function bhv_item_ground_init(obj)
    --obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj.oVelX = obj.oForwardVel*sins(obj.oFaceAngleYaw)
    obj.oVelZ = obj.oForwardVel*coss(obj.oFaceAngleYaw)
end

local function bhv_item_ground_green_shell(obj)
    -- figure out direction
    local v = {
        x = sins(obj.oFaceAngleYaw) * obj.oForwardVel,
        y = 0,
        z = coss(obj.oFaceAngleYaw) * obj.oForwardVel,
    }
    local info = collision_find_surface_on_ray(
        obj.oPosX, obj.oPosY + obj.oVelY, obj.oPosZ,
        v.x, v.y, v.z)
    local floorHeight = find_floor_height(obj.oPosX, obj.oPosY, obj.oPosZ)
    obj.oPosX = info.hitPos.x
    obj.oPosZ = info.hitPos.z
    obj.oPosY = floorHeight
    obj.oTimer = obj.oTimer + 1

    if info.surface ~= nil then
        local wallAngle = atan2s(info.surface.normal.z, info.surface.normal.x)
        obj.oFaceAngleYaw = wallAngle-(obj.oFaceAngleYaw-wallAngle)+0x8000
        obj.oHealth = obj.oHealth - 1
    end
    if obj.oHealth == 0 then
        obj_mark_for_deletion(obj)
    end
    vec3f_set(obj.header.gfx.pos, obj.oPosX, obj.oPosY, obj.oPosZ)
    obj.header.gfx.angle.y = obj.oFaceAngleYaw + get_network_area_timer()*0x1000

    if obj.oTimer > 5 then
        local player = nearest_mario_state_to_object(obj)--gMarioStates[0].marioObj
        local distanceToPlayer = dist_between_objects(obj, player.marioObj)

        if distanceToPlayer < 300 then
            set_mario_action(player, ACT_KART_SPIN, 0)
            obj_mark_for_deletion(obj)
        end
    end
end

local function bhv_item_path(obj, type)
    local nextCheckpoint = get_checkpoint(obj.oAction)
    local angleToCheck = obj_angle_to_point(obj, nextCheckpoint[1], nextCheckpoint[3])
    local m = nearest_mario_state_to_object(obj)
    if type == 1 then
        m = gMarioStates[gRankings[1].playerIndex]
    end
    if dist_between_object_and_point(obj, nextCheckpoint[1], nextCheckpoint[2], nextCheckpoint[3]) < 200 then
        obj.oAction = obj.oAction + 1
    end
    if obj.oAction > #checkpointTbl then
        obj.oAction = 1
    end
    --djui_chat_message_create("Shell Floor: "..tostring(type))
    if dist_between_object_and_point(obj, m.pos.x, m.pos.y, m.pos.z) < 2400+(1600*type) and obj.oTimer > 30 then
        angleToCheck = obj_angle_to_point(obj, m.pos.x, m.pos.z)
    end
    obj.oFaceAngleYaw = angleToCheck
end

local function bhv_item_ground_red_shell(obj)
    -- figure out direction
    local v = {
        x = sins(obj.oFaceAngleYaw) * obj.oForwardVel,
        y = 0,
        z = coss(obj.oFaceAngleYaw) * obj.oForwardVel,
    }
    local info = collision_find_surface_on_ray(
        obj.oPosX, obj.oPosY + obj.oVelY, obj.oPosZ,
        v.x, v.y, v.z)
    local floorHeight = find_floor_height(obj.oPosX, obj.oPosY, obj.oPosZ)
    obj.oPosX = info.hitPos.x
    obj.oPosZ = info.hitPos.z
    obj.oPosY = floorHeight
    obj.oTimer = obj.oTimer + 1
    bhv_item_path(obj, 0)
    if info.surface ~= nil then
        obj.oHealth = 0
    end
    if obj.oHealth == 0 then
        obj_mark_for_deletion(obj)
    end
    vec3f_set(obj.header.gfx.pos, obj.oPosX, obj.oPosY, obj.oPosZ)
    obj.header.gfx.angle.y = obj.oFaceAngleYaw + get_network_area_timer()*0x1000

    if obj.oTimer > 5 then
        local player = nearest_mario_state_to_object(obj)--gMarioStates[0].marioObj
        local distanceToPlayer = dist_between_objects(obj, player.marioObj)

        if distanceToPlayer < 300 then
            set_mario_action(player, ACT_KART_SPIN, 0)
            obj_mark_for_deletion(obj)
        end
    end
end

local function bhv_item_ground_blue_shell(obj)
    -- figure out direction
    local v = {
        x = sins(obj.oFaceAngleYaw) * obj.oForwardVel,
        y = 0,
        z = coss(obj.oFaceAngleYaw) * obj.oForwardVel,
    }
    local info = collision_find_surface_on_ray(
        obj.oPosX, obj.oPosY + obj.oVelY, obj.oPosZ,
        v.x, v.y, v.z)
    local floorHeight = find_floor_height(obj.oPosX, obj.oPosY, obj.oPosZ)
    obj.oPosX = info.hitPos.x
    obj.oPosZ = info.hitPos.z
    obj.oPosY = floorHeight
    obj.oTimer = obj.oTimer + 1
    bhv_item_path(obj, 1)
    if info.surface ~= nil then
        obj.oHealth = 0
    end
    if obj.oHealth == 0 then
        obj_mark_for_deletion(obj)
    end
    vec3f_set(obj.header.gfx.pos, obj.oPosX, obj.oPosY, obj.oPosZ)
    obj.header.gfx.angle.y = obj.oFaceAngleYaw + get_network_area_timer()*0x1000

    if obj.oTimer > 5 then
        local player = nearest_mario_state_to_object(obj)--gMarioStates[0].marioObj
        if not (player.playerIndex == gRankings[1].playerIndex) then
            return
        end
        local distanceToPlayer = dist_between_objects(obj, player.marioObj)

        if distanceToPlayer < 300 then
            set_mario_action(player, ACT_KART_SPIN, 0)
            cur_obj_play_sound_2(SOUND_GENERAL2_BOBOMB_EXPLOSION)
            set_environmental_camera_shake(SHAKE_ENV_EXPLOSION)
            obj_mark_for_deletion(obj)
        end
    end
end

local function bhv_item_ground_loop(obj)
    if obj.oHealth == -5 then
        bhv_item_ground_red_shell(obj)
    elseif obj.oHealth == -6 then
        bhv_item_ground_blue_shell(obj)
    else
        bhv_item_ground_green_shell(obj)
    end
end

id_bhvItemGround = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_item_ground_init, bhv_item_ground_loop)

ITEMBOX_POOR = 1
ITEMBOX_MID = 2
ITEMBOX_RARE = 3
ITEMBOX_BEST = 4

itemTbl = {
    [ITEMBOX_POOR] = {
        ITEM_MUSHROOM,
        ITEM_MUSHROOM,
        ITEM_GREEN_SHELL,
        ITEM_GREEN_SHELL,
        ITEM_RED_SHELL,
        ITEM_TRIPLE_GREEN_SHELL
    },
    [ITEMBOX_MID] = {
        ITEM_MUSHROOM,
        ITEM_TRIPLE_MUSHROOM,
        ITEM_TRIPLE_MUSHROOM,
        ITEM_GREEN_SHELL,
        ITEM_RED_SHELL,
        ITEM_TRIPLE_GREEN_SHELL
    },
    [ITEMBOX_RARE] = {
        ITEM_MUSHROOM,
        ITEM_TRIPLE_MUSHROOM,
        ITEM_TRIPLE_MUSHROOM,
        ITEM_TRIPLE_GREEN_SHELL,
        ITEM_TRIPLE_RED_SHELL,
        ITEM_RED_SHELL,
        ITEM_BLUE_SHELL,
        ITEM_BULLET_BILL,
    },
    [ITEMBOX_BEST] = {
        ITEM_TRIPLE_MUSHROOM,
        ITEM_TRIPLE_RED_SHELL,
        ITEM_TRIPLE_RED_SHELL,
        ITEM_TRIPLE_RED_SHELL,
        ITEM_BLUE_SHELL,
        ITEM_BLUE_SHELL,
        ITEM_BULLET_BILL,
    },
}

local function determine_item()
    if gGlobalSyncTable.itemSetting == ITEMS_FRANTIC then
        return math.random(ITEMBOX_POOR, ITEMBOX_BEST)
    end
    local score = gPlayerSyncTable[0].score
    local highestScore = 0

    for i=0, MAX_PLAYERS-1 do
        if gPlayerSyncTable[i].score > highestScore then
            highestScore = gPlayerSyncTable[i].score
        end
    end

    if highestScore - score < 300 then
        return ITEMBOX_POOR
    elseif highestScore - score < 600 then
        return ITEMBOX_MID
    elseif highestScore - score < 900 then
        return ITEMBOX_RARE
    elseif highestScore - score < 1400 then
        return ITEMBOX_BEST
    end
    return ITEMBOX_BEST
end

local function bhv_itembox_init(obj)
    obj.hitboxRadius = 40
    obj.oAction = obj.oPosY
    if gGlobalSyncTable.itemSetting == ITEMS_DISABLED then
        obj_mark_for_deletion(obj)
    end
end

local function bhv_itembox_loop(obj)
    local player = gMarioStates[0].marioObj
    local s = gPlayerSyncTable[gMarioStates[0].playerIndex]
    local distanceToPlayer = dist_between_objects(obj, player)
    local oRadius = obj.hitboxRadius
    local oGfx = obj.header.gfx
    -- Decrease the angle by a fixed amount (0x200)
    oGfx.angle.y = oGfx.angle.y - 0x200

    -- Calculate y-position using a single calculation
    local networkAreaTimer = get_network_area_timer()
    oGfx.pos.y = obj.oPosY + sins(networkAreaTimer * 0x800) * 60 + (-60 + obj.hitboxRadius) * 8 + 60

    -- Scale the object based on hitbox radius
    obj_scale(obj, obj.hitboxRadius / 60)

    -- Increase hitbox radius if it's less than 60
    obj.hitboxRadius = math.min(obj.hitboxRadius + 1, 60)

    if distanceToPlayer < 300 and obj.hitboxRadius >= 60 then
        obj.hitboxRadius = 0
        if s.item[1] == ITEM_NONE then
            -- Pick up a random item from the determined item class
            local itemClass = determine_item()
            s.item[1] = itemTbl[itemClass][math.random(#itemTbl[itemClass])]
        end
    end
end


id_bhvItemBox = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_itembox_init, bhv_itembox_loop)