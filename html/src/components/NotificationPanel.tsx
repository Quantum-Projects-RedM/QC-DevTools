import React, { useEffect, useState } from 'react'
import { NotificationData } from '../types/menu'

interface NotificationPanelProps {
  notifications: NotificationData[]
  onRemoveNotification: (id: string) => void
}

const NotificationPanel: React.FC<NotificationPanelProps> = ({
  notifications,
  onRemoveNotification,
}) => {
  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'success':
        return '✓'
      case 'error':
        return '✕'
      case 'warning':
        return '⚠'
      case 'info':
      default:
        return 'ℹ'
    }
  }

  const getNotificationClasses = (type: string) => {
    return `notification notification-${type}`
  }

  return (
    <div className="notification-panel">
      {notifications.map((notification) => (
        <NotificationItem
          key={notification.id}
          notification={notification}
          onRemove={() => onRemoveNotification(notification.id)}
          icon={getNotificationIcon(notification.type)}
          classes={getNotificationClasses(notification.type)}
        />
      ))}
    </div>
  )
}

interface NotificationItemProps {
  notification: NotificationData
  onRemove: () => void
  icon: string
  classes: string
}

const NotificationItem: React.FC<NotificationItemProps> = ({
  notification,
  onRemove,
  icon,
  classes,
}) => {
  const [isVisible, setIsVisible] = useState(false)
  const [isExiting, setIsExiting] = useState(false)
  const [progress, setProgress] = useState(100)

  useEffect(() => {
    // Trigger entrance animation
    const showTimer = setTimeout(() => setIsVisible(true), 10)
    
    const duration = notification.duration || 5000
    
    // Progress countdown animation
    const progressInterval = setInterval(() => {
      setProgress((prev) => {
        const newProgress = prev - (100 / (duration / 100))
        return newProgress <= 0 ? 0 : newProgress
      })
    }, 100)
    
    // Auto-remove after duration
    const hideTimer = setTimeout(() => {
      setIsExiting(true)
      setTimeout(onRemove, 500) // Wait for exit animation
    }, duration)

    return () => {
      clearTimeout(showTimer)
      clearTimeout(hideTimer)
      clearInterval(progressInterval)
    }
  }, [notification.duration, onRemove])

  const handleClick = () => {
    setIsExiting(true)
    setTimeout(onRemove, 300)
  }

  return (
    <div 
      className={`${classes} ${isVisible ? 'notification-show' : ''} ${isExiting ? 'notification-exit' : ''}`}
      onClick={handleClick}
    >
      <div className="notification-content">
        <div className="notification-icon">{icon}</div>
        <div className="notification-text">
          <div className="notification-title">{notification.title}</div>
          <div className="notification-message">{notification.message}</div>
        </div>
        <div className="notification-progress">
          <svg className="progress-ring" width="24" height="24">
            <circle
              className="progress-ring-circle-bg"
              stroke="#666"
              strokeWidth="2"
              fill="transparent"
              r="10"
              cx="12"
              cy="12"
            />
            <circle
              className="progress-ring-circle"
              stroke="#fff"
              strokeWidth="2"
              fill="transparent"
              r="10"
              cx="12"
              cy="12"
              strokeDasharray={`${2 * Math.PI * 10}`}
              strokeDashoffset={`${2 * Math.PI * 10 * (1 - progress / 100)}`}
              transform="rotate(-90 12 12)"
            />
            {/* White checkmark in center */}
            <text
              x="12"
              y="16"
              textAnchor="middle"
              fill="#fff"
              fontSize="12"
              fontWeight="bold"
              fontFamily="monospace"
              transform="rotate(90 12 12)"
            >
              ✓
            </text>
          </svg>
        </div>
      </div>
    </div>
  )
}

export default NotificationPanel