--=========================================================
-- QC-DEVTOOLS - IPL MODULE 
--=========================================================
-- Interior Placement (IPL) management system
-- Based on t3chman's ipl_tool for RedM
-- Enable/disable IPLs through menu buttons
--=========================================================

local iplCategories = {}

-- Visual IPL system variables (like original ipl_tool)
local showIPLHandles = false
local iplDisplayRange = 25.0
local range = 25.0 -- Alias for compatibility
local displayRanges = {25.0, 50.0, 100.0, 150.0, 200.0, 300.0}
local currentRangeIndex = 1 -- Start at 25.0
local renderedHandles = {} -- For handle collision detection

-- Initialize IPL categories based on hashname patterns
local function initializeIPLCategories()
    local categories = {}
    
    -- Process validCoords IPLs
    for hexHash, iplInfo in pairs(ipls.validCoords) do
        local hashname = iplInfo.hashname
        local categoryName = "Miscellaneous"
        
        -- Categorize based on hashname patterns
        if string.find(hashname, "^a_") then
            categoryName = "Area IPLs"
        elseif string.find(hashname, "aba_") then
            categoryName = "Abandoned"
        elseif string.find(hashname, "camp") then
            categoryName = "Camps"
        elseif string.find(hashname, "house") or string.find(hashname, "building") then
            categoryName = "Buildings"
        elseif string.find(hashname, "saloon") or string.find(hashname, "bar") then
            categoryName = "Saloons & Bars"
        elseif string.find(hashname, "shop") or string.find(hashname, "store") then
            categoryName = "Shops & Stores"
        elseif string.find(hashname, "bridge") then
            categoryName = "Bridges"
        elseif string.find(hashname, "train") or string.find(hashname, "station") then
            categoryName = "Trains & Stations"
        elseif string.find(hashname, "boat") or string.find(hashname, "ship") then
            categoryName = "Boats & Ships"
        elseif string.find(hashname, "gang") or string.find(hashname, "hideout") then
            categoryName = "Gang Hideouts"
        elseif string.find(hashname, "valentine") then
            categoryName = "Valentine"
        elseif string.find(hashname, "strawberry") then
            categoryName = "Strawberry"
        elseif string.find(hashname, "rhodes") then
            categoryName = "Rhodes"
        elseif string.find(hashname, "saintdenis") or string.find(hashname, "saint_denis") then
            categoryName = "Saint Denis"
        elseif string.find(hashname, "blackwater") then
            categoryName = "Blackwater"
        elseif string.find(hashname, "armadillo") then
            categoryName = "Armadillo"
        elseif string.find(hashname, "tumbleweed") then
            categoryName = "Tumbleweed"
        elseif string.find(hashname, "_strm_") then
            categoryName = "Streaming"
        elseif string.find(hashname, "_lod") then
            categoryName = "Level of Detail"
        end
        
        if not categories[categoryName] then
            categories[categoryName] = {}
        end
        
        table.insert(categories[categoryName], {
            hexHash = hexHash,
            hashname = hashname,
            decHash = iplInfo.dec_hash,
            coords = {
                x = iplInfo.x,
                y = iplInfo.y,
                z = iplInfo.z,
                h = iplInfo.h
            }
        })
    end
    
    -- Process invalidCoords IPLs if they exist
    if ipls.invalidCoords then
        for hexHash, iplInfo in pairs(ipls.invalidCoords) do
            if not categories["Invalid Coords"] then
                categories["Invalid Coords"] = {}
            end
            
            table.insert(categories["Invalid Coords"], {
                hexHash = hexHash,
                hashname = iplInfo.hashname,
                decHash = iplInfo.dec_hash,
                coords = {
                    x = iplInfo.x,
                    y = iplInfo.y,
                    z = iplInfo.z,
                    h = iplInfo.h
                }
            })
        end
    end
    
    return categories
end

-- Check if an IPL is currently active in the game world
local function isIPLActive(decHash)
    return IsIplActiveHash(decHash)
end

