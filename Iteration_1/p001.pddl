;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: TER_Shift_1
;;
;; Description:
;; This problem represents a warehouse shift where a worker must process
;; two palettes received from an incoming truck.
;;
;; Both palettes must go through the complete logistics workflow:
;;
;;     Arrival -> Storage -> Preparation -> Control -> Shipping
;;
;; The objective is to move both palettes from the incoming truck to the
;; outgoing truck while ensuring they pass the control stage.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem TER_Shift_1)

    (:domain Project_TER)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;
    ;; LOCATIONS
    ;;
    ;; truck_in       : Incoming truck containing received goods.
    ;; dock_arrival   : Arrival dock where goods are unloaded.
    ;; rack_1         : Storage area for temporary inventory.
    ;; prep_area      : Area where packages are prepared.
    ;; control_point  : Inspection and quality-control area.
    ;; dock_shipping  : Shipping dock before loading.
    ;; truck_out      : Outgoing truck used for shipment.
    ;;
    ;; PACKAGES
    ;;
    ;; palette_A      : First package to process.
    ;; palette_B      : Second package to process.
    ;;
    ;; WORKERS
    ;;
    ;; cariste_1      : Warehouse worker responsible for moving packages.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:objects

        ;; Warehouse locations
        truck_in
        dock_arrival
        rack_1
        prep_area
        control_point
        dock_shipping
        truck_out - loc

        ;; Packages
        palette_A
        palette_B - package

        ;; Worker
        cariste_1 - worker
    )

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL POSITIONS
        ;;
        ;; The worker starts at the arrival dock.
        ;;
        ;; Both palettes are initially inside the incoming truck and
        ;; have not yet entered the warehouse workflow.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at cariste_1 dock_arrival)

        (on palette_A truck_in)
        (on palette_B truck_in)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; ZONE DEFINITIONS
        ;;
        ;; These predicates assign a functional role to each location.
        ;;
        ;; Arrival Zone:
        ;;     Where packages first enter the warehouse.
        ;;
        ;; Storage Zone:
        ;;     Temporary storage location.
        ;;
        ;; Preparation Zone:
        ;;     Area used to prepare packages.
        ;;
        ;; Control Zone:
        ;;     Inspection and validation area.
        ;;
        ;; Shipping Dock:
        ;;     Final destination before transportation.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_arrival_zone dock_arrival)

        (is_storage_zone rack_1)

        (is_prep_zone prep_area)

        (is_control_zone control_point)

        (is_shipping_dock dock_shipping)
        (is_shipping_dock truck_out)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; LOCATION CONNECTIVITY
        ;;
        ;; Connections define where workers can move.
        ;;
        ;; Paths are bi-directional, allowing:
        ;;   - Movement with a package.
        ;;   - Return trips without a package.
        ;;
        ;; Warehouse Layout:
        ;;
        ;; truck_in
        ;;     |
        ;; dock_arrival
        ;;     |
        ;; rack_1
        ;;     |
        ;; prep_area
        ;;     |
        ;; control_point
        ;;     |
        ;; dock_shipping
        ;;     |
        ;; truck_out
        ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (connected truck_in dock_arrival)
        (connected dock_arrival truck_in)

        (connected dock_arrival rack_1)
        (connected rack_1 dock_arrival)

        (connected rack_1 prep_area)
        (connected prep_area rack_1)

        (connected prep_area control_point)
        (connected control_point prep_area)

        (connected control_point dock_shipping)
        (connected dock_shipping control_point)

        (connected dock_shipping truck_out)
        (connected truck_out dock_shipping)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;
    ;; Success criteria:
    ;;
    ;; 1. Both palettes must be inside the outgoing truck.
    ;; 2. Both palettes must have completed the control stage.
    ;;
    ;; This guarantees that the packages have been fully processed
    ;; and are ready for shipment.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and

            ;; Final location of packages
            (on palette_A truck_out)
            (on palette_B truck_out)

            ;; Quality-control validation completed
            (controlled palette_A)
            (controlled palette_B)
        )
    )
)