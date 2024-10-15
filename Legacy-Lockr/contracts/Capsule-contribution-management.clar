
;; title: Capsule-contribution-management
;; version: 1.0.0
;; summary: Smart contract for managing contributors to capsules
;; description: 
;; This smart contract provides functionality to manage contributors for capsules.
;; It allows capsule owners to add and remove contributors, and provides a way to
;; check if an address is a contributor to a specific capsule. The contract
;; ensures that only capsule owners can modify the contributor list.

;; traits
;;

;; token definitions
;;

;; constants
;; Define error constants
(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-ALREADY-CONTRIBUTOR (err u101))
(define-constant ERR-NOT-CONTRIBUTOR (err u102))

;; data vars
;;

;; data maps
;; Define data maps
(define-map capsules
  { capsule-id: uint }
  { owner: principal }
)

(define-map contributors
  { capsule-id: uint, contributor: principal }
  { is-contributor: bool }
)

;; public functions
;; Add a contributor to a capsule
(define-public (add-contributor (capsule-id uint) (contributor principal))
  (begin
    (asserts! (is-owner capsule-id) ERR-NOT-OWNER)
    (asserts! (is-none (map-get? contributors { capsule-id: capsule-id, contributor: contributor })) ERR-ALREADY-CONTRIBUTOR)
    (map-set contributors { capsule-id: capsule-id, contributor: contributor } { is-contributor: true })
    (ok true)
  )
)

;; Remove a contributor from a capsule
(define-public (remove-contributor (capsule-id uint) (contributor principal))
  (begin
    (asserts! (is-owner capsule-id) ERR-NOT-OWNER)
    (asserts! (is-some (map-get? contributors { capsule-id: capsule-id, contributor: contributor })) ERR-NOT-CONTRIBUTOR)
    (map-delete contributors { capsule-id: capsule-id, contributor: contributor })
    (ok true)
  )
)

;; Initialize a new capsule (helper function for testing)
(define-public (initialize-capsule (capsule-id uint))
  (begin
    (asserts! (is-none (map-get? capsules { capsule-id: capsule-id })) (err u103))
    (map-set capsules { capsule-id: capsule-id } { owner: tx-sender })
    (ok true)
  )
)

;; read only functions
;; Check if an address is a contributor to a capsule
(define-read-only (is-contributor (capsule-id uint) (contributor principal))
  (default-to false (get is-contributor (map-get? contributors { capsule-id: capsule-id, contributor: contributor })))
)


;; private functions
;; Check if the sender is the capsule owner
(define-private (is-owner (capsule-id uint))
  (match (map-get? capsules { capsule-id: capsule-id })
    capsule-data (is-eq tx-sender (get owner capsule-data))
    false
  )
)
