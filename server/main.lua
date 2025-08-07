--=========================================================
-- QC-DEVTOOLS - SERVER
--=========================================================
-- Server-side functionality for development tools
-- Standalone - no framework dependencies
--=========================================================

-- Permission check function
local function HasPermission(src)
    if not Config.Permissions.adminOnly then
        return true
    end
    
    -- Check allowed players by server ID or identifiers
    if #Config.Permissions.allowedPlayers > 0 then
        local identifiers = GetPlayerIdentifiers(src)
        local serverId = tostring(src)
        
        for _, allowedId in ipairs(Config.Permissions.allowedPlayers) do
            -- Check by server ID
            if serverId == tostring(allowedId) then
                return true
            end
            
            -- Check by steam, license, discord, etc.
            for _, identifier in ipairs(identifiers) do
                if identifier == allowedId then
                    return true
                end
            end
        end
    end
    
    -- If admin only is enabled but no allowed players specified, deny access
    if Config.Permissions.adminOnly then
        return false
    end
    
    return true
end

-- Log dev tool usage
local function LogUsage(src, action, details)
    local playerName = GetPlayerName(src)
    local identifiers = GetPlayerIdentifiers(src)
    local steam = 'Unknown'
    local license = 'Unknown'
    
    -- Extract steam and license for better identification
    for _, id in ipairs(identifiers) do
        if string.match(id, 'steam:') then
            steam = id
        elseif string.match(id, 'license:') then
            license = id
        end
    end
    
    print(string.format('[QC-DEVTOOLS] %s (ID: %s | %s) used: %s - %s', 
        playerName,
        src,
        steam,
        action,
        details or 'No details'
    ))
end

-- Server events
RegisterNetEvent('qc-devtools:server:requestPermission')
AddEventHandler('qc-devtools:server:requestPermission', function()
    local src = source
    local hasPermission = HasPermission(src)
    
    TriggerClientEvent('qc-devtools:client:permissionResult', src, hasPermission)
    
    if not hasPermission then
        local playerName = GetPlayerName(src)
        print(string.format('[QC-DEVTOOLS] Permission denied for %s (ID: %s)', 
            playerName,
            src
        ))
    end
end)

RegisterNetEvent('qc-devtools:server:logAction')
AddEventHandler('qc-devtools:server:logAction', function(action, details)
    local src = source
    if HasPermission(src) then
        LogUsage(src, action, details)
    end
end)

print('[QC-DEVTOOLS] Server loaded successfully')