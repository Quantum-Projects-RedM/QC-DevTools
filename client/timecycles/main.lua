--=========================================================
-- QC-DEVTOOLS - TIMECYCLES MODULE
--=========================================================
-- Handles timecycle modifier testing and application
-- SET TIMECYCLE: Citizen.InvokeNative(0xFA08722A5EA82DA7,timecycle_modifier)
-- SET STRENGTH: Citizen.InvokeNative(0xFDB74C9CC54C3F37,1.0)
-- CLEAR TIMECYCLE: Citizen.InvokeNative(0x0E3F4AF2D63491FB)
--=========================================================

local activeTimecycle = nil
local currentStrength = 1.0

-- Open Timecycles Main Menu
function OpenTimecyclesMenu()
    print('[DEVTOOLS] Building Timecycles Menu...')
    local options = {}
    
    -- Add category options
    for categoryId, categoryData in pairs(TimecycleData) do
        table.insert(options, {
            id = categoryId,
            title = categoryData.name,
            description = string.format('Browse %s (%d available)', categoryData.name:lower(), #categoryData.timecycles),
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
        title = 'Clear Timecycle',
        description = 'Remove currently active timecycle modifier',
        icon = '🛑'
    })
    
    table.insert(options, {
        id = 'strength',
        title = 'Adjust Strength',
        description = string.format('Current strength: %.1f - Click to cycle', currentStrength),
        icon = '⚡'
    })
    
    local menuData = {
        id = 'timecycles',
        title = 'Timecycle Modifiers',
        subtitle = 'Select a category to browse effects',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Open Timecycles Category Menu
function OpenTimecyclesCategoryMenu(categoryId, categoryData)
    local options = {}
    
    -- Add timecycle options
    for i, timecycle in ipairs(categoryData.timecycles) do
        local isActive = activeTimecycle == timecycle
        
        table.insert(options, {
            id = timecycle,
            title = timecycle,
            description = string.format('%s timecycle modifier%s', 
                isActive and 'Clear' or 'Apply',
                isActive and ' (Currently Active)' or ''
            ),
            icon = isActive and '⏹️' or '▶️',
            applied = isActive,
            data = {
                timecycle = timecycle,
                categoryId = categoryId
            }
        })
    end
    
    local menuData = {
        id = 'timecycles_category_' .. categoryId,
        title = categoryData.name,
        subtitle = 'Click to apply/clear timecycle modifiers',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Apply Timecycle
function ApplyTimecycle(timecycle)
    print(string.format('[DEVTOOLS] Applying Timecycle: %s (strength: %.1f)', timecycle, currentStrength))
    
    -- Clear any existing timecycle first
    if activeTimecycle then
        Citizen.InvokeNative(0x0E3F4AF2D63491FB) -- CLEAR_TIMECYCLE_MODIFIER
    end
    
    -- Set new timecycle
    Citizen.InvokeNative(0xFA08722A5EA82DA7, timecycle) -- SET_TIMECYCLE_MODIFIER
    Citizen.InvokeNative(0xFDB74C9CC54C3F37, currentStrength) -- SET_TIMECYCLE_MODIFIER_STRENGTH
    
    activeTimecycle = timecycle
    
    print(string.format('[DEVTOOLS] Applied timecycle: %s', timecycle))
    
    -- Auto-copy timecycle name to clipboard
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = timecycle,
        description = 'Timecycle Applied: ' .. timecycle
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Timecycle Applied',
        message = string.format('Applied "%s" at %.1f strength', timecycle, currentStrength),
        type = 'success',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Apply Timecycle', string.format('%s (strength: %.1f)', timecycle, currentStrength))
end

-- Clear Timecycle
function ClearTimecycle()
    if not activeTimecycle then
        print('[DEVTOOLS] No active timecycle to clear')
        return
    end
    
    local previousTimecycle = activeTimecycle
    
    print(string.format('[DEVTOOLS] Clearing Timecycle: %s', activeTimecycle))
    
    -- Clear the timecycle
    Citizen.InvokeNative(0x0E3F4AF2D63491FB) -- CLEAR_TIMECYCLE_MODIFIER
    activeTimecycle = nil
    
    print('[DEVTOOLS] Timecycle cleared')
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Timecycle Cleared',
        message = string.format('Cleared "%s"', previousTimecycle),
        type = 'info',
        duration = 3000
    })
    
    -- Log to server for tracking
    TriggerServerEvent('qc-devtools:server:logAction', 'Clear Timecycle', previousTimecycle)
end

-- Cycle Strength Values
function CycleStrength()
    local strengths = {0.1, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0}
    local currentIndex = 1
    
    -- Find current strength index
    for i, strength in ipairs(strengths) do
        if math.abs(currentStrength - strength) < 0.01 then
            currentIndex = i
            break
        end
    end
    
    -- Move to next strength (cycle back to start if at end)
    currentIndex = currentIndex + 1
    if currentIndex > #strengths then
        currentIndex = 1
    end
    
    currentStrength = strengths[currentIndex]
    
    -- If there's an active timecycle, reapply with new strength
    if activeTimecycle then
        Citizen.InvokeNative(0xFDB74C9CC54C3F37, currentStrength) -- SET_TIMECYCLE_MODIFIER_STRENGTH
    end
    
    print(string.format('[DEVTOOLS] Timecycle strength changed to: %.2f', currentStrength))
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Strength Updated',
        message = string.format('Timecycle strength set to %.2f', currentStrength),
        type = 'info',
        duration = 2000
    })
    
    -- Refresh main menu to show new strength
    OpenTimecyclesMenu()
