# QC-DevTools Module Development Guide

## 📖 Overview

QC-DevTools is a modular RedM development tools featuring a custom NUI system, global search functionality, and automatic clipboard integration. This guide explains how to create new modules that integrate seamlessly with the existing system.

## 🏗️ Module Structure

### Basic Module Template
```
client/
├── yourmodule/
│   ├── main.lua              # Main module logic
│   ├── data.lua             # Module data/configuration
│   └── README.md            # Module documentation
```

## 📋 Required Components

### 1. Module Registration in Config

Add your module to `shared/config.lua`:
```lua
Config.Categories = {
    -- Existing modules...
    {
        id = 'yourmodule',
        label = 'Your Module Name',
        description = 'Brief description of functionality',
        icon = '🎯', -- Emoji or Font Awesome class
        enabled = true
    }
}
```

### 2. Main Event Handler Registration

In `client/main.lua`, add your module handler:
```lua
-- In the NUI Menu Option Selected Handler
elseif optionId == 'yourmodule' then
    TriggerEvent('qc-devtools:client:openYourModule')
```

## 🎛️ Menu System API

### Core Functions

#### `ShowDevToolsMenu(menuData)`
Display a new menu (replaces current menu):
```lua
local menuData = {
    id = 'unique_menu_id',
    title = 'Menu Title',
    subtitle = 'Optional subtitle',
    options = {} -- Array of menu options
}
ShowDevToolsMenu(menuData)
```

#### `NavigateDevToolsMenu(menuData)` 
Navigate to submenu (adds to navigation history):
```lua
NavigateDevToolsMenu(menuData)
```

#### `UpdateDevToolsMenu(menuData)`
Update current menu without affecting navigation:
```lua
UpdateDevToolsMenu(menuData)
```

### Menu Option Structure
```lua
{
    id = 'option_id',           -- Required: Unique identifier
    title = 'Display Title',     -- Required: Button text
    description = 'Details...',  -- Optional: Subtitle text
    icon = '🎨',                -- Optional: Emoji or icon
    disabled = false,           -- Optional: Grayed out state
    applied = false,            -- Optional: Shows checkmark
    separator = false,          -- Optional: Creates divider
    data = {                    -- Optional: Custom data
        customField = 'value'
    }
}
```

### Separator Example
```lua
{
    id = 'separator',
    separator = true
}
```

## 🔔 Notification System

### Basic Notification
```lua
TriggerEvent('qc-devtools:client:showNotification', {
    title = 'Action Complete',
    message = 'Your action was successful',
    type = 'success',           -- 'success', 'error', 'warning', 'info'
    duration = 3000             -- Optional: milliseconds (default 5000)
})
```

### Notification Types
- `success` - Green checkmark
- `error` - Red X mark  
- `warning` - Yellow warning triangle
- `info` - Blue info circle

## 📋 Auto-Copy Integration

For action buttons that trigger effects, automatically copy relevant data:

```lua
-- Auto-copy functionality for action buttons
TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
    text = 'EFFECT_NAME',                    -- Text to copy
    description = 'Effect Applied: EFFECT_NAME'  -- Notification description
})
```

**When to use auto-copy:**
- ✅ Apply/Play/Trigger/Enable actions
- ❌ Navigation/Back/Settings actions

## 🔍 Global Search Integration

Add your module data to global search in `client/main.lua`:

```lua
-- In GetGlobalSearchData() function
-- Your Module Data
if YourModuleData then
    for categoryKey, categoryData in pairs(YourModuleData) do
        if categoryData.items then
            for _, item in ipairs(categoryData.items) do
                table.insert(searchData, {
                    id = 'yourmodule_' .. item.name,
                    title = item.label or item.name,
                    description = 'Your Module - ' .. categoryData.name,
                    category = 'yourmodule',
                    categoryLabel = 'Your Module',
                    icon = '🎯',
                    searchTerms = item.name .. ' ' .. (item.label or '') .. ' keywords'
                })
            end
        end
    end
end
```

## 📊 Module Examples

