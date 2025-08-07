--=========================================================
-- QC-DEVTOOLS - ENTITY INFO MODULE
--=========================================================
-- Entity inspection tool for developers
-- Based on bs-entityinfo but integrated into QC-DevTools
-- Allows raycasting entities and capturing their data
--=========================================================

local isEntityScannerActive = false
local displayEntityInfo = true
local targetEntity = nil
local lastCapturedEntityInfo = nil
local entityScannerThread = nil

-- Raycast settings (from bs-entityinfo config)
local raycastConfig = {
    maxDistance = 25.0,
    drawLine = true,
    lineColor = {255, 0, 0, 180}, -- RGBA
    drawMarker = true,
    markerColor = {255, 0, 0, 255}, -- RGBA
    markerSize = 0.03
}

-- Key bindings for entity scanner
local entityKeys = {
    captureEntity = 0xF84FA74F,    -- Right Mouse Button to capture entity data
    cancelScanner = 0x156F7119,    -- ESC key to cancel
}

---@param entity number The entity handle
---@return table|nil Entity information or nil if entity doesn't exist
local function GetEntityInfo(entity)
    if not DoesEntityExist(entity) then return nil end
    
    local coords = GetEntityCoords(entity)
    local rotation = GetEntityRotation(entity, 2)
    local heading = GetEntityHeading(entity)
    local hash = GetEntityModel(entity)
    local hashStr = tostring(hash)
    local entityType = GetEntityType(entity)
    
    local entityTypeStr = "Unknown"
    if entityType == 1 then entityTypeStr = "Ped"
    elseif entityType == 2 then entityTypeStr = "Vehicle"
    elseif entityType == 3 then entityTypeStr = "Object" end
    
    local networkId = 'N/A'
    if NetworkGetEntityIsNetworked(entity) then
        networkId = NetworkGetNetworkIdFromEntity(entity)
    end
    
    return {
        entity = entity,
        hash = hash,
        hashStr = hashStr,
        coords = coords,
        rotation = rotation,
        heading = heading,
        type = entityTypeStr,
        networkId = networkId
    }
end

---@param entity number The entity handle
local function UpdateEntityInfo(entity)
    if not entity or not DoesEntityExist(entity) then return end
    
    local entityInfo = GetEntityInfo(entity)
    print('[QC-DevTools] Updating entity info for entity:', entity, 'type:', entityInfo.type)
    
    -- Send to our entity overlay NUI
    SendNUIMessage({
        action = 'updateEntityInfo',
        entityInfo = entityInfo,
        showUI = true
    })
end

---@param rotation vector3 Camera rotation
---@return vector3 Direction vector
local function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    
    return vector3(direction.x, direction.y, direction.z)
end

---@param distance number Maximum distance to raycast
---@return number, vector3, number hit, endCoords, entityHit
local function RaycastCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(
        StartShapeTestRay(
            cameraCoord.x, cameraCoord.y, cameraCoord.z,
            destination.x, destination.y, destination.z,
            -1, PlayerPedId(), 0
        )
    )
    
    return hit, endCoords, entityHit
end

-- Stop Entity Scanner Mode
local function StopEntityScanner()
    isEntityScannerActive = false
    displayEntityInfo = false
    targetEntity = nil
    
    -- Hide entity overlay
    SendNUIMessage({
        action = 'hideEntityScanner'
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Entity Scanner Deactivated',
        message = 'Use /devtools to access menu again',
        type = 'info',
        duration = 3000
    })
    
    print('[QC-DevTools] Entity scanner deactivated')
end

-- Stop Entity Scanner and Capture Data
local function StopEntityScannerAndCapture(entityInfo)
    isEntityScannerActive = false
    displayEntityInfo = false
    targetEntity = nil
    
    -- Hide entity overlay only
    SendNUIMessage({
        action = 'hideEntityScanner'
    })
    
    print('[QC-DevTools] Entity scanner stopped - captured entity data')
end

