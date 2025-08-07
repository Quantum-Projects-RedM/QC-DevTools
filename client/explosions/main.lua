--=========================================================
-- QC-DEVTOOLS - EXPLOSIONS MODULE
--=========================================================
-- Handles explosion testing with player protection
-- Makes player invincible while testing explosions
-- Usage: ADD_EXPLOSION(x, y, z, explosionType, damageScale, isAudible, isInvisible, cameraShake)
--=========================================================

local playerInvincible = false
local playerFrozen = false
local explosionDistance = 15.0 -- Distance in front of player

-- Toggle Player Protection (Invincibility + Freeze)
function TogglePlayerProtection(enable)
    local ped = PlayerPedId()
    SetEntityInvincible(ped, enable)
    FreezeEntityPosition(ped, enable)
    
    playerInvincible = enable
    playerFrozen = enable
    
    local status = enable and "enabled" or "disabled"
    print(string.format('[DEVTOOLS] Player protection %s (invincible + frozen)', status))
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Full Protection ' .. (enable and 'Enabled' or 'Disabled'),
        message = enable and 'You are now invincible and frozen for safety' or 'Protection removed - be careful!',
        type = enable and 'success' or 'warning',
        duration = 3000
    })
end

-- Calculate explosion position in front of player
function GetExplosionPosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forwardX = GetEntityForwardX(ped)
    local forwardY = GetEntityForwardY(ped)
    
    local explosionX = coords.x + (forwardX * explosionDistance)
    local explosionY = coords.y + (forwardY * explosionDistance)
    local explosionZ = coords.z
    
    return explosionX, explosionY, explosionZ
end

-- Open Explosions Main Menu
function OpenExplosionsMenu()
    print('[DEVTOOLS] Building Explosions Menu...')
    
    -- Automatically enable protection when entering explosions menu
    if not playerInvincible then
        TogglePlayerProtection(true)
    end
    
    local options = {}
    
    -- Add category options
    for categoryId, categoryData in pairs(ExplosionData) do
        table.insert(options, {
            id = categoryId,
            title = categoryData.name,
            description = string.format('Browse %s (%d available)', categoryData.name:lower(), #categoryData.explosions),
            icon = categoryData.icon
        })
    end
    
    -- Add utility options
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'distance',
        title = 'Explosion Distance',
        description = string.format('Current: %.0fm - Click to adjust', explosionDistance),
        icon = '📏'
    })
    
    table.insert(options, {
        id = 'status',
        title = 'Safety Status',
        description = 'Protection: ENABLED (Invincible + Frozen)',
        icon = '🛡️'
    })
    
    local menuData = {
        id = 'explosions',
        title = 'Explosion Testing',
        subtitle = 'Protection auto-enabled! Select explosion category',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Open Explosions Category Menu
function OpenExplosionsCategoryMenu(categoryId, categoryData)
    local options = {}
    
    -- Add explosion options
    for i, explosion in ipairs(categoryData.explosions) do
        table.insert(options, {
            id = explosion.tag,
            title = explosion.name,
            description = explosion.description .. string.format(' (ID: %d)', explosion.id),
            icon = '💥',
            data = {
                id = explosion.id,
                tag = explosion.tag,
                name = explosion.name,
                description = explosion.description,
                categoryId = categoryId
            }
        })
    end
    
    local menuData = {
        id = 'explosions_category_' .. categoryId,
        title = categoryData.name,
        subtitle = 'Click to trigger explosions',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Trigger Explosion
function TriggerExplosion(explosionId, explosionName, explosionTag)
    -- Protection should already be enabled, but double check
    if not playerInvincible then
        TogglePlayerProtection(true)
    end
    
    local x, y, z = GetExplosionPosition()
    
    print(string.format('[DEVTOOLS] Triggering explosion: %s (ID: %d) at distance %.0fm', explosionName, explosionId, explosionDistance))
    
    -- Trigger explosion using RedM native
    -- ADD_EXPLOSION(x, y, z, explosionType, damageScale, isAudible, isInvisible, cameraShake)
    AddExplosion(x, y, z, explosionId, 1.0, true, false, 1.0)
    
    print(string.format('[DEVTOOLS] Explosion triggered: %s', explosionName))
    
    -- Auto-copy explosion tag to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = explosionTag,
        description = 'Explosion Triggered: ' .. explosionName .. ' (' .. explosionTag .. ')'
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Explosion Triggered',
        message = string.format('"%s" at %.0fm distance', explosionName, explosionDistance),
        type = 'success',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Trigger Explosion', string.format('%s (%s) - ID: %d', explosionName, explosionTag, explosionId))
end

-- Cycle Explosion Distance
function CycleExplosionDistance()
    local distances = {5.0, 10.0, 15.0, 20.0, 25.0, 30.0}
    local currentIndex = 1
    
    -- Find current distance index
    for i, distance in ipairs(distances) do
        if math.abs(explosionDistance - distance) < 0.1 then
            currentIndex = i
            break
        end
    end
    
    -- Move to next distance (cycle back to start if at end)
    currentIndex = currentIndex + 1
    if currentIndex > #distances then
        currentIndex = 1
    end
    
    explosionDistance = distances[currentIndex]
    
    print(string.format('[DEVTOOLS] Explosion distance changed to: %.0fm', explosionDistance))
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Distance Updated',
        message = string.format('Explosions will spawn %.0fm away', explosionDistance),
        type = 'info',
        duration = 2000
    })
    
    -- Refresh main menu to show new distance
    OpenExplosionsMenu()
end

-- Handle menu close - disable protection when menu is closed
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Disable protection when the menu is closed for safety
    if playerInvincible or playerFrozen then
        TogglePlayerProtection(false)
    end
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'explosions' then
        if optionId == 'distance' then
            CycleExplosionDistance()
        else
            -- Open explosions category
            local categoryData = ExplosionData[optionId]
            if categoryData then
                OpenExplosionsCategoryMenu(optionId, categoryData)
            end
        end
    elseif menuId:find('explosions_category_') then
        -- Handle explosion selection
        if optionData and optionData.data then
            local explosionData = optionData.data
            TriggerExplosion(explosionData.id, explosionData.name, explosionData.tag)
        end
    end
end)

-- Event Handlers
RegisterNetEvent('qc-devtools:client:openExplosions')
AddEventHandler('qc-devtools:client:openExplosions', function()
    print('[DEVTOOLS] Opening Explosions Menu...')
    OpenExplosionsMenu()
end)

RegisterNetEvent('qc-devtools:client:toggleProtection')
AddEventHandler('qc-devtools:client:toggleProtection', function()
    TogglePlayerProtection(not playerInvincible)
end)