end

-- Handle menu close - clear all effects when menu is closed
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Clear timecycle when the menu is closed (escape pressed)
    if activeTimecycle then
        ClearTimecycle()
    end
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'timecycles' then
        if optionId == 'clear' then
            ClearTimecycle()
            OpenTimecyclesMenu() -- Refresh menu
        elseif optionId == 'strength' then
            CycleStrength()
        else
            -- Open timecycles category
            local categoryData = TimecycleData[optionId]
            if categoryData then
                OpenTimecyclesCategoryMenu(optionId, categoryData)
            end
        end
    elseif menuId:find('timecycles_category_') then
        -- Handle timecycle selection
        if optionData and optionData.data then
            local timecycleData = optionData.data
            local isActive = activeTimecycle == timecycleData.timecycle
            
            if isActive then
                ClearTimecycle()
            else
                ApplyTimecycle(timecycleData.timecycle)
            end
            
            -- Update the current menu with new active state
            local categoryData = TimecycleData[timecycleData.categoryId]
            if categoryData then
                local updatedOptions = {}
                
                -- Rebuild options with current active state
                for i, timecycle in ipairs(categoryData.timecycles) do
                    local isCurrentlyActive = activeTimecycle == timecycle
                    
                    table.insert(updatedOptions, {
                        id = timecycle,
                        title = timecycle,
                        description = string.format('%s timecycle modifier%s', 
                            isCurrentlyActive and 'Clear' or 'Apply',
                            isCurrentlyActive and ' (Currently Active)' or ''
                        ),
                        icon = isCurrentlyActive and '⏹️' or '▶️',
                        applied = isCurrentlyActive,
                        data = {
                            timecycle = timecycle,
                            categoryId = timecycleData.categoryId
                        }
                    })
                end
                
                local updatedMenu = {
                    id = 'timecycles_category_' .. timecycleData.categoryId,
                    title = categoryData.name,
                    subtitle = 'Click to apply/clear timecycle modifiers',
                    options = updatedOptions
                }
                
                -- Update the current menu instead of navigating
                UpdateDevToolsMenu(updatedMenu)
            end
        end
    end
end)

-- Event Handlers
RegisterNetEvent('qc-devtools:client:openTimecycles')
AddEventHandler('qc-devtools:client:openTimecycles', function()
    print('[DEVTOOLS] Opening Timecycles Menu...')
    OpenTimecyclesMenu()
end)

RegisterNetEvent('qc-devtools:client:clearTimecycle')
AddEventHandler('qc-devtools:client:clearTimecycle', function()
    ClearTimecycle()
end)