-- Request (enable) an IPL
local function requestIPL(decHash, hashname)
    if not isIPLActive(decHash) then
        RequestIplHash(decHash)
        
        print(string.format('[QC-DevTools] Requested IPL: %s (0x%08X)', hashname, decHash))
        
        -- Auto-copy IPL name to clipboard
        TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
            text = hashname,
            description = 'IPL Enabled: ' .. hashname
        })
        
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'IPL Enabled',
            message = string.format('Loaded: %s', hashname),
            type = 'success',
            duration = 3000
        })
        
        TriggerServerEvent('qc-devtools:server:logAction', 'Enable IPL', hashname)
        return true
    else
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'IPL Already Active',
            message = string.format('%s is already loaded', hashname),
            type = 'warning',
            duration = 2000
        })
        return false
    end
end

-- Remove (disable) an IPL
local function removeIPL(decHash, hashname)
    if isIPLActive(decHash) then
        RemoveIplHash(decHash)
        
        print(string.format('[QC-DevTools] Removed IPL: %s (0x%08X)', hashname, decHash))
        
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'IPL Disabled',
            message = string.format('Unloaded: %s', hashname),
            type = 'info',
            duration = 3000
        })
        
        TriggerServerEvent('qc-devtools:server:logAction', 'Disable IPL', hashname)
        return true
    else
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'IPL Not Active',
            message = string.format('%s is not currently loaded', hashname),
            type = 'warning',
            duration = 2000
        })
        return false
    end
end

-- Toggle IPL on/off
local function toggleIPL(decHash, hashname)
    if isIPLActive(decHash) then
        return removeIPL(decHash, hashname)
    else
        return requestIPL(decHash, hashname)
    end
end

-- Request all IPLs in a category
local function requestAllIPLsInCategory(category)
    if not category or type(category) ~= "table" then
        print('[QC-DevTools] ERROR: Invalid category passed to requestAllIPLsInCategory:', category)
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Error',
            message = 'Invalid category data',
            type = 'error',
            duration = 3000
        })
        return
    end
    
    local count = 0
    for _, ipl in ipairs(category) do
        if not isIPLActive(ipl.decHash) then
            requestIPL(ipl.decHash, ipl.hashname)
            count = count + 1
        end
    end
    
    if count > 0 then
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Category Enabled',
            message = string.format('Loaded %d IPLs in category', count),
            type = 'success',
            duration = 4000
        })
    else
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Category Already Active',
            message = 'All IPLs in this category are already loaded',
            type = 'warning',
            duration = 3000
        })
    end
end

-- Remove all IPLs in a category
local function removeAllIPLsInCategory(category)
    if not category or type(category) ~= "table" then
        print('[QC-DevTools] ERROR: Invalid category passed to removeAllIPLsInCategory:', category)
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Error',
            message = 'Invalid category data',
            type = 'error',
            duration = 3000
        })
        return
    end
    
    local count = 0
    for _, ipl in ipairs(category) do
        if isIPLActive(ipl.decHash) then
            removeIPL(ipl.decHash, ipl.hashname)
            count = count + 1
        end
    end
    
    if count > 0 then
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Category Disabled',
            message = string.format('Unloaded %d IPLs in category', count),
            type = 'info',
            duration = 4000
        })
    else
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Category Not Active',
            message = 'No IPLs in this category are currently loaded',
            type = 'warning',
            duration = 3000
        })
    end
end

-- Toggle IPL visual display
local function toggleIPLDisplay()
    showIPLHandles = not showIPLHandles
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'IPL Display ' .. (showIPLHandles and 'Enabled' or 'Disabled'),
        message = showIPLHandles and string.format('Showing IPLs within %.0fm', iplDisplayRange) or 'IPL visualization disabled',
        type = showIPLHandles and 'success' or 'info',
        duration = 3000
    })
    
    print(string.format('[QC-DevTools] IPL display %s (range: %.0fm)', 
        showIPLHandles and 'enabled' or 'disabled', iplDisplayRange))
end

