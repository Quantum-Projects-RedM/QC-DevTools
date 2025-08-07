--=========================================================
-- QC-DEVTOOLS - AUDIO MODULE (Based on wd_audiodev)
--=========================================================
-- Complete rewrite using working wd_audiodev structure
-- Adapted for QC-DevTools NUI menu system
--=========================================================

local is_frontend_sound_playing = false
local cached_createstream = {}
local cached_music_events = {}
local cached_frontend_soundsets = {}
local cached_audio_flags = {}
local cached_audio_banks = {}
local active_streams = {}
local active_music = {}

-- Speech functions from wd_audiodev (working implementation)
local function play_ambient_speech_from_entity(entity_id, sound_ref_string, sound_name_string, speech_params_string, speech_line)
    local struct = DataView.ArrayBuffer(128)
    local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string, Citizen.ResultAsLong())
    local sound_ref = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_ref_string, Citizen.ResultAsLong())
    local speech_params = GetHashKey(speech_params_string)
    local sound_name_BigInt = DataView.ArrayBuffer(16)
    sound_name_BigInt:SetInt64(0, sound_name)
    local sound_ref_BigInt = DataView.ArrayBuffer(16)
    sound_ref_BigInt:SetInt64(0, sound_ref)
    local speech_params_BigInt = DataView.ArrayBuffer(16)
    speech_params_BigInt:SetInt64(0, speech_params)
    struct:SetInt64(0, sound_name_BigInt:GetInt64(0))
    struct:SetInt64(8, sound_ref_BigInt:GetInt64(0))
    struct:SetInt32(16, speech_line)
    struct:SetInt64(24, speech_params_BigInt:GetInt64(0))
    struct:SetInt32(32, 0)
    struct:SetInt32(40, 1)
    struct:SetInt32(48, 1)
    struct:SetInt32(56, 1)
    Citizen.InvokeNative(0x8E04FEDD28D42462, entity_id, struct:Buffer())
end

-- Function to play ambient speech from a position
local function play_ambient_speech_from_position(x, y, z, sound_ref_string, sound_name_string, speech_line)
    local struct = DataView.ArrayBuffer(128)
    local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string, Citizen.ResultAsLong())
    local sound_ref = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_ref_string, Citizen.ResultAsLong())
    local sound_name_BigInt = DataView.ArrayBuffer(16)
    sound_name_BigInt:SetInt64(0, sound_name)
    local sound_ref_BigInt = DataView.ArrayBuffer(16)
    sound_ref_BigInt:SetInt64(0, sound_ref)
    local speech_params_BigInt = DataView.ArrayBuffer(16)
    speech_params_BigInt:SetInt64(0, 291934926)
    struct:SetInt64(0, sound_name_BigInt:GetInt64(0))
    struct:SetInt64(8, sound_ref_BigInt:GetInt64(0))
    struct:SetInt32(16, speech_line)
    struct:SetInt64(24, speech_params_BigInt:GetInt64(0))
    struct:SetInt32(32, 0)
    struct:SetInt32(40, 1)
    struct:SetInt32(48, 1)
    struct:SetInt32(56, 1)
    Citizen.InvokeNative(0xED640017ED337E45, x, y, z, struct:Buffer())
end

-- Categorize music events function from wd_audiodev
function categorizeMusicEvents(events)
    local categories = {}

    for _, event in ipairs(events) do
        local prefix = event:match("^(.+)_")
        if prefix then
            if not categories[prefix] then
                categories[prefix] = {}
            end
            table.insert(categories[prefix], event)
        end
    end

    return categories
end

