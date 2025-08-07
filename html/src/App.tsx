import React, { useState, useEffect } from 'react'
import WesternMenu from './components/WesternMenu'
import NotificationPanel from './components/NotificationPanel'
import EntityScanner from './components/EntityScanner'
import { MenuData, MenuOption, NotificationData } from './types/menu'

// Global function declarations
declare global {
  interface Window {
    GetParentResourceName?: () => string
  }
}

// EntityInfo interface
interface EntityInfo {
  entity: number
  hash: number
  hashStr: string
  coords: { x: number; y: number; z: number }
  rotation: { x: number; y: number; z: number }
  heading: number
  type: string
  networkId: string | number
}

const App: React.FC = () => {
  const [isVisible, setIsVisible] = useState(false)
  const [currentMenu, setCurrentMenu] = useState<MenuData | null>(null)
  const [menuHistory, setMenuHistory] = useState<MenuData[]>([])
  const [notifications, setNotifications] = useState<NotificationData[]>([])
  
  // Entity Scanner state
  const [entityScannerVisible, setEntityScannerVisible] = useState(false)
  const [entityInfo, setEntityInfo] = useState<EntityInfo | null>(null)
  const [showNoEntity, setShowNoEntity] = useState(false)
  const [entityInstructions, setEntityInstructions] = useState({
    capture: 'ENTER - Capture Entity Data',
    cancel: 'RIGHT CLICK - Cancel Scanner'
  })

  // Helper function to get resource name
  const getResourceName = () => {
    if (window.GetParentResourceName) {
      return window.GetParentResourceName()
    }
    return 'qc-devtools' // Fallback
  }

  // Handle clipboard copy with fallback method
  const handleClipboardCopy = async (text: string, description: string) => {
    let success = false
    
    // Try modern clipboard API first
    try {
      await navigator.clipboard.writeText(text)
      success = true
      console.log('[QC-DevTools] Copied using modern clipboard API')
    } catch (err) {
      console.log('[QC-DevTools] Modern clipboard failed, trying fallback method:', err)
      
      // Fallback to execCommand method (like bs-entityinfo)
      try {
        const tempInput = document.createElement('textarea')
        tempInput.value = text
        tempInput.style.position = 'fixed'
        tempInput.style.opacity = '0'
        document.body.appendChild(tempInput)
        
        tempInput.select()
        tempInput.setSelectionRange(0, 99999) // For mobile devices
        
        success = document.execCommand('copy')
        document.body.removeChild(tempInput)
        
        console.log('[QC-DevTools] Fallback copy success:', success)
      } catch (fallbackErr) {
        console.error('[QC-DevTools] Both clipboard methods failed:', fallbackErr)
        success = false
      }
    }
    
    // Notify Lua of the result
    fetch(`https://${getResourceName()}/clipboardResult`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        success: success,
        description: description
      }),
    }).catch(() => {})
  }

  // Add notification function (replaces existing instead of stacking)
  const addNotification = (notification: Omit<NotificationData, 'id'>) => {
    const newNotification: NotificationData = {
      ...notification,
      id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
    }
    
    // Replace all existing notifications with the new one
    setNotifications([newNotification])
  }

  // Remove notification function
  const removeNotification = (id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id))
  }

  // Handle NUI messages from Lua
  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const messageData = event.data
      const { action } = messageData
      console.log('[QC-DevTools NUI] Received message:', action, messageData)

      switch (action) {
        case 'showMenu':
          setCurrentMenu(messageData.menu || messageData.data?.menu)
          setMenuHistory([])
          setIsVisible(true)
          document.body.style.display = 'block'
          break

        case 'hideMenu':
          setIsVisible(false)
          setCurrentMenu(null)
          setMenuHistory([])
          document.body.style.display = 'none'
          break

        case 'updateMenu':
          setCurrentMenu(messageData.menu || messageData.data?.menu)
          break

        case 'navigateToMenu':
          if (currentMenu) {
            setMenuHistory(prev => [...prev, currentMenu])
          }
          setCurrentMenu(messageData.menu || messageData.data?.menu)
          break

        case 'goBack':
          if (menuHistory.length > 0) {
            const previousMenu = menuHistory[menuHistory.length - 1]
            setMenuHistory(prev => prev.slice(0, -1))
            setCurrentMenu(previousMenu)
          } else {
            // No history, close menu
            handleClose()
          }
          break

        case 'showNotification':
          addNotification(messageData.notification || messageData.data?.notification)
          break

        case 'showEntityScanner':
          console.log('[QC-DevTools] Setting entityScannerVisible to true')
          setEntityScannerVisible(true)
          setShowNoEntity(true)
          setEntityInfo(null)
          if (messageData.instructions) {
            setEntityInstructions(messageData.instructions)
          }
          console.log('[QC-DevTools] EntityScanner state should now be visible')
          break

        case 'hideEntityScanner':
          setEntityScannerVisible(false)
          setShowNoEntity(false)
          setEntityInfo(null)
          break

        case 'updateEntityInfo':
          console.log('[QC-DevTools] updateEntityInfo received:', messageData)
          console.log('[QC-DevTools] messageData.entityInfo exists?', !!messageData.entityInfo)
          console.log('[QC-DevTools] messageData contents:', messageData)
          if (messageData.entityInfo) {
            setEntityInfo(messageData.entityInfo)
            console.log('[QC-DevTools] Set entityInfo to:', messageData.entityInfo)
          } else {
            console.log('[QC-DevTools] ERROR: entityInfo not found in data structure')
          }
          if (messageData.showUI !== undefined) {
            // When showUI is true, hide no entity message
            if (messageData.showUI) {
              setShowNoEntity(false)
            }
          }
          if (messageData.showNoEntity !== undefined) {
            setShowNoEntity(messageData.showNoEntity)
          }
          break

        case 'copyToClipboard':
          console.log('[QC-DevTools] Copy to clipboard request:', messageData)
          handleClipboardCopy(messageData.text, messageData.description)
          break
      }
    }

    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [currentMenu, menuHistory])

  // Handle escape key
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && isVisible) {
        handleClose()
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [isVisible])

  // Handle option selection
  const handleOptionSelect = (option: MenuOption) => {
    if (option.disabled) return

    // Send selection to Lua
    fetch(`https://${getResourceName()}/menuOptionSelected`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        optionId: option.id,
        optionData: option,
        menuId: currentMenu?.id
      }),
    }).catch(() => {
      // Handle error silently in production
      console.warn('Failed to send menu option to Lua')
    })
  }

  // Handle back button
  const handleBack = () => {
    if (menuHistory.length > 0) {
      const previousMenu = menuHistory[menuHistory.length - 1]
      setMenuHistory(prev => prev.slice(0, -1))
      setCurrentMenu(previousMenu)
    } else {
      handleClose()
    }

    // Notify Lua
    fetch(`https://${getResourceName()}/menuBack`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({}),
    }).catch(() => {})
  }

  // Handle menu close
  const handleClose = () => {
    setIsVisible(false)
    setCurrentMenu(null)
    setMenuHistory([])
    document.body.style.display = 'none'

    // Notify Lua
    fetch(`https://${getResourceName()}/menuClosed`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({}),
    }).catch(() => {})
  }

  // Development mode - show menu for testing
  useEffect(() => {
    if (import.meta.env.DEV) {
      // Show test menu in development
      const testMenu: MenuData = {
        id: 'main',
        title: 'QC Development Tools',
        subtitle: 'Select a category to continue',
        options: [
          {
            id: 'peddecals',
            title: 'Ped Decals',
            description: 'Apply and test ped decals (damage, scars, etc.)',
            icon: '🎨',
          },
          {
            id: 'pedoutfits',
            title: 'Ped Outfits',
            description: 'Test different ped outfits and clothing',
            icon: '👕',
            disabled: true,
          },
          {
            id: 'separator',
            separator: true,
          },
          {
            id: 'clear',
            title: 'Clear All Effects',
            description: 'Remove all applied decals, outfits, etc.',
            icon: '🧹',
          },
        ],
      }

      setCurrentMenu(testMenu)
      setIsVisible(true)
      document.body.style.display = 'block'
    }
  }, [])

  return (
    <>
      <div className={`app-container ${isVisible ? 'menu-visible' : ''}`}>
        {isVisible && currentMenu && (
          <WesternMenu
            menu={currentMenu}
            canGoBack={menuHistory.length > 0}
            onOptionSelect={handleOptionSelect}
            onBack={handleBack}
            onClose={handleClose}
          />
        )}
      </div>
      
      <EntityScanner
        isVisible={entityScannerVisible}
        entityInfo={entityInfo}
        showNoEntity={showNoEntity}
        instructions={entityInstructions}
      />
      
      <NotificationPanel
        notifications={notifications}
        onRemoveNotification={removeNotification}
      />
    </>
  )
}

export default App