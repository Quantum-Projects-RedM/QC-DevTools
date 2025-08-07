--=========================================================
-- QC-DEVTOOLS - PARTICLE EFFECTS (PTFX) MODULE
--=========================================================
-- Handles PTFX testing and application
-- Supports both looped and non-looped particle effects
--=========================================================

local activePTFX = {}

-- Open PTFX Main Menu
function OpenPTFXMenu()
    print('[DEVTOOLS] Building PTFX Menu...')
    local options = {}
    
    -- Add category options
    for categoryId, categoryData in pairs(PTFXData) do
        table.insert(options, {
            id = categoryId,
            title = categoryData.name,
            description = string.format('Browse %s (%d available)', categoryData.name:lower(), #categoryData.effects),
            icon = categoryData.icon
        })
    end
    
    -- Add utility options
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'clear',
        title = 'Stop All PTFX',
        description = 'Stop all currently active particle effects',
        icon = '🛑'
    })
    
    local menuData = {
        id = 'ptfx',
        title = 'Particle Effects (PTFX)',
        subtitle = 'Select an effect category',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Open PTFX Category Menu
function OpenPTFXCategoryMenu(categoryId, categoryData)
    local options = {}
    
    -- Add effect options
    for i, effect in ipairs(categoryData.effects) do
        local effectKey = effect.dict .. ":" .. effect.name
        local isActive = activePTFX[effectKey] ~= nil
        local effectType = effect.type or categoryData.type or "unknown"
        
        table.insert(options, {
            id = effectKey,
            title = effect.label,
            description = string.format('%s %s particle effect%s', 
                isActive and 'Stop' or 'Play',
                effectType,
                isActive and ' (Currently Active)' or ''
            ),
            icon = isActive and '⏹️' or '▶️',
            applied = isActive,
            data = {
                dict = effect.dict,
                effectName = effect.name,
                effectLabel = effect.label,
                effectType = effectType,
                categoryId = categoryId
            }
        })
    end
    
    local menuData = {
        id = 'ptfx_category_' .. categoryId,
        title = categoryData.name,
        subtitle = 'Click to play/stop particle effects',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Play PTFX Effect
function PlayPTFXEffect(dict, effectName, effectLabel, effectType)
    local ped = PlayerPedId()
    
    print(string.format('[DEVTOOLS] Playing PTFX: %s:%s (%s)', dict, effectName, effectType))
    
    -- Request the particle FX dictionary using RedM natives
    if not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(dict)) then -- HasNamedPtfxAssetLoaded
        Citizen.InvokeNative(0xF2B2353BBC0D4E8F, GetHashKey(dict)) -- RequestNamedPtfxAsset
        local counter = 0
        while not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(dict)) and counter <= 300 do -- while not HasNamedPtfxAssetLoaded
            Wait(0)
            counter = counter + 1
        end
    end
    
    local ptfxHandle = nil
    local effectKey = dict .. ":" .. effectName
    
    if Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(dict)) then -- HasNamedPtfxAssetLoaded
        Citizen.InvokeNative(0xA10DB07FC234DD12, dict) -- UseParticleFxAsset
        
        if effectType == "looped" then
            -- Get player position and heading to spawn effect in front
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local forwardX = math.sin(math.rad(-heading)) * 2.0 -- 2 units in front
            local forwardY = math.cos(math.rad(-heading)) * 2.0
            local spawnX = coords.x + forwardX
            local spawnY = coords.y + forwardY
            local spawnZ = coords.z
            
            -- Use looped particle FX at coordinates in front of player
            ptfxHandle = Citizen.InvokeNative(0x25129531F77B9ED3, effectName, spawnX, spawnY, spawnZ, 0.0, 0.0, 0.0, 1.0, false, false, false) -- StartNetworkedParticleFxLoopedAtCoord
            
            if ptfxHandle then
                -- Store the looped effect handle for stopping later
                activePTFX[effectKey] = {
                    handle = ptfxHandle,
                    dict = dict,
                    name = effectName,
                    label = effectLabel,
                    type = effectType,
                    entity = ped,
                    startedAt = GetGameTimer()
                }
                print(string.format('[DEVTOOLS] Started looped PTFX: %s (handle: %d)', effectName, ptfxHandle))
            else
                print(string.format('[DEVTOOLS] Failed to start looped PTFX: %s', effectName))
            end
        else
            -- Get player position and heading to spawn effect in front
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local forwardX = math.sin(math.rad(-heading)) * 2.0 -- 2 units in front
            local forwardY = math.cos(math.rad(-heading)) * 2.0
            local spawnX = coords.x + forwardX
            local spawnY = coords.y + forwardY
            local spawnZ = coords.z + 1.0 -- Slightly elevated
            
            -- Use non-looped particle FX at coordinates in front of player
            ptfxHandle = Citizen.InvokeNative(0x8C042E3580485E5F, effectName, spawnX, spawnY, spawnZ, 0.0, 0.0, 0.0, 1.0, false, false, false) -- StartNetworkedParticleFxNonLoopedAtCoord
            
            print(string.format('[DEVTOOLS] Played non-looped PTFX: %s on entity', effectName))
            
            -- Non-looped effects don't need persistent tracking
            activePTFX[effectKey] = {
                handle = ptfxHandle,
                dict = dict,
                name = effectName,
                label = effectLabel,
                type = effectType,
                entity = ped,
                startedAt = GetGameTimer()
            }
            
            -- Remove from active list after a short time since it's non-looped
            SetTimeout(3000, function()
                if activePTFX[effectKey] and activePTFX[effectKey].type ~= "looped" then
                    activePTFX[effectKey] = nil
                end
            end)
        end
    else
        print(string.format('[DEVTOOLS] Failed to load PTFX dictionary: %s', dict))
    end
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'PTFX Started',
        message = string.format('Playing "%s" (%s)', effectLabel, effectType),
        type = 'success',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Play PTFX', string.format('%s:%s - %s (%s)', dict, effectName, effectLabel, effectType))
