;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: test_broken_path
;;
;; Description:
;; This problem is designed to test warehouse connectivity constraints.
;;
;; Unlike the normal warehouse scenarios, the route between the storage
;; area and the preparation area is intentionally missing.
;;
;; As a result, the package cannot complete the full warehouse workflow
;; required to reach the shipping stage.
;;
;; Purpose:
;;   - Validate that the planner correctly detects unreachable goals.
;;   - Verify that connectivity predicates are required for package
;;     movement between warehouse zones.
;;   - Demonstrate a planning problem with no valid solution.
;;
;; Expected Result:
;;   The planner should report that no plan exists because the package
;;   cannot move beyond the storage area.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem test_broken_path)

    (:domain Project_TER)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;
    ;; LOCATIONS
    ;;
    ;; truck_dock      : Incoming truck area.
    ;; arrival_zone    : Receiving area.
    ;; rack_storage    : Storage location.
    ;; prep_zone       : Preparation area.
    ;; shipping_dock   : Shipping location.
    ;;
    ;; WORKER
    ;;
    ;; cariste1        : Warehouse employee.
    ;;
    ;; PACKAGES
    ;;
    ;; pal_mono        : Mono-product palette that must be shipped.
    ;;
    ;; dummy_mix       : Unused mixed palette included only as an object.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:objects

        ;; Warehouse locations
        truck_dock
        arrival_zone
        rack_storage
        prep_zone
        shipping_dock - loc

        ;; Worker
        cariste1 - worker

        ;; Unused mixed palette
        dummy_mix - mixed

        ;; Package to process
        pal_mono - mono
    )

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL WORKER POSITION
        ;;
        ;; The worker begins at the truck dock.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at cariste1 truck_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WAREHOUSE CONNECTIVITY
        ;;
        ;; Existing Connections:
        ;;
        ;; truck_dock <-> arrival_zone
        ;; arrival_zone <-> rack_storage
        ;;
        ;; Missing Connection:
        ;;
        ;; rack_storage <-> prep_zone
        ;;
        ;; Because this connection does not exist, packages cannot
        ;; continue through preparation, control, and loading stages.
        ;;
        ;; Warehouse Layout:
        ;;
        ;; truck_dock
        ;;      |
        ;; arrival_zone
        ;;      |
        ;; rack_storage
        ;;
        ;; prep_zone       (unreachable)
        ;; shipping_dock   (unreachable)
        ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (connected truck_dock arrival_zone)
        (connected arrival_zone truck_dock)

        (connected arrival_zone rack_storage)
        (connected rack_storage arrival_zone)

        ;; Intentionally omitted:
        ;; (connected rack_storage prep_zone)
        ;; (connected prep_zone rack_storage)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; ZONE DEFINITIONS
        ;;
        ;; Only the available warehouse zones are defined.
        ;;
        ;; Note:
        ;; No preparation zone or control zone role is provided,
        ;; making completion of the workflow impossible.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_arrival_zone arrival_zone)

        (is_storage_zone rack_storage)

        (is_shipping_dock shipping_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL PACKAGE LOCATION
        ;;
        ;; The mono palette begins at the incoming truck.
        ;;
        ;; It must normally pass through:
        ;;
        ;; Unload -> Storage -> Preparation -> Control -> Loading
        ;;
        ;; However, the workflow cannot be completed because the
        ;; required path is broken.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (on pal_mono truck_dock)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;
    ;; Goal:
    ;;     Load the mono palette for shipment.
    ;;
    ;; Expected Planner Outcome:
    ;;     No solution exists.
    ;;
    ;; Reason:
    ;;     The package cannot reach the preparation stage due to the
    ;;     missing warehouse connection.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and
            (loaded pal_mono)
        )
    )
)