### Simple Toggle Module
```lua
--=========================================================
-- EXAMPLE MODULE - Simple Toggle System
--=========================================================

local moduleState = false

-- Main menu function
local function OpenExampleMenu()
    local options = {}
    
    table.insert(options, {
        id = 'toggle',
        title = moduleState and 'Disable Feature' or 'Enable Feature',
        description = 'Toggle the main feature on/off',
        icon = moduleState and '⏹️' or '▶️',
        applied = moduleState
    })
    
    table.insert(options, {
        id = 'separator',
        separator = true
    })
    
    table.insert(options, {
        id = 'settings',
        title = 'Settings',
        description = 'Configure module options',
        icon = '⚙️'
    })
    
    local menuData = {
        id = 'example',
        title = 'Example Module',
        subtitle = 'Demonstration of menu system',
        options = options
    }
    
    ShowDevToolsMenu(menuData)
end

-- Toggle function with auto-copy
local function ToggleFeature()
    moduleState = not moduleState
    
    -- Auto-copy for action buttons
    if moduleState then
        TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
            text = 'EXAMPLE_FEATURE_ON',
            description = 'Feature Enabled: EXAMPLE_FEATURE_ON'
        })
    end
    
    -- Show notification
    TriggerEvent('qc-devtools:client:showNotification', {
        title = moduleState and 'Feature Enabled' or 'Feature Disabled',
        message = 'Example feature is now ' .. (moduleState and 'active' or 'inactive'),
        type = moduleState and 'success' or 'info',
        duration = 3000
    })
    
    -- Refresh menu to show new state
    OpenExampleMenu()
end

-- Menu selection handler
RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'example' then
        if optionId == 'toggle' then
            ToggleFeature()
        elseif optionId == 'settings' then
            -- Navigate to settings submenu
            -- Implementation here...
        end
    end
end)

-- Main entry point
RegisterNetEvent('qc-devtools:client:openExample')
AddEventHandler('qc-devtools:client:openExample', function()
    OpenExampleMenu()
end)
```

### Category-Based Module
```lua
--=========================================================
-- CATEGORY MODULE - Multiple Categories with Items
--=========================================================

-- Data structure
ExampleData = {
    category1 = {
        name = "First Category",
        icon = "🎨",
        items = {
            { name = "ITEM_1", label = "First Item" },
            { name = "ITEM_2", label = "Second Item" }
        }
    },
    category2 = {
        name = "Second Category", 
        icon = "🔧",
        items = {
            { name = "TOOL_1", label = "First Tool" },
            { name = "TOOL_2", label = "Second Tool" }
        }
    }
}

-- Main menu
local function OpenCategoryModule()
    local options = {}
    
    for categoryId, categoryData in pairs(ExampleData) do
        table.insert(options, {
            id = categoryId,
            title = categoryData.name,
            description = string.format('Browse %s (%d items)', 
                categoryData.name:lower(), #categoryData.items),
            icon = categoryData.icon
        })
    end
    
    local menuData = {
        id = 'category_module',
        title = 'Category Module',
        subtitle = 'Select a category',
        options = options
    }
    
    ShowDevToolsMenu(menuData)
end

-- Category submenu
local function OpenCategoryMenu(categoryId, categoryData)
    local options = {}
    
    for _, item in ipairs(categoryData.items) do
        table.insert(options, {
            id = item.name,
            title = item.label,
            description = 'Apply this item',
            icon = '▶️',
            data = {
                itemName = item.name,
                itemLabel = item.label,
                categoryId = categoryId
            }
        })
    end
    
    local menuData = {
        id = 'category_' .. categoryId,
        title = categoryData.name,
        subtitle = 'Select an item to apply',
        options = options
    }
    
    NavigateDevToolsMenu(menuData)
end

-- Apply item with auto-copy
local function ApplyItem(itemName, itemLabel)
    -- Your item logic here
    print('Applied item: ' .. itemName)
    
    -- Auto-copy the item name
    TriggerEvent('qc-devtools:client:autoCopyToClipboard', {
        text = itemName,
        description = 'Item Applied: ' .. itemLabel
    })
    
    -- Show notification
    TriggerEvent('qc-devtools:client:showNotification', {
        title = 'Item Applied',
        message = string.format('Applied "%s"', itemLabel),
        type = 'success',
        duration = 3000
    })
end

-- Menu handlers
RegisterNetEvent('qc-devtools:nui:menuSelection')
AddEventHandler('qc-devtools:nui:menuSelection', function(optionId, optionData, menuId)
    if menuId == 'category_module' then
        -- Handle category selection
        if ExampleData[optionId] then
            OpenCategoryMenu(optionId, ExampleData[optionId])
        end
    elseif menuId:find('category_') then
        -- Handle item selection
        if optionData and optionData.data then
            ApplyItem(optionData.data.itemName, optionData.data.itemLabel)
        end
    end
end)
```

## 🎨 UI Guidelines

### Menu Design Best Practices
- **Titles**: Use clear, descriptive names
- **Descriptions**: Provide helpful context
- **Icons**: Use relevant emojis or Font Awesome classes
- **Grouping**: Use separators to organize options
- **State**: Show applied/active states with checkmarks

## 🔧 Advanced Features

### Custom NUI Messages
Send custom data to the React frontend:
```lua
SendNUIMessage({
    action = 'customAction',
    data = {
        customField = 'value'
    }
})
```

### Server Integration
Log actions to server:
```lua
TriggerServerEvent('qc-devtools:server:logAction', 'Action Type', 'Details')
```

### Cleanup on Resource Stop
```lua
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Cleanup your module
        -- Clear effects, reset states, etc.
    end
end)
```
## 🤝 Contributing

When creating modules:
- Follow the established patterns
- Include proper error handling
- Add meaningful notifications
- Implement auto-copy for action buttons
- Test thoroughly before sharing
- Document your code

## 📞 Support

For questions about module development:
- Review existing modules for examples
- Check this documentation
- Test with simple implementations first

Happy coding! 🎉