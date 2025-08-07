--=========================================================
-- QC-DEVTOOLS - PED OUTFITS MODULE
--=========================================================
-- Handles ped outfit testing and application
-- Based on RedM ped outfit system
--=========================================================

local appliedOutfits = {}
local originalOutfit = nil

-- Open Ped Outfits Main Menu
function OpenPedOutfitsMenu()
    print('[DEVTOOLS] Building Ped Outfits Menu...')
    local options = {}
    
    -- Add category options
    for categoryId, categoryData in pairs(PedOutfitsData) do
        table.insert(options, {
            id = categoryId,
            title = categoryData.name,
            description = string.format('Browse %s outfits (%d available)', categoryData.name:lower(), #categoryData.outfits),
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
        title = 'Reset to Original Outfit',
        description = 'Remove applied outfit and restore original appearance',
        icon = '🔄'
    })
    
    local menuData = {
        id = 'pedoutfits',
        title = 'Ped Outfits',
        subtitle = 'Select an outfit category',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Open Outfit Category Menu
function OpenOutfitCategoryMenu(categoryId, categoryData)
    local options = {}
    
    -- Add outfit options
    for i, outfit in ipairs(categoryData.outfits) do
        local isApplied = appliedOutfits.current == outfit.hash
        table.insert(options, {
            id = tostring(outfit.hash),
            title = outfit.label,
            description = string.format('Apply outfit to ped%s', 
                isApplied and ' (Currently Applied)' or ''
            ),
            icon = isApplied and '👕' or '🎭',
            applied = isApplied,
            data = {
                outfitHash = outfit.hash,
                outfitLabel = outfit.label,
                categoryId = categoryId
            }
        })
    end
    
    local menuData = {
        id = 'outfit_category_' .. categoryId,
        title = categoryData.name,
        subtitle = 'Click to apply outfit',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Apply Outfit
function ApplyOutfit(outfitHash, outfitLabel)
    local ped = PlayerPedId()
    
    -- Store original outfit if this is the first application
    if not originalOutfit then
        originalOutfit = {
            stored = true,
            appliedAt = GetGameTimer()
        }
        print('[DEVTOOLS] Original outfit stored for restoration')
    end
    
    print(string.format('[DEVTOOLS] Attempting to apply outfit: 0x%X to ped %s', outfitHash, ped))
    
    -- Apply the outfit using RedM native
    -- Based on rdr3_discoveries example: _APPLY_NON_REQUESTED_METAPED_OUTFIT
    Citizen.InvokeNative(0x1902C4CFCC5BE57C, ped, outfitHash)
    -- Update ped variation to apply changes
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    
    print('[DEVTOOLS] Outfit natives called successfully')
    
    -- Store the applied outfit data
    appliedOutfits.current = outfitHash
    appliedOutfits.label = outfitLabel
    appliedOutfits.appliedAt = GetGameTimer()
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Outfit Applied',
        message = string.format('Applied "%s" to ped', outfitLabel),
        type = 'success',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Apply Outfit', string.format('0x%X - %s', outfitHash, outfitLabel))
    
    print(string.format('[DEVTOOLS] Applied outfit: 0x%X (%s)', outfitHash, outfitLabel))
end

-- Reset to Original Outfit
function ResetToOriginalOutfit(showNotification)
    local ped = PlayerPedId()
    
    if not originalOutfit then
        if showNotification ~= false then
            TriggerEvent('qc-devtools:client:showNotification', {
                title = 'No Outfit to Reset',
                message = 'No outfit changes have been made',
                type = 'warning',
                duration = 3000
            })
        end
        return
    end
    
    print('[DEVTOOLS] Resetting to original outfit')
    
    -- Reset ped to default outfit by clearing metaped outfit
    -- This should restore the ped to its original appearance
    Citizen.InvokeNative(0x1902C4CFCC5BE57C, ped, 0x0) -- Clear outfit with hash 0
    -- Update ped variation to apply changes
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    
    appliedOutfits = {}
    originalOutfit = nil
    
    -- Only show notification if explicitly requested (default true for manual reset)
    if showNotification ~= false then
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Outfit Reset',
            message = 'Restored original appearance',
            type = 'success',
            duration = 3000
        })
    end
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Reset Outfit', 'Restored original appearance')
    
    print('[DEVTOOLS] Reset to original outfit')
end

-- Handle back navigation
RegisterNetEvent('qc-devtools:nui:back')
AddEventHandler('qc-devtools:nui:back', function()
    -- Let React handle the back navigation internally
end)

-- Handle menu close - reset outfit when menu is closed
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Reset outfit when the menu is closed (escape pressed)
    -- Don't show notification since this is automatic cleanup
    ResetToOriginalOutfit(false)
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'pedoutfits' then
        if optionId == 'clear' then
            ResetToOriginalOutfit()
        else
            -- Open outfit category
            local categoryData = PedOutfitsData[optionId]
            if categoryData then
                OpenOutfitCategoryMenu(optionId, categoryData)
            end
        end
    elseif menuId:find('outfit_category_') then
        -- Handle outfit selection
        if optionData and optionData.data then
            local outfitData = optionData.data
            
            -- Apply the selected outfit
            ApplyOutfit(outfitData.outfitHash, outfitData.outfitLabel)
            
            -- Update the current menu with new applied state
            local categoryData = PedOutfitsData[outfitData.categoryId]
            if categoryData then
                local updatedOptions = {}
                
                -- Rebuild options with current applied state
                for i, outfit in ipairs(categoryData.outfits) do
                    local isCurrentlyApplied = appliedOutfits.current == outfit.hash
                    table.insert(updatedOptions, {
                        id = tostring(outfit.hash),
                        title = outfit.label,
                        description = string.format('Apply outfit to ped%s', 
                            isCurrentlyApplied and ' (Currently Applied)' or ''
                        ),
                        icon = isCurrentlyApplied and '👕' or '🎭',
                        applied = isCurrentlyApplied,
                        data = {
                            outfitHash = outfit.hash,
                            outfitLabel = outfit.label,
                            categoryId = outfitData.categoryId
                        }
                    })
                end
                
                local updatedMenu = {
                    id = 'outfit_category_' .. outfitData.categoryId,
                    title = categoryData.name,
                    subtitle = 'Click to apply outfit',
                    options = updatedOptions
                }
                
                -- Update the current menu instead of navigating
                UpdateDevToolsMenu(updatedMenu)
            end
        end
    end
end)

-- Event Handlers
RegisterNetEvent('qc-devtools:client:openPedOutfits')
AddEventHandler('qc-devtools:client:openPedOutfits', function()
    print('[DEVTOOLS] Opening Ped Outfits Menu...')
    OpenPedOutfitsMenu()
end)

RegisterNetEvent('qc-devtools:client:resetAllOutfits')
AddEventHandler('qc-devtools:client:resetAllOutfits', function()
    ResetToOriginalOutfit()
end)