-- Start Entity Scanner Mode
local function StartEntityScanner()
    isEntityScannerActive = true
    displayEntityInfo = true
    
    -- No NUI focus - player can move freely, but SendNUIMessage still works
    SetNuiFocus(false, false)
    
    -- Show entity overlay with instructions
    print('[QC-DevTools] Sending showEntityScanner NUI message')
    SendNUIMessage({
        action = 'showEntityScanner',
        instructions = {
            capture = 'RIGHT CLICK - Capture Entity Data',
            cancel = 'ESC - Cancel Scanner'
        }
    })
    
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Entity Scanner Activated',
        message = 'Aim at entities and RIGHT CLICK to capture data',
        type = 'success',
        duration = 4000
    })
    
    print('[QC-DevTools] Entity scanner activated')
    
    -- Main scanner thread
    CreateThread(function()
        while isEntityScannerActive do
            Wait(0)
            
            local playerPed = PlayerPedId()
            local hit, endCoords, entityHit = RaycastCamera(raycastConfig.maxDistance)
                
            if hit == 1 and DoesEntityExist(entityHit) then
                targetEntity = entityHit
                
                local playerPos = GetEntityCoords(playerPed)
                
                -- Draw raycast line
                if raycastConfig.drawLine then
                    DrawLine(
                        playerPos.x, playerPos.y, playerPos.z,
                        endCoords.x, endCoords.y, endCoords.z,
                        raycastConfig.lineColor[1], raycastConfig.lineColor[2], 
                        raycastConfig.lineColor[3], raycastConfig.lineColor[4]
                    )
                end
                
                -- Draw target marker
                if raycastConfig.drawMarker then
                    DrawMarker(0x50638AB9, endCoords.x, endCoords.y, endCoords.z, 
                              0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 
                              raycastConfig.markerSize, raycastConfig.markerSize, raycastConfig.markerSize, 
                              raycastConfig.markerColor[1], raycastConfig.markerColor[2], 
                              raycastConfig.markerColor[3], raycastConfig.markerColor[4], 
                              false, false, 2, false, nil, nil, false)
                end
                
                -- Update entity info display
                if displayEntityInfo then
                    UpdateEntityInfo(entityHit)
                end
                
                -- Hide "no entity" message
                SendNUIMessage({
                    action = 'updateEntityInfo',
                    showNoEntity = false
                })
                
                -- Check for capture key (Right Mouse Button)
                if IsControlJustReleased(0, entityKeys.captureEntity) then
                    print('[QC-DevTools] Right mouse button pressed - capturing entity')
                    local entityInfo = GetEntityInfo(entityHit)
                    if entityInfo then
                        lastCapturedEntityInfo = entityInfo
                        
                        TriggerEvent('qc-devtools:client:showNotification', {
                            title = 'Entity Data Captured',
                            message = string.format('Captured %s entity data', entityInfo.type),
                            type = 'success',
                            duration = 3000
                        })
                        
                        -- Stop scanner 
                        StopEntityScannerAndCapture(entityInfo)
                        
                        -- Re-enable NUI focus and immediately show menu with captured entity data
                        print('[QC-DevTools] Re-enabling NUI focus and showing captured entity menu')
                        SetNuiFocus(true, true)
                        ShowCapturedEntityInfo(entityInfo)
                        
                        TriggerServerEvent('qc-devtools:server:logAction', 'Capture Entity', string.format('%s - %s', entityInfo.type, entityInfo.hashStr))
                    end
                end
                
            else
                -- Show "no entity" message
                SendNUIMessage({
                    action = 'updateEntityInfo',
                    showNoEntity = true,
                    showUI = false
                })
                
                if targetEntity then
                    targetEntity = nil
                end
            end
            
            -- Check for cancel key (ESC) - works anywhere
            if IsControlJustReleased(0, entityKeys.cancelScanner) then
                print('[QC-DevTools] ESC pressed - cancelling entity scanner')
                StopEntityScanner()
                -- Don't reopen menu - user needs to use command again
            end
        end
    end)
