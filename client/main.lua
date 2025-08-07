--=========================================================
-- QC-DEVTOOLS - MAIN CLIENT
--=========================================================
-- Main menu system for development tools
-- Modular design for easy expansion
--=========================================================

-- Collect all searchable data from modules
local function GetGlobalSearchData()
    local searchData = {}
    
    -- Ped Decals
    if PedDecalsData then
        for categoryKey, categoryData in pairs(PedDecalsData) do
            if categoryData.decals then
                for _, decal in ipairs(categoryData.decals) do
                    table.insert(searchData, {
                        id = 'peddecals_' .. decal.name,
                        title = decal.label or decal.name,
                        description = 'Ped Decal - ' .. categoryData.name,
                        category = 'peddecals',
                        categoryLabel = 'Ped Decals',
                        icon = '🎨',
                        searchTerms = decal.name .. ' ' .. (decal.label or '') .. ' decal ped ' .. categoryData.name
                    })
                end
            end
        end
    end
    
    -- IPL Data (limit to first 50 to avoid performance issues)
    if ipls and ipls.validCoords then
        local iplCount = 0
        for hash, ipl in pairs(ipls.validCoords) do
            if iplCount >= 50 then break end -- Limit to 50 IPLs
            
            table.insert(searchData, {
                id = 'ipls_' .. ipl.hashname,
                title = ipl.hashname,
                description = 'IPL Location - Interior/Map Area',
                category = 'ipls',
                categoryLabel = 'IPL Locations',
                icon = '🏢',
                searchTerms = ipl.hashname .. ' ipl location interior map area'
            })
            
            iplCount = iplCount + 1
        end
    end
    
    -- Audio Banks (limit to first 10 banks to avoid performance issues)
    if audiobanks then
        local bankCount = 0
        for bankName, sounds in pairs(audiobanks) do
            if bankCount >= 10 then break end -- Limit to 10 banks
            
            -- Add the bank itself
            table.insert(searchData, {
                id = 'audio_' .. bankName,
                title = bankName,
                description = 'Audio Bank - ' .. #sounds .. ' sounds',
                category = 'audio',
                categoryLabel = 'Audio Tools',
                icon = '🔊',
                searchTerms = bankName .. ' audio sound bank voice'
            })
            
            -- Add individual sounds from the bank (first 3 to avoid too many results)
            for i = 1, math.min(3, #sounds) do
                table.insert(searchData, {
                    id = 'audio_' .. bankName .. '_' .. sounds[i],
                    title = sounds[i],
                    description = 'Sound - From ' .. bankName,
                    category = 'audio',
                    categoryLabel = 'Audio Tools',
                    icon = '🔊',
                    searchTerms = sounds[i] .. ' ' .. bankName .. ' audio sound effect voice'
                })
            end
            
            bankCount = bankCount + 1
        end
    end
    
    -- Explosion Data
    if ExplosionData then
        for categoryKey, categoryData in pairs(ExplosionData) do
            if categoryData.explosions then
                for _, explosion in ipairs(categoryData.explosions) do
                    table.insert(searchData, {
                        id = 'explosions_' .. explosion.id,
                        title = explosion.name,
                        description = explosion.description .. ' - ' .. categoryData.name,
                        category = 'explosions',
                        categoryLabel = 'Explosions',
                        icon = '💥',
                        searchTerms = explosion.name .. ' ' .. explosion.tag .. ' ' .. explosion.description .. ' explosion effect boom ' .. categoryData.name
                    })
                end
            end
        end
    end
    
    return searchData
end

-- Main DevTools Menu
local function OpenMainMenu()
    local options = {}
    
    -- Build menu options from config categories
    for _, category in ipairs(Config.Categories) do
        if category.enabled then
            table.insert(options, {
                id = category.id,
                title = category.label,
                description = category.description,
                icon = category.icon
            })
        end
    end
    
    -- Don't add the "Clear All Effects" option since each module has its own clear function
    
    local menuData = {
        id = 'main',
        title = 'RedM Development Tools',
        subtitle = 'Select a category to continue',
        options = options,
        searchData = GetGlobalSearchData() -- Add search data
    }
    
    ShowDevToolsMenu(menuData)
end

-- NUI Menu Option Selected Handler
RegisterNetEvent('qc-devtools:nui:optionSelected')
AddEventHandler('qc-devtools:nui:optionSelected', function(optionId, optionData, menuId)
    if menuId == 'main' then
        -- Handle search result selections (items from within categories)
        if string.find(optionId, '_') then
            local category, itemId = optionId:match('(.-)_(.*)')
            
            if category == 'peddecals' then
                -- Open ped decals and apply the specific decal
                TriggerEvent('qc-devtools:client:openPedDecals')
                -- Wait a bit for the module to load, then apply the decal
                Citizen.SetTimeout(100, function()
                    TriggerEvent('qc-devtools:client:applyPedDecal', itemId)
                end)
            elseif category == 'ipls' then
                -- Open IPLs and teleport to the specific location
                TriggerEvent('qc-devtools:client:openIPLs')
                Citizen.SetTimeout(100, function()
                    TriggerEvent('qc-devtools:client:teleportToIPL', itemId)
                end)
            elseif category == 'audio' then
                -- Open audio tools
                TriggerEvent('qc-devtools:client:openAudio')
                Citizen.SetTimeout(100, function()
                    TriggerEvent('qc-devtools:client:playAudioBank', itemId)
                end)
            elseif category == 'explosions' then
                -- Open explosions and trigger the specific explosion
                TriggerEvent('qc-devtools:client:openExplosions')
                Citizen.SetTimeout(100, function()
                    TriggerEvent('qc-devtools:client:triggerExplosion', itemId)
                end)
            else
                -- Fallback: just open the category
                if optionData and optionData.data and optionData.data.category then
                    TriggerEvent('qc-devtools:client:openCategory', optionData.data.category)
                end
            end
        else
            -- Regular category selections
            if optionId == 'peddecals' then
                TriggerEvent('qc-devtools:client:openPedDecals')
            elseif optionId == 'animpostfx' then
                TriggerEvent('qc-devtools:client:openAnimPostFX')
            elseif optionId == 'timecycles' then
                TriggerEvent('qc-devtools:client:openTimecycles')
            elseif optionId == 'explosions' then
                TriggerEvent('qc-devtools:client:openExplosions')
            elseif optionId == 'audio' then
                TriggerEvent('qc-devtools:client:openAudio')
            elseif optionId == 'ipls' then
                TriggerEvent('qc-devtools:client:openIPLs')
            elseif optionId == 'entityinfo' then
                TriggerEvent('qc-devtools:client:openEntityInfo')
            else
                -- Coming soon notification for other modules
                TriggerEvent('qc-devtools:client:showNotification', {
                    title = 'Coming Soon',
                    message = 'This module is under development',
                    type = 'info'
                })
            end
        end
    else
        -- Handle other menu selections
        TriggerEvent('qc-devtools:nui:menuSelection', optionId, optionData, menuId)
    end
end)

-- NUI Menu Closed Handler
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Menu was closed, handle cleanup if needed
end)

