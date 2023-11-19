-- Init

E_MODEL_STANDARD = smlua_model_util_get_id("standard_geo")
E_MODEL_B_DASHER = smlua_model_util_get_id("b_dasher_geo")
E_MODEL_STREAMLINER = smlua_model_util_get_id("streamliner_geo")
E_MODEL_MUSHMELLOW = smlua_model_util_get_id("mushmellow_geo")
E_MODEL_ZIPPER = smlua_model_util_get_id("zipper_geo")
E_MODEL_BRUTE = smlua_model_util_get_id("brute_geo")
E_MODEL_MR_SCOOTY = smlua_model_util_get_id("mr_scooty_geo")

E_MODEL_STANDARD_WHEEL = smlua_model_util_get_id("wheel_standard_geo")
E_MODEL_MONSTER_WHEEL = smlua_model_util_get_id("wheel_monster_geo")
E_MODEL_ROLLER_WHEEL = smlua_model_util_get_id("wheel_roller_geo")

E_MODEL_STANDARD_GLIDER = smlua_model_util_get_id("standard_glider_geo")

E_MODEL_KOOPA_PLAYER = smlua_model_util_get_id("koopa_player_geo")
E_MODEL_PEACH = smlua_model_util_get_id("peach_geo")
E_MODEL_DAISY = smlua_model_util_get_id("daisy_geo")

KART_STANDARD = 0
KART_B_DASHER = 1
KART_STREAMLINER = 2
KART_MUSHMELLOW = 3
KART_ZIPPER = 4
KART_BRUTE = 5
KART_MR_SCOOTY = 6
KART_MAX = 7

WHEEL_STANDARD = 0
WHEEL_MONSTER = 1
WHEEL_ROLLER = 2
WHEEL_MAX = 3

GLIDER_STANDARD = 0
GLIDER_MAX = 1

--- @type CharacterType
CT_KOOPA = CT_MAX
--- @type CharacterType
CT_PEACH = CT_MAX+1
--- @type CharacterType
CT_DAISY = CT_MAX+2

function is_in_menu()
    return gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE_GROUNDS
end

SPD_50CC = 0
SPD_100CC = 1
SPD_150CC = 2
SPD_200CC = 3

speedTbl = {
    [SPD_50CC] = 20,
    [SPD_100CC] = 40,
    [SPD_150CC] = 60,
    [SPD_200CC] = 80,
}

local statsTex = get_texture_info("hud-kart-stats")
function render_kart_stats(x, y)
    local s = gPlayerSyncTable[0]
    local spd = gGlobalSyncTable.speedSetting

    local kart = s.kart
    local wheel = s.wheel
    local character = s.character

    local kTbl = kartTbl[kart]
    local wTbl = wheelTbl[wheel]
    local cTbl = charTbl[character]

    local kAcc = kTbl.acc+wTbl.acc+cTbl.acc
    local kDcc = kTbl.dcc
    local kTop = kTbl.top+wTbl.topSpd+cTbl.top
    local kDft = kTbl.drift
    
    local highestTop = 130
    local highestAcc = 4.8
    local highestDcc = 3
    local highestDrift = 0.05

    local rTop = kTop/highestTop
    local rAcc = kAcc/highestAcc
    local rDcc = kDcc/highestDcc
    local rDft = kDft/highestDrift

    djui_hud_set_color(255,255,255,255)
    djui_hud_render_texture(statsTex, x-1, y, 1, 1)
    djui_hud_set_color(180,225,255,255)
    djui_hud_render_rect(x, y+8, math.floor(rTop*85), 4)
    djui_hud_render_rect(x, y+20, math.floor(rAcc*85), 4)
    djui_hud_render_rect(x, y+32, math.floor(rDcc*85), 4)
    djui_hud_render_rect(x, y+44, math.floor(rDft*85), 4)
    
end

