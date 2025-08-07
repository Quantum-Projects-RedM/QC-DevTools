import React from 'react'

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

interface EntityScannerProps {
  isVisible: boolean
  entityInfo: EntityInfo | null
  showNoEntity: boolean
  instructions: {
    capture: string
    cancel: string
  }
}

const EntityScanner: React.FC<EntityScannerProps> = ({
  isVisible,
  entityInfo,
  showNoEntity,
  instructions
}) => {
/*   console.log('[EntityScanner] Props:', { isVisible, entityInfo: !!entityInfo, showNoEntity })
  console.log('[EntityScanner] EntityInfo details:', entityInfo) */

  const formatCoords = (coords: { x: number; y: number; z: number } | null | undefined) => {
    if (!coords) return '-'
    return `vector3(${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)})`
  }

  const formatHeading = (heading: number | null | undefined) => {
    if (heading === undefined || heading === null) return '-'
    return heading.toFixed(2)
  }

  if (!isVisible && !showNoEntity) {
    /* console.log('[EntityScanner] Not rendering - isVisible:', isVisible, 'showNoEntity:', showNoEntity) */
    return null
  }

  /* console.log('[EntityScanner] Rendering component') */
  
  return (
    <div className="entity-scanner">
      {/* Entity Information Panel - Show when scanner is active */}
      {isVisible && (
        <div className="entity-info-panel">
          <div className="entity-header">
            <h3>Entity Information</h3>
            <div className="status-indicator">ACTIVE</div>
          </div>
          
          {/* Show entity details if we have entity info */}
          {entityInfo ? (
            <div className="entity-details">
              <div className="info-row">
                <span className="label">ENTITY:</span>
                <span className="value">{entityInfo.entity || '-'}</span>
              </div>
              
              <div className="info-row">
                <span className="label">TYPE:</span>
                <span className="value">{entityInfo.type || '-'}</span>
              </div>

              <div className="info-row">
                <span className="label">NETWORK ID:</span>
                <span className="value">{entityInfo.networkId || '-'}</span>
              </div>
              
              <div className="info-row">
                <span className="label">MODEL HASH:</span>
                <span className="value">{entityInfo.hashStr || '-'}</span>
              </div>
              
              <div className="info-row">
                <span className="label">COORDINATES:</span>
                <span className="value">{formatCoords(entityInfo.coords)}</span>
              </div>
              
              <div className="info-row">
                <span className="label">ROTATION:</span>
                <span className="value">{formatCoords(entityInfo.rotation)}</span>
              </div>
              
              <div className="info-row">
                <span className="label">HEADING:</span>
                <span className="value">{formatHeading(entityInfo.heading)}</span>
              </div>
            </div>
          ) : (
            /* Show "No Entity" when no entity is detected */
            <div className="entity-details">
              <div className="no-entity-content">
                <div className="no-entity-text">No entity detected</div>
                <div className="no-entity-subtext">Aim at an object, ped, or vehicle</div>
              </div>
            </div>
          )}
          
          <div className="entity-controls">
            <div className="control-instruction">
              <span className="key-bind">RIGHT CLICK</span>
              <span>{instructions.capture}</span>
            </div>
            <div className="control-instruction">
              <span className="key-bind">ESC</span>
              <span>{instructions.cancel}</span>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default EntityScanner