;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: warehouse_job_1
;;
;; Description:
;; This problem represents a warehouse operation involving two incoming
;; palettes:
;;
;;   1. pal_mono  : A standard mono-product palette.
;;   2. pal_mixed : A mixed palette containing different product types.
;;
;; The mono palette follows the normal warehouse workflow:
;;
;;     Unload
;;         ↓
;;     Storage
;;         ↓
;;     Preparation
;;         ↓
;;     Control
;;         ↓
;;     Loading
;;
;; The mixed palette requires an additional processing step:
;;
;;     Unload
;;         ↓
;;     Split Mixed Palette
;;         ↓
;;     Create v_pal1 and v_pal2
;;         ↓
;;     Storage
;;         ↓
;;     Preparation
;;         ↓
;;     Control
;;         ↓
;;     Loading
;;
;; Goal:
;;   - Ship the mono palette.
;;   - Process (split) the mixed palette.
;;   - Ship both resulting standard palettes.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem warehouse_job_1)

    (:domain Project_TER)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;
    ;; LOCATIONS
    ;;
    ;; truck_dock      : Incoming truck unloading area.
    ;; arrival_zone    : Receiving area where packages enter the system.
    ;; rack_storage    : Warehouse storage location.
    ;; prep_zone       : Order preparation area.
    ;; control_zone    : Inspection and quality-control area.
    ;; shipping_dock   : Outgoing shipping location.
    ;;
    ;; WORKER
    ;;
    ;; cariste1        : Warehouse worker responsible for moving palettes.
    ;;
    ;; PACKAGES
    ;;
    ;; pal_mono        : Mono-product palette.
    ;; pal_mixed       : Mixed palette requiring splitting.
    ;;
    ;; STANDARD PALETTES
    ;;
    ;; v_pal1, v_pal2  : Palettes generated after splitting pal_mixed.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:objects

        ;; Warehouse locations
        truck_dock
        arrival_zone
        rack_storage
        prep_zone
        control_zone
        shipping_dock - loc

        ;; Worker
        cariste1 - worker

        ;; Incoming mono palette
        pal_mono - mono

        ;; Incoming mixed palette
        pal_mixed - mixed

        ;; Standard palettes produced after splitting
        v_pal1
        v_pal2 - standard
    )

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL WORKER POSITION
        ;;
        ;; The worker starts at the truck dock where incoming
        ;; palettes are located.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at cariste1 truck_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WAREHOUSE CONNECTIONS
        ;;
        ;; Locations are connected in both directions to allow:
        ;;   - Transporting palettes forward through the workflow.
        ;;   - Returning to previous locations when necessary.
        ;;
        ;; Warehouse Layout:
        ;;
        ;; truck_dock
        ;;      |
        ;; arrival_zone
        ;;      |
        ;; rack_storage
        ;;      |
        ;; prep_zone
        ;;      |
        ;; control_zone
        ;;      |
        ;; shipping_dock
        ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (connected truck_dock arrival_zone)
        (connected arrival_zone truck_dock)

        (connected arrival_zone rack_storage)
        (connected rack_storage arrival_zone)

        (connected rack_storage prep_zone)
        (connected prep_zone rack_storage)

        (connected prep_zone control_zone)
        (connected control_zone prep_zone)

        (connected control_zone shipping_dock)
        (connected shipping_dock control_zone)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; ZONE DEFINITIONS
        ;;
        ;; Assign operational roles to each warehouse location.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_arrival_zone arrival_zone)

        (is_storage_zone rack_storage)

        (is_prep_zone prep_zone)

        (is_control_zone control_zone)

        (is_shipping_dock shipping_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL PACKAGE POSITIONS
        ;;
        ;; Both palettes start at the incoming truck dock and have
        ;; not yet entered the warehouse workflow.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (on pal_mono truck_dock)

        (on pal_mixed truck_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PACKAGE CLASSIFICATION
        ;;
        ;; Marks pal_mixed as a mixed palette.
        ;; This palette must be split before storage.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_mixed pal_mixed)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;
    ;; Success Conditions:
    ;;
    ;; 1. The mono palette must be fully processed and loaded.
    ;; 2. The mixed palette must have been processed (split).
    ;; 3. The resulting standard palettes must be loaded.
    ;;
    ;; This ensures that all incoming goods have completed the
    ;; warehouse workflow and are ready for shipment.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and

            ;; Mono palette shipped
            (loaded pal_mono)

            ;; Mixed palette processed
            (processed pal_mixed)

            ;; Generated standard palettes shipped
            (loaded v_pal1)
            (loaded v_pal2)
        )
    )
)