(define (problem TER_Shift_1)
    (:domain Project_TER)
    (:objects 
        truck_in dock_arrival rack_1 prep_area control_point dock_shipping truck_out - loc
        palette_A palette_B - package
        cariste_1 - worker
    )

    (:init
        ;; 1. Initial positions
        (at cariste_1 dock_arrival) ;; Worker starts in the warehouse
        (on palette_A truck_in)     ;; Palette A is in the arrival truck
        (on palette_B truck_in)     ;; Palette B is in the arrival truck
        
        ;; 2. Zone Definitions (Logical Roles)
        (is_arrival_zone dock_arrival)
        (is_storage_zone rack_1)
        (is_prep_zone prep_area)
        (is_control_zone control_point)
        (is_shipping_dock dock_shipping)
        (is_shipping_dock truck_out)

        ;; 3. Path Connections (Bi-directional)
        ;; This allows the worker to move forward WITH a palette
        ;; and move backward EMPTY to get the next one.
        (connected truck_in dock_arrival) (connected dock_arrival truck_in)
        (connected dock_arrival rack_1) (connected rack_1 dock_arrival)
        (connected rack_1 prep_area) (connected prep_area rack_1)
        (connected prep_area control_point) (connected control_point prep_area)
        (connected control_point dock_shipping) (connected dock_shipping control_point)
        (connected dock_shipping truck_out) (connected truck_out dock_shipping)
    )

    (:goal (and 
        ;; The goal is to have both palettes in the outgoing truck
        ;; and they must have passed through the control check.
        (on palette_A truck_out)
        (on palette_B truck_out)
        (controlled palette_A)
        (controlled palette_B)
    ))
)