-- Cycle IPL display range
local function cycleIPLRange()
    currentRangeIndex = currentRangeIndex + 1
    if currentRangeIndex > #displayRanges then
        currentRangeIndex = 1
    end
    
    iplDisplayRange = displayRanges[currentRangeIndex]
    range = iplDisplayRange -- Update compatibility variable
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'IPL Display Range',
        message = string.format('Range set to %.0fm', iplDisplayRange),
        type = 'info',
        duration = 2000
    })
    
    print(string.format('[QC-DevTools] IPL display range set to %.0fm', iplDisplayRange))
end

-- Draw 3D text for IPLs (based on original ipl_tool.lua)
function drawText3d(x, y, z, ipl)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)
    local text = tostring(ipl.dec_hash)
    local hashname = ipl.hashname
    if hashname and hashname ~= '' then
        text = text.." | "..tostring(hashname)
    end
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFontForCurrentCommand(1)
        SetTextColor(255, 255, 255, 255)
        SetTextCentre(1)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), screenX, screenY)        
    end
end

-- Draw IPL handle with collision detection (based on original ipl_tool.lua)
function drawIplHandle(ipl, playerCoords)
    local coords = vector3(ipl.x, ipl.y, ipl.z)
    local distance = #(playerCoords - coords)
    local offset = distance/25
    if distance <= range then
        local numRenderedHandles = #renderedHandles
        if numRenderedHandles >= 1 then
            for _, renderedHandle in next, renderedHandles do
                if #(vector3(renderedHandle.x, renderedHandle.y, renderedHandle.z) - coords) <= offset then
                    coords = coords + offset
                end
            end
        end
        table.insert(renderedHandles, ipl)
        drawText3d(coords.x, coords.y, coords.z, ipl)
    end
end

-- Main IPL display thread (based on original ipl_tool.lua)
CreateThread(function()
    while true do
        if showIPLHandles then
            local playerCoords = GetEntityCoords(PlayerPedId())
            renderedHandles = {} -- Reset rendered handles each frame
            
            -- Process valid coordinate IPLs (matching original structure)
            if ipls and ipls.validCoords then
                for hexHash, ipl in pairs(ipls.validCoords) do
                    drawIplHandle(ipl, playerCoords)
                end
                
                -- Process invalid coordinate IPLs if they exist
                if ipls.invalidCoords then
                    for hexHash, ipl in pairs(ipls.invalidCoords) do
                        drawIplHandle(ipl, playerCoords)
                    end
                end
            end
            
            -- Show range info on screen
            local countText = string.format("IPL Range: %.0fm | Count: %d", range or 0, #renderedHandles)
            SetTextScale(0.35, 0.35)
            SetTextFontForCurrentCommand(1)
            SetTextColor(255, 255, 255, 200)
            SetTextCentre(0)
            DisplayText(CreateVarString(10, "LITERAL_STRING", countText), 0.02, 0.02)
        end
        
        Wait(0)
    end
end)

-- Request all inactive IPLs (enable all IPLs that aren't currently active)
local function requestAllIPLs()
    local count = 0
    
    -- Check all known IPLs and enable any that are currently inactive
    if ipls and ipls.validCoords then
        for hexHash, ipl in pairs(ipls.validCoords) do
            if not isIPLActive(ipl.dec_hash) then
                RequestIplHash(ipl.dec_hash)
                count = count + 1
            end
        end
    end
    
    -- Also check invalid coords if they exist
    if ipls and ipls.invalidCoords then
        for hexHash, ipl in pairs(ipls.invalidCoords) do
            if not isIPLActive(ipl.dec_hash) then
                RequestIplHash(ipl.dec_hash)
                count = count + 1
            end
        end
    end
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'All IPLs Requested',
        message = string.format('Loaded %d inactive IPLs into game world', count),
        type = 'success',
        duration = 4000
    })
    
    print(string.format('[QC-DevTools] Requested all inactive IPLs (%d total)', count))
    TriggerServerEvent('qc-devtools:server:logAction', 'Request All IPLs', string.format('%d IPLs loaded', count))