end

-- Stop PTFX Effect
function StopPTFXEffect(dict, effectName, effectLabel, effectType)
    local effectKey = dict .. ":" .. effectName
    local ptfxData = activePTFX[effectKey]
    
    if not ptfxData then
        print(string.format('[DEVTOOLS] PTFX not active: %s', effectName))
        return
    end
    
    print(string.format('[DEVTOOLS] Stopping PTFX: %s:%s', dict, effectName))
    
    if effectType == "looped" and ptfxData.handle then
        -- Check if particle effect still exists and stop it using RedM natives
        if Citizen.InvokeNative(0x9DD5AFF561E88F2A, ptfxData.handle) then -- DoesParticleFxLoopedExist
            Citizen.InvokeNative(0x459598F579C98929, ptfxData.handle, false) -- RemoveParticleFx
            print(string.format('[DEVTOOLS] Stopped looped PTFX: %s (handle: %d)', effectName, ptfxData.handle))
        end
    end
    
    -- Remove from active effects
    activePTFX[effectKey] = nil
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'PTFX Stopped',
        message = string.format('Stopped "%s"', effectLabel),
        type = 'info',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Stop PTFX', string.format('%s:%s - %s', dict, effectName, effectLabel))
end

-- Stop All PTFX Effects
function StopAllPTFXEffects(showNotification)
    local count = 0
    
    for effectKey, ptfxData in pairs(activePTFX) do
        if ptfxData.type == "looped" and ptfxData.handle then
            -- Check if particle effect still exists and stop it using RedM natives
            if Citizen.InvokeNative(0x9DD5AFF561E88F2A, ptfxData.handle) then -- DoesParticleFxLoopedExist
                Citizen.InvokeNative(0x459598F579C98929, ptfxData.handle, false) -- RemoveParticleFx
                count = count + 1
            end
        end
    end
    
    -- Clear active effects
    activePTFX = {}
    
    -- Only show notification if explicitly requested (default true for manual stop)
    if showNotification ~= false then
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'All PTFX Stopped',
            message = string.format('Stopped %d active particle effects', count),
            type = 'success',
            duration = 3000
        })
    end
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Stop All PTFX', string.format('%d effects stopped', count))
    
    print(string.format('[DEVTOOLS] Stopped all PTFX effects (%d total)', count))
end

-- Handle back navigation
RegisterNetEvent('qc-devtools:nui:back')
AddEventHandler('qc-devtools:nui:back', function()
    -- Let React handle the back navigation internally
end)

-- Handle menu close - stop all effects when menu is closed
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Stop all PTFX when the menu is closed (escape pressed)
    -- Don't show notification since this is automatic cleanup
    StopAllPTFXEffects(false)
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'ptfx' then
        if optionId == 'clear' then
            StopAllPTFXEffects()
        else
            -- Open PTFX category
            local categoryData = PTFXData[optionId]
            if categoryData then
                OpenPTFXCategoryMenu(optionId, categoryData)
            end
        end
    elseif menuId:find('ptfx_category_') then
        -- Handle PTFX selection
        if optionData and optionData.data then
            local ptfxData = optionData.data
            local effectKey = ptfxData.dict .. ":" .. ptfxData.effectName
            local isActive = activePTFX[effectKey] ~= nil
            
            if isActive then
                StopPTFXEffect(ptfxData.dict, ptfxData.effectName, ptfxData.effectLabel, ptfxData.effectType)
            else
                PlayPTFXEffect(ptfxData.dict, ptfxData.effectName, ptfxData.effectLabel, ptfxData.effectType)
            end
            
            -- Update the current menu with new active state
            local categoryData = PTFXData[ptfxData.categoryId]
            if categoryData then
                local updatedOptions = {}
                
                -- Rebuild options with current active state
                for i, effect in ipairs(categoryData.effects) do
                    local currentEffectKey = effect.dict .. ":" .. effect.name
                    local isCurrentlyActive = activePTFX[currentEffectKey] ~= nil
                    local effectType = effect.type or categoryData.type or "unknown"
                    
                    table.insert(updatedOptions, {
                        id = currentEffectKey,
                        title = effect.label,
                        description = string.format('%s %s particle effect%s', 
                            isCurrentlyActive and 'Stop' or 'Play',
                            effectType,
                            isCurrentlyActive and ' (Currently Active)' or ''
                        ),
                        icon = isCurrentlyActive and '⏹️' or '▶️',
                        applied = isCurrentlyActive,
                        data = {
                            dict = effect.dict,
                            effectName = effect.name,
                            effectLabel = effect.label,
                            effectType = effectType,
                            categoryId = ptfxData.categoryId
                        }
                    })
                end
                
                local updatedMenu = {
                    id = 'ptfx_category_' .. ptfxData.categoryId,
                    title = categoryData.name,
                    subtitle = 'Click to play/stop particle effects',
                    options = updatedOptions
                }
                
                -- Update the current menu instead of navigating
                UpdateDevToolsMenu(updatedMenu)
            end
        end
    end
end)

-- Event Handlers
RegisterNetEvent('qc-devtools:client:openPTFX')
AddEventHandler('qc-devtools:client:openPTFX', function()
    print('[DEVTOOLS] Opening PTFX Menu...')
    OpenPTFXMenu()
end)

RegisterNetEvent('qc-devtools:client:stopAllPTFX')
AddEventHandler('qc-devtools:client:stopAllPTFX', function()
    StopAllPTFXEffects()
end)