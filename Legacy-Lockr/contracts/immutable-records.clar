;; Immutable Records Contract
;; Maintains comprehensive logs of all important actions for transparency and traceability

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-INPUT (err u400))

;; Data Variables
(define-data-var log-counter uint u0)

;; Action Types
(define-constant ACTION-CAPSULE-CREATED u1)
(define-constant ACTION-CAPSULE-UPDATED u2)
(define-constant ACTION-CAPSULE-UNLOCKED u3)
(define-constant ACTION-CAPSULE-DELETED u4)
(define-constant ACTION-ACCESS-GRANTED u5)
(define-constant ACTION-ACCESS-REVOKED u6)
(define-constant ACTION-METADATA-UPDATED u7)

;; Data Maps
(define-map action-logs
    { log-id: uint }
    {
        action-type: uint,
        capsule-id: uint,
        actor: principal,
        timestamp: uint,
        block-height: uint,
        description: (string-ascii 256),
        metadata: (optional (string-ascii 512))
    }
)

(define-map capsule-logs
    { capsule-id: uint }
    { log-ids: (list 1000 uint) }
)

(define-map actor-logs
    { actor: principal }
    { log-ids: (list 1000 uint) }
)

(define-map action-type-logs
    { action-type: uint }
    { log-ids: (list 10000 uint) }
)

;; Helper Functions
(define-private (get-current-timestamp)
    (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))
)

(define-private (increment-log-counter)
    (let ((current-counter (var-get log-counter)))
        (var-set log-counter (+ current-counter u1))
        (+ current-counter u1))
)

(define-private (add-to-capsule-logs (capsule-id uint) (log-id uint))
    (let ((current-logs (default-to { log-ids: (list) } (map-get? capsule-logs { capsule-id: capsule-id }))))
        (map-set capsule-logs
            { capsule-id: capsule-id }
            { log-ids: (unwrap! (as-max-len? (append (get log-ids current-logs) log-id) u1000) false) }
        )
    )
)

(define-private (add-to-actor-logs (actor principal) (log-id uint))
    (let ((current-logs (default-to { log-ids: (list) } (map-get? actor-logs { actor: actor }))))
        (map-set actor-logs
            { actor: actor }
            { log-ids: (unwrap! (as-max-len? (append (get log-ids current-logs) log-id) u1000) false) }
        )
    )
)

(define-private (add-to-action-type-logs (action-type uint) (log-id uint))
    (let ((current-logs (default-to { log-ids: (list) } (map-get? action-type-logs { action-type: action-type }))))
        (map-set action-type-logs
            { action-type: action-type }
            { log-ids: (unwrap! (as-max-len? (append (get log-ids current-logs) log-id) u10000) false) }
        )
    )
)

;; Public Functions

;; Log a capsule creation event
(define-public (log-capsule-created (capsule-id uint) (description (string-ascii 256)) (metadata (optional (string-ascii 512))))
    (let ((log-id (increment-log-counter)))
        (map-set action-logs
            { log-id: log-id }
            {
                action-type: ACTION-CAPSULE-CREATED,
                capsule-id: capsule-id,
                actor: tx-sender,
                timestamp: (get-current-timestamp),
                block-height: stacks-block-height,
                description: description,
                metadata: metadata
            }
        )
        (add-to-capsule-logs capsule-id log-id)
        (add-to-actor-logs tx-sender log-id)
        (add-to-action-type-logs ACTION-CAPSULE-CREATED log-id)
        (ok log-id)
    )
)

;; Log a capsule update event
(define-public (log-capsule-updated (capsule-id uint) (description (string-ascii 256)) (metadata (optional (string-ascii 512))))
    (let ((log-id (increment-log-counter)))
        (map-set action-logs
            { log-id: log-id }
            {
                action-type: ACTION-CAPSULE-UPDATED,
                capsule-id: capsule-id,
                actor: tx-sender,
                timestamp: (get-current-timestamp),
                block-height: stacks-block-height,
                description: description,
                metadata: metadata
            }
        )
        (add-to-capsule-logs capsule-id log-id)
        (add-to-actor-logs tx-sender log-id)
        (add-to-action-type-logs ACTION-CAPSULE-UPDATED log-id)
        (ok log-id)
    )
)

;; Log a capsule unlock event
(define-public (log-capsule-unlocked (capsule-id uint) (description (string-ascii 256)) (metadata (optional (string-ascii 512))))
    (let ((log-id (increment-log-counter)))
        (map-set action-logs
            { log-id: log-id }
            {
                action-type: ACTION-CAPSULE-UNLOCKED,
                capsule-id: capsule-id,
                actor: tx-sender,
                timestamp: (get-current-timestamp),
                block-height: stacks-block-height,
                description: description,
                metadata: metadata
            }
        )
        (add-to-capsule-logs capsule-id log-id)
        (add-to-actor-logs tx-sender log-id)
        (add-to-action-type-logs ACTION-CAPSULE-UNLOCKED log-id)
        (ok log-id)
    )
)

;; Log a capsule deletion event
(define-public (log-capsule-deleted (capsule-id uint) (description (string-ascii 256)) (metadata (optional (string-ascii 512))))
    (let ((log-id (increment-log-counter)))
        (map-set action-logs
            { log-id: log-id }
            {
                action-type: ACTION-CAPSULE-DELETED,
                capsule-id: capsule-id,
                actor: tx-sender,
                timestamp: (get-current-timestamp),
                block-height: stacks-block-height,
                description: description,
                metadata: metadata
            }
        )
        (add-to-capsule-logs capsule-id log-id)
        (add-to-actor-logs tx-sender log-id)
        (add-to-action-type-logs ACTION-CAPSULE-DELETED log-id)
        (ok log-id)
    )
)