-- Initialize cached data
CreateThread(function()
    Wait(1000) -- Wait for all data files to load
    
    cached_createstream = createStream
    cached_music_events = categorizeMusicEvents(music_events)
    cached_frontend_soundsets = frontend_soundsets
    cached_audio_flags = audio_flags
    cached_audio_banks = audiobanks
    
    print('[QC-DevTools] Audio system initialized with wd_audiodev data')
    print(string.format('[QC-DevTools] Loaded: %d createstreams, %d music categories, %d frontend soundsets, %d audio flags, %d audio banks',
        #cached_createstream, #cached_music_events, #cached_frontend_soundsets, #cached_audio_flags, #cached_audio_banks))
end)

-- CreateStream Functions (from wd_audiodev)
local function playCreateStream(soundSet, streamName)
    local timeout = 0
    while not LoadStream(soundSet, streamName) do
        Wait(1)
        timeout = timeout + 1
        if timeout > 200 then
            break
        end
    end
    local streamedMusic = Citizen.InvokeNative(0x0556C784FA056628, soundSet, streamName)
    PlayStreamFromPed(PlayerPedId(), streamedMusic)
    
    active_streams[soundSet .. "_" .. streamName] = {
        streamedMusic = streamedMusic,
        soundSet = soundSet,
        streamName = streamName,
        startedAt = GetGameTimer()
    }
    
    -- Auto-copy stream name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = streamName,
        description = 'Stream Playing: ' .. streamName .. ' (' .. soundSet .. ')'
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Stream Playing',
        message = string.format('Playing "%s" (%s)', streamName, soundSet),
        type = 'success',
        duration = 3000
    })
    
    TriggerServerEvent('qc-devtools:server:logAction', 'Play CreateStream', string.format('%s - %s', streamName, soundSet))
end

local function stopCreateStream(streamedMusic)
    StopStream(streamedMusic)
    
    -- Remove from active streams
    for key, stream in pairs(active_streams) do
        if stream.streamedMusic == streamedMusic then
            active_streams[key] = nil
            break
        end
    end
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Stream Stopped',
        message = 'Audio stream stopped',
        type = 'info',
        duration = 2000
    })
end

-- Music Event Functions (from wd_audiodev)
local function playMusicEvent(eventName)
    PrepareMusicEvent(eventName)
    Wait(100)
    TriggerMusicEvent(eventName)
    
    active_music[eventName] = {
        eventName = eventName,
        startedAt = GetGameTimer()
    }
    
    -- Auto-copy music event name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = eventName,
        description = 'Music Event Playing: ' .. eventName
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Music Event Playing',
        message = string.format('Playing "%s"', eventName),
        type = 'success',
        duration = 3000
    })
    
    TriggerServerEvent('qc-devtools:server:logAction', 'Play Music Event', eventName)
end

local function stopMusicEvent(eventName)
    CancelMusicEvent(eventName)
    Citizen.InvokeNative(0x706D57B0F50DA710, "MC_MUSIC_STOP")
    
    active_music[eventName] = nil
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Music Event Stopped',
        message = string.format('Stopped "%s"', eventName),
        type = 'info',
        duration = 2000
    })
end

-- Frontend Soundset Functions (from wd_audiodev)
local function playFrontendSoundset(soundsetRef, soundsetName)
    if not is_frontend_sound_playing then
        if soundsetRef ~= 0 then
            Citizen.InvokeNative(0x0F2A2175734926D8, soundsetName, soundsetRef)
        end
        Citizen.InvokeNative(0x67C540AA08E4A6F5, soundsetName, soundsetRef, true, 0)
        is_frontend_sound_playing = true
        
        -- Auto-copy sound name to clipboard
        TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
            text = soundsetName,
            description = 'Frontend Sound Playing: ' .. soundsetName
        })
        
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Frontend Sound Playing',
            message = string.format('Playing "%s" (%s)', soundsetName, soundsetRef),
            type = 'success',
            duration = 3000
        })
        
        Citizen.SetTimeout(3000, function()
            Citizen.InvokeNative(0x9D746964E0CF2C5F, soundsetName, soundsetRef)
            is_frontend_sound_playing = false
        end)
    else
        Citizen.InvokeNative(0x9D746964E0CF2C5F, soundsetName, soundsetRef)
        is_frontend_sound_playing = false
        
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Frontend Sound Stopped',
            message = 'Frontend sound stopped',
            type = 'info',
            duration = 2000
        })
    end
    
    TriggerServerEvent('qc-devtools:server:logAction', 'Play Frontend Soundset', string.format('%s - %s', soundsetName, soundsetRef))
