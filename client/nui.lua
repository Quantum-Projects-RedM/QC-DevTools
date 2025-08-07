--=========================================================
-- QC-DEVTOOLS - NUI INTERFACE
--=========================================================
-- Handles React NUI menu communication
-- Replaces ox_lib context menus with custom western-themed menus
--=========================================================

local nuiOpened = false
local currentMenuId = nil

-- Show Menu
local function ShowMenu(menuData)
    print('[QC-DevTools] ShowMenu called, nuiOpened:', nuiOpened)
    if nuiOpened then 
        print('[QC-DevTools] NUI already opened, ignoring ShowMenu call')
        return 
    end
    
    print('[QC-DevTools] Sending showMenu message to NUI')
    SendNUIMessage({
        action = 'showMenu',
        menu = menuData
    })
    
    SetNuiFocus(true, true)
    nuiOpened = true
    currentMenuId = menuData.id
end

-- Hide Menu
local function HideMenu()
    if not nuiOpened then return end
    
    SendNUIMessage({
        action = 'hideMenu'
    })
    
    SetNuiFocus(false, false)
    nuiOpened = false
    currentMenuId = nil
end

-- Navigate to Sub Menu
local function NavigateToMenu(menuData)
    if not nuiOpened then return end
    
    SendNUIMessage({
        action = 'navigateToMenu',
        menu = menuData
    })
    
    currentMenuId = menuData.id
end

-- Go Back
local function GoBack()
    if not nuiOpened then return end
    
    SendNUIMessage({
        action = 'goBack'
    })
end

-- Update Current Menu
local function UpdateMenu(menuData)
    if not nuiOpened then return end
    
    SendNUIMessage({
        action = 'updateMenu',
        menu = menuData
    })
end

-- NUI Callbacks
RegisterNUICallback('menuOptionSelected', function(data, cb)
    cb({})
    
    print('[QC-DevTools] NUI Callback menuOptionSelected:', json.encode(data))
    -- Handle menu option selection
    TriggerEvent('qc-devtools:nui:optionSelected', data.optionId, data.optionData, data.menuId)
end)

RegisterNUICallback('menuBack', function(data, cb)
    cb({})
    
    -- React handles back navigation internally, no Lua event needed
end)

RegisterNUICallback('menuClosed', function(data, cb)
    cb({})
    
    -- Handle menu close
    SetNuiFocus(false, false)
    nuiOpened = false
    currentMenuId = nil
    TriggerEvent('qc-devtools:nui:closed')
end)

-- Exports for other modules
exports('ShowMenu', function(menuData)
    ShowMenu(menuData)
end)

exports('HideMenu', function()
    HideMenu()
end)

exports('NavigateToMenu', function(menuData)
    NavigateToMenu(menuData)
end)

exports('GoBack', function()
    GoBack()
end)

exports('UpdateMenu', function(menuData)
    UpdateMenu(menuData)
end)

exports('IsMenuOpen', function()
    return nuiOpened
end)

exports('GetCurrentMenuId', function()
    return currentMenuId
end)

-- Show Notification
local function ShowNotification(notificationData)
    SendNUIMessage({
        action = 'showNotification',
        notification = notificationData
    })
end

-- Global functions for easy access
function ShowDevToolsMenu(menuData)
    print('[QC-DevTools] ShowDevToolsMenu called with:', json.encode(menuData))
    print('[QC-DevTools] Current nuiOpened state:', nuiOpened)
    
    if nuiOpened then
        print('[QC-DevTools] NUI already open, using NavigateToMenu instead')
        NavigateToMenu(menuData)
    else
        print('[QC-DevTools] NUI closed, using ShowMenu')
        ShowMenu(menuData)
    end
end

function HideDevToolsMenu()
    HideMenu()
end

function NavigateDevToolsMenu(menuData)
    NavigateToMenu(menuData)
end

function ShowDevToolsNotification(notificationData)
    ShowNotification(notificationData)
end

function UpdateDevToolsMenu(menuData)
    UpdateMenu(menuData)
end