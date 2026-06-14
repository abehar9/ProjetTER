(define (problem TER_warehouse_instance_1)
    (:domain Project_TER)
    
    (:objects
        ;; Locations / Topology Nodes
        loc_truck loc_arrival loc_empty_pallets loc_prep loc_control loc_shipping - loc
        
        ;; Agents & Logistics Fleet
        cariste_1 - worker
        fenwick_1 - fenwick
        
        ;; Pallets & Stock Items
        mixed_pallet_01 target_pallet_01 - package
        item_batch_A - object
        
        ;; Structural Attributes
        euro_profile - pallet_type
    )
    
    (:init
        ;; Topology Connectivity Map
        (connected loc_truck loc_arrival)
        (connected loc_arrival loc_truck)
        (connected loc_arrival loc_empty_pallets)
        (connected loc_empty_pallets loc_arrival)
        (connected loc_arrival loc_prep)
        (connected loc_prep loc_arrival)
        (connected loc_prep loc_control)
        (connected loc_control loc_prep)
        (connected loc_control loc_shipping)
        (connected loc_shipping loc_control)
        
        ;; Functional Zone Definitions
        (is_truck loc_truck)
        (is_arrival_zone loc_arrival)
        (is_empty_pallet_zone loc_empty_pallets)
        (is_prep_zone loc_prep)
        (is_control_zone loc_control)
        (is_shipping_dock loc_shipping)
        
        ;; Fleet & Operator Initialization
        (at cariste_1 loc_control)         ; Worker begins on foot in control zone to log in
        (pda_idle cariste_1)               ; Device needs authentication
        
        (at fenwick_1 loc_arrival)         ; Forklift parked at arrival docks
        (forklift_empty fenwick_1)
        
        ;; Inbound Cargo State
        (at mixed_pallet_01 loc_arrival)
        (is_mixed mixed_pallet_01)
        (contains mixed_pallet_01 item_batch_A)
        
        ;; Target/Picking Base State
        (at target_pallet_01 loc_empty_pallets)
        (empty target_pallet_01)           ; Raw, clean structure awaiting configuration
        
        ;; Metric Calculation Start Hook
        (= (total-cost) 0)
    )
    
    (:goal
        (and
            ;; Verify the pipeline execution reached fulfillment
            (loaded target_pallet_01)
            
            ;; Verify the target inventory allocation was fully transferred
            (is_mono target_pallet_01)
            (not (contains mixed_pallet_01 item_batch_A))
            
            ;; Clean up step: Ensure equipment is parked safely inside the terminal docks
            (at fenwick_1 loc_shipping)
            (forklift_empty fenwick_1)
        )
    )
    
    (:metric minimize (total-cost))
)