end

-- Audio Flag Functions (from wd_audiodev)
local function setAudioFlag(flagName, flagState)
    Citizen.InvokeNative(0xB9EFD5C25018725A, flagName, flagState)
    
    -- Auto-copy audio flag name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = flagName,
        description = 'Audio Flag Set: ' .. flagName .. ' = ' .. tostring(flagState)
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Audio Flag Set',
        message = string.format('%s set to %s', flagName, tostring(flagState)),
        type = 'info',
        duration = 3000
    })
    
    TriggerServerEvent('qc-devtools:server:logAction', 'Set Audio Flag', string.format('%s - %s', flagName, tostring(flagState)))
end

-- Audio Bank Speech Functions (from wd_audiodev)
local function playAudioBankSpeechFromEntity(bank_name, sound_hash, speech_params)
    play_ambient_speech_from_entity(PlayerPedId(), bank_name, sound_hash, speech_params, 0)
    
    -- Auto-copy sound name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = sound_hash,
        description = 'Speech Playing: ' .. sound_hash .. ' from ' .. bank_name
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Speech from Entity',
        message = string.format('Playing "%s" from %s', sound_hash, bank_name),
        type = 'success',
        duration = 3000
    })
    
    TriggerServerEvent('qc-devtools:server:logAction', 'Play Speech from Entity', string.format('%s - %s (%s)', sound_hash, bank_name, speech_params))
end

local function playAudioBankSpeechFromPosition(bank_name, sound_hash)
    local coords = GetEntityCoords(PlayerPedId())
    play_ambient_speech_from_position(coords.x, coords.y, coords.z, bank_name, sound_hash, 0)
    
    -- Auto-copy sound name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = sound_hash,
        description = 'Speech at Position: ' .. sound_hash .. ' from ' .. bank_name
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Speech from Position',
        message = string.format('Playing "%s" from %s at location', sound_hash, bank_name),
        type = 'success',
        duration = 3000
    })
    
    TriggerServerEvent('qc-devtools:server:logAction', 'Play Speech from Position', string.format('%s - %s', sound_hash, bank_name))
end

-- Stop All Audio
local function stopAllAudio()
    local count = 0
    
    -- Stop all active streams
    for key, stream in pairs(active_streams) do
        StopStream(stream.streamedMusic)
        count = count + 1
    end
    active_streams = {}
    
    -- Stop all active music events
    for eventName, _ in pairs(active_music) do
        CancelMusicEvent(eventName)
        count = count + 1
    end
    active_music = {}
    Citizen.InvokeNative(0x706D57B0F50DA710, "MC_MUSIC_STOP")
    
    -- Stop frontend sounds
    if is_frontend_sound_playing then
        is_frontend_sound_playing = false
        count = count + 1
    end
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'All Audio Stopped',
        message = string.format('Stopped %d active audio sources', count),
        type = 'success',
        duration = 3000
    })
    
    TriggerServerEvent('qc-devtools:server:logAction', 'Stop All Audio', string.format('%d sources stopped', count))
end

