;; Contributors Management Smart Contract
;; This contract allows for the management of contributors to specific "capsules."
;; Each capsule has an owner, and contributors can be added or removed by the owner.

;; --- Constants ---
;; Define constants for error handling and ownership.
(define-constant contract-owner tx-sender) ;; The account deploying the contract is the owner.
(define-constant err-owner-only (err u100)) ;; Error for actions restricted to the contract owner.
(define-constant err-unauthorized (err u101)) ;; Error for unauthorized access to a capsule.
(define-constant err-capsule-not-found (err u102)) ;; Error when a capsule is not found.
(define-constant err-contributor-already-exists (err u103)) ;; Error when a contributor is already added.
(define-constant err-contributor-not-found (err u104)) ;; Error when trying to remove a non-existent contributor.

;; --- Data Maps ---
;; `capsules` map to store capsule ownership.
(define-map capsules
  { capsule-id: uint } ;; Key: unique capsule ID.
  { owner: principal } ;; Value: the principal who owns the capsule.
)

;; `contributors` map to manage contributors for each capsule.
(define-map contributors
  { capsule-id: uint, contributor: principal } ;; Key: capsule ID and contributor principal.
  { active: bool } ;; Value: boolean indicating if the contributor is active.
)

;; --- Functions ---

;; Function to create a new capsule.
(define-public (create-capsule (capsule-id uint))
  (begin
    ;; Ensure the capsule ID is not already in use.
    (asserts! (is-none (map-get? capsules { capsule-id: capsule-id })) (err u105))
    ;; Assign the caller as the owner of the new capsule.
    (map-set capsules
      { capsule-id: capsule-id }
      { owner: tx-sender }
    )
    ;; Return success.
    (ok true)
  )
)

;; Function to add a contributor to a capsule.
(define-public (add-contributor (capsule-id uint) (contributor principal))
  (let (
    ;; Fetch the capsule or return an error if it does not exist.
    (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
    ;; Check if the contributor already exists for the capsule.
    (existing-contributor (map-get? contributors { capsule-id: capsule-id, contributor: contributor }))
  )
    ;; Ensure the caller is the owner of the capsule.
    (asserts! (is-eq (get owner capsule) tx-sender) err-unauthorized)
    ;; Ensure the contributor is not already added.
    (asserts! (is-none existing-contributor) err-contributor-already-exists)
    ;; Add the contributor to the map.
    (map-set contributors
      { capsule-id: capsule-id, contributor: contributor }
      { active: true }
    )
    ;; Return success.
    (ok true)
  )
)

;; Function to remove a contributor from a capsule.
(define-public (remove-contributor (capsule-id uint) (contributor principal))
  (let (
    ;; Fetch the capsule or return an error if it does not exist.
    (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-capsule-not-found))
    ;; Fetch the contributor details or return an error if not found.
    (existing-contributor (unwrap! (map-get? contributors { capsule-id: capsule-id, contributor: contributor }) err-contributor-not-found))
  )
    ;; Ensure the caller is the owner of the capsule.
    (asserts! (is-eq (get owner capsule) tx-sender) err-unauthorized)
    ;; Remove the contributor from the map.
    (map-delete contributors { capsule-id: capsule-id, contributor: contributor })
    ;; Return success.
    (ok true)
  )
)

;; Read-only function to check if a principal is a contributor for a capsule.
(define-read-only (is-contributor (capsule-id uint) (contributor principal))
  ;; Check the contributors map for the given capsule ID and contributor.
  (match (map-get? contributors { capsule-id: capsule-id, contributor: contributor })
    contributor-data (get active contributor-data) ;; Return true if the contributor is active.
    false ;; Return false if the contributor is not found.
  )
)

;; Read-only function to get the owner of a capsule.
(define-read-only (get-capsule-owner (capsule-id uint))
  ;; Retrieve the capsule's owner or return an error if the capsule does not exist.
  (match (map-get? capsules { capsule-id: capsule-id })
    capsule (ok (get owner capsule)) ;; Return the owner's principal.
    (err err-capsule-not-found) ;; Return an error if the capsule is not found.
  )
)
