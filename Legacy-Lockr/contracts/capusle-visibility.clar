
;; title: capusle-visibility
;; version:
;; summary:
;; description:

;; Capsule Visibility Smart Contract

;; Define data map for capsules
(define-map capsules
  { capsule-id: uint }
  {
    owner: principal,
    visibility: bool,  ;; true for public, false for private
    content: (string-utf8 500)
  }
)

;; Define data variable for next capsule ID
(define-data-var next-capsule-id uint u1)

;; Define constants for error handling
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u403))

;; Function to create a new capsule
(define-public (create-capsule (content (string-utf8 500)))
  (let
    (
      (capsule-id (var-get next-capsule-id))
    )
    (map-insert capsules
      { capsule-id: capsule-id }
      {
        owner: tx-sender,
        visibility: false,  ;; default to private
        content: content
      }
    )
    (var-set next-capsule-id (+ capsule-id u1))
    (ok capsule-id)
  )
)

;; Function to set capsule visibility
(define-public (set-capsule-visibility (capsule-id uint) (is-public bool))
  (let
    (
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-not-found))
    )
    ;; Check if the sender is the owner of the capsule
    (asserts! (is-eq tx-sender (get owner capsule)) err-unauthorized)
    
    ;; Update the visibility
    (map-set capsules
      { capsule-id: capsule-id }
      (merge capsule { visibility: is-public })
    )
    (ok true)
  )
)

;; Read-only function to get capsule details
(define-read-only (get-capsule (capsule-id uint))
  (let
    (
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) err-not-found))
    )
    (if (or (is-eq tx-sender (get owner capsule)) (get visibility capsule))
      (ok capsule)
      err-unauthorized
    )
  )
)

;; Read-only function to check if a capsule is public
(define-read-only (is-capsule-public (capsule-id uint))
  (default-to false (get visibility (map-get? capsules { capsule-id: capsule-id })))
)