-- Menu Functions for QC-DevTools Integration
function OpenAudioMenu()
    print('[QC-DevTools] Opening Audio Menu...')
    local options = {}
    
    -- CreateStream
    table.insert(options, {
        id = 'createstream',
        title = 'CreateStream',
        description = 'Start Audio using CreateStream',
        icon = '🎵'
    })
    
    -- Music Events
    table.insert(options, {
        id = 'music_events',
        title = 'Music Events',
        description = 'Start, stop or mix OST from the game',
        icon = '🎼'
    })
    
    -- Frontend Soundsets
    table.insert(options, {
        id = 'frontend_soundsets',
        title = 'Frontend Soundsets',
        description = 'Play or stop frontend soundsets',
        icon = '🔊'
    })
    
    -- Audio Banks
    table.insert(options, {
        id = 'audio_banks',
        title = 'Audio Banks',
        description = 'Play ambient speech from audio banks',
        icon = '🎙️'
    })
    
    -- Audio Flags
    table.insert(options, {
        id = 'audio_flags',
        title = 'Audio Flags',
        description = 'Set or unset various audio flags',
        icon = '🚩'
    })
    
    -- Utility options
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'stop_all',
        title = 'Stop All Audio',
        description = 'Stop all currently playing audio',
        icon = '🛑'
    })
    
    table.insert(options, {
        id = 'status',
        title = 'Audio Status',
        description = string.format('Active: %d streams, %d music events', 
            #active_streams, #active_music),
        icon = '📊'
    })
    
    local menuData = {
        id = 'audio',
        title = 'Audio Testing (wd_audiodev)',
        subtitle = 'Select an audio category to test',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Update Audio Menu (without navigating, just update current menu)
function UpdateAudioMenu()
    local options = {}
    
    -- CreateStream
    table.insert(options, {
        id = 'createstream',
        title = 'CreateStream',
        description = 'Start Audio using CreateStream',
        icon = '🎵'
    })
    
    -- Music Events
    table.insert(options, {
        id = 'music_events',
        title = 'Music Events',
        description = 'Start, stop or mix OST from the game',
        icon = '🎼'
    })
    
    -- Frontend Soundsets
    table.insert(options, {
        id = 'frontend_soundsets',
        title = 'Frontend Soundsets',
        description = 'Play or stop frontend soundsets',
        icon = '🔊'
    })
    
    -- Audio Banks
    table.insert(options, {
        id = 'audio_banks',
        title = 'Audio Banks',
        description = 'Play ambient speech from audio banks',
        icon = '🎙️'
    })
    
    -- Audio Flags
    table.insert(options, {
        id = 'audio_flags',
        title = 'Audio Flags',
        description = 'Set or unset various audio flags',
        icon = '🚩'
    })
    
    -- Utility options
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'stop_all',
        title = 'Stop All Audio',
        description = 'Stop all currently playing audio',
        icon = '🛑'
    })
    
    table.insert(options, {
        id = 'status',
        title = 'Audio Status',
        description = string.format('Active: %d streams, %d music events', 
            #active_streams, #active_music),
        icon = '📊'
    })
    
    local menuData = {
        id = 'audio',
        title = 'Audio Testing (wd_audiodev)',
        subtitle = 'Select an audio category to test',
        options = options
    }
    
    UpdateDevToolsMenu(menuData)
end

-- CreateStream Category Menu
function OpenCreateStreamMenu()
    local options = {}
    
    for streamName, soundSets in pairs(cached_createstream) do
        table.insert(options, {
            id = streamName,
            title = streamName,
            description = string.format('%d sound variations available', #soundSets),
            icon = '🎵',
            data = {
                streamName = streamName,
                soundSets = soundSets
            }
        })
    end
    
    local menuData = {
        id = 'createstream',
        title = 'CreateStream',
        subtitle = 'Select a stream to play',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- CreateStream Variations Menu
function OpenCreateStreamVariationsMenu(streamName, soundSets)
    local options = {}
    
    for _, soundSet in ipairs(soundSets) do
        local streamKey = streamName .. "_" .. soundSet
        local isActive = active_streams[streamKey] ~= nil
        
        table.insert(options, {
            id = soundSet,
            title = string.format('%s (%s)', streamName, soundSet),
            description = string.format('%s with soundSet %s%s', 
                streamName, 
                soundSet,
                isActive and ' (Currently Playing)' or ''
            ),
            icon = isActive and '🔊' or '▶️',
            applied = isActive,
            data = {
                streamName = streamName,
                soundSet = soundSet
            }
        })
    end
    
    local menuData = {
        id = 'stream_variations_' .. streamName,
        title = streamName,
        subtitle = 'Select a sound variation',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Update CreateStream Variations Menu (without navigating, just update current menu)
function UpdateCreateStreamVariationsMenu(streamName, soundSets)
    local options = {}
    
    for _, soundSet in ipairs(soundSets) do
        local streamKey = streamName .. "_" .. soundSet
        local isActive = active_streams[streamKey] ~= nil
        
        table.insert(options, {
            id = soundSet,
            title = string.format('%s (%s)', streamName, soundSet),
            description = string.format('%s with soundSet %s%s', 
                streamName, 
                soundSet,
                isActive and ' (Currently Playing)' or ''
            ),
            icon = isActive and '🔊' or '▶️',
            applied = isActive,
            data = {
                streamName = streamName,
                soundSet = soundSet
            }
        })
    end
    
    local menuData = {
        id = 'stream_variations_' .. streamName,
        title = streamName,
        subtitle = 'Select a sound variation',
        options = options
    }
    
    UpdateDevToolsMenu(menuData)
end

-- Music Events Category Menu
function OpenMusicEventsMenu()
    local options = {}
    
    for category, events in pairs(cached_music_events) do
        table.insert(options, {
            id = category,
            title = category,
            description = string.format('%d music events available', #events),
            icon = '🎼',
            data = {
                category = category,
                events = events
            }
        })
    end
    
    local menuData = {
        id = 'music_events',
        title = 'Music Events',
        subtitle = 'Select a music category',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Music Events List Menu
function OpenMusicEventsListMenu(category, events)
    local options = {}
    
    for _, event in ipairs(events) do
        local isActive = active_music[event] ~= nil
        
        table.insert(options, {
            id = event,
            title = event,
            description = string.format('%s music event%s', 
                category,
                isActive and ' (Currently Playing)' or ''
            ),
            icon = isActive and '🔊' or '▶️',
            applied = isActive,
            data = {
                eventName = event
            }
        })
    end
    
    local menuData = {
        id = 'music_category_' .. category,
        title = category,
        subtitle = 'Select a music event',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Update Music Events List Menu (without navigating, just update current menu)
function UpdateMusicEventsListMenu(category, events)
    local options = {}
    
    for _, event in ipairs(events) do
        local isActive = active_music[event] ~= nil
        
        table.insert(options, {
            id = event,
            title = event,
            description = string.format('%s music event%s', 
                category,
                isActive and ' (Currently Playing)' or ''
            ),
            icon = isActive and '🔊' or '▶️',
            applied = isActive,
            data = {
                eventName = event
            }
        })
    end
    
    local menuData = {
        id = 'music_category_' .. category,
        title = category,
        subtitle = 'Select a music event',
        options = options
    }
    
    UpdateDevToolsMenu(menuData)
end

-- Frontend Soundsets Menu
function OpenFrontendSoundsetsMenu()
    local options = {}
    
    for soundsetRef, sounds in pairs(cached_frontend_soundsets) do
        table.insert(options, {
            id = soundsetRef,
            title = string.format('%s', soundsetRef),
            description = string.format('%d sounds available', #sounds),
            icon = '🔊',
            data = {
                soundsetRef = soundsetRef,
                sounds = sounds
            }
        })
    end
    
    local menuData = {
        id = 'frontend_soundsets',
        title = 'Frontend Soundsets',
        subtitle = 'Select a soundset to play',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Frontend Soundset Sounds Menu
function OpenFrontendSoundsetSoundsMenu(soundsetRef, sounds)
    local options = {}
    
    for _, soundName in ipairs(sounds) do
        table.insert(options, {
            id = soundName,
            title = soundName,
            description = string.format('Play %s from %s', soundName, soundsetRef),
            icon = '▶️',
            data = {
                soundsetRef = soundsetRef,
                soundName = soundName
            }
        })
    end
    
    local menuData = {
        id = 'frontend_sounds_' .. soundsetRef,
        title = soundsetRef,
        subtitle = 'Select a sound to play',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Audio Banks Menu
function OpenAudioBanksMenu()
    local options = {}
    
    for bankName, sounds in pairs(cached_audio_banks) do
        table.insert(options, {
            id = bankName,
            title = bankName,
            description = string.format('%d speech sounds available', #sounds),
            icon = '🎙️',
            data = {
                bankName = bankName,
                sounds = sounds
            }
        })
    end
    
    local menuData = {
        id = 'audio_banks',
        title = 'Audio Banks',
        subtitle = 'Select a bank for speech synthesis',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Audio Bank Sounds Menu
function OpenAudioBankSoundsMenu(bankName, sounds)
    local options = {}
    
    for _, soundHash in ipairs(sounds) do
        table.insert(options, {
            id = soundHash,
            title = soundHash,
            description = string.format('Play speech from %s', bankName),
            icon = '🗣️',
            data = {
                bankName = bankName,
                soundHash = soundHash,
                type = 'entity' -- Default to entity
            }
        })
        
        table.insert(options, {
            id = soundHash .. '_position',
            title = soundHash .. ' (Position)',
            description = string.format('Play speech from %s at current location', bankName),
            icon = '📍',
            data = {
                bankName = bankName,
                soundHash = soundHash,
                type = 'position'
            }
        })
    end
    
    local menuData = {
        id = 'audio_bank_sounds_' .. bankName,
        title = bankName,
        subtitle = 'Select speech to play',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Audio Flags Menu
function OpenAudioFlagsMenu()
    local options = {}
    
    for _, flagName in ipairs(cached_audio_flags) do
        table.insert(options, {
            id = flagName .. '_true',
            title = flagName .. ' (Enable)',
            description = string.format('Set %s flag to true', flagName),
            icon = '✅',
            data = {
                flagName = flagName,
                flagState = true
            }
        })
        
        table.insert(options, {
            id = flagName .. '_false',
            title = flagName .. ' (Disable)', 
            description = string.format('Set %s flag to false', flagName),
            icon = '❌',
            data = {
                flagName = flagName,
                flagState = false
            }
        })
    end
    
    local menuData = {
        id = 'audio_flags',
        title = 'Audio Flags',
        subtitle = 'Select a flag to set',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Event Handlers
-- Audio cleanup on back navigation - using menu closed instead
local function stopAllAudioSilently()
    local activeCount = 0
    
    -- Count active streams
    for _, _ in pairs(active_streams) do
        activeCount = activeCount + 1
    end
    
    -- Count active music
    for _, _ in pairs(active_music) do
        activeCount = activeCount + 1
    end
    
    -- Count frontend sounds
    if is_frontend_sound_playing then
        activeCount = activeCount + 1
    end
    
    -- Stop all audio silently (no notification)
    if activeCount > 0 then
        -- Stop all active streams
        for key, stream in pairs(active_streams) do
            StopStream(stream.streamedMusic)
        end
        active_streams = {}
        
        -- Stop all active music events
        for eventName, _ in pairs(active_music) do
            CancelMusicEvent(eventName)
        end
        active_music = {}
        Citizen.InvokeNative(0x706D57B0F50DA710, "MC_MUSIC_STOP")
        
        -- Stop frontend sounds
        if is_frontend_sound_playing then
            is_frontend_sound_playing = false
        end
        
        print(string.format('[QC-DevTools] Stopped %d audio sources', activeCount))
    end
end

RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    stopAllAudioSilently()
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'audio' then
        if optionId == 'stop_all' then
            stopAllAudio()
            UpdateAudioMenu() -- Update menu without adding to navigation history
        elseif optionId == 'status' then
            -- Show detailed status
            local statusMsg = string.format(
                "Active Streams: %d\nActive Music: %d\nFrontend Playing: %s", 
                #active_streams, #active_music, tostring(is_frontend_sound_playing)
            )
            TriggerEvent('qc-devtools:client:showNotification', {
                title = 'Audio System Status',
                message = statusMsg,
                type = 'info',
                duration = 5000
            })
        elseif optionId == 'createstream' then
            OpenCreateStreamMenu()
        elseif optionId == 'music_events' then
            OpenMusicEventsMenu()
        elseif optionId == 'frontend_soundsets' then
            OpenFrontendSoundsetsMenu()
        elseif optionId == 'audio_banks' then
            OpenAudioBanksMenu()
        elseif optionId == 'audio_flags' then
            OpenAudioFlagsMenu()
        end
    elseif menuId == 'createstream' then
        -- Handle createstream selection - show variations
        if optionData and optionData.data then
            OpenCreateStreamVariationsMenu(optionData.data.streamName, optionData.data.soundSets)
        end
    elseif menuId:find('stream_variations_') then
        -- Handle stream variation selection
        if optionData and optionData.data then
            local streamName = optionData.data.streamName
            local soundSet = optionData.data.soundSet
            local streamKey = streamName .. "_" .. soundSet
            
            if active_streams[streamKey] then
                -- Stop stream
                stopCreateStream(active_streams[streamKey].streamedMusic)
            else
                -- Play stream
                playCreateStream(soundSet, streamName)
            end
            
            -- Update menu to show new state without adding to navigation history
            UpdateCreateStreamVariationsMenu(streamName, cached_createstream[streamName])
        end
    elseif menuId == 'music_events' then
        -- Handle music events category selection
        if optionData and optionData.data then
            OpenMusicEventsListMenu(optionData.data.category, optionData.data.events)
        end
    elseif menuId:find('music_category_') then
        -- Handle music event selection
        if optionData and optionData.data then
            local eventName = optionData.data.eventName
            
            if active_music[eventName] then
                -- Stop music event
                stopMusicEvent(eventName)
            else
                -- Play music event
                playMusicEvent(eventName)
            end
            
            -- Update menu to show new state without adding to navigation history
            local category = menuId:gsub('music_category_', '')
            UpdateMusicEventsListMenu(category, cached_music_events[category])
        end
    elseif menuId == 'frontend_soundsets' then
        -- Handle frontend soundsets selection
        if optionData and optionData.data then
            OpenFrontendSoundsetSoundsMenu(optionData.data.soundsetRef, optionData.data.sounds)
        end
    elseif menuId:find('frontend_sounds_') then
        -- Handle frontend sound selection
        if optionData and optionData.data then
            playFrontendSoundset(optionData.data.soundsetRef, optionData.data.soundName)
        end
    elseif menuId == 'audio_banks' then
        -- Handle audio banks selection
        if optionData and optionData.data then
            OpenAudioBankSoundsMenu(optionData.data.bankName, optionData.data.sounds)
        end
    elseif menuId:find('audio_bank_sounds_') then
        -- Handle audio bank sound selection
        if optionData and optionData.data then
            if optionData.data.type == 'entity' then
                playAudioBankSpeechFromEntity(optionData.data.bankName, optionData.data.soundHash, 'SPEECH_PARAMS_STANDARD')
            elseif optionData.data.type == 'position' then
                playAudioBankSpeechFromPosition(optionData.data.bankName, optionData.data.soundHash)
            end
        end
    elseif menuId == 'audio_flags' then
        -- Handle audio flag selection
        if optionData and optionData.data then
            setAudioFlag(optionData.data.flagName, optionData.data.flagState)
        end
    end
end)

-- Main Event Handlers
RegisterNetEvent('qc-devtools:client:openAudio')
AddEventHandler('qc-devtools:client:openAudio', function()
    print('[QC-DevTools] Opening Audio Menu...')
    OpenAudioMenu()
end)