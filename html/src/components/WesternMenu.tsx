import React, { useState, useMemo, useEffect } from 'react'
import { MenuProps, MenuOption } from '../types/menu'

interface SearchResultItem {
  id: string
  title: string
  description: string
  category: string
  categoryLabel: string
  icon: string
  searchTerms: string
}

// Custom hook for debounced search with immediate clear
const useDebounce = (value: string, delay: number) => {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    // If value is empty, clear immediately
    if (!value.trim()) {
      setDebouncedValue(value)
      return
    }

    // Otherwise use debounce
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => {
      clearTimeout(handler)
    }
  }, [value, delay])

  return debouncedValue
}

const WesternMenu: React.FC<MenuProps> = ({
  menu,
  canGoBack,
  onOptionSelect,
  onBack,
}) => {
  const [searchTerm, setSearchTerm] = useState('')
  const [forceRefresh, setForceRefresh] = useState(0) // Force refresh trigger
  const debouncedSearchTerm = useDebounce(searchTerm, 150) // 150ms delay

  // Force refresh when search is completely cleared
  useEffect(() => {
    if (!searchTerm.trim()) {
      setForceRefresh(prev => prev + 1) // Trigger re-render
    }
  }, [searchTerm])
  
  const handleOptionClick = (option: MenuOption) => {
    if (option.disabled || option.separator) return
    onOptionSelect(option)
  }

  // Debounced search to improve performance
  const filteredOptions = useMemo(() => {
    const debouncedTerm = debouncedSearchTerm.trim()
    
    // Always return original menu options if no search term
    if (!debouncedTerm) {
      return menu.options
    }
    
    const term = debouncedTerm.toLowerCase()
    
    // If we have searchData (main menu), search through all items
    if ((menu as any).searchData && !canGoBack) {
      const searchData: SearchResultItem[] = (menu as any).searchData
      
      // Filter and deduplicate results
      const filteredResults = searchData.filter((item: SearchResultItem) => {
        const itemTerms = item.searchTerms.toLowerCase()
        const itemTitle = item.title.toLowerCase()
        const itemDesc = item.description.toLowerCase()
        
        return itemTerms.includes(term) || itemTitle.includes(term) || itemDesc.includes(term)
      })
      
      // Deduplicate by title to avoid showing the same item multiple times
      const seen = new Set<string>()
      const searchResults = filteredResults
        .filter((item: SearchResultItem) => {
          const key = item.title.toLowerCase()
          if (seen.has(key)) {
            return false
          }
          seen.add(key)
          return true
        })
        .slice(0, 30) // Limit results for better performance
      
      // Convert search results to menu options
      return searchResults.map((item: SearchResultItem): MenuOption => ({
        id: item.id,
        title: item.title,
        description: `${item.description} → ${item.categoryLabel}`,
        icon: item.icon,
        disabled: false,
        separator: false,
        data: {
          category: item.category
        }
      }))
    }
    
    // Regular category filtering
    return menu.options.filter(option => {
      if (option.separator) return false
      return (
        option.title?.toLowerCase().includes(term) ||
        option.description?.toLowerCase().includes(term) ||
        option.id?.toLowerCase().includes(term)
      )
    })
  }, [menu.options, (menu as any).searchData, debouncedSearchTerm, canGoBack, forceRefresh])

  // Reset search when switching menus
  React.useEffect(() => {
    if (canGoBack) {
      setSearchTerm('')
    }
  }, [canGoBack])

  const handleBackClick = (event: React.MouseEvent) => {
    event.preventDefault()
    event.stopPropagation()
    onBack()
  }

  const getOptionClasses = (option: MenuOption) => {
    let classes = 'menu-option'
    if (option.disabled) classes += ' disabled'
    if (option.applied) classes += ' applied'
    return classes
  }

  const getIcon = (option: MenuOption) => {
    if (!option.icon) return null
    
    // Handle emoji icons
    if (option.icon.length <= 2) {
      return <span className="option-icon">{option.icon}</span>
    }
    
    // Handle Font Awesome classes
    if (option.icon.startsWith('fa-')) {
      return <i className={`option-icon fas ${option.icon}`}></i>
    }
    
    // Handle other icon formats
    return <span className="option-icon">{option.icon}</span>
  }

  return (
    <div className="western-menu">
      <div className="menu-header">
        {canGoBack && (
          <button className="back-button" onClick={handleBackClick}>
            ← Back
          </button>
        )}
        <h2 className="menu-title">{menu.title}</h2>
        {menu.subtitle && (
          <p className="menu-subtitle">{menu.subtitle}</p>
        )}
      </div>

      <div className="menu-content">
        {/* Search Bar - only show on main menu (no back button) */}
        {!canGoBack && (
          <div className="search-container">
            <input
              type="text"
              id="global-search"
              placeholder="Search all categories..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="global-search-input"
            />
          </div>
        )}
        
        <div className="menu-options">
          {filteredOptions.length > 0 ? (
            filteredOptions.map((option, index) => {
              if (option.separator) {
                return <div key={`separator-${index}`} className="menu-separator" />
              }

              return (
                <div
                  key={option.id}
                  className={getOptionClasses(option)}
                  onClick={() => handleOptionClick(option)}
                >
                  <div className="option-header">
                    {getIcon(option)}
                    <span className="option-title">{option.title}</span>
                    {option.applied && (
                      <span className="text-gold"> ✓</span>
                    )}
                  </div>
                  {option.description && (
                    <p className="option-description">{option.description}</p>
                  )}
                </div>
              )
            })
          ) : searchTerm.trim() ? (
            <div className="no-results">
              <p>No results found for "{searchTerm}"</p>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  )
}

export default WesternMenu