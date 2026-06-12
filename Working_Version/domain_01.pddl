;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN: warehouse (Fully Documented Standard Version)
;;
;; Purpose:
;; This domain models a warehouse picking system where:
;;   - Workers execute commands (orders)
;;   - Products must be picked by type and location
;;   - Zone-based scanning controls workflow progression
;;   - Each order must pass per-type checkpoints before completion
;;
;; Workflow:
;;   Start Mission → Print Label → Move → Scan Zone →
;;   Pick Items → Verify Checkpoints → Finalize Order
;;
;; Key Concepts:
;;   - Commands represent customer orders
;;   - Products are assigned and picked per order
;;   - Each product type requires zone validation
;;   - Workers must not move with open picking zones
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain warehouse)

    (:requirements
        :strips
        :typing
        :negative-preconditions
        :universal-preconditions
        :quantified-preconditions
        :disjunctive-preconditions
    )

    (:types
        product
        product-type
        command
        worker
        location
    )

    (:predicates

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WORKER LOCATION AND STATE
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at ?w - worker ?l - location)                 ;; Worker position in warehouse
        (free ?w - worker)                             ;; Worker is not assigned to a command
        (working-on ?w - worker ?c - command)          ;; Worker is actively executing a command

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; COMMAND STATE
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (mission-started ?c - command)                 ;; Command has been activated
        (command-complete ?c - command)                ;; Command fully completed

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INVENTORY AND ASSIGNMENT
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (in-inventory ?p - product)                    ;; Product is still available in stock
        (assigned ?p - product ?c - command)           ;; Product assigned to a command

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; LOCATION STRUCTURE
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (start-loc ?l - location)                      ;; Starting/control location for workers
        (type-zone ?t - product-type ?l - location)    ;; Location corresponds to product-type zone

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PRODUCT INFORMATION
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is-type ?p - product ?t - product-type)       ;; Product belongs to a type
        (at-loc ?p - product ?l - location)            ;; Product is physically at a location

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; COMMAND REQUIREMENTS
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (requires-type ?c - command ?t - product-type) ;; Order requires product type
        (required-product ?c - command ?p - product)    ;; Specific product required by command

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; ZONE CONTROL / WORKFLOW TRACKING
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (zone-open ?w - worker ?c - command ?t - product-type)
                                                      ;; Worker has an active picking session for a type

        (checkpoint-verified ?t - product-type ?c - command)
                                                      ;; All required checks completed for a type

        (order-label-printed ?c - command)             ;; Order label has been printed
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: New-mission-PDA-and-print-order-label
    ;;
    ;; Purpose:
    ;;     Initialize a command and assign it to a worker.
    ;;
    ;; Preconditions:
    ;;     - Worker must be free
    ;;     - Worker must be at a start location
    ;;     - Command must not already be started
    ;;
    ;; Effects:
    ;;     - Worker becomes assigned to command
    ;;     - Command is marked as started
    ;;     - Worker is no longer free
    ;;
    ;; Workflow Stage:
    ;;     Mission initialization / dispatch
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action New-mission-PDA-and-print-order-label

        :parameters (?w - worker ?c - command ?l - location)

        :precondition
        (and
            (free ?w)
            (at ?w ?l)
            (start-loc ?l)
            (not (mission-started ?c))
        )

        :effect
        (and
            (not (free ?w))
            (working-on ?w ?c)
            (mission-started ?c)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: Print-order-label
    ;;
    ;; Purpose:
    ;;     Generate and attach order label for tracking.
    ;;
    ;; Preconditions:
    ;;     - Worker is assigned to command
    ;;     - Label has not yet been printed
    ;;
    ;; Effects:
    ;;     - Order label becomes available
    ;;
    ;; Workflow Stage:
    ;;     Order preparation / identification
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action Print-order-label

        :parameters (?w - worker ?c - command)

        :precondition
        (and
            (working-on ?w ?c)
            (not (order-label-printed ?c))
        )

        :effect
        (order-label-printed ?c)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: move
    ;;
    ;; Purpose:
    ;;     Move worker between locations while ensuring safe workflow.
    ;;
    ;; Preconditions:
    ;;     - Worker is assigned to a command
    ;;     - Worker is at origin location
    ;;     - No active zone sessions exist
    ;;
    ;; Effects:
    ;;     - Worker changes location
    ;;
    ;; Constraint:
    ;;     - Worker cannot leave a zone while a picking session is open
    ;;
    ;; Workflow Stage:
    ;;     Navigation / warehouse traversal
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action move

        :parameters (?w - worker ?c - command ?from - location ?to - location)

        :precondition
        (and
            (working-on ?w ?c)
            (at ?w ?from)

            ;; ensure no open zone sessions
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

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: Scan-item-type
    ;;
    ;; Purpose:
    ;;     Open a picking session for a product type in a zone.
    ;;
    ;; Preconditions:
    ;;     - Worker is in correct zone location
    ;;     - Location corresponds to product type zone
    ;;     - No existing open session for this type
    ;;
    ;; Effects:
    ;;     - Zone session becomes active
    ;;
    ;; Workflow Stage:
    ;;     Zone validation / picking setup
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action Scan-item-type

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

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: add-to-order
    ;;
    ;; Purpose:
    ;;     Pick a product and assign it to a command.
    ;;
    ;; Preconditions:
    ;;     - Worker is in active picking session
    ;;     - Product is at worker location
    ;;     - Product matches required type
    ;;     - Product is still in inventory
    ;;
    ;; Effects:
    ;;     - Product is removed from inventory
    ;;     - Product is assigned to command
    ;;
    ;; Workflow Stage:
    ;;     Picking / order fulfillment
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action add-to-order

        :parameters (?w - worker ?c - command ?p - product ?t - product-type ?l - location)

        :precondition
        (and
            (working-on ?w ?c)
            (at ?w ?l)
            (at-loc ?p ?l)
            (is-type ?p ?t)
            (zone-open ?w ?c ?t)
            (in-inventory ?p)
        )

        :effect
        (and
            (not (in-inventory ?p))
            (assigned ?p ?c)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: Scan-order-label
    ;;
    ;; Purpose:
    ;;     Verify completion of all required products in a zone.
    ;;
    ;; Preconditions:
    ;;     - Worker is in correct zone
    ;;     - Zone session is active
    ;;     - All required products are assigned
    ;;
    ;; Effects:
    ;;     - Zone is marked as completed
    ;;     - Picking session is closed
    ;;
    ;; Workflow Stage:
    ;;     Checkpoint validation
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action Scan-order-label

        :parameters (?w - worker ?c - command ?t - product-type ?l - location)

        :precondition
        (and
            (working-on ?w ?c)
            (at ?w ?l)
            (type-zone ?t ?l)
            (zone-open ?w ?c ?t)

            ;; ensure all required products are assigned
            (forall (?p - product)
                (imply
                    (required-product ?c ?p)
                    (assigned ?p ?c)
                )
            )
        )

        :effect
        (and
            (not (zone-open ?w ?c ?t))
            (checkpoint-verified ?t ?c)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: finish-command-print-label-scan-finished-codebar-and-leave-in-controlzone
    ;;
    ;; Purpose:
    ;;     Finalize a command after all zones are validated.
    ;;
    ;; Preconditions:
    ;;     - Worker is assigned to command
    ;;     - All required product-type checkpoints are verified
    ;;     - No zone sessions are open
    ;;
    ;; Effects:
    ;;     - Worker becomes free
    ;;     - Command is completed
    ;;
    ;; Workflow Stage:
    ;;     Order completion / checkout
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action finish-command-print-label-scan-finished-codebar-and-leave-in-controlzone

        :parameters (?w - worker ?c - command)

        :precondition
        (and
            (working-on ?w ?c)

            ;; all required types checked
            (forall (?t - product-type)
                (imply
                    (requires-type ?c ?t)
                    (checkpoint-verified ?t ?c)
                )
            )

            ;; no active picking sessions
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