end

-- Remove all active IPLs (all IPLs currently loaded in the game world)
local function removeAllIPLs()
    local count = 0
    
    -- Check all known IPLs and remove any that are currently active
    if ipls and ipls.validCoords then
        for hexHash, ipl in pairs(ipls.validCoords) do
            if isIPLActive(ipl.dec_hash) then
                RemoveIplHash(ipl.dec_hash)
                count = count + 1
            end
        end
    end
    
    -- Also check invalid coords if they exist
    if ipls and ipls.invalidCoords then
        for hexHash, ipl in pairs(ipls.invalidCoords) do
            if isIPLActive(ipl.dec_hash) then
                RemoveIplHash(ipl.dec_hash)
                count = count + 1
            end
        end
    end
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'All IPLs Disabled',
        message = string.format('Unloaded %d active IPLs from game world', count),
        type = 'success',
        duration = 4000
    })
    
    print(string.format('[QC-DevTools] Removed all active IPLs (%d total)', count))
    TriggerServerEvent('qc-devtools:server:logAction', 'Disable All IPLs', string.format('%d IPLs removed', count))
end

-- Initialize categories when script starts
CreateThread(function()
    Wait(1000) -- Wait for IPL data to load
    
    -- Check if IPL data exists
    if not ipls then
        print('[QC-DevTools] ERROR: ipls is nil!')
        return
    end
    
    if not ipls.validCoords then
        print('[QC-DevTools] ERROR: ipls.validCoords is nil!')
        return
    end
    
    local validCount = 0
    for _ in pairs(ipls.validCoords) do
        validCount = validCount + 1
    end
    print(string.format('[QC-DevTools] IPL system initialized with %d IPLs', validCount))
    
    iplCategories = initializeIPLCategories()
    
    -- Set initial range
    range = iplDisplayRange
end)

