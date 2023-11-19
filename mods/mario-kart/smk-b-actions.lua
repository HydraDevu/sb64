-- Kart Actions
function lerp(a, b, t)
	return a + (b - a) * t
end

local function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

driftMinSpeed = 50

local approach_f32 = approach_f32
local sins = sins
local coss = coss

ACT_KART_GROUND = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_WATER_OR_TEXT)
ACT_KART_SPECTATE = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY)
ACT_KART_START = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY | ACT_FLAG_WATER_OR_TEXT)
ACT_KART_SPIN = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_INVULNERABLE | ACT_FLAG_WATER_OR_TEXT)
ACT_KART_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_WATER_OR_TEXT)
ACT_KART_GLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_FLYING | ACT_FLAG_WATER_OR_TEXT)
ACT_KART_MENU = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_WATER_OR_TEXT)
ACT_KART_BULLET = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

local function head_dir(m)
    local e = gStateExtras[m.playerIndex]
    local driftTurn = (64*e.driftDir)+(e.turnTargetX-(20*e.driftDir))
    if not e.drifting then
        driftTurn = 0
    end
    m.marioBodyState.headAngle.y = e.turnTargetX * -0x50+ driftTurn*96
    m.marioBodyState.headAngle.x = e.turnTargetY * 0x25
end

local function act_kart_start(m)
    local step = perform_ground_step(m)
    local spd = gGlobalSyncTable.speedSetting
    local e = gStateExtras[m.playerIndex]
    local s = gPlayerSyncTable[m.playerIndex]
    local kart = s.kart
    local wheel = s.wheel
    local character = s.character

    local kTbl = kartTbl[kart]
    local wTbl = wheelTbl[wheel]
    local cTbl = charTbl[character]

    local kTop = kTbl.top+wTbl.topSpd+cTbl.top+speedTbl[spd]

    if s.spectating then
        set_mario_action(m, ACT_KART_SPECTATE, 0)
    end
    m.pos.y = m.floorHeight
    if step == GROUND_STEP_NONE then
        m.vel.x, m.vel.z = 0, 0
        m.faceAngle.y = 0x8000
        e.targetYaw = 0x8000
        set_mario_animation(m, MARIO_ANIM_HOLDING_BOWSER)
        if (m.controller.buttonDown & A_BUTTON) ~= 0 then
            e.speed = approach_f32(e.speed, kTop, 4, 4)
            e.boostTimer = e.boostTimer + 1
            e.boostSpd = e.boostSpd + 0.5
            --djui_chat_message_create(tostring(e.boostTimer))
        else
            e.speed = approach_f32(e.speed, 0, 4, 4)
            e.boostTimer = 0
            e.boostSpd = 0
        end
    
        if gGlobalSyncTable.startTimer <= 0 then
            if e.boostTimer < 60 then
                set_mario_action(m, ACT_KART_GROUND, 0)
            else
                e.speed = 0
                set_mario_action(m, ACT_KART_SPIN, 0)
            end
        end
    end
end

local function act_kart_spectate(m)
    m.pos.y = 16000
    m.pos.x, m.pos.z = 0, 0
end