wheelTbl = {
    [WHEEL_STANDARD] = {
        acc = 0.5,
        topSpd = 0,
        yOffset = 0,
        model = E_MODEL_STANDARD_WHEEL,
        offroad = 0.3,
        zOffset = 0,
        name = "Standard Wheel",
    },
    [WHEEL_MONSTER] = {
        acc = 0.4,
        topSpd = -15,
        yOffset = 20,
        model = E_MODEL_MONSTER_WHEEL,
        offroad = 0.7,
        zOffset = 20,
        name = "Monster",
    },
    [WHEEL_ROLLER] = {
        acc = 1,
        topSpd = -10,
        yOffset = -5,
        model = E_MODEL_ROLLER_WHEEL,
        offroad = 0.2,
        zOffset = -10,
        name = "Roller",
    },
}

kartTbl = {
    [KART_STANDARD] = {
        acc = 1.5,
        dcc = 3,
        top = 90,
        weight = 0.5,
        frc = 0.5,
        drift = 0.03,
        model = E_MODEL_STANDARD,
        wheel_f = {
            x = 40, y = 20, z = 45, size = 1
        },
        wheel_b = {
            x = 70, y = 25, z = 60, size = 1.4
        },
        yOffset = 0,
        gliderZ = -65,
        name = "Standard Kart",
    },
    [KART_B_DASHER] = {
        acc = 2,
        dcc = 2,
        top = 105,
        weight = 0.4,
        frc = 0.4,
        drift = 0.02,
        model = E_MODEL_B_DASHER,
        wheel_f = {
            x = 80, y = 20, z = 50, size = 1
        },
        wheel_b = {
            x = 60, y = 22, z = 60, size = 1.2
        },
        yOffset = 0,
        gliderZ = -55,
        name = "B Dasher",
    },
    [KART_STREAMLINER] = {
        acc = 0.5,
        dcc = 2,
        top = 110,
        weight = 0.3,
        frc = 0.6,
        drift = 0.01,
        model = E_MODEL_STREAMLINER,
        wheel_f = {
            x = 80, y = 20, z = 65, size = 1
        },
        wheel_b = {
            x = 60, y = 25, z = 70, size = 1.4
        },
        yOffset = 0,
        gliderZ = -60,
        name = "Streamliner",
    },
    [KART_MUSHMELLOW] = {
        acc = 3,
        dcc = 2,
        top = 90,
        weight = 0.2,
        frc = 0.6,
        drift = 0.04,
        model = E_MODEL_MUSHMELLOW,
        wheel_f = {
            x = 40, y = 20, z = 60, size = 1
        },
        wheel_b = {
            x = 40, y = 20, z = 60, size = 1
        },
        yOffset = 40,
        gliderZ = -60,
        name = "Mushmellow",
    },
    [KART_ZIPPER] = {
        acc = 1,
        dcc = 3,
        top = 105,
        weight = 0.4,
        frc = 0.5,
        drift = 0.04,
        model = E_MODEL_ZIPPER,
        wheel_f = {
            x = 110, y = 20, z = 0, size = 1
        },
        wheel_b = {
            x = 60, y = 30, z = 50, size = 1.4
        },
        yOffset = 0,
        gliderZ = -60,
        name = "Zipper",
    },
    [KART_BRUTE] = {
        acc = 0.8,
        dcc = 3,
        top = 120,
        weight = 0.7,
        frc = 0.6,
        drift = 0.005,
        model = E_MODEL_BRUTE,
        wheel_f = {
            x = 80, y = 20, z = 75, size = 1
        },
        wheel_b = {
            x = 60, y = 20, z = 75, size = 1
        },
        yOffset = 0,
        gliderZ = -40,
        name = "Brute",
    },
    [KART_MR_SCOOTY] = {
        acc = 2.5,
        dcc = 3,
        top = 90,
        weight = 0.6,
        frc = 0.8,
        drift = 0.05,
        model = E_MODEL_MR_SCOOTY,
        wheel_f = {
            x = 60, y = 20, z = 0, size = 1
        },
        wheel_b = {
            x = 60, y = 20, z = 0, size = 1
        },
        yOffset = 40,
        gliderZ = -40,
        name = "Mr Scooty",
    },
}

