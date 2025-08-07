# QC-DevTools

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform: RedM](https://img.shields.io/badge/Platform-RedM-red)
![Framework: React](https://img.shields.io/badge/Frontend-React-lightblue)
![Language: Lua](https://img.shields.io/badge/Backend-Lua-orange)
![Version: Beta](https://img.shields.io/badge/Version-Beta-important)

**Advanced RedM Development Tools Framework**

*By Quantum Projects*

## 🚀 Overview

QC-DevTools is a comprehensive, modular development framework for RedM featuring a modern React-based NUI interface, global search functionality, and automatic clipboard integration. Designed to streamline testing and development workflows for RedM server developers.

## ✨ Features
-  🎨 **Modern NUI Interface**
- 🔍 **Global Search System**
- 📋 **Automatic Clipboard Integration**
- 🧩 **Modular Architecture**

## 📦 Included Modules

- 🎨 **Ped Decals**
- 💥 **Explosions**
- 🔊 **Audio System**
- 🏢 **IPL Management**
- 🎭 **Animation Post FX**
- 🌅 **Timecycle Modifiers**
- 📡 **Entity Information**

## 🛠️ Installation

1. **Download** the latest release
2. **Extract** to your RedM resources folder
3. **Add** `ensure QC-DevTools` to your server.cfg
4. **Configure** modules in `shared/config.lua`
5. **Start** your server and enjoy!

### Entity Scanner
1. Navigate to "Entity Information"
2. Scanner activates automatically
3. Look at entities to see live data
4. Right-click to capture and view details


## 🔧 Development

### Creating Custom Modules

QC-DevTools features a comprehensive module development system. See [MODULE_DEVELOPMENT.md](MODULE_DEVELOPMENT.md) for detailed instructions on:

- Module structure and organization
- Menu system API usage
- Notification system integration
- Auto-copy functionality implementation
- Global search integration
- Testing and deployment

### Module Development Quick Start
```lua
-- Basic module template
RegisterNetEvent('qc-devtools:client:openYourModule')
AddEventHandler('qc-devtools:client:openYourModule', function()
    local menuData = {
        id = 'yourmodule',
        title = 'Your Module',
        subtitle = 'Module description',
        options = {
            {
                id = 'action1',
                title = 'Action Button',
                description = 'Performs an action',
                icon = '🎯'
            }
        }
    }
    ShowDevToolsMenu(menuData)
end)
```

## 🎨 UI Customization

The NUI interface supports theming and customization:
- Modify `html/src/index.css` for styling changes
- Update assets in `html/public/assets/`
- React components in `html/src/components/`
- Build with `npm run build` in the html directory

## 🐛 Troubleshooting

### Common Issues

**Menu not opening:**
- Check F8 console for errors
- Verify resource is started

**NUI not loading:**
- Ensure `html/dist/` folder exists
- Run `npm install && npm run build` in html directory

**Search not working:**
- Verify module data is properly loaded
- Restart resource after config changes

## 📋 Requirements

- **RedM** server
- **Modern browser** for NUI (Chrome/Edge recommended)
- **Node.js** (for development/building only)

## 🤝 Contributing

QC-DevTools is open source! We welcome contributions from the community.

### How to Contribute

1. **Fork** this repository
2. **Create** a feature branch
3. **Make** your changes following our coding standards
4. **Test** thoroughly across different scenarios  
5. **Submit** a pull request with detailed description

### Contribution Guidelines

- Follow existing code patterns and structure
- Include comprehensive error handling
- Test all functionality before submitting
- Respect the modular architecture

### Report Issues

If you encounter bugs or have feature requests:
- Check existing issues first
- Provide detailed reproduction steps
- Include error logs and system information
- Be respectful and constructive

For direct contact, reach out to the project maintainer.

## 📄 License

This project is open source and available under the MIT License. Feel free to use, modify, and distribute according to the license terms.

## 🙏 Credits

### 🏗️ **Core Development**
**Quantum Projects** - *Project Architecture, NUI Framework & Module Integration*

### 📚 **Original Tool Inspirations**
QC-DevTools builds upon the excellent work of several community developers:

- **[Wartype](https://github.com/iamvillain)** - *Audio Development Tool*  
  Original audio system implementations and RedM audio native research

- **[Blaze Scripts](https://github.com/Blaze-Scripts)** - *Entity Information Tool*  
  Entity scanning methodologies and raycasting techniques

- **[RicX](https://github.com/zelbeus)** - *Animation Post FX Tool*  
  Visual effects system and animation post FX implementations

- **[T3chman](https://github.com/t3chman)** - *IPL Management Tool*  
  Interior placement systems and IPL handling techniques

### 💪 **Powered By Open Source**
*QC-DevTools is built on the shoulders of giants - we're proud to contribute back to the RedM development community with our own open source modular tool for developers.*

**🚀 Developed with ❤️ by Quantum Projects**

*Professional RedM development tools for the modern developer*