end

-- Format coordinates for display
local function formatCoords(coords)
    if not coords then return '-' end
    return string.format('vector3(%.2f, %.2f, %.2f)', coords.x, coords.y, coords.z)
end

-- Format heading for display  
local function formatHeading(heading)
    if heading == nil then return '-' end
    return string.format('%.2f', heading)
end

-- Copy to clipboard function
local function CopyToClipboard(text, description)
    SendNUIMessage({
        action = 'copyToClipboard',
        text = text,
        description = description or 'Text'
    })
end

-- Show captured entity info in menu
function ShowCapturedEntityInfo(entityInfo)
    print('[QC-DevTools] ShowCapturedEntityInfo called for entity:', entityInfo.entity)
    print('[QC-DevTools] EntityInfo details:', json.encode(entityInfo))
    local options = {
        {
            id = 'copy_entity',
            title = 'Copy Entity Handle',
            description = tostring(entityInfo.entity),
            icon = '🎯'
        },
        {
            id = 'copy_type',
            title = 'Copy Entity Type',
            description = entityInfo.type,
            icon = '📋'
        },
        {
            id = 'copy_hash',
            title = 'Copy Model Hash',
            description = entityInfo.hashStr,
            icon = '🔢'
        },
        {
            id = 'copy_coords',
            title = 'Copy Coordinates',
            description = formatCoords(entityInfo.coords),
            icon = '📍'
        },
        {
            id = 'copy_rotation',
            title = 'Copy Rotation',
            description = formatCoords(entityInfo.rotation),
            icon = '🔄'
        },
        {
            id = 'copy_heading',
            title = 'Copy Heading',
            description = formatHeading(entityInfo.heading),
            icon = '🧭'
        },
        {
            id = 'copy_network',
            title = 'Copy Network ID',
            description = tostring(entityInfo.networkId),
            icon = '🌐'
        },
        {
            id = 'copy_all',
            title = 'Copy All Entity Data',
            description = 'Copy complete entity information as formatted text',
            icon = '📄'
        },
        {
            id = 'separator',
            separator = true
        },
        {
            id = 'scan_another',
            title = 'Scan Another Entity',
            description = 'Start entity scanner again',
            icon = '🔍'
        }
    }
    
    local menuData = {
        id = 'captured_entity_info',
        title = 'Captured Entity Data',
        subtitle = string.format('%s Entity Information', entityInfo.type),
        options = options
    }
    
    print('[QC-DevTools] Calling UpdateDevToolsMenu with captured entity data')
    print('[QC-DevTools] Menu data:', json.encode(menuData))
    UpdateDevToolsMenu(menuData)
end