local function act_kart_ground(m)
    local step = perform_ground_step(m)
    local spd = gGlobalSyncTable.speedSetting
    local e = gStateExtras[m.playerIndex]
    local s = gPlayerSyncTable[m.playerIndex]
    local kart = s.kart
    local wheel = s.wheel
    local character = s.character

    local kTbl = kartTbl[kart]
    local wTbl = wheelTbl[wheel]
    local cTbl = charTbl[character]

    local kAcc = kTbl.acc+wTbl.acc+cTbl.acc
    local kDcc = kTbl.dcc
    local kTop = kTbl.top+wTbl.topSpd+cTbl.top+speedTbl[spd]
    local turnTop = kTop
    local kFrc = kTbl.frc
    if m.floor.type == SURFACE_SLOW and e.boostState <= BOOST_DRIFT then
        kTop = kTop * (wheelTbl[wheel].offroad)
        if (m.controller.buttonDown & A_BUTTON) ~= 0 then
            e.speed = approach_f32(e.speed, kTop, kAcc, kFrc)
        end
    end
    local accFactor = math.min(math.abs(e.speed)/turnTop, 1)

    -- Grounded
    if (step == GROUND_STEP_NONE) then
        -- Driving
        if (m.controller.buttonDown & A_BUTTON) ~= 0 and (m.controller.buttonDown & B_BUTTON) == 0 and e.speed < kTop then
            e.speed = approach_f32(e.speed, kTop, kAcc, kFrc)
        elseif (m.controller.buttonDown & B_BUTTON) ~= 0 and (m.controller.buttonDown & A_BUTTON) == 0 and e.speed > -40 then
            e.speed = e.speed - kDcc * 1
        else
            e.speed = approach_f32(e.speed, 0, kAcc, kFrc)
        end
        e.angleX = 0
        if e.speed > kTop then
            e.speed = e.speed - kDcc
        end
        set_mario_animation(m, MARIO_ANIM_HOLDING_BOWSER)
        local kartYaw = 0
        local accMin = kFrc
        local accMax = kTop*0.04

        local acc = lerp(accMin, accMax, accFactor)
        slideAcc = acc*4
        if e.boostTimer > 0 then
            e.speed = kTop + e.boostSpd
            e.boostTimer = e.boostTimer - 1
            m.particleFlags = m.particleFlags | PARTICLE_FIRE
            if (m.controller.buttonDown & B_BUTTON) ~= 0 then
                e.boostTimer = e.boostTimer - 4
            end
            slideAcc = acc*4
        else
            e.boostSpd = 0
            e.boostState = BOOST_NONE
        end
        e.targetVelX = sins(m.faceAngle.y)*e.speed
        e.targetVelZ = coss(m.faceAngle.y)*e.speed

        

        if (not e.drifting) then
            local turnSpeed = 8*math.max(accFactor+0.1, 0.0)
            e.driftPower = 0
            if e.speed ~= 0 then
                m.faceAngle.y = m.faceAngle.y - (e.turnTargetX*turnSpeed)*sign(e.speed)
                e.targetYaw = e.targetYaw - (e.turnTargetX*turnSpeed)*sign(e.speed)
            end
            kartYaw = m.faceAngle.y-- - approach_s32(convert_s16(e.targetYaw - m.faceAngle.y), 0, .1, .1)
        end
        if m.wall ~= nil then
            local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x);
            local bounceSpd = 48*accFactor
            m.vel.x = m.vel.x + sins(wallAngle)*bounceSpd
            m.vel.z = m.vel.z + coss(wallAngle)*bounceSpd
        end

        -- Drifting
        if (e.drifting) then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
            
            play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
            if e.speed < 38 then
                e.drifting = false
                e.driftTimer = 0
            end
            local driftTurn = (76*e.driftDir)+(e.turnTargetX-(20*e.driftDir))
            local driftSpeed = e.speed*0.5
            if (m.controller.buttonDown & B_BUTTON) ~= 0 then
                driftTurn = (76*e.driftDir)+(e.turnTargetX-(-20*e.driftDir))
                --e.speed = e.speed - kDcc
            end
            if math.abs(m.controller.stickX) >= e.driftPower*8 and sign(m.controller.stickX) == e.driftPower and e.driftTimer < 3 then
                e.driftPower = -e.driftPower
                e.driftTimer = e.driftTimer + 0.25
            end
            kartYaw = m.faceAngle.y - driftTurn*64
            
            slideAcc = slideAcc * 1.5
            m.faceAngle.y = m.faceAngle.y - driftTurn*4
            e.targetVelX = (sins(m.faceAngle.y+((0x2000)*e.driftDir))*driftSpeed)+sins(m.faceAngle.y)*driftSpeed
            e.targetVelZ = (coss(m.faceAngle.y+((0x2000)*e.driftDir))*driftSpeed)+coss(m.faceAngle.y)*driftSpeed
            if e.driftTimer < 3 then
                e.driftTimer = e.driftTimer + kTbl.drift
            end
            if (m.controller.buttonDown & Z_TRIG) == 0 then
                if e.driftTimer > 1 then
                    charTbl[s.character].char_sound_yahoo(m)--play_sound(SOUND_OBJ_KOOPA_TALK, m.marioObj.header.gfx.cameraToObject)
                    e.boostSpd = 40+(math.floor(e.driftTimer)*6)
                    e.boostTimer = e.boostTimer + 10+10*math.floor(e.driftTimer)
                    e.boostState = BOOST_DRIFT
                end
                e.driftTimer = 0
                e.drifting = false
            end
        end
        local targetSpeed = 0x200
        if e.boostState ~= BOOST_DRIFT or e.drifting then
            targetSpeed = 0x400
        else
            targetSpeed = 0x100
        end
        e.targetYaw = kartYaw - approach_s32(convert_s16(kartYaw - e.targetYaw), 0, targetSpeed, targetSpeed)
        m.marioObj.header.gfx.angle.y = e.targetYaw+e.wobble*sins(get_network_area_timer()*0x2000)

        m.vel.x = approach_f32(m.vel.x, e.targetVelX, slideAcc, slideAcc)
        m.vel.z = approach_f32(m.vel.z, e.targetVelZ, slideAcc, slideAcc)
        if (m.controller.buttonPressed & Z_TRIG) ~= 0 then
            m.vel.y = 16
            e.driftDir = sign(m.controller.stickX)
            set_jumping_action(m, ACT_KART_AIR, 1)
        end
        if m.floor.type == SURFACE_HARD_NOT_SLIPPERY then
            m.pos.y = m.floorHeight + 0
            set_mario_action(m, ACT_KART_GLIDE, 0)
        end
    elseif (step == GROUND_STEP_LEFT_GROUND) then
        local floor = m.floor
        local slopeAngle = atan2s(floor.normal.z, floor.normal.x)
        local steepness = math.sqrt(floor.normal.x * floor.normal.x + floor.normal.z * floor.normal.z)
        m.vel.y = e.speed*steepness
        --djui_chat_message_create(tostring(steepness))
        set_mario_action(m, ACT_KART_AIR, 0)
    elseif (step == GROUND_STEP_HIT_WALL) then
        local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x)
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        local bounceSpd = 48*accFactor
        m.vel.x = sins(wallAngle)*bounceSpd
        m.vel.z = coss(wallAngle)*bounceSpd
        e.speed = e.speed * 0.02--math.sqrt(m.vel.x^2+m.vel.z^2)--e.speed * 0.98
        e.targetVelX = 0--(sins(m.faceAngle.y+((0x2000)*e.driftDir)))+sins(m.faceAngle.y)
        e.targetVelZ = 0--(coss(m.faceAngle.y+((0x2000)*e.driftDir)))+coss(m.faceAngle.y)
    end
    head_dir(m)
    return 0
