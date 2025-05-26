;; title: time-capsule-contract
;; version: 1.0.0
;; summary: A smart contract for creating and unlocking digital time capsules
;; description: This contract allows users to create digital time capsules with content hashes
;;              and metadata that can be unlocked at a later time by the creator or an admin.

;; Contract owner and administration
(define-constant CONTRACT_OWNER tx-sender)

;; Define error codes
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_CAPSULE_NOT_FOUND (err u1002))
(define-constant ERR_CAPSULE_ALREADY_UNLOCKED (err u1003))
(define-constant ERR_INVALID_PARAMETERS (err u1004))
(define-constant ERR_CAPSULE_LOCKED (err u1005))

;; Data structures
(define-data-var capsule-nonce uint u0)

(define-map capsules uint {
    creator: principal,
    created-at: uint,
    unlocked-at: (optional uint),
    content-hash: (string-ascii 64),
    metadata: (optional (string-ascii 1024))
})

;; Event types for logging
(define-data-var event-counter uint u0)

;; Helper functions
(define-private (is-authorized-for-capsule (capsule-id uint))
    (let ((capsule (map-get? capsules capsule-id)))
        (match capsule
            capsule-data (or 
                (is-eq tx-sender (get creator capsule-data))
                (is-eq tx-sender CONTRACT_OWNER)
            )
            false
        )
    )
)

;; Function to log create event
(define-private (log-capsule-created (capsule-id uint) (creator principal) (created-at uint) 
                                     (content-hash (string-ascii 64)) (metadata (optional (string-ascii 1024))))
    (print {
        event: "capsule-created",
        capsule-id: capsule-id,
        creator: creator,
        created-at: created-at,
        content-hash: content-hash,
        metadata: metadata
    })
)

;; Function to log unlock event
(define-private (log-capsule-unlocked (capsule-id uint) (unlocked-by principal) (unlocked-at uint) 
                                      (content-hash (string-ascii 64)))
    (print {
        event: "capsule-unlocked",
        capsule-id: capsule-id,
        unlocked-by: unlocked-by,
        unlocked-at: unlocked-at,
        content-hash: content-hash
    })
)

;; Function to log update event
(define-private (log-capsule-updated (capsule-id uint) (updated-by principal) (updated-at uint))
    (print {
        event: "capsule-updated",
        capsule-id: capsule-id,
        updated-by: updated-by,
        updated-at: updated-at
    })
)

;; Public functions
;; Create a new capsule
(define-public (create-capsule (content-hash (string-ascii 64)) (metadata (optional (string-ascii 1024))))
    (begin
        ;; Validate input parameters
        (asserts! (> (len content-hash) u0) ERR_INVALID_PARAMETERS)
        
        (let (
            (capsule-id (var-get capsule-nonce))
            (created-at stacks-block-height)
        )
            ;; Store the capsule data
            (map-set capsules capsule-id {
                creator: tx-sender,
                created-at: created-at,
                unlocked-at: none,
                content-hash: content-hash,
                metadata: metadata
            })
            
            ;; Increment the nonce
            (var-set capsule-nonce (+ capsule-id u1))
            
            ;; Log the creation event
            (log-capsule-created capsule-id tx-sender created-at content-hash metadata)
            
            (ok capsule-id)
        )
    )
)

;; Unlock an existing capsule
(define-public (unlock-capsule (capsule-id uint))
    (let (
        (capsule (unwrap! (map-get? capsules capsule-id) ERR_CAPSULE_NOT_FOUND))
    )
        ;; Check if already unlocked
        (asserts! (is-none (get unlocked-at capsule)) ERR_CAPSULE_ALREADY_UNLOCKED)
        
        ;; Only the creator can unlock (or contract owner for admin purposes)
        (asserts! (or 
            (is-eq tx-sender (get creator capsule))
            (is-eq tx-sender CONTRACT_OWNER)
        ) ERR_NOT_AUTHORIZED)
        
        ;; Update the capsule with unlock time
        (map-set capsules capsule-id (merge capsule {
            unlocked-at: (some stacks-block-height)
        }))
        
        ;; Log the unlock event
        (log-capsule-unlocked capsule-id tx-sender stacks-block-height (get content-hash capsule))
        
        (ok true)
    )
)

;; Update capsule metadata (only if not yet unlocked)
(define-public (update-capsule-metadata (capsule-id uint) (new-metadata (optional (string-ascii 1024))))
    (let (
        (capsule (unwrap! (map-get? capsules capsule-id) ERR_CAPSULE_NOT_FOUND))
    )
        ;; Check if already unlocked
        (asserts! (is-none (get unlocked-at capsule)) ERR_CAPSULE_ALREADY_UNLOCKED)
        
        ;; Only the creator can update (or contract owner for admin purposes)
        (asserts! (or 
            (is-eq tx-sender (get creator capsule))
            (is-eq tx-sender CONTRACT_OWNER)
        ) ERR_NOT_AUTHORIZED)
        
        ;; Update the capsule metadata
        (map-set capsules capsule-id (merge capsule {
            metadata: new-metadata
        }))
        
        ;; Log the update event
        (log-capsule-updated capsule-id tx-sender stacks-block-height)
        
        (ok true)
    )
)

;; Read-only functions
;; Get capsule information
(define-read-only (get-capsule (capsule-id uint))
    (ok (map-get? capsules capsule-id))
)

;; Get capsule content hash (only available if unlocked)
(define-read-only (get-capsule-content (capsule-id uint))
    (let ((capsule (unwrap! (map-get? capsules capsule-id) ERR_CAPSULE_NOT_FOUND)))
        ;; Check if unlocked
        (asserts! (is-some (get unlocked-at capsule)) ERR_CAPSULE_LOCKED)
        
        (ok (get content-hash capsule))
    )
)

;; Get total capsule count
(define-read-only (get-capsule-count)
    (ok (var-get capsule-nonce))
)