-- Main Entity Info Menu
function OpenEntityInfoMenu()
    local options = {
        {
            id = 'activate_scanner',
            title = 'Activate Entity Scanner',
            description = 'Start raycasting mode to inspect entities',
            icon = '🔍'
        },
        {
            id = 'separator',
            separator = true
        }
    }
    
    -- Show last captured data if available
    if lastCapturedEntityInfo then
        table.insert(options, {
            id = 'show_last_capture',
            title = 'Show Last Captured Entity',
            description = string.format('View %s entity data', lastCapturedEntityInfo.type),
            icon = '📊'
        })
    end
    
    local menuData = {
        id = 'entityinfo',
        title = 'Entity Information Tool',
        subtitle = 'Developer entity inspection toolkit',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Event Handlers
RegisterNetEvent('qc-devtools:nui:closed')
AddEventHandler('qc-devtools:nui:closed', function()
    -- Stop entity scanner when menu is closed
    if isEntityScannerActive then
        StopEntityScanner()
    end
end)

RegisterNetEvent('qc-devtools:nui:optionSelected')
AddEventHandler('qc-devtools:nui:optionSelected', function(optionId, optionData, menuId)
    print('[QC-DevTools] Menu selection - MenuID:', menuId, 'OptionID:', optionId)
    print('[QC-DevTools] lastCapturedEntityInfo exists:', lastCapturedEntityInfo ~= nil)
    if lastCapturedEntityInfo then
        print('[QC-DevTools] lastCapturedEntityInfo details:', json.encode(lastCapturedEntityInfo))
    end
    
    if menuId == 'entityinfo' then
        if optionId == 'activate_scanner' then
            print('[QC-DevTools] Starting entity scanner from menu')
            StartEntityScanner()
        elseif optionId == 'show_last_capture' and lastCapturedEntityInfo then
            print('[QC-DevTools] Showing last captured entity info from button')
            ShowCapturedEntityInfo(lastCapturedEntityInfo)
        else
            print('[QC-DevTools] Option not handled or lastCapturedEntityInfo is nil')
        end
    elseif menuId == 'captured_entity_info' then
        if optionId == 'scan_another' then
            print('[QC-DevTools] Starting another scan from captured entity menu')
            StartEntityScanner()
        elseif optionId == 'copy_entity' and lastCapturedEntityInfo then
            CopyToClipboard(tostring(lastCapturedEntityInfo.entity), 'Entity handle')
        elseif optionId == 'copy_type' and lastCapturedEntityInfo then
            CopyToClipboard(lastCapturedEntityInfo.type, 'Entity type')
        elseif optionId == 'copy_hash' and lastCapturedEntityInfo then
            CopyToClipboard(lastCapturedEntityInfo.hashStr, 'Model hash')
        elseif optionId == 'copy_coords' and lastCapturedEntityInfo then
            local coordsStr = formatCoords(lastCapturedEntityInfo.coords)
            CopyToClipboard(coordsStr, 'Coordinates')
        elseif optionId == 'copy_rotation' and lastCapturedEntityInfo then
            local rotationStr = formatCoords(lastCapturedEntityInfo.rotation)
            CopyToClipboard(rotationStr, 'Rotation')
        elseif optionId == 'copy_heading' and lastCapturedEntityInfo then
            local headingStr = formatHeading(lastCapturedEntityInfo.heading)
            CopyToClipboard(headingStr, 'Heading')
        elseif optionId == 'copy_network' and lastCapturedEntityInfo then
            CopyToClipboard(tostring(lastCapturedEntityInfo.networkId), 'Network ID')
        elseif optionId == 'copy_all' and lastCapturedEntityInfo then
            local allDataStr = string.format([[Entity Information:
Entity Handle: %s
Entity Type: %s
Model Hash: %s
Coordinates: %s
Rotation: %s
Heading: %s
Network ID: %s]], 
                tostring(lastCapturedEntityInfo.entity),
                lastCapturedEntityInfo.type,
                lastCapturedEntityInfo.hashStr,
                formatCoords(lastCapturedEntityInfo.coords),
                formatCoords(lastCapturedEntityInfo.rotation),
                formatHeading(lastCapturedEntityInfo.heading),
                tostring(lastCapturedEntityInfo.networkId)
            )
            CopyToClipboard(allDataStr, 'All entity data')
        end
    else
        print('[QC-DevTools] Menu ID not recognized:', menuId)
    end
end)

-- NUI Callback for clipboard operations
RegisterNUICallback('clipboardResult', function(data, cb)
    if data.success then
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Copied to Clipboard',
            message = data.description .. ' copied successfully',
            type = 'success',
            duration = 2000
        })
    else
        TriggerEvent('qc-devtools:client:showNotification', {
            title = 'Copy Failed',
            message = 'Failed to copy ' .. data.description,
            type = 'error',
            duration = 2000
        })
    end
    cb('ok')
end)

-- Main Event Handler
RegisterNetEvent('qc-devtools:client:openEntityInfo')
AddEventHandler('qc-devtools:client:openEntityInfo', function()
    print('[QC-DevTools] Opening Entity Info Menu...')
    OpenEntityInfoMenu()
end)