gliderTbl = {
    [GLIDER_STANDARD] = {
        model = E_MODEL_STANDARD_GLIDER,
    },
}

charTbl = {
    [CT_MARIO] = {
        char_sound_yahoo = function(m) play_character_sound(m, CHAR_SOUND_YAHOO) end,
        char_sound_item = function(m) play_character_sound(m, CHAR_SOUND_PUNCH_YAH) end,
        char_sound_hurt = function(m) play_character_sound(m, CHAR_SOUND_WAAAOOOW) end,
        model = E_MODEL_MARIO,
        weight = 2,
        acc = 0.5,
        top = 0,
        name = "Mario",
        yOffset = 0,
        ct = CT_MARIO,
    },
    [CT_LUIGI] = {
        char_sound_yahoo = function(m) play_character_sound(m, CHAR_SOUND_YAHOO) end,
        char_sound_item = function(m) play_character_sound(m, CHAR_SOUND_PUNCH_YAH) end,
        char_sound_hurt = function(m) play_character_sound(m, CHAR_SOUND_WAAAOOOW) end,
        model = E_MODEL_LUIGI,
        weight = 1.5,
        acc = 0.4,
        top = -5,
        name = "Luigi",
        yOffset = 0,
        ct = CT_LUIGI,
    },
    [CT_TOAD] = {
        char_sound_yahoo = function(m) play_character_sound(m, CHAR_SOUND_YAHOO) end,
        char_sound_item = function(m) play_character_sound(m, CHAR_SOUND_PUNCH_YAH) end,
        char_sound_hurt = function(m) play_character_sound(m, CHAR_SOUND_WAAAOOOW) end,
        model = E_MODEL_TOAD_PLAYER,
        weight = 1,
        acc = 0.8,
        top = 0,
        name = "Toad",
        yOffset = 20,
        ct = CT_TOAD,
    },
    [CT_WALUIGI] = {
        char_sound_yahoo = function(m) play_character_sound(m, CHAR_SOUND_YAHOO) end,
        char_sound_item = function(m) play_character_sound(m, CHAR_SOUND_PUNCH_YAH) end,
        char_sound_hurt = function(m) play_character_sound(m, CHAR_SOUND_WAAAOOOW) end,
        model = E_MODEL_WALUIGI,
        weight = 2.5,
        acc = 0.2,
        top = 8,
        name = "Waluigi",
        yOffset = 0,
        ct = CT_WALUIGI,
    },
    [CT_WARIO] = {
        char_sound_yahoo = function(m) play_character_sound(m, CHAR_SOUND_YAHOO) end,
        char_sound_item = function(m) play_character_sound(m, CHAR_SOUND_PUNCH_YAH) end,
        char_sound_hurt = function(m) play_character_sound(m, CHAR_SOUND_WAAAOOOW) end,
        model = E_MODEL_WARIO,
        weight = 4.5,
        acc = -0.3,
        top = 10,
        name = "Wario",
        yOffset = 0,
        ct = CT_WARIO,
    },
    [CT_KOOPA] = {
        char_sound_yahoo = function(m) play_sound(SOUND_OBJ_KOOPA_TALK, m.marioObj.header.gfx.cameraToObject) end,
        char_sound_item = function(m) play_sound(SOUND_OBJ_KOOPA_DAMAGE, m.marioObj.header.gfx.cameraToObject) end,
        char_sound_hurt = function(m) play_sound(SOUND_OBJ_KOOPA_FLYGUY_DEATH, m.marioObj.header.gfx.cameraToObject) end,
        model = E_MODEL_KOOPA_PLAYER,
        weight = 2.5,
        acc = 0.5,
        top = 0,
        name = "Koopa",
        yOffset = 0,
        ct = CT_MARIO,
    },
    [CT_PEACH] = {
        char_sound_yahoo = function(m) play_sound(SOUND_PEACH_MARIO2, m.marioObj.header.gfx.cameraToObject) end,
        char_sound_item = function(m) play_sound(SOUND_PEACH_SOMETHING_SPECIAL, m.marioObj.header.gfx.cameraToObject) end,
        char_sound_hurt = function(m) play_sound(SOUND_PEACH_THANKS_TO_YOU, m.marioObj.header.gfx.cameraToObject) end,
        model = E_MODEL_PEACH,
        weight = 1.5,
        acc = 0.3,
        top = 0,
        name = "Peach",
        yOffset = 0,
        ct = CT_TOAD,
    },
    [CT_DAISY] = {
        char_sound_yahoo = function(m) play_sound_with_freq_scale(SOUND_PEACH_MARIO2, m.marioObj.header.gfx.cameraToObject, 0.9) end,
        char_sound_item = function(m) play_sound_with_freq_scale(SOUND_PEACH_SOMETHING_SPECIAL, m.marioObj.header.gfx.cameraToObject, 0.9) end,
        char_sound_hurt = function(m) play_sound_with_freq_scale(SOUND_PEACH_THANKS_TO_YOU, m.marioObj.header.gfx.cameraToObject, 0.9) end,
        model = E_MODEL_DAISY,
        weight = 1.3,
        acc = 0.6,
        top = -5,
        name = "Daisy",
        yOffset = 0,
        ct = CT_TOAD,
    },
}


