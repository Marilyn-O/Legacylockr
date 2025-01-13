
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

