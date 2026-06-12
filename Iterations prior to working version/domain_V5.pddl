(define (domain warehouse)

(:requirements
    :strips
    :typing
    :negative-preconditions
    :universal-preconditions
    :quantified-preconditions
)

(:types
    product product-type command worker location
)

(:predicates

    (at ?w - worker ?l - location)
    (start-loc ?l - location)
    (type-zone ?t - product-type ?l - location)

    (free ?w - worker)
    (working-on ?w - worker ?c - command)
    (mission-started ?c - command)
    (command-complete ?c - command)

    (in-inventory ?p - product)
    (assigned ?p - product ?c - command)

    (is-type ?p - product ?t - product-type)
    (at-loc ?p - product ?l - location)

    ;; FIXED (no DEMAND)
    (required-type ?c - command ?t - product-type)

    (picked ?c - command ?t - product ?p - product)

    (zone-open ?w - worker ?c - command ?t - product-type)

    (checkpoint-verified ?t - product-type ?c - command)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SCAN TYPE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:action Scan-Item-Type
    :parameters (?w - worker ?c - command ?t - product-type ?l - location)
    :precondition
    (and
        (working-on ?w ?c)
        (at ?w ?l)
        (type-zone ?t ?l)
        (not (zone-open ?w ?c ?t))
    )
    :effect
    (zone-open ?w ?c ?t)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PICK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:action add-to-order
    :parameters (?w - worker ?c - command ?p - product ?t - product-type ?l - location)
    :precondition
    (and
        (working-on ?w ?c)
        (at ?w ?l)
        (at-loc ?p ?l)
        (is-type ?p ?t)
        (required-type ?c ?t)
        (zone-open ?w ?c ?t)
        (in-inventory ?p)
    )
    :effect
    (and
        (not (in-inventory ?p))
        (assigned ?p ?c)
        (picked ?c ?t ?p)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CHECKPOINT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:action Scan-Checkpoint
    :parameters (?w - worker ?c - command ?t - product-type ?l - location)
    :precondition
    (and
        (working-on ?w ?c)
        (at ?w ?l)
        (type-zone ?t ?l)
        (zone-open ?w ?c ?t)
    )
    :effect
    (and
        (not (zone-open ?w ?c ?t))
        (checkpoint-verified ?t ?c)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MOVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:action move
    :parameters (?w - worker ?c - command ?from - location ?to - location)
    :precondition
    (and
        (at ?w ?from)
        (working-on ?w ?c)
        (forall (?t - product-type)
            (not (zone-open ?w ?c ?t))
        )
    )
    :effect
    (and
        (not (at ?w ?from))
        (at ?w ?to)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FINISH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:action finish-command
    :parameters (?w - worker ?c - command)
    :precondition
    (and
        (working-on ?w ?c)
        (forall (?t - product-type)
            (imply
                (required-type ?c ?t)
                (checkpoint-verified ?t ?c)
            )
        )
        (forall (?t - product-type)
            (not (zone-open ?w ?c ?t))
        )
    )
    :effect
    (and
        (free ?w)
        (not (working-on ?w ?c))
        (command-complete ?c)
    )
)
)