BOOST_NONE = 0
BOOST_DRIFT = 1
BOOST_ITEM = 2

gStateExtras = {}

for i = 0, (MAX_PLAYERS - 1) do
    gStateExtras[i] = {}
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

    e.kart = KART_B_DASHER
    e.wheel = WHEEL_STANDARD

    e.angleX = 0
    e.checkpoint = 1

    e.boostState = BOOST_NONE

    e.glideMomentum = 0

    e.targetYaw = 0

    e.wobble = 0
end

gGlobalSyncTable.speedSetting = SPD_200CC
gGlobalSyncTable.itemSetting = ITEMS_REGULAR

speedStringTbl = {
    [SPD_50CC] = "50cc",
    [SPD_100CC] = "100cc",
    [SPD_150CC] = "150cc",
    [SPD_200CC] = "200cc",
}

ITEMS_DISABLED = 0
ITEMS_REGULAR = 1
ITEMS_FRANTIC = 2

itemStringTbl = {
    [ITEMS_DISABLED] = "No Items",
    [ITEMS_REGULAR] = "Regular Items",
    [ITEMS_FRANTIC] = "Frantic Items",
}

ITEM_NONE = 0
ITEM_BANANA = 1
ITEM_MUSHROOM = 2
ITEM_DOUBLE_MUSHROOM = 3
ITEM_TRIPLE_MUSHROOM = 4
ITEM_GREEN_SHELL = 5
ITEM_DOUBLE_GREEN_SHELL = 6
ITEM_TRIPLE_GREEN_SHELL = 7
ITEM_RED_SHELL = 8
ITEM_DOUBLE_RED_SHELL = 9
ITEM_TRIPLE_RED_SHELL = 10
ITEM_BLUE_SHELL = 11
ITEM_BULLET_BILL = 12
ITEM_STAR = 13

for i = 0, (MAX_PLAYERS - 1) do
    gPlayerSyncTable[i].kart = KART_STANDARD
    gPlayerSyncTable[i].wheel = WHEEL_STANDARD
    gPlayerSyncTable[i].character = CT_MARIO
    gPlayerSyncTable[i].lap = 1
    gPlayerSyncTable[i].score = 0
    gPlayerSyncTable[i].points = 0
    gPlayerSyncTable[i].spectating = false
    gPlayerSyncTable[i].item = {}
    for o = 1, 1 do
        gPlayerSyncTable[i].item[o] = ITEM_NONE
    end