end

local function act_kart_spin(m)
    local step = perform_ground_step(m)
    local spd = gGlobalSyncTable.speedSetting
    local e = gStateExtras[m.playerIndex]
    local s = gPlayerSyncTable[m.playerIndex]
    local kart = s.kart
    local wheel = s.wheel
    local character = s.character

    local kTbl = kartTbl[kart]
    local wTbl = wheelTbl[wheel]
    local cTbl = charTbl[character]

    local kTop = kTbl.top+wTbl.topSpd+cTbl.top+speedTbl[spd]
    local accFactor = math.min(math.abs(e.speed)/kTop, 1)
    if m.actionTimer == 0 then
        cTbl.char_sound_hurt(m)
    end

    m.actionTimer = m.actionTimer + 1
    
    if m.actionTimer > 30 then
        set_mario_action(m, ACT_KART_GROUND, 0)
    end
    -- Grounded
    if (step == GROUND_STEP_NONE) then
        -- Driving
        e.boostTimer = 0
        e.boostSpd = 0
        e.boostState = BOOST_NONE
        set_mario_animation(m, MARIO_ANIM_HOLDING_BOWSER)
        e.speed = approach_f32(e.speed, 0, 6, 6)
        e.targetVelX = sins(m.faceAngle.y)*e.speed
        e.targetVelZ = coss(m.faceAngle.y)*e.speed

        m.marioObj.header.gfx.angle.y = m.marioObj.header.gfx.angle.y + (30-m.actionTimer)*0x1000

        if m.wall ~= nil then
            local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x);
            local bounceSpd = 48*accFactor
            m.vel.x = m.vel.x + sins(wallAngle)*bounceSpd
            m.vel.z = m.vel.z + coss(wallAngle)*bounceSpd
        end
        local slideAcc = 12
        m.vel.x = approach_f32(m.vel.x, e.targetVelX, slideAcc, slideAcc)
        m.vel.z = approach_f32(m.vel.z, e.targetVelZ, slideAcc, slideAcc)
        m.vel.y = e.speed * (m.floorAngle)
    elseif (step == GROUND_STEP_LEFT_GROUND) then
        set_mario_action(m, ACT_KART_AIR, 0)
    elseif (step == GROUND_STEP_HIT_WALL) then
        local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x)
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        local bounceSpd = 48*accFactor
        m.vel.x = sins(wallAngle)*bounceSpd
        m.vel.z = coss(wallAngle)*bounceSpd
        e.speed = e.speed * 0.02
        e.targetVelX = 0
        e.targetVelZ = 0
    end
    return 0
