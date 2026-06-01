;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: multi_staff_warehouse
;;
;; Description:
;; This problem models a warehouse operation involving multiple workers
;; and different types of incoming cargo.
;;
;; Unlike previous scenarios, two workers are available and start at
;; different locations in the warehouse. This allows tasks to be shared
;; between employees and may reduce overall processing time.
;;
;; Incoming Cargo:
;;
;;   1. pal_mono
;;      - Mono-product palette.
;;      - Must complete the full workflow.
;;
;;   2. pal_mixed
;;      - Mixed palette.
;;      - Must be split into two standard palettes before processing.
;;
;;   3. pal_standard_direct
;;      - Standard palette already located in the arrival zone.
;;      - Already marked as arrived.
;;      - Does not require unloading.
;;
;; Standard Workflow:
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
;; Mixed Palette Workflow:
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
;;   - All cargo must be processed and loaded.
;;   - The mixed palette must be successfully split.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem multi_staff_warehouse)

    (:domain Project_TER)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;
    ;; LOCATIONS
    ;;
    ;; truck_dock      : Incoming truck unloading area.
    ;; arrival_zone    : Receiving area where packages enter the workflow.
    ;; rack_storage    : Storage location.
    ;; prep_zone       : Preparation area.
    ;; control_zone    : Inspection and quality-control area.
    ;; shipping_dock   : Outgoing shipping area.
    ;;
    ;; WORKERS
    ;;
    ;; cariste1        : Worker starting at the incoming truck.
    ;; cariste2        : Worker starting near shipping operations.
    ;;
    ;; PACKAGES
    ;;
    ;; pal_mono            : Mono-product palette.
    ;; pal_mixed           : Mixed palette requiring splitting.
    ;; pal_standard_direct : Standard palette already at arrival zone.
    ;;
    ;; GENERATED PACKAGES
    ;;
    ;; v_pal1, v_pal2 : Standard palettes created after splitting
    ;;                  the mixed palette.
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

        ;; Workers
        cariste1
        cariste2 - worker

        ;; Incoming mono palette
        pal_mono - mono

        ;; Incoming mixed palette
        pal_mixed - mixed

        ;; Standard palettes created after splitting
        v_pal1
        v_pal2 - standard

        ;; Standard palette already in the warehouse
        pal_standard_direct - standard
    )

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL WORKER POSITIONS
        ;;
        ;; Workers begin at different locations:
        ;;
        ;; cariste1 starts at the receiving side of the warehouse.
        ;; cariste2 starts at the shipping side of the warehouse.
        ;;
        ;; This setup allows work to be distributed between employees.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at cariste1 truck_dock)
        (at cariste2 shipping_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WAREHOUSE CONNECTIVITY
        ;;
        ;; All locations are connected in both directions.
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
        ;; Assigns warehouse functions to each location.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_arrival_zone arrival_zone)

        (is_storage_zone rack_storage)

        (is_prep_zone prep_zone)

        (is_control_zone control_zone)

        (is_shipping_dock shipping_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL PACKAGE POSITIONS
        ;;
        ;; pal_mono and pal_mixed are still in the truck and
        ;; must first be unloaded.
        ;;
        ;; pal_standard_direct is already located in the arrival
        ;; zone and can immediately continue through the workflow.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (on pal_mono truck_dock)

        (on pal_mixed truck_dock)

        (on pal_standard_direct arrival_zone)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PACKAGE CLASSIFICATION
        ;;
        ;; pal_mixed is identified as a mixed palette.
        ;; It must be split before storage.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_mixed pal_mixed)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL PROCESSING STATUS
        ;;
        ;; pal_standard_direct has already been unloaded and
        ;; registered in the warehouse system.
        ;;
        ;; Therefore it already possesses the arrived status.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (arrived pal_standard_direct)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;
    ;; Success Conditions:
    ;;
    ;; 1. pal_mono must be loaded.
    ;; 2. pal_standard_direct must be loaded.
    ;; 3. pal_mixed must have been processed (split).
    ;; 4. v_pal1 must be loaded.
    ;; 5. v_pal2 must be loaded.
    ;;
    ;; This ensures that all incoming cargo has completed the
    ;; warehouse workflow and is ready for shipment.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and

            ;; Mono palette shipped
            (loaded pal_mono)

            ;; Standard palette shipped
            (loaded pal_standard_direct)

            ;; Mixed palette processed
            (processed pal_mixed)

            ;; Generated palettes shipped
            (loaded v_pal1)
            (loaded v_pal2)
        )
    )
)