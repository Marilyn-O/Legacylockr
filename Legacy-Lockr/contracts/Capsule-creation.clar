;; title: Capsule Creation
;; version: 1.0.0
;; summary: A smart contract for creating and managing digital time capsules.
;; description: This contract enables users to create time capsules that can store metadata, unlock dates, and contributors in a decentralized manner. Capsules can contain messages, photos, videos, and other media. The contract tracks capsule ownership and status, providing functionality to create, retrieve, and manage these digital assets securely.

;; traits
;; Event for capsule creation
(define-trait capsule-event-trait
  ((capsule-created (uint principal) (response bool uint)))
)

;; token definitions
;;

;; constants
;;

;; data vars
;; Keep track of the next available capsule ID
(define-data-var next-capsule-id uint u1)

;; data maps
;; Define the capsule data structure
(define-map capsules
  { capsule-id: uint }
  {
    owner: principal,
    unlock-date: uint,
    title: (string-ascii 256),
    description: (string-ascii 1024),
    contributors: (list 20 principal),
    is-unlocked: bool
  }
)

;; public functions
;; Function to create a new capsule
(define-public (create-capsule 
    (unlock-date uint) 
    (title (string-ascii 256)) 
    (description (string-ascii 1024)) 
    (contributors (list 20 principal))
    (capsule-event <capsule-event-trait>)
  )
  (let
    (
      (capsule-id (var-get next-capsule-id))
      (owner tx-sender)
    )
    ;; Store the capsule data
    (map-set capsules
      { capsule-id: capsule-id }
      {
        owner: owner,
        unlock-date: unlock-date,
        title: title,
        description: description,
        contributors: contributors,
        is-unlocked: false
      }
    )
    ;; Increment the next capsule ID
    (var-set next-capsule-id (+ capsule-id u1))
    ;; Emit the capsule created event
    (try! (contract-call? capsule-event capsule-created capsule-id owner))
    ;; Return the capsule ID
    (ok capsule-id)
  )
)

;; read only functions
;; Function to get capsule data
(define-read-only (get-capsule (capsule-id uint))
  (map-get? capsules { capsule-id: capsule-id })
)