-- Category router (legacy support)
RegisterNetEvent('qc-devtools:client:openCategory')
AddEventHandler('qc-devtools:client:openCategory', function(categoryId)
    -- This is now handled by the NUI option selection
    TriggerEvent('qc-devtools:nui:optionSelected', categoryId, {}, 'main')
end)

-- Main menu opener (for back navigation)
RegisterNetEvent('qc-devtools:client:openMain')
AddEventHandler('qc-devtools:client:openMain', function()
    OpenMainMenu()
end)

-- Notification system
RegisterNetEvent('qc-devtools:client:showNotification')
AddEventHandler('qc-devtools:client:showNotification', function(data)
    ShowDevToolsNotification({
        title = data.title or 'DevTools',
        message = data.message,
        type = data.type or 'info',
        duration = data.duration or 5000
    })
end)

-- Auto-copy to clipboard for action buttons
RegisterNetEvent('qc-devtools:client:autoCopyToClipboard')
AddEventHandler('qc-devtools:client:autoCopyToClipboard', function(data)
    -- Send copy request to NUI
    SendNUIMessage({
        action = 'copyToClipboard',
        text = data.text,
        description = data.description
    })
end)

-- Clear all effects
RegisterNetEvent('qc-devtools:client:clearAll')
AddEventHandler('qc-devtools:client:clearAll', function()
    -- For now, just clear without confirmation (can add confirmation dialog later)
    
    -- Clear decals
    TriggerEvent('qc-devtools:client:clearAllDecals')
    
    -- Future: Clear outfits, vehicles, etc.
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Effects Cleared',
        message = 'All applied effects have been removed',
        type = 'success'
    })
end)

-- Commands
RegisterCommand(Config.Commands.mainMenu, function()
    OpenMainMenu()
end, false)

-- Alternative direct access to ped decals
RegisterCommand(Config.Commands.pedDecals, function()
    TriggerEvent('qc-devtools:client:openPedDecals')
end, false)

-- Debug command to teleport to IPL location for testing
RegisterCommand('ipl_test', function()
    if not ipls or not ipls.validCoords then
        print('[QC-DevTools] No IPL data available for teleport test')
        return
    end
    
    -- Find first IPL and teleport near it
    for hexHash, ipl in pairs(ipls.validCoords) do
        local x, y, z = ipl.x, ipl.y, ipl.z
        SetEntityCoords(PlayerPedId(), x + 50.0, y + 50.0, z + 10.0)
        print(string.format('[QC-DevTools] Teleported to IPL test area near %s (%.1f, %.1f, %.1f)', 
            ipl.hashname, x, y, z))
        
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'IPL Test Teleport',
            message = string.format('Teleported near %s\nNow enable IPL display!', ipl.hashname),
            type = 'info',
            duration = 5000
        })
        break
    end
end, false)

-- Debug command to show IPLs near current location
RegisterCommand('ipl_nearby', function()
    if not ipls or not ipls.validCoords then
        print('[QC-DevTools] No IPL data available')
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    print(string.format('[QC-DevTools] Player location: %.1f, %.1f, %.1f', playerCoords.x, playerCoords.y, playerCoords.z))
    print('[QC-DevTools] Nearby IPLs (within 500m):')
    
    local count = 0
    for hexHash, ipl in pairs(ipls.validCoords) do
        local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, ipl.x, ipl.y, ipl.z, true)
        if distance <= 500 then
            print(string.format('  %s: %.1fm away at %.1f,%.1f,%.1f', ipl.hashname, distance, ipl.x, ipl.y, ipl.z))
            count = count + 1
        end
    end
    
    if count == 0 then
        print('[QC-DevTools] No IPLs found within 500m of your location')
        print('[QC-DevTools] Try /ipl_test to teleport to a known IPL area')
    else
        print(string.format('[QC-DevTools] Found %d IPLs within 500m', count))
    end
end, false)

-- Initialization
CreateThread(function()
    print(string.format('[QC-DevTools] Loaded! Use /%s to open development tools', Config.Commands.mainMenu))
end)
