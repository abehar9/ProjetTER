;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN: Project_TER (Forklift-Based Warehouse System)
;;
;; Purpose:
;; This domain models a warehouse system where a worker uses a forklift
;; (fenwick) to transport and process packages through a structured pipeline.
;;
;; Key features:
;;   - Forklift-based movement (mounted worker system)
;;   - Package scanning for traceability
;;   - Mixed packages contain two items
;;   - Mono Packages contain one item
;;   - Mixed package sorting into new pallets
;;   - Multi-step processing workflow
;;   - Cost-based optimization
;;
;; Workflow:
;;   Arrival → Sorting → Storage → Preparation → Control → Shipping
;;
;; Important rule:
;;   Mixed packages must be unpacked and redistributed into new pallets
;;   before they can follow the normal workflow.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain Project_TER)

    (:requirements
        :strips
        :typing
        :action-costs
        :disjunctive-preconditions
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; TYPES
    ;;
    ;; loc:
    ;;     Warehouse locations (zones and docks)
    ;;
    ;; worker:
    ;;     Human operator controlling forklift operations
    ;;
    ;; fenwick:
    ;;     Forklift vehicle used for transportation
    ;;
    ;; package:
    ;;     Physical goods moving through the warehouse
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:types
        loc worker fenwick package
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PREDICATES
    ;;
    ;; POSITIONING
    ;;
    ;; (at ?obj ?l)
    ;;     Object (worker, forklift, or package) is at location
    ;;
    ;; (connected ?l1 ?l2)
    ;;     Two locations are directly connected
    ;;
    ;;
    ;; FORKLIFT STATE
    ;;
    ;; (worker_mounted ?w ?v)
    ;;     Worker is operating a forklift
    ;;
    ;; (carrying ?v ?p)
    ;;     Forklift is carrying a package
    ;;
    ;; (forklift_empty ?v)
    ;;     Forklift is not carrying anything
    ;;
    ;;
    ;; PACKAGE TYPE
    ;;
    ;; (is_mono ?p)
    ;;     Package is a standard single unit
    ;;
    ;; (is_mixed ?p)
    ;;     Package contains multiple items
    ;;
    ;; (contains ?p ?item)
    ;;     Package contains an item
    ;;
    ;; (empty ?p)
    ;;     Package is empty (used for building new pallets)
    ;;
    ;;
    ;; TRACEABILITY & STATUS
    ;;
    ;; (product_scanned ?p)
    ;;     Package has been scanned
    ;;
    ;; (prepared ?p)
    ;;     Package is ready for inspection
    ;;
    ;; (controlled ?p)
    ;;     Package passed quality control
    ;;
    ;; (loaded ?p)
    ;;     Package has been shipped
    ;;
    ;;
    ;; ZONES
    ;;
    ;; (is_truck ?l)
    ;; (is_arrival_zone ?l)
    ;; (is_prep_zone ?l)
    ;; (is_control_zone ?l)
    ;; (is_shipping_dock ?l)
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:predicates
        (at ?obj - object ?l - loc)
        (connected ?l1 - loc ?l2 - loc)

        (worker_mounted ?w - worker ?v - fenwick)
        (carrying ?v - fenwick ?p - package)
        (forklift_empty ?v - fenwick)

        (is_mono ?p - package)
        (is_mixed ?p - package)
        (contains ?p - package ?item - object)
        (empty ?p - package)

        (product_scanned ?p - package)
        (prepared ?p - package)
        (controlled ?p - package)
        (loaded ?p - package)

        (is_truck ?l - loc)
        (is_arrival_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
    )

    (:functions
        (total-cost)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mount_fenwick
    ;;
    ;; Purpose:
    ;;     Worker mounts the forklift to begin vehicle operations.
    ;;
    ;; Preconditions:
    ;;     - Worker and forklift are at same location
    ;;
    ;; Effects:
    ;;     - Worker becomes mounted on forklift
    ;;     - Cost increases
    ;;
    ;; Workflow Stage:
    ;;     Vehicle activation
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mount_fenwick
        :parameters (?w - worker ?v - fenwick ?l - loc)
        :precondition (and (at ?w ?l) (at ?v ?l))
        :effect (and
            (not (at ?w ?l))
            (worker_mounted ?w ?v)
            (increase (total-cost) 5)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: dismount_fenwick
    ;;
    ;; Purpose:
    ;;     Worker leaves the forklift.
    ;;
    ;; Preconditions:
    ;;     - Worker is mounted on forklift
    ;;     - Forklift is at a location
    ;;
    ;; Effects:
    ;;     - Worker returns to ground movement
    ;;     - Cost increases
    ;;
    ;; Workflow Stage:
    ;;     Vehicle deactivation
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action dismount_fenwick
        :parameters (?w - worker ?v - fenwick ?l - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?l))
        :effect (and
            (at ?w ?l)
            (not (worker_mounted ?w ?v))
            (increase (total-cost) 5)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: drive_fenwick
    ;;
    ;; Purpose:
    ;;     Move forklift between connected warehouse locations.
    ;;
    ;; Preconditions:
    ;;     - Worker is mounted on forklift
    ;;     - Forklift is at starting location
    ;;     - Locations are connected
    ;;
    ;; Effects:
    ;;     - Forklift moves to new location
    ;;     - Cost increases
    ;;
    ;; Workflow Stage:
    ;;     Transport
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action drive_fenwick
        :parameters (?w - worker ?v - fenwick ?from - loc ?to - loc)
        :precondition (and
            (worker_mounted ?w ?v)
            (at ?v ?from)
            (connected ?from ?to)
        )
        :effect (and
            (not (at ?v ?from))
            (at ?v ?to)
            (increase (total-cost) 20)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: load_forklift
    ;;
    ;; Purpose:
    ;;     Load a package onto the forklift.
    ;;
    ;; Preconditions:
    ;;     - Worker is mounted
    ;;     - Package is at same location
    ;;     - Forklift is empty
    ;;
    ;; Effects:
    ;;     - Package is loaded onto forklift
    ;;     - Forklift becomes occupied
    ;;
    ;; Workflow Stage:
    ;;     Loading
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action load_forklift
        :parameters (?w - worker ?v - fenwick ?p - package ?l - loc)
        :precondition (and
            (worker_mounted ?w ?v)
            (at ?v ?l)
            (at ?p ?l)
            (forklift_empty ?v)
        )
        :effect (and
            (not (at ?p ?l))
            (carrying ?v ?p)
            (not (forklift_empty ?v))
            (increase (total-cost) 5)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: unload_forklift
    ;;
    ;; Purpose:
    ;;     Remove a package from forklift at destination.
    ;;
    ;; Preconditions:
    ;;     - Worker is mounted
    ;;     - Forklift is carrying a package
    ;;
    ;; Effects:
    ;;     - Package is placed at location
    ;;     - Forklift becomes empty
    ;;
    ;; Workflow Stage:
    ;;     Unloading
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action unload_forklift
        :parameters (?w - worker ?v - fenwick ?p - package ?l - loc)
        :precondition (and
            (worker_mounted ?w ?v)
            (at ?v ?l)
            (carrying ?v ?p)
        )
        :effect (and
            (at ?p ?l)
            (not (carrying ?v ?p))
            (forklift_empty ?v)
            (increase (total-cost) 5)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: scan_product
    ;;
    ;; Purpose:
    ;;     Record a traceability scan for a package.
    ;;
    ;; Preconditions:
    ;;     - Package is at location
    ;;     - Worker or forklift is present
    ;;
    ;; Effects:
    ;;     - Package is marked as scanned
    ;;
    ;; Workflow Stage:
    ;;     Traceability
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action scan_product
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and
            (at ?p ?l)
            (or
                (at ?w ?l)
                (exists (?v - fenwick)
                    (and (worker_mounted ?w ?v) (at ?v ?l))
                )
            )
        )
        :effect (and
            (product_scanned ?p)
            (increase (total-cost) 1)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: sort_into_new_palette
    ;;
    ;; Purpose:
    ;;     Convert mixed package contents into new mono/standard pallets.
    ;;
    ;; Preconditions:
    ;;     - Mixed package is at arrival zone
    ;;     - Target pallet is empty
    ;;
    ;; Effects:
    ;;     - Item is removed from mixed package
    ;;     - New pallet is created/filled
    ;;
    ;; Workflow Stage:
    ;;     Sorting / decomposition
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action sort_into_new_palette
        :parameters (?w - worker ?mixed_pal - package ?item - object ?target_pal - package ?l - loc)
        :precondition (and
            (at ?w ?l)
            (at ?mixed_pal ?l)
            (at ?target_pal ?l)
            (is_mixed ?mixed_pal)
            (contains ?mixed_pal ?item)
            (empty ?target_pal)
            (is_arrival_zone ?l)
        )
        :effect (and
            (not (contains ?mixed_pal ?item))
            (not (empty ?target_pal))
            (is_mono ?target_pal)
            (increase (total-cost) 15)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mark_prepared
    ;;
    ;; Purpose:
    ;;     Mark package as ready for inspection.
    ;;
    ;; Preconditions:
    ;;     - Package is mono type
    ;;     - Package is at prep zone
    ;;     - Package has been scanned
    ;;
    ;; Effects:
    ;;     - Package becomes prepared
    ;;
    ;; Workflow Stage:
    ;;     Preparation
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mark_prepared
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and
            (at ?p ?l)
            (product_scanned ?p)
            (is_mono ?p)
            (is_prep_zone ?l)
            (or
                (at ?w ?l)
                (exists (?v - fenwick)
                    (and (worker_mounted ?w ?v) (at ?v ?l))
                )
            )
        )
        :effect (and
            (prepared ?p)
            (increase (total-cost) 2)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mark_controlled
    ;;
    ;; Purpose:
    ;;     Quality inspection approval step.
    ;;
    ;; Preconditions:
    ;;     - Package is prepared
    ;;     - Package is at control zone
    ;;
    ;; Effects:
    ;;     - Package is marked as controlled
    ;;
    ;; Workflow Stage:
    ;;     Quality control
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mark_controlled
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and
            (at ?p ?l)
            (prepared ?p)
            (is_control_zone ?l)
            (or
                (at ?w ?l)
                (exists (?v - fenwick)
                    (and (worker_mounted ?w ?v) (at ?v ?l))
                )
            )
        )
        :effect (and
            (controlled ?p)
            (increase (total-cost) 2)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mark_loaded
    ;;
    ;; Purpose:
    ;;     Final shipping step for a package.
    ;;
    ;; Preconditions:
    ;;     - Package is controlled
    ;;     - Package is at shipping dock
    ;;
    ;; Effects:
    ;;     - Package is marked as loaded (shipped)
    ;;
    ;; Workflow Stage:
    ;;     Final delivery
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mark_loaded
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and
            (at ?p ?l)
            (controlled ?p)
            (is_shipping_dock ?l)
            (or
                (at ?w ?l)
                (exists (?v - fenwick)
                    (and (worker_mounted ?w ?v) (at ?v ?l))
                )
            )
        )
        :effect (and
            (loaded ?p)
            (increase (total-cost) 2)
        )
    )
)