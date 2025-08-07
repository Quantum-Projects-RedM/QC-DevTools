Config = {}

-- Main DevTools Configuration
Config.Commands = {
    mainMenu = 'devtools',
    pedDecals = 'dev_decals' -- Alternative direct access
}

-- DevTools Categories Configuration
Config.Categories = {
    {
        id = 'peddecals',
        label = 'Ped Decals',
        description = 'Apply and test ped decals (damage, scars, etc.)',
        icon = '🎭',
        enabled = true
    },
    {
        id = 'animpostfx',
        label = 'Animation Post FX',
        description = 'Test and apply animation post FX effects',
        icon = '🎬',
        enabled = true
    },
    {
        id = 'timecycles',
        label = 'Timecycle Modifiers',
        description = 'Apply and test timecycle visual effects',
        icon = '🌅',
        enabled = true
    },
    {
        id = 'explosions',
        label = 'Explosion Testing',
        description = 'Test explosions with player protection',
        icon = '💥',
        enabled = true
    },
    {
        id = 'audio',
        label = 'Audio Testing',
        description = 'Test sounds, speech, music, and effects',
        icon = '🔊',
        enabled = true
    },
    {
        id = 'ipls',
        label = 'Interior Placements',
        description = 'Enable/disable interior placements (IPLs)',
        icon = '🏗️',
        enabled = true
    },
    {
        id = 'entityinfo',
        label = 'Entity Information',
        description = 'Inspect and capture entity data for development',
        icon = '🎯',
        enabled = true
    }
}

-- Permission system (standalone - no framework dependencies)
Config.Permissions = {
    adminOnly = false, -- Set to true to restrict to specific players only
    allowedPlayers = {} -- Add player identifiers: server IDs, steam IDs, license IDs, etc.
    -- Examples:
    -- allowedPlayers = { "1", "2", "steam:110000103fd1bb1", "license:a1b2c3d4e5f6g7h8" }
}