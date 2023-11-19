-- Music Controller

local musCircuit = audio_stream_load("SNES-Mario-Circuit.mp3")
local musMenu1 = audio_stream_load("Menu-Character.mp3")
local musMenu2 = audio_stream_load("Menu-Kart.mp3")
local musMenu3 = audio_stream_load("Menu-Wait.mp3")

TRACK_MARIO_CIRCUIT_3 = 1
TRACK_MAX = 2


local trackA = musMenu1
local trackB = musMenu2
local trackC = musMenu3

mscTbl = {
    [TRACK_MARIO_CIRCUIT_3] = {
        loop = 30.857,
        mus = musCircuit,
    },
}


local function backround_music()
    local track = mscTbl[TRACK_MARIO_CIRCUIT_3].mus
    local trackPos = audio_stream_get_position(musCircuit)
    local loop = mscTbl[TRACK_MARIO_CIRCUIT_3].loop
    local lap = gPlayerSyncTable[0].lap

    if lap < 3 then
        lap = 0
    end

    --if not audio_sample
    audio_stream_set_speed(track, 24000+lap*1000, 1, true)
    audio_stream_play(track, false, 0.6)
    if trackPos > loop+1 then
        audio_stream_set_position(track, trackPos-loop)--trackPos-loop)
    end
end

volA = 1
volB = 0
volC = 0

local function menu_music()
    local loop = 21.94
    local trackPos = audio_stream_get_position(musMenu1)

    local volATarget = 0
    local volBTarget = 0
    local volCTarget = 0

    if menu == MENU_CHARACTER then
        volATarget = 1
        volBTarget = 0
        volCTarget = 0
    elseif menu == MENU_KART then
        volATarget = 0
        volBTarget = 1
        volCTarget = 0
    else
        volATarget = 0
        volBTarget = 0
        volCTarget = 1
    end

    if volA > volATarget then
        volA = volA - 0.02
    else
        volA = volA + 0.02
    end
    volA = clamp(volA, 0, 1)

    if volB > volBTarget then
        volB = volB - 0.02
    else
        volB = volB + 0.02
    end
    volB = clamp(volB, 0, 1)

    if volC > volCTarget then
        volC = volC - 0.02
    else
        volC = volC + 0.02
    end
    volC = clamp(volC, 0, 1)
    --approach_f32(volA, volATarget, 0.02, 0.02)
    --approach_f32(volB, volBTarget, 0.02, 0.02)
    --approach_f32(volC, volCTarget, 0.02, 0.02)
    
    audio_stream_play(trackA, false, 0)
    audio_stream_play(trackB, false, 0)
    audio_stream_play(trackC, false, 0)

    if trackPos > loop+1 then
        audio_stream_set_position(trackA, trackPos-loop)--trackPos-loop)
        audio_stream_set_position(trackB, trackPos-loop)--trackPos-loop)
        audio_stream_set_position(trackC, trackPos-loop)--trackPos-loop)
    end
    audio_stream_set_volume(trackA, volA)
    audio_stream_set_volume(trackB, volB)
    audio_stream_set_volume(trackC, volC)
end

function music()
    if is_in_menu() then
        audio_stream_stop(mscTbl[TRACK_MARIO_CIRCUIT_3].mus)
        audio_stream_set_position(mscTbl[TRACK_MARIO_CIRCUIT_3].mus, 0)
        menu_music()
        return
    else
        audio_stream_stop(trackA)
        audio_stream_stop(trackB)
        audio_stream_stop(trackC)
        audio_stream_set_position(trackA, 0)
        audio_stream_set_position(trackB, 0)
        audio_stream_set_position(trackC, 0)
    end
    if gNetworkPlayers[0].currLevelNum == LEVEL_BOB then
        backround_music()
    end

    local m = gMarioStates[0]
    local s = gPlayerSyncTable[0]
    local wheel = s.wheel
end

