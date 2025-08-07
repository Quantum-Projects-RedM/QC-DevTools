export interface MenuOption {
  id: string
  title?: string
  description?: string
  icon?: string
  disabled?: boolean
  applied?: boolean  // For showing applied state (e.g., applied decals)
  separator?: boolean  // For separator lines
  data?: any  // Additional data to pass with the option
}

export interface MenuData {
  id: string
  title: string
  subtitle?: string
  options: MenuOption[]
}

export interface MenuProps {
  menu: MenuData
  canGoBack: boolean
  onOptionSelect: (option: MenuOption) => void
  onBack: () => void
  onClose: () => void
}

export interface NotificationData {
  id: string
  title: string
  message: string
  type: 'success' | 'error' | 'warning' | 'info'
  duration?: number
}