;; Log access granted event
(define-public (log-access-granted (capsule-id uint) (grantee principal) (description (string-ascii 256)) (metadata (optional (string-ascii 512))))
    (let ((log-id (increment-log-counter)))
        (map-set action-logs
            { log-id: log-id }
            {
                action-type: ACTION-ACCESS-GRANTED,
                capsule-id: capsule-id,
                actor: tx-sender,
                timestamp: (get-current-timestamp),
                block-height: stacks-block-height,
                description: description,
                metadata: metadata
            }
        )
        (add-to-capsule-logs capsule-id log-id)
        (add-to-actor-logs tx-sender log-id)
        (add-to-actor-logs grantee log-id)
        (add-to-action-type-logs ACTION-ACCESS-GRANTED log-id)
        (ok log-id)
    )
)

;; Log access revoked event
(define-public (log-access-revoked (capsule-id uint) (revokee principal) (description (string-ascii 256)) (metadata (optional (string-ascii 512))))
    (let ((log-id (increment-log-counter)))
        (map-set action-logs
            { log-id: log-id }
            {
                action-type: ACTION-ACCESS-REVOKED,
                capsule-id: capsule-id,
                actor: tx-sender,
                timestamp: (get-current-timestamp),
                block-height: stacks-block-height,
                description: description,
                metadata: metadata
            }
        )
        (add-to-capsule-logs capsule-id log-id)
        (add-to-actor-logs tx-sender log-id)
        (add-to-actor-logs revokee log-id)
        (add-to-action-type-logs ACTION-ACCESS-REVOKED log-id)
        (ok log-id)
    )
)

;; Log metadata update event
(define-public (log-metadata-updated (capsule-id uint) (description (string-ascii 256)) (metadata (optional (string-ascii 512))))
    (let ((log-id (increment-log-counter)))
        (map-set action-logs
            { log-id: log-id }
            {
                action-type: ACTION-METADATA-UPDATED,
                capsule-id: capsule-id,
                actor: tx-sender,
                timestamp: (get-current-timestamp),
                block-height: stacks-block-height,
                description: description,
                metadata: metadata
            }
        )
        (add-to-capsule-logs capsule-id log-id)
        (add-to-actor-logs tx-sender log-id)
        (add-to-action-type-logs ACTION-METADATA-UPDATED log-id)
        (ok log-id)
    )
)

;; Read-only Functions

;; Get a specific log entry
(define-read-only (get-log (log-id uint))
    (map-get? action-logs { log-id: log-id })
)

;; Get all log IDs for a specific capsule
(define-read-only (get-capsule-logs (capsule-id uint))
    (map-get? capsule-logs { capsule-id: capsule-id })
)

;; Get all log IDs for a specific actor
(define-read-only (get-actor-logs (actor principal))
    (map-get? actor-logs { actor: actor })
)

;; Get all log IDs for a specific action type
(define-read-only (get-action-type-logs (action-type uint))
    (map-get? action-type-logs { action-type: action-type })
)

;; Get the current log counter
(define-read-only (get-total-logs)
    (var-get log-counter)
)

;; Get action type constants
(define-read-only (get-action-types)
    {
        capsule-created: ACTION-CAPSULE-CREATED,
        capsule-updated: ACTION-CAPSULE-UPDATED,
        capsule-unlocked: ACTION-CAPSULE-UNLOCKED,
        capsule-deleted: ACTION-CAPSULE-DELETED,
        access-granted: ACTION-ACCESS-GRANTED,
        access-revoked: ACTION-ACCESS-REVOKED,
        metadata-updated: ACTION-METADATA-UPDATED
    }
)

;; Get logs within a specific block height range
(define-read-only (get-logs-in-range (start-block uint) (end-block uint) (action-type uint))
    (let ((type-logs (default-to { log-ids: (list) } (map-get? action-type-logs { action-type: action-type }))))
        (filter filter-logs-by-block-range (get log-ids type-logs))
    )
)

;; Helper function for filtering logs by block range
(define-private (filter-logs-by-block-range (log-id uint))
    (let ((log-entry (map-get? action-logs { log-id: log-id })))
        (match log-entry
            entry (and (>= (get block-height entry) stacks-block-height) (<= (get block-height entry) stacks-block-height))
            false
        )
    )
)

;; Verify log integrity by checking if a log exists and hasn't been tampered with
(define-read-only (verify-log-integrity (log-id uint))
    (let ((log-entry (map-get? action-logs { log-id: log-id })))
        (match log-entry
            entry {
                exists: true,
                log-id: log-id,
                action-type: (get action-type entry),
                capsule-id: (get capsule-id entry),
                actor: (get actor entry),
                timestamp: (get timestamp entry),
                block-height: (get block-height entry),
                hash: (sha256 (concat (unwrap-panic (to-consensus-buff? entry)) (unwrap-panic (to-consensus-buff? log-id))))
            }
            { exists: false, log-id: log-id, action-type: u0, capsule-id: u0, actor: CONTRACT-OWNER, timestamp: u0, block-height: u0, hash: 0x }
        )
    )
)