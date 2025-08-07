--=========================================================
-- QC-DEVTOOLS - ANIMATION POST FX MODULE
--=========================================================
-- Handles animation post FX testing and application
-- Based on RedM AnimPostFX system
--=========================================================

local activeEffects = {}

-- Open Animation Post FX Main Menu  
function OpenAnimPostFXMenu()
    print('[DEVTOOLS] Building Animation Post FX Menu...')
    local options = {}
    
    -- Add category options
    for categoryId, categoryData in pairs(AnimPostFXData) do
        table.insert(options, {
            id = categoryId,
            title = categoryData.name,
            description = string.format('Browse %s effects (%d available)', categoryData.name:lower(), #categoryData.effects),
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
        title = 'Stop All Effects',
        description = 'Stop all currently active animation post FX effects',
        icon = '🛑'
    })
    
    local menuData = {
        id = 'animpostfx',
        title = 'Animation Post FX',
        subtitle = 'Select an effect category',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Open Effect Category Menu
function OpenEffectCategoryMenu(categoryId, categoryData)
    local options = {}
    
    -- Add effect options
    for i, effect in ipairs(categoryData.effects) do
        local isActive = activeEffects[effect.name] ~= nil
        table.insert(options, {
            id = effect.name,
            title = effect.label,
            description = string.format('%s animation post FX effect%s', 
                isActive and 'Stop' or 'Play',
                isActive and ' (Currently Active)' or ''
            ),
            icon = isActive and '⏹️' or '▶️',
            applied = isActive,
            data = {
                effectName = effect.name,
                effectLabel = effect.label,
                categoryId = categoryId
            }
        })
    end
    
    local menuData = {
        id = 'animpostfx_category_' .. categoryId,
        title = categoryData.name,
        subtitle = 'Click to play/stop effects',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Play Animation Post FX Effect
function PlayAnimPostFXEffect(effectName, effectLabel)
    print(string.format('[DEVTOOLS] Playing AnimPostFX effect: %s', effectName))
    
    -- Play the effect using RedM function
    AnimpostfxPlay(effectName)
    
    -- Store the active effect data
    activeEffects[effectName] = {
        label = effectLabel,
        startedAt = GetGameTimer()
    }
    
    -- Auto-copy effect name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = effectName,
        description = 'AnimPostFX Effect: ' .. (effectLabel or effectName)
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Effect Started',
        message = string.format('Playing "%s"', effectLabel),
        type = 'success',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Play AnimPostFX', string.format('%s - %s', effectName, effectLabel))
    
    print(string.format('[DEVTOOLS] Started AnimPostFX effect: %s (%s)', effectName, effectLabel))
end

-- Stop Animation Post FX Effect
function StopAnimPostFXEffect(effectName, effectLabel)
    print(string.format('[DEVTOOLS] Stopping AnimPostFX effect: %s', effectName))
    
    -- Stop the effect using RedM function
    AnimpostfxStop(effectName)
    
    -- Remove from active effects
    activeEffects[effectName] = nil
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Effect Stopped',
        message = string.format('Stopped "%s"', effectLabel),
        type = 'info',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Stop AnimPostFX', string.format('%s - %s', effectName, effectLabel))
    
    print(string.format('[DEVTOOLS] Stopped AnimPostFX effect: %s (%s)', effectName, effectLabel))
end

-- Stop All Animation Post FX Effects
function StopAllAnimPostFXEffects(showNotification)
    local count = 0
    
    for effectName, effectData in pairs(activeEffects) do
        AnimpostfxStop(effectName)
        count = count + 1
    end
    
    -- Clear active effects
    activeEffects = {}
    
    -- Only show notification if explicitly requested (default true for manual stop)
    if showNotification ~= false then
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'All Effects Stopped',
            message = string.format('Stopped %d active effects', count),
            type = 'success',
            duration = 3000
        })
    end
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Stop All AnimPostFX', string.format('%d effects stopped', count))
    
    print(string.format('[DEVTOOLS] Stopped all AnimPostFX effects (%d total)', count))
end

-- React handles back navigation internally

-- Handle menu close - stop all effects when menu is closed
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Stop all effects when the menu is closed (escape pressed)
    -- Don't show notification since this is automatic cleanup
    StopAllAnimPostFXEffects(false)
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'animpostfx' then
        if optionId == 'clear' then
            StopAllAnimPostFXEffects()
        else
            -- Open effect category
            local categoryData = AnimPostFXData[optionId]
            if categoryData then
                OpenEffectCategoryMenu(optionId, categoryData)
            end
        end
    elseif menuId:find('animpostfx_category_') then
        -- Handle effect selection
        if optionData and optionData.data then
            local effectData = optionData.data
            local isActive = activeEffects[effectData.effectName] ~= nil
            
            if isActive then
                StopAnimPostFXEffect(effectData.effectName, effectData.effectLabel)
            else
                PlayAnimPostFXEffect(effectData.effectName, effectData.effectLabel)
            end
            
            -- Update the current menu with new active state
            local categoryData = AnimPostFXData[effectData.categoryId]
            if categoryData then
                local updatedOptions = {}
                
                -- Rebuild options with current active state
                for i, effect in ipairs(categoryData.effects) do
                    local isCurrentlyActive = activeEffects[effect.name] ~= nil
                    table.insert(updatedOptions, {
                        id = effect.name,
                        title = effect.label,
                        description = string.format('%s animation post FX effect%s', 
                            isCurrentlyActive and 'Stop' or 'Play',
                            isCurrentlyActive and ' (Currently Active)' or ''
                        ),
                        icon = isCurrentlyActive and '⏹️' or '▶️',
                        applied = isCurrentlyActive,
                        data = {
                            effectName = effect.name,
                            effectLabel = effect.label,
                            categoryId = effectData.categoryId
                        }
                    })
                end
                
                local updatedMenu = {
                    id = 'animpostfx_category_' .. effectData.categoryId,
                    title = categoryData.name,
                    subtitle = 'Click to play/stop effects',
                    options = updatedOptions
                }
                
                -- Update the current menu instead of navigating
                UpdateDevToolsMenu(updatedMenu)
            end
        end
    end
end)

-- Event Handlers
RegisterNetEvent('qc-devtools:client:openAnimPostFX')
AddEventHandler('qc-devtools:client:openAnimPostFX', function()
    print('[DEVTOOLS] Opening Animation Post FX Menu...')
    OpenAnimPostFXMenu()
end)

RegisterNetEvent('qc-devtools:client:stopAllAnimPostFX')
AddEventHandler('qc-devtools:client:stopAllAnimPostFX', function()
    StopAllAnimPostFXEffects()
end)