
;; title: Unlock-mechanism
;; version:
;; summary:
;; description:

;; Unlock Mechanism Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-capsule-not-found (err u102))
(define-constant err-already-unlocked (err u103))
(define-constant err-not-unlocked (err u104))

;; Define data maps
(define-map capsules
  { capsule-id: uint }
  {
    owner: principal,
    unlock-height: uint,
    content: (string-ascii 256),
    is-unlocked: bool
  }
)

;; Function to create a new capsule
(define-public (create-capsule (capsule-id uint) (unlock-height uint) (content (string-ascii 256)))
  (let
    (
      (capsule-data {
        owner: tx-sender,
        unlock-height: unlock-height,
        content: content,
        is-unlocked: false
      })
    )
    (asserts! (is-none (map-get? capsules { capsule-id: capsule-id })) (err u105))
    (map-set capsules { capsule-id: capsule-id } capsule-data)
    (ok true)
  )
)

;; Function to check unlock status and update if necessary
(define-public (check-unlock-status (capsule-id uint))
  (let
    (
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
      (current-height block-height)
    )
    (if (and (>= current-height (get unlock-height capsule)) (not (get is-unlocked capsule)))
      (begin
        (map-set capsules
          { capsule-id: capsule-id }
          (merge capsule { is-unlocked: true })
        )
        (ok true)
      )
      (ok false)
    )
  )
)

;; Function to retrieve capsule content
(define-public (retrieve-content (capsule-id uint))
  (let
    (
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
    )
    (asserts! (is-eq (get owner capsule) tx-sender) err-unauthorized)
    (asserts! (get is-unlocked capsule) err-not-unlocked)
    (ok (get content capsule))
  )
)

;; Read-only function to get capsule details
(define-read-only (get-capsule-details (capsule-id uint))
  (match (map-get? capsules { capsule-id: capsule-id })
    capsule (ok {
      owner: (get owner capsule),
      unlock-height: (get unlock-height capsule),
      is-unlocked: (get is-unlocked capsule)
    })
    (err err-capsule-not-found)
  )
)

;; Read-only function to check if a capsule is unlocked
(define-read-only (is-capsule-unlocked (capsule-id uint))
  (match (map-get? capsules { capsule-id: capsule-id })
    capsule (get is-unlocked capsule)
    false
  )
)

