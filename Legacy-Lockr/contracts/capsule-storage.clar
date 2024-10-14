
;; title: Capsule Storage
;; version: 1.0.0
;; summary: A smart contract for creating and managing digital time capsules with various functionalities.
;; description: This smart contract allows users to create, store, and manage digital time capsules that contain media links, contributors, and status information. Users can define unlock dates, update capsule statuses, and control the visibility of capsules (public/private). The contract maintains a record of each capsule's state, ensuring secure and decentralized management of digital memories. Functions include capsule creation, data retrieval, status updates, and validation of user permissions for actions.


;; traits
;;

;; Define constants for status values
(define-constant ACTIVE u0)
(define-constant UNLOCKED u1)
(define-constant ARCHIVED u2)

;; Define constants for public/private status
(define-constant PUBLIC u0)
(define-constant PRIVATE u1)

;; Define the capsule data structure
(define-map capsules
  { capsule-id: uint }
  {
    owner: principal,
    unlock-date: uint,
    media-links: (list 10 (string-ascii 256)),
    contributors: (list 20 principal),
    public-status: uint,
    status: uint
  }
)

;; Keep track of the next available capsule ID
(define-data-var next-capsule-id uint u1)

;; Function to create a new capsule
(define-public (create-capsule 
    (unlock-date uint) 
    (media-links (list 10 (string-ascii 256)))
    (contributors (list 20 principal))
    (public-status uint)
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
        media-links: media-links,
        contributors: contributors,
        public-status: public-status,
        status: ACTIVE
      }
    )
    ;; Increment the next capsule ID
    (var-set next-capsule-id (+ capsule-id u1))
    ;; Return the capsule ID
    (ok capsule-id)
  )
)

;; Function to get capsule data
(define-read-only (get-capsule (capsule-id uint))
  (map-get? capsules { capsule-id: capsule-id })
)

;; Function to update capsule status
(define-public (update-capsule-status (capsule-id uint) (new-status uint))
  (let
    (
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) (err u404)))
      (owner (get owner capsule))
    )
    ;; Check if the caller is the owner
    (asserts! (is-eq tx-sender owner) (err u403))
    ;; Check if the new status is valid
    (asserts! (or (is-eq new-status ACTIVE) (is-eq new-status UNLOCKED) (is-eq new-status ARCHIVED)) (err u400))
    ;; Update the status
    (ok (map-set capsules
      { capsule-id: capsule-id }
      (merge capsule { status: new-status })
    ))
  )
)

;; Function to update public/private status
(define-public (update-public-status (capsule-id uint) (new-public-status uint))
  (let
    (
      (capsule (unwrap! (map-get? capsules { capsule-id: capsule-id }) (err u404)))
      (owner (get owner capsule))
    )
    ;; Check if the caller is the owner
    (asserts! (is-eq tx-sender owner) (err u403))
    ;; Check if the new public status is valid
    (asserts! (or (is-eq new-public-status PUBLIC) (is-eq new-public-status PRIVATE)) (err u400))
    ;; Update the public status
    (ok (map-set capsules
      { capsule-id: capsule-id }
      (merge capsule { public-status: new-public-status })
    ))
  )
)