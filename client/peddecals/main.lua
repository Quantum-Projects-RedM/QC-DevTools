--=========================================================
-- PED DECALS MODULE
--=========================================================
-- Handles ped decal application and management
-- Part of QC-DevTools modular system
--=========================================================

local appliedDecals = {}

-- Open Ped Decals Main Menu
local function OpenPedDecalsMenu()
    local options = {}
    
    -- Add category options
    for categoryId, categoryData in pairs(PedDecalsData) do
        if categoryId ~= 'bodyParts' then -- Skip body parts data
            table.insert(options, {
                id = categoryId,
                title = categoryData.name,
                description = string.format('Browse %s decals (%d available)', categoryData.name:lower(), #categoryData.decals),
                icon = categoryData.icon
            })
        end
    end
    
    -- Add utility options
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'clear',
        title = 'Clear All Decals',
        description = 'Remove all applied decals from your character',
        icon = '🧹'
    })
    
    local menuData = {
        id = 'peddecals',
        title = 'Ped Decals',
        subtitle = 'Select a decal category',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Open Decal Category Menu
function OpenDecalCategoryMenu(categoryId, categoryData)
    local options = {}
    
    -- Add decal options
    for i, decal in ipairs(categoryData.decals) do
        local isApplied = appliedDecals[decal.name] ~= nil
        table.insert(options, {
            id = decal.name,
            title = decal.label,
            description = string.format('Apply damage pack to entire ped%s', 
                isApplied and ' (Currently Applied)' or ''
            ),
            icon = isApplied and '✅' or '🎨',
            applied = isApplied,
            data = {
                decalName = decal.name,
                decalLabel = decal.label,
                categoryId = categoryId
            }
        })
    end
    
    local menuData = {
        id = 'decal_category_' .. categoryId,
        title = categoryData.name,
        subtitle = 'Select a decal to apply or remove',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Body part selector removed - damage packs apply to entire ped

-- Apply Decal to Player
function ApplyDecal(decalName, decalLabel, bodyPart, boneName)
    local ped = PlayerPedId()
    
    print(string.format('[DEVTOOLS] Attempting to apply decal: %s to ped %s', decalName, ped))
    
    -- Apply the decal using RedM native
    -- Citizen.InvokeNative(0x46DF918788CB093F, PlayerPedId(), "PD_Vomit", 0.0, 0.0);
    local success = Citizen.InvokeNative(0x46DF918788CB093F, ped, decalName, 0.0, 0.0)
    
    print(string.format('[DEVTOOLS] Native result: %s', tostring(success)))
    
    -- Auto-copy decal name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = decalName,
        description = 'Decal Applied: ' .. (decalLabel or decalName)
    })
    
    -- Store the applied decal data
    appliedDecals[decalName] = {
        label = decalLabel,
        bodyPart = bodyPart,
        boneName = boneName,
        appliedAt = GetGameTimer()
    }
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Decal Applied',
        message = string.format('Applied "%s" to ped', decalLabel),
        type = 'success',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Apply Decal', string.format('%s to %s', decalName, bodyPart))
    
    print(string.format('[DEVTOOLS] Applied decal: %s to %s (%s)', decalName, bodyPart, boneName))
end

-- Remove Specific Decal
function RemoveDecal(decalName)
    if appliedDecals[decalName] then
        local decalData = appliedDecals[decalName]
        local ped = PlayerPedId()
        
        -- Get the body zone for removal
        local bodyZone = GetBodyZoneFromPart(decalData.bodyPart)
        
        -- Clear decals from specific zone
        -- Citizen.InvokeNative(0x523C79AEEFCC4A2A, PlayerPedId(), 10, "ALL")
        Citizen.InvokeNative(0x523C79AEEFCC4A2A, ped, bodyZone, "ALL")
        
        appliedDecals[decalName] = nil
        
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Decal Removed',
            message = string.format('Removed "%s"', decalData.label),
            type = 'info',
            duration = 3000
        })
        
        -- Log to server for tracking
        TriggerServerEvent('qc-devtools:server:logAction', 'Remove Decal', string.format('%s from %s', decalName, decalData.bodyPart))
        
        print(string.format('[DEVTOOLS] Removed decal: %s', decalName))
    end
end

