
;; title: capsule-unlock
;; version:
;; summary:
;; description:

;; capsule-unlock.clar
;; A contract for managing the unlock mechanism of capsules

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-CAPSULE-NOT-FOUND (err u101))
(define-constant ERR-CAPSULE-LOCKED (err u102))
(define-constant ERR-INVALID-UNLOCK-HEIGHT (err u103))

;; Capsule status constants
(define-constant STATUS-LOCKED u1)
(define-constant STATUS-UNLOCKED u2)

;; Data maps
;; Map of capsule ID to owner
(define-map capsule-owners (buff 32) principal)

;; Map of capsule ID to unlock block height
(define-map capsule-unlock-heights (buff 32) uint)

;; Map of capsule ID to current status
(define-map capsule-status (buff 32) uint)

;; Map of capsule ID to content hash (simplified representation)
(define-map capsule-contents (buff 32) (buff 64))

;; Public functions

;; Create a new capsule with unlock height
(define-public (create-capsule (capsule-id (buff 32)) (unlock-height uint) (content-hash (buff 64)))
  (begin
    ;; Ensure unlock height is in the future
    (asserts! (> unlock-height stacks-block-height) ERR-INVALID-UNLOCK-HEIGHT)
    
    ;; Set capsule owner, unlock height, and initial status
    (map-set capsule-owners capsule-id tx-sender)
    (map-set capsule-unlock-heights capsule-id unlock-height)
    (map-set capsule-status capsule-id STATUS-LOCKED)
    (map-set capsule-contents capsule-id content-hash)
    
    (ok true)))

;; Check if a capsule is unlocked and update status if needed
(define-public (check-unlock-status (capsule-id (buff 32)))
  (let ((unlock-height (get-unlock-height capsule-id))
        (current-status (get-capsule-status capsule-id)))
    
    ;; Ensure capsule exists
    (asserts! (is-some unlock-height) ERR-CAPSULE-NOT-FOUND)
    (asserts! (is-some current-status) ERR-CAPSULE-NOT-FOUND)
    
    (let ((unwrapped-height (unwrap-panic unlock-height))
          (unwrapped-status (unwrap-panic current-status)))
      
      ;; If already unlocked, just return the status
      (if (is-eq unwrapped-status STATUS-UNLOCKED)
          (ok STATUS-UNLOCKED)
          ;; If locked, check if it should be unlocked
          (if (>= stacks-block-height unwrapped-height)
              (begin
                ;; Update status to unlocked
                (map-set capsule-status capsule-id STATUS-UNLOCKED)
                (ok STATUS-UNLOCKED))
              ;; Still locked
              (ok STATUS-LOCKED))))))

;; Retrieve capsule contents (only if unlocked)
(define-public (retrieve-capsule-contents (capsule-id (buff 32)))
  (let ((status (get-capsule-status capsule-id))
        (contents (get-capsule-contents capsule-id)))
    
    ;; Ensure capsule exists
    (asserts! (is-some status) ERR-CAPSULE-NOT-FOUND)
    (asserts! (is-some contents) ERR-CAPSULE-NOT-FOUND)
    
    ;; Check if unlocked
    (asserts! (is-eq (unwrap-panic status) STATUS-UNLOCKED) ERR-CAPSULE-LOCKED)
    
    ;; Return the contents
    (ok (unwrap-panic contents))))

;; Read-only functions

;; Get the unlock height of a capsule
(define-read-only (get-unlock-height (capsule-id (buff 32)))
  (map-get? capsule-unlock-heights capsule-id))

;; Get the status of a capsule
(define-read-only (get-capsule-status (capsule-id (buff 32)))
  (map-get? capsule-status capsule-id))

;; Get the contents of a capsule
(define-read-only (get-capsule-contents (capsule-id (buff 32)))
  (map-get? capsule-contents capsule-id))

;; Check if a capsule is unlocked
(define-read-only (is-capsule-unlocked (capsule-id (buff 32)))
  (let ((status (get-capsule-status capsule-id)))
    (if (is-some status)
        (is-eq (unwrap-panic status) STATUS-UNLOCKED)
        false)))