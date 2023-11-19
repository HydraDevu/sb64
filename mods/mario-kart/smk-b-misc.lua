-- Kart Misc

-- Skybox

E_MODEL_SKYBOX_CIRCUIT = smlua_model_util_get_id("skybox_circuit_geo")
E_MODEL_SKYBOX_MENU = smlua_model_util_get_id("skybox_menu_geo")

local function bhv_skybox_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_ACTIVE_FROM_AFAR
end

local function bhv_skybox_loop(obj)
    local lakPosX = gLakituState.pos.x + gMarioStates[0].vel.x + -sins(gLakituState.yaw) * 100
    local lakPosY = gLakituState.pos.y + gMarioStates[0].vel.y
    local lakPosZ = gLakituState.pos.z + gMarioStates[0].vel.z + -coss(gLakituState.yaw) * 100
    obj.oPosX, obj.oPosY, obj.oPosZ = lakPosX, lakPosY, lakPosZ
end

id_bhvSkyBox = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_skybox_init, bhv_skybox_loop)

-- Checkpoints

E_MODEL_CHECKPOINT = smlua_model_util_get_id("checkpoint_geo")

checkpointTbl = {

}

for i=1, 1 do
    checkpointTbl[i] = {}
end

local function bhv_checkpoint_init(obj)
    local checkID = obj.oBehParams & 0x00000000FF
    --print(tostring(checkID)..": "..tostring(obj.oPosX)..tostring(obj.oPosY)..tostring(obj.oPosZ))
    checkpointTbl[checkID] = {math.floor(obj.oPosX), math.floor(obj.oPosY), math.floor(obj.oPosZ)}
    local scale = (1/8)*12 
    cur_obj_scale(0)
end

local function bhv_checkpoint_loop(obj)
    local player = gMarioStates[0].marioObj
    local distanceToPlayer = dist_between_objects(obj, player)
    if distanceToPlayer > 2000 then
        return
    end
    local checkID = obj.oBehParams & 0x00000000FF
    if distanceToPlayer <= 2000 and (gStateExtras[0].checkpoint == checkID-1 or gStateExtras[0].checkpoint == checkID-2 or gStateExtras[0].checkpoint == checkID-3) then--gStateExtras[0].checkpoint == checkID-1 then
        --djui_chat_message_create(tostring(checkID))
        gStateExtras[0].checkpoint = checkID
    end
end

id_bhvCheckpoint = hook_behavior(nil, OBJ_LIST_SURFACE, true, bhv_checkpoint_init, bhv_checkpoint_loop)

-- Start Positions

local function bhv_startpos_init(obj)
    local checkID = obj.oBehParams & 0x00000000FF
    local m = gMarioStates[0]
    local globalIndex = gNetworkPlayers[0].globalIndex
    if globalIndex == checkID-1 then
        m.pos.x = obj.oPosX
        m.pos.y = obj.oPosY+600
        m.pos.z = obj.oPosZ
    end
end

local function bhv_startpos_loop(obj)
end


id_bhvStartPos = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_startpos_init, bhv_startpos_loop)