-- Clear All Decals
function ClearAllDecals(showNotification)
    local count = 0
    local ped = PlayerPedId()
    
    for decalName, decalData in pairs(appliedDecals) do
        count = count + 1
    end
    
    -- Only proceed if there are decals to clear
    if count > 0 then
        -- Clear all decals from all zones
        Citizen.InvokeNative(0x523C79AEEFCC4A2A, ped, 10, "ALL")
        
        appliedDecals = {}
        
        -- Only show notification if explicitly requested (default true for manual clear)
        if showNotification ~= false then
            TriggerEvent('qc-devtools:client:showNotification', {
                title = 'Decals Cleared',
                message = string.format('Removed %d decals', count),
                type = 'success'
            })
        end
        
        -- Log to server for tracking
        TriggerServerEvent('qc-devtools:server:logAction', 'Clear All Decals', string.format('%d decals cleared', count))
        
        print(string.format('[DEVTOOLS] Cleared %d decals', count))
    end
end

-- Helper function to map body parts to RedM zones
function GetBodyZoneFromPart(bodyPart)
    local zoneMap = {
        face = 1,     -- head
        head = 1,     -- head
        torso = 0,    -- upperbody
        chest = 0,    -- upperbody
        back = 0,     -- upperbody
        arms = 3,     -- left arm (could also use 5 for right arm)
        hands = 4,    -- left palm (could also use 6 for right palm)
        legs = 7,     -- left leg (could also use 8 for right leg)
        feet = 7,     -- left leg (could also use 8 for right leg)
    }
    
    return zoneMap[bodyPart] or 10 -- Default to all zones if unknown
end

-- NUI Menu Selection Handler
-- React handles back navigation internally

-- Handle menu close - clear all decals when menu is closed
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Clear all decals when the menu is closed (escape pressed)
    -- Don't show notification since this is automatic cleanup
    ClearAllDecals(false)
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'peddecals' then
        if optionId == 'clear' then
            ClearAllDecals()
        else
            -- Open decal category
            local categoryData = PedDecalsData[optionId]
            if categoryData then
                OpenDecalCategoryMenu(optionId, categoryData)
            end
        end
    elseif menuId:find('decal_category_') then
        -- Handle decal selection
        if optionData and optionData.data then
            local decalData = optionData.data
            local isApplied = appliedDecals[decalData.decalName] ~= nil
            
            if isApplied then
                RemoveDecal(decalData.decalName)
            else
                ApplyDecal(decalData.decalName, decalData.decalLabel, 'whole_body', 'entire_ped')
            end
            
            -- Update the current menu with new applied state instead of recreating
            local categoryData = PedDecalsData[decalData.categoryId]
            if categoryData then
                local updatedOptions = {}
                
                -- Rebuild options with current applied state
                for i, decal in ipairs(categoryData.decals) do
                    local isCurrentlyApplied = appliedDecals[decal.name] ~= nil
                    table.insert(updatedOptions, {
                        id = decal.name,
                        title = decal.label,
                        description = string.format('Apply damage pack to entire ped%s', 
                            isCurrentlyApplied and ' (Currently Applied)' or ''
                        ),
                        icon = isCurrentlyApplied and '✅' or '🎨',
                        applied = isCurrentlyApplied,
                        data = {
                            decalName = decal.name,
                            decalLabel = decal.label,
                            categoryId = decalData.categoryId
                        }
                    })
                end
                
                local updatedMenu = {
                    id = 'decal_category_' .. decalData.categoryId,
                    title = categoryData.name,
                    subtitle = 'Click to apply/remove decals',
                    options = updatedOptions
                }
                
                -- Update the current menu instead of navigating
                UpdateDevToolsMenu(updatedMenu)
            end
        end
    end
end)

-- Event Handlers
RegisterNetEvent('qc-devtools:client:openPedDecals')
AddEventHandler('qc-devtools:client:openPedDecals', function()
    OpenPedDecalsMenu()
end)

RegisterNetEvent('qc-devtools:client:clearAllDecals')
AddEventHandler('qc-devtools:client:clearAllDecals', function()
    ClearAllDecals()
end)

-- Export functions for other modules
exports('GetAppliedDecals', function()
    return appliedDecals
end)

exports('ClearAllDecals', function()
    ClearAllDecals()
end)