-- Main IPLs Menu
function OpenIPLsMenu()
    print('[QC-DevTools] Building IPL menu...')
    local options = {}
    
    -- Add visual display controls first
    options[#options + 1] = {
        id = 'toggle_display',
        title = showIPLHandles and 'Hide IPL Display' or 'Show IPL Display',
        description = showIPLHandles and 'Click to hide IPL visualization' or 'Show nearby IPLs with 3D labels',
        icon = showIPLHandles and '👁️' or '👁️‍🗨️'
    }
    
    options[#options + 1] = {
        id = 'cycle_range',
        title = 'Display Range',
        description = string.format('Current: %.0fm - Click to cycle', iplDisplayRange),
        icon = '📏'
    }
    
    options[#options + 1] = {
        id = 'separator1',
        separator = true
    }
    
    -- Add a few main categories (simplified)
    local mainCategories = {
        "Area IPLs",
        "Buildings", 
        "Camps",
        "Miscellaneous"
    }
    
    for _, categoryName in ipairs(mainCategories) do
        if iplCategories[categoryName] then
            local categoryIPLs = iplCategories[categoryName]
            local activeCount = 0
            
            for _, ipl in ipairs(categoryIPLs) do
                if isIPLActive(ipl.decHash) then
                    activeCount = activeCount + 1
                end
            end
            
            options[#options + 1] = {
                id = categoryName,
                title = categoryName,
                description = string.format('%d IPLs (%d active)', #categoryIPLs, activeCount),
                icon = activeCount > 0 and '🟢' or '⚪',
                data = {
                    categoryName = categoryName,
                    categoryIPLs = categoryIPLs
                }
            }
        end
    end
    
    -- Add utilities
    options[#options + 1] = {
        id = 'separator2',
        separator = true
    }
    
    options[#options + 1] = {
        id = 'request_all',
        title = 'Request All IPLs',
        description = 'Load all inactive IPLs into the game world',
        icon = '✅'
    }
    
    options[#options + 1] = {
        id = 'remove_all',
        title = 'Remove All IPLs',
        description = 'Stop all active IPLs',
        icon = '🛑'
    }
    
    local menuData = {
        id = 'ipls',
        title = 'Interior Placements (IPLs)',
        subtitle = 'IPL management and visualization',
        options = options
    }
    
    print('[QC-DevTools] Menu built with', #options, 'options')
    NavigateDevToolsMenu(menuData)
end

-- IPL Category Menu
function OpenIPLCategoryMenu(categoryName, categoryIPLs)
    if not categoryIPLs or type(categoryIPLs) ~= "table" then
        print('[QC-DevTools] ERROR: Invalid categoryIPLs passed to OpenIPLCategoryMenu:', categoryIPLs)
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Error',
            message = 'Invalid category data',
            type = 'error',
            duration = 3000
        })
        return
    end
    
    local options = {}
    
    -- Add individual IPL options
    for _, ipl in ipairs(categoryIPLs) do
        local isActive = isIPLActive(ipl.decHash)
        
        table.insert(options, {
            id = ipl.hashname,
            title = ipl.hashname,
            description = string.format('Dec: %d | Coords: %.0f, %.0f, %.0f%s',
                ipl.decHash,
                ipl.coords.x, ipl.coords.y, ipl.coords.z,
                isActive and ' (ACTIVE)' or ''
            ),
            icon = isActive and '🟢' or '⚪',
            applied = isActive,
            data = {
                decHash = ipl.decHash,
                hashname = ipl.hashname,
                coords = ipl.coords
            }
        })
    end
    
    -- Sort IPLs alphabetically
    table.sort(options, function(a, b)
        return a.title < b.title
    end)
    
    -- Add category-wide options
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'enable_all',
        title = 'Enable All in Category',
        description = string.format('Load all %d IPLs in %s', #categoryIPLs, categoryName),
        icon = '✅'
    })
    
    table.insert(options, {
        id = 'disable_all',
        title = 'Disable All in Category', 
        description = string.format('Unload all IPLs in %s', categoryName),
        icon = '❌'
    })
    
    local menuData = {
        id = 'ipl_category_' .. categoryName:gsub(' ', '_'):lower(),
        title = categoryName,
        subtitle = 'Select IPL to toggle on/off',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Update IPL Category Menu (without navigating, just update current menu)
function UpdateIPLCategoryMenu(categoryName, categoryIPLs)
    if not categoryIPLs or type(categoryIPLs) ~= "table" then
        return
    end
    
    local options = {}
    
    -- Add individual IPL options with current state
    for _, ipl in ipairs(categoryIPLs) do
        local isActive = isIPLActive(ipl.decHash)
        
        table.insert(options, {
            id = ipl.hashname,
            title = ipl.hashname,
            description = string.format('Dec: %d | Coords: %.0f, %.0f, %.0f%s',
                ipl.decHash,
                ipl.coords.x, ipl.coords.y, ipl.coords.z,
                isActive and ' (ACTIVE)' or ''
            ),
            icon = isActive and '🟢' or '⚪',
            applied = isActive,
            data = {
                decHash = ipl.decHash,
                hashname = ipl.hashname,
                coords = ipl.coords
            }
        })
    end
    
    -- Sort IPLs alphabetically
    table.sort(options, function(a, b)
        return a.title < b.title
    end)
    
    -- Add category-wide options
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'enable_all',
        title = 'Enable All in Category',
        description = string.format('Load all %d IPLs in %s', #categoryIPLs, categoryName),
        icon = '✅'
    })
    
    table.insert(options, {
        id = 'disable_all',
        title = 'Disable All in Category', 
        description = string.format('Unload all IPLs in %s', categoryName),
        icon = '❌'
    })
    
    local menuData = {
        id = 'ipl_category_' .. categoryName:gsub(' ', '_'):lower(),
        title = categoryName,
        subtitle = 'Select IPL to toggle on/off',
        options = options
    }
    
    UpdateDevToolsMenu(menuData)
end

-- Event Handlers
-- No back handler needed - React handles menu navigation internally

RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- IPL display should persist when menu is closed - this is a walking tool
    -- Don't disable showIPLHandles here
    -- Optional: Remove all IPLs when menu is closed
    -- removeAllIPLs()
