;; title: Unlock-mechanism
;; version: 1.0
;; summary: A smart contract for creating and managing capsules with time-based unlocking.
;; description: 
;; This contract allows users to create capsules containing sensitive data that can only 
;; be unlocked after a specified block height. Owners can retrieve the content once the 
;; unlocking conditions are met.

;; Unlock Mechanism Smart Contract

;; --- Constants ---
;; Define constants for easy reference and error management.
(define-constant contract-owner tx-sender) ;; The contract owner is the one deploying the contract.
(define-constant err-owner-only (err u100)) ;; Error for actions restricted to the owner.
(define-constant err-unauthorized (err u101)) ;; Error for unauthorized access.
(define-constant err-capsule-not-found (err u102)) ;; Error for missing capsule.
(define-constant err-already-unlocked (err u103)) ;; Error when the capsule is already unlocked.
(define-constant err-not-unlocked (err u104)) ;; Error when the capsule is not yet unlocked.

;; --- Data Map ---
;; Define the `capsules` map to store capsule details.
(define-map capsules
  { capsule-id: uint } ;; Key: unique capsule ID.
  {
    owner: principal, ;; Owner of the capsule.
    unlock-height: uint, ;; Block height when the capsule can be unlocked.
    content: (string-ascii 256), ;; Content stored in the capsule.
    is-unlocked: bool ;; Status indicating whether the capsule is unlocked.
  }
)

;; --- Functions ---

;; Function to create a new capsule
(define-public (create-capsule (capsule-id uint) (unlock-height uint) (content (string-ascii 256)))
  (let
    (
      ;; Create capsule data structure.
      (capsule-data {
        owner: tx-sender, ;; Assign the creator as the owner.
        unlock-height: unlock-height, ;; Set the block height for unlocking.
        content: content, ;; Store the provided content.
        is-unlocked: false ;; Default the unlocked status to false.
      })
    )
    ;; Ensure the capsule ID is unique.
    (asserts! (is-none (map-get? capsules { capsule-id: capsule-id })) (err u105))
    ;; Save the capsule in the map.
    (map-set capsules { capsule-id: capsule-id } capsule-data)
    ;; Return success.
    (ok true)
  )
)

;; Function to check unlock status and update if necessary
(define-public (check-unlock-status (capsule-id uint))
  (let
    (
      ;; Retrieve the capsule or return an error if not found.
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
      ;; Get the current block height.
      (current-height block-height)
    )
    ;; Check if the capsule can be unlocked.
    (if (and (>= current-height (get unlock-height capsule)) (not (get is-unlocked capsule)))
      (begin
        ;; Update the unlocked status.
        (map-set capsules
          { capsule-id: capsule-id }
          (merge capsule { is-unlocked: true })
        )
        ;; Return success if unlocked.
        (ok true)
      )
      ;; Return false if not yet unlocked.
      (ok false)
    )
  )
)

;; Function to retrieve capsule content
(define-public (retrieve-content (capsule-id uint))
  (let
    (
      ;; Retrieve the capsule or return an error if not found.
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
    )
    ;; Ensure the caller is the owner.
    (asserts! (is-eq (get owner capsule) tx-sender) err-unauthorized)
    ;; Ensure the capsule is unlocked.
    (asserts! (get is-unlocked capsule) err-not-unlocked)
    ;; Return the content.
    (ok (get content capsule))
  )
)

;; Read-only function to get capsule details
(define-read-only (get-capsule-details (capsule-id uint))
  ;; Retrieve capsule details or return an error if not found.
  (match (map-get? capsules { capsule-id: capsule-id })
    capsule (ok {
      owner: (get owner capsule), ;; Owner of the capsule.
      unlock-height: (get unlock-height capsule), ;; Unlock block height.
      is-unlocked: (get is-unlocked capsule) ;; Unlock status.
    })
    (err err-capsule-not-found) ;; Error if the capsule is not found.
  )
)

;; Read-only function to check if a capsule is unlocked
(define-read-only (is-capsule-unlocked (capsule-id uint))
  ;; Check if the capsule is unlocked or return false if not found.
  (match (map-get? capsules { capsule-id: capsule-id })
    capsule (get is-unlocked capsule) ;; Return unlock status.
    false ;; Return false if the capsule is not found.
  )
)
