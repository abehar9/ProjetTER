;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: warehouse_v5
;;
;; Purpose:
;; This problem models a warehouse logistics system using:
;;   - A worker (cariste1)
;;   - A vehicle (fenwick1)
;;   - Standard and mixed packages
;;
;; The system enforces a full delivery pipeline:
;;   Arrival → Storage → Preparation → Control → Shipping
;;
;; Key rules:
;;   - Mixed packages must be processed (split requirement in domain)
;;   - All deliveries must be completed successfully
;;   - Total cost is minimized
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem fenwick_test)

    (:domain Project_TER)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;
    ;; LOCATIONS:
    ;;   truck_dock     : Entry point for incoming goods
    ;;   arrival_zone   : Unloading / receiving area
    ;;   rack_storage   : Storage zone
    ;;   prep_zone      : Preparation area
    ;;   control_zone   : Quality control / inspection area
    ;;   shipping_dock  : Final shipping location
    ;;
    ;; WORKER:
    ;;   cariste1       : Warehouse operator
    ;;
    ;; VEHICLE:
    ;;   fenwick1       : Forklift-style transport vehicle
    ;;
    ;; PACKAGES:
    ;;   pal_mono       : Standard package
    ;;   pal_mixed      : Mixed package requiring processing
    ;;   v1, v2         : Standard packages (results of processing)
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:objects
        truck_dock
        arrival_zone
        rack_storage
        prep_zone
        control_zone
        shipping_dock - loc

        cariste1 - worker

        fenwick1 - fenwick

        pal_mono - mono

        pal_mixed - mixed

        v1 v2 - standard
    )

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL STATE
        ;;
        ;; Worker and vehicle start at arrival zone.
        ;; Packages are initially located in the truck dock.
        ;;
        ;; This forces the planner to begin by transporting goods.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at cariste1 arrival_zone)
        (at fenwick1 arrival_zone)

        (at pal_mono truck_dock)
        (at pal_mixed truck_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WAREHOUSE CONNECTIONS
        ;;
        ;; Defines bidirectional movement paths between zones.
        ;; These paths allow forward progression and return movement.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; ZONE DEFINITIONS
        ;;
        ;; Assigns roles to each location in the workflow.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_truck truck_dock)
        (is_arrival_zone arrival_zone)
        (is_prep_zone prep_zone)
        (is_control_zone control_zone)
        (is_shipping_dock shipping_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PACKAGE CLASSIFICATION
        ;;
        ;; Identifies pal_mixed as a mixed package requiring processing.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_mixed pal_mixed)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; COST INITIALIZATION
        ;;
        ;; Total cost starts at zero and increases with actions.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (= (total-cost) 0)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;
    ;; The system is complete when:
    ;;
    ;; 1. pal_mono is successfully loaded
    ;; 2. v1 and v2 (processed outputs) are loaded
    ;; 3. pal_mixed has been processed (split requirement satisfied)
    ;;
    ;; Objective:
    ;;   Achieve full delivery while minimizing total cost.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and
            (loaded pal_mono)
            (loaded v1)
            (loaded v2)
            (processed pal_mixed)
        )
    )

    (:metric minimize (total-cost))
)