end)

RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'ipls' then
        if optionId == 'toggle_display' then
            toggleIPLDisplay()
            OpenIPLsMenu() -- Refresh menu to show new state
        elseif optionId == 'cycle_range' then
            cycleIPLRange()
            OpenIPLsMenu() -- Refresh menu to show new range
        elseif optionId == 'request_all' then
            requestAllIPLs()
            OpenIPLsMenu() -- Refresh menu
        elseif optionId == 'remove_all' then
            removeAllIPLs()
            OpenIPLsMenu() -- Refresh menu
        elseif optionId == 'status' then
            local activeCount = 0
            -- Count all currently active IPLs in the game world
            if ipls and ipls.validCoords then
                for hexHash, ipl in pairs(ipls.validCoords) do
                    if isIPLActive(ipl.dec_hash) then
                        activeCount = activeCount + 1
                    end
                end
            end
            if ipls and ipls.invalidCoords then
                for hexHash, ipl in pairs(ipls.invalidCoords) do
                    if isIPLActive(ipl.dec_hash) then
                        activeCount = activeCount + 1
                    end
                end
            end
            
            local totalIPLs = 0
            for _ in pairs(ipls.validCoords) do
                totalIPLs = totalIPLs + 1
            end
            if ipls.invalidCoords then
                for _ in pairs(ipls.invalidCoords) do
                    totalIPLs = totalIPLs + 1
                end
            end
            
            local categoryCount = 0
            for _ in pairs(iplCategories) do
                categoryCount = categoryCount + 1
            end
            
            local statusMsg = string.format(
                "Active IPLs: %d\nTotal Available: %d\nCategories: %d", 
                activeCount, 
                totalIPLs,
                categoryCount
            )
            TriggerEvent('qc-devtools:client:showNotification', {
                title = 'IPL System Status',
                message = statusMsg,
                type = 'info',
                duration = 5000
            })
        else
            -- Handle category selection
            if optionData and optionData.data then
                OpenIPLCategoryMenu(optionData.data.categoryName, optionData.data.categoryIPLs)
            end
        end
    elseif menuId:find('ipl_category_') then
        -- Extract the category name and find the correct case-sensitive key
        local lowercaseName = menuId:gsub('ipl_category_', ''):gsub('_', ' ')
        local actualCategoryName = nil
        
        -- Find the actual category name with correct case
        for categoryName, _ in pairs(iplCategories) do
            if categoryName:lower() == lowercaseName then
                actualCategoryName = categoryName
                break
            end
        end
        
        print('[QC-DevTools] MenuId:', menuId, 'Lowercase name:', lowercaseName, 'Actual name:', actualCategoryName)
        
        if actualCategoryName and iplCategories[actualCategoryName] then
            local category = iplCategories[actualCategoryName]
            
            if optionId == 'enable_all' then
                requestAllIPLsInCategory(category)
                UpdateIPLCategoryMenu(actualCategoryName, category) -- Update menu without adding to history
            elseif optionId == 'disable_all' then
                removeAllIPLsInCategory(category)
                UpdateIPLCategoryMenu(actualCategoryName, category) -- Update menu without adding to history
            else
                -- Handle individual IPL toggle
                if optionData and optionData.data then
                    toggleIPL(optionData.data.decHash, optionData.data.hashname)
                    -- Update the menu to show new state without adding to history
                    UpdateIPLCategoryMenu(actualCategoryName, category)
                end
            end
        else
            print('[QC-DevTools] ERROR: Category not found for:', lowercaseName)
            TriggerEvent('qc-devtools:client:showNotification', {
                title = 'Error',
                message = 'Category not found',
                type = 'error',
                duration = 3000
            })
        end
    end
end)

-- Main Event Handler
RegisterNetEvent('qc-devtools:client:openIPLs')
AddEventHandler('qc-devtools:client:openIPLs', function()
    print('[QC-DevTools] Opening IPLs Menu...')
    OpenIPLsMenu()
end)