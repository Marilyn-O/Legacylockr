
;; title: contributors-management
;; version:
;; summary:
;; description:

;; Contributors Management Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-capsule-not-found (err u102))
(define-constant err-contributor-already-exists (err u103))
(define-constant err-contributor-not-found (err u104))

;; Define data maps
(define-map capsules
  { capsule-id: uint }
  { owner: principal }
)

(define-map contributors
  { capsule-id: uint, contributor: principal }
  { active: bool }
)

;; Function to create a new capsule
(define-public (create-capsule (capsule-id uint))
  (begin
    (asserts! (is-none (map-get? capsules { capsule-id: capsule-id })) (err u105))
    (map-set capsules
      { capsule-id: capsule-id }
      { owner: tx-sender }
    )
    (ok true)
  )
)

;; Function to add a contributor
(define-public (add-contributor (capsule-id uint) (contributor principal))
  (let (
    (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
    (existing-contributor (map-get? contributors { capsule-id: capsule-id, contributor: contributor }))
  )
    (asserts! (is-eq (get owner capsule) tx-sender) err-unauthorized)
    (asserts! (is-none existing-contributor) err-contributor-already-exists)
    (map-set contributors
      { capsule-id: capsule-id, contributor: contributor }
      { active: true }
    )
    (ok true)
  )
)

;; Function to remove a contributor
(define-public (remove-contributor (capsule-id uint) (contributor principal))
  (let (
    (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
    (existing-contributor (unwrap! (map-get? contributors { capsule-id: capsule-id, contributor: contributor }) err-contributor-not-found))
  )
    (asserts! (is-eq (get owner capsule) tx-sender) err-unauthorized)
    (map-delete contributors { capsule-id: capsule-id, contributor: contributor })
    (ok true)
  )
)

;; Read-only function to check if a principal is a contributor
(define-read-only (is-contributor (capsule-id uint) (contributor principal))
  (match (map-get? contributors { capsule-id: capsule-id, contributor: contributor })
    contributor-data (get active contributor-data)
    false
  )
)

;; Read-only function to get the owner of a capsule
(define-read-only (get-capsule-owner (capsule-id uint))
  (match (map-get? capsules { capsule-id: capsule-id })
    capsule (ok (get owner capsule))
    (err err-capsule-not-found)
  )
)