end



texRank = get_texture_info("hud-ranks")
texItemWheel = get_texture_info("hud-item-background")

texMapMarioCircuit3 = get_texture_info("hud-map-mc3")

texCharBox = get_texture_info("hud-char-box")
texCharSelect = get_texture_info("hud-char-select")
texVehicleIcons = get_texture_info("hud-vehicle-parts")
texCharacterIcons = get_texture_info("hud-chars")

texFont = get_texture_info("hud-font")

hudTbl = {
    [1] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 0, 0, 64, 64) end, -- 1st
    },
    [2] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 64, 0, 64, 64) end, -- 2nd
    },
    [3] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 128, 0, 64, 64) end, -- 3rd
    },
    [4] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 192, 0, 64, 64) end, -- 4th
    },
    [5] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 0, 64, 64, 64) end, -- 1st
    },
    [6] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 64, 64, 64, 64) end, -- 2nd
    },
    [7] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 128, 64, 64, 64) end, -- 3rd
    },
    [8] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 192, 64, 64, 64) end, -- 4th
    },

    [9] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 0, 128, 64, 64) end, -- 1st
    },
    [10] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 64, 128, 64, 64) end, -- 2nd
    },
    [11] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 128, 128, 64, 64) end, -- 3rd
    },
    [12] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 192, 128, 64, 64) end, -- 4th
    },
    [13] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 0, 192, 64, 64) end, -- 1st
    },
    [14] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 64, 192, 64, 64) end, -- 2nd
    },
    [15] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 128, 192, 64, 64) end, -- 3rd
    },
    [16] = {
        rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 192, 192, 64, 64) end, -- 4th
    },
}

--[[fontTbl = {
    [97] = {
        x = 0, y = 0--rend = function(x, y) djui_hud_render_texture_tile(texRank, x, y, 1, 1, 0, 0, 64, 64) end, -- 1st
    },
}]]

function render_text(message, font, x, y)
    local xOffset = 0
    for i=1, string.len(message) do
        local char = string.sub(message, i, i)
        if not tonumber(char) and not (char == "/") then
            local column = (string.byte(char)-97)%16
            local row = math.floor((string.byte(char)-97)/16)
            
            if char ~= " " then
                djui_hud_render_texture_tile(texFont, math.floor(x+i*14)+xOffset, math.floor(y), 1, 1, column*16, row*16, 16, 16)
            end
            if char == "i" then
                xOffset = xOffset - 8
            end
        else
            local column = (string.byte(char)-47)%16
            local row = math.floor((string.byte(char)-47)/16)
            if char == "1" then
                --xOffset = xOffset - 8
            end
            djui_hud_render_texture_tile(texFont, math.floor(x+i*14)+xOffset, math.floor(y), 1, 1, column*16, (row*16)+128, 16, 16)
        end
    end
end

cameraRot = 64000

function reset_game()
    gGlobalSyncTable.startTimer = 7*30
    gGlobalSyncTable.endTimer = -10*30
    for i=0, MAX_PLAYERS-1 do
        local s = gPlayerSyncTable[i]
        local e = gStateExtras[i]
        s.lap = 1
        s.score = 0
        for o = 1, 1 do
            gPlayerSyncTable[i].item[o] = ITEM_NONE
        end
    end
end

menuTbl = {
    [1] = {
        x = 0,
        mX = 3,
        y = 0,
        mY = 1,
    },
    [2] = {
        [1] = {CT_MARIO, CT_LUIGI, CT_TOAD, CT_KOOPA},
        [2] = {CT_WARIO, CT_WALUIGI, CT_PEACH, CT_DAISY},
    },
    -- Kart and Wheels
    [3] = {
        x = 0,
        mX = 1,
        k = 0,
        w = 0,
    },
    -- Settings
    [4] = {
        y = 0,
        mY = 2,
        spd = SPD_150CC,
        items = ITEMS_REGULAR,
    }
}

function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end
