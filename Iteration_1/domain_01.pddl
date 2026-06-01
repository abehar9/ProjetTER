;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN: Project_TER
;;
;; Description:
;; This domain models a warehouse/logistics terminal where packages are
;; processed through several stages before being shipped.
;;
;; A worker moves packages between specialized zones in the warehouse.
;;
;; Package workflow:
;;
;;     Unload -> Storage -> Preparation -> Control -> Shipping
;;
;; Each stage updates the package status and ensures that operations occur
;; in the correct order.
;;
;; Main actors:
;;   - Worker  : moves packages between locations
;;   - Package : item being processed
;;   - Location: warehouse zones and transit points
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain Project_TER)

    (:requirements :strips :typing :negative-preconditions)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; TYPES
    ;;
    ;; loc     : Any warehouse location.
    ;; package : Goods moving through the warehouse process.
    ;; worker  : Employee responsible for moving packages.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:types
        loc package worker - object
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PREDICATES
    ;;
    ;; LOCATION PREDICATES
    ;;
    ;; (on package location)
    ;;     Indicates where a package is currently located.
    ;;
    ;; (at worker location)
    ;;     Indicates the current location of a worker.
    ;;
    ;; STATUS PREDICATES
    ;;
    ;; (arrived package)
    ;;     Package has been unloaded and registered in the system.
    ;;
    ;; (prepared package)
    ;;     Package has been prepared for shipment.
    ;;
    ;; (controlled package)
    ;;     Package has passed the inspection/control phase.
    ;;
    ;; (loaded package)
    ;;     Package has been loaded onto the shipping dock.
    ;;
    ;; CONNECTIVITY PREDICATE
    ;;
    ;; (connected location1 location2)
    ;;     A worker can move directly between these locations.
    ;;
    ;; ZONE TYPE PREDICATES
    ;;
    ;; These predicates define the purpose of each warehouse location.
    ;;
    ;; (is_arrival_zone location)
    ;; (is_storage_zone location)
    ;; (is_prep_zone location)
    ;; (is_control_zone location)
    ;; (is_shipping_dock location)
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:predicates

        ;; Package position
        (on ?y - package ?l - loc)

        ;; Worker position
        (at ?w - worker ?l - loc)

        ;; Package processing status
        (arrived ?y - package)
        (prepared ?y - package)
        (controlled ?y - package)
        (loaded ?y - package)

        ;; Location connectivity
        (connected ?l1 - loc ?l2 - loc)

        ;; Zone definitions
        (is_arrival_zone ?l - loc)
        (is_storage_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: worker_travel
    ;;
    ;; Purpose:
    ;;     Move a worker from one location to another.
    ;;
    ;; Preconditions:
    ;;     - Worker must be at the starting location.
    ;;     - The two locations must be connected.
    ;;
    ;; Effects:
    ;;     - Worker leaves the starting location.
    ;;     - Worker arrives at the destination.
    ;;
    ;; Example:
    ;;     A worker travels from the storage area to the preparation area.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action worker_travel
        :parameters (?w - worker ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (at ?w ?from))
                (at ?w ?to)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: unload
    ;;
    ;; Purpose:
    ;;     Receive a package and place it into an arrival zone.
    ;;
    ;; Preconditions:
    ;;     - Worker and package are at the same location.
    ;;     - Package has not yet been marked as arrived.
    ;;     - Destination must be an arrival zone.
    ;;     - Locations must be connected.
    ;;
    ;; Effects:
    ;;     - Package is moved to the arrival zone.
    ;;     - Worker moves with the package.
    ;;     - Package becomes officially arrived.
    ;;
    ;; Workflow Stage:
    ;;     Step 1 of the process.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action unload
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (not (arrived ?y))

                (is_arrival_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (arrived ?y)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: stockage
    ;;
    ;; Purpose:
    ;;     Move an arrived package into a storage zone.
    ;;
    ;; Preconditions:
    ;;     - Package has already arrived.
    ;;     - Package has not yet been prepared.
    ;;     - Destination must be a storage zone.
    ;;     - Locations must be connected.
    ;;
    ;; Effects:
    ;;     - Package is transferred to storage.
    ;;     - Worker moves with the package.
    ;;
    ;; Workflow Stage:
    ;;     Step 2 of the process.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action stockage
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (arrived ?y)
                (not (prepared ?y))

                (is_storage_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: prepare_command
    ;;
    ;; Purpose:
    ;;     Prepare a package before inspection and shipment.
    ;;
    ;; Preconditions:
    ;;     - Worker and package are together.
    ;;     - Package has not already been controlled.
    ;;     - Destination must be a preparation zone.
    ;;     - Locations must be connected.
    ;;
    ;; Effects:
    ;;     - Package is moved to preparation area.
    ;;     - Worker moves with package.
    ;;     - Package is marked as prepared.
    ;;
    ;; Workflow Stage:
    ;;     Step 3 of the process.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action prepare_command
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (not (controlled ?y))

                (is_prep_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (prepared ?y)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: control_check
    ;;
    ;; Purpose:
    ;;     Perform inspection and quality control on a prepared package.
    ;;
    ;; Preconditions:
    ;;     - Package must be prepared.
    ;;     - Package must not already be loaded.
    ;;     - Destination must be a control zone.
    ;;     - Locations must be connected.
    ;;
    ;; Effects:
    ;;     - Package is moved to the control area.
    ;;     - Worker moves with package.
    ;;     - Package is marked as controlled.
    ;;
    ;; Workflow Stage:
    ;;     Step 4 of the process.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action control_check
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (prepared ?y)
                (not (loaded ?y))

                (is_control_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (controlled ?y)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: load_truck
    ;;
    ;; Purpose:
    ;;     Load a validated package onto the shipping dock.
    ;;
    ;; Preconditions:
    ;;     - Package must have passed control.
    ;;     - Destination must be a shipping dock.
    ;;     - Locations must be connected.
    ;;
    ;; Effects:
    ;;     - Package is moved to the shipping dock.
    ;;     - Worker moves with package.
    ;;     - Package is marked as loaded.
    ;;
    ;; Workflow Stage:
    ;;     Step 5 (final step) of the process.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action load_truck
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (controlled ?y)

                (is_shipping_dock ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (loaded ?y)
            )
    )
)