end

local function act_kart_air(m)
    local step = perform_air_step(m, 0)
    local e = gStateExtras[m.playerIndex]
    local kart = e.kart
    local kAcc = kartTbl[kart].acc
    local kDcc = kartTbl[kart].dcc
    local kTop = kartTbl[kart].top
    local kFrc = kartTbl[kart].frc
    local accFactor = math.min(math.abs(e.speed)/kTop, 1)
    -- Grounded
    if (step == AIR_STEP_NONE) then
        local accMin = kFrc
        local accMax = kTop*0.04

        local acc = lerp(accMin, accMax, accFactor)
        if m.vel.y < 0 then
            e.angleX = approach_f32(e.angleX, -0x2000, 0x0100, 0x0100) 
        end
        m.marioObj.header.gfx.angle.x = e.angleX
        e.targetVelX = sins(m.faceAngle.y)*e.speed
        e.targetVelZ = coss(m.faceAngle.y)*e.speed

        if (e.boostTimer > 0) then
            e.boostTimer = e.boostTimer - 1
        end

        if (not e.drifting) then
            local turnSpeed = 6*math.max(accFactor, 0.8)

            m.faceAngle.y = m.faceAngle.y - m.controller.stickX*turnSpeed
            e.targetYaw = e.targetYaw - m.controller.stickX*turnSpeed
        end
        if m.wall ~= nil then
            local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x);
            local bounceSpd = 48*accFactor
            m.vel.x = m.vel.x + sins(wallAngle)*bounceSpd
            m.vel.z = m.vel.z + coss(wallAngle)*bounceSpd
        end

        -- Drifting
        if (e.drifting) then
            local driftTurn = (64*e.driftDir)+(m.controller.stickX-(20*e.driftDir))
            local driftSpeed = e.speed*0.5
            m.faceAngle.y = m.faceAngle.y - driftTurn*4
            e.targetYaw = e.targetYaw - driftTurn*4
            e.targetVelX = (sins(m.faceAngle.y+((0x2000)*e.driftDir))*driftSpeed)+sins(m.faceAngle.y)*driftSpeed
            e.targetVelZ = (coss(m.faceAngle.y+((0x2000)*e.driftDir))*driftSpeed)+coss(m.faceAngle.y)*driftSpeed
            if (m.controller.buttonDown & Z_TRIG) == 0 then
                e.driftDir = sign(m.controller.stickX)
            end
        end
        m.marioObj.header.gfx.angle.y = e.targetYaw
        m.vel.x = approach_f32(m.vel.x, e.targetVelX, acc, acc)
        m.vel.z = approach_f32(m.vel.z, e.targetVelZ, acc, acc)

        

    elseif (step == AIR_STEP_LANDED) then
        if (m.controller.buttonDown & Z_TRIG) ~= 0 and e.driftDir == 0 then
            e.driftDir = sign(m.controller.stickX)
        end
        if (m.controller.buttonDown & Z_TRIG) ~= 0 and math.abs(m.controller.stickX) > 0.3 and e.speed >= driftMinSpeed and e.driftDir ~= 0 then
            e.drifting = true
            e.driftPower = -e.driftDir

        else
            e.drifting = false
            e.driftDir = 0
            e.driftPower = 0
            e.driftTimer = 0
        end
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        --djui_chat_message_create(tostring(m.vel.y))
        if m.vel.y < -50 and m.actionArg == 0 then
            m.vel.y = 16--m.vel.y * -0.4
            m.actionArg = 1
        else
            set_mario_action(m, ACT_KART_GROUND, 0)
        end
    elseif (step == AIR_STEP_HIT_WALL) then
        local wallAngle = atan2s(m.wallNormal.z, m.wallNormal.x)
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        local bounceSpd = 48*accFactor
        m.vel.x = sins(wallAngle)*bounceSpd
        m.vel.z = coss(wallAngle)*bounceSpd
        e.speed = e.speed * 0.5
    end
    return 0
end
local function act_kart_glide(m)
    local step = perform_air_step(m, 0)
    local e = gStateExtras[m.playerIndex]

    if step == AIR_STEP_NONE then
        if m.floor.type ~= SURFACE_VERTICAL_WIND and e.glideMomentum <= 0 then
            if m.actionTimer < 120 then
                m.actionTimer = m.actionTimer + 1
            end
        else
            if m.actionTimer > 30 then
                m.actionTimer = m.actionTimer - 1
            else
                m.actionTimer = m.actionTimer + 1
            end
        end
        if e.glideMomentum > 0 then
            e.glideMomentum = e.glideMomentum - 1
        end
        e.speed = (140-(m.actionTimer*0.4))*coss(m.faceAngle.x*0.4)
        m.vel.x = (e.speed * sins(m.faceAngle.y))
        m.vel.z = (e.speed * coss(m.faceAngle.y))
        m.vel.y = (e.speed * sins(m.faceAngle.x)) - m.actionTimer*0.8 + e.glideMomentum*0.5
        
        if m.vel.y < -30 and e.glideMomentum < 30 and e.turnTargetY >= 32 then
            e.glideMomentum = 30--e.glideMomentum + 1
        end
        
        m.faceAngle.x = -(-0x400+e.turnTargetY*64)
        m.faceAngle.y = m.faceAngle.y - e.turnTargetX*4
        m.faceAngle.z = e.turnTargetX*100
        m.marioObj.header.gfx.angle.x = -m.faceAngle.x
        m.marioObj.header.gfx.angle.z = m.faceAngle.z
    elseif step == AIR_STEP_LANDED then
        if m.floor.type ~= SURFACE_HARD_NOT_SLIPPERY then
            set_mario_action(m, ACT_KART_AIR, 0)
        else
            m.pos.y = m.floorHeight + 60
            m.vel.x = (e.speed * sins(m.faceAngle.y))
            m.vel.z = (e.speed * coss(m.faceAngle.y))
            m.vel.y = (e.speed * sins(m.faceAngle.x))
        end
    end
end

function act_kart_menu(m)
    local step = perform_ground_step(m)
    m.pos.y = m.floorHeight
    if step == GROUND_STEP_NONE then
        m.pos.x = 0
        m.pos.z = 0
        m.vel.x = 0
        m.vel.z = 0
        m.faceAngle.y = m.faceAngle.y + 0x0100
        set_mario_animation(m, MARIO_ANIM_HOLDING_BOWSER)
    end
    return 0
end

function act_kart_bullet(m)
    local step = perform_air_step(m, AIR_STEP_CHECK_LEDGE_GRAB)
    
    m.pos.y = m.floorHeight+80
    -- Grounded
    if (step == AIR_STEP_NONE) then
        local e = gStateExtras[m.playerIndex]
        local nextCheckpoint = get_checkpoint(e.checkpoint+1)
        local angleToCheck = obj_angle_to_point(m.marioObj, nextCheckpoint[1], nextCheckpoint[3])
        --djui_chat_message_create(tostring(m.actionTimer))

        cur_obj_hide()

        m.actionTimer = m.actionTimer + 1

        --m.faceAngle.y = approach_f32(m.faceAngle.y, angleToCheck, 0x1000, 0x1000)
        m.faceAngle.y = angleToCheck - approach_s32(convert_s16(angleToCheck - m.faceAngle.y), 0, 0x2000, 0x2000)
        if m.actionArg == 0 then
            e.speed = 280
        else
            e.speed = approach_f32(e.speed, 100, 6, 6)
            if m.actionTimer > 130 then
                
                --m.pos.y = m.floorHeight+40+(e.speed*0.4)
                set_mario_action(m, ACT_KART_AIR, 0)
            end
        end
        e.targetVelX = sins(m.faceAngle.y)*e.speed
        e.targetVelZ = coss(m.faceAngle.y)*e.speed

        m.vel.x = e.targetVelX--approach_f32(m.vel.x, e.targetVelX, acc, acc)
        m.vel.z = e.targetVelZ--approach_f32(m.vel.z, e.targetVelZ, acc, acc)

        if m.actionTimer > 100 then
            m.actionArg = 1
            --set_mario_action(m, ACT_KART_AIR, 0)
        end
    end

    return 0
end

hook_mario_action(ACT_KART_GROUND, act_kart_ground)
hook_mario_action(ACT_KART_SPECTATE, act_kart_spectate)
hook_mario_action(ACT_KART_START, act_kart_start)
hook_mario_action(ACT_KART_SPIN, act_kart_spin)
hook_mario_action(ACT_KART_AIR, act_kart_air)
hook_mario_action(ACT_KART_GLIDE, act_kart_glide)
hook_mario_action(ACT_KART_MENU, act_kart_menu)
hook_mario_action(ACT_KART_BULLET, act_kart_bullet)
