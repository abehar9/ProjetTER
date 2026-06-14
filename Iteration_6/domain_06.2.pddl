(define (domain Project_TER)
    (:requirements :strips :typing :action-costs :disjunctive-preconditions)
    
    (:types
        loc          ; Fixed warehouse locations/zones
        worker       ; Human operators (caristes)
        fenwick      ; Forklifts / Material handling vehicles
        package      ; Pallets (mono, mixed, or empty targets)
        pallet_type  ; Euro, Half, Non-Euro profiles
    )
    
    (:predicates
        ;; Spatial Positioning
        (at ?obj - object ?l - loc)              ; Track workers, forklifts, packages
        (connected ?l1 - loc ?l2 - loc)          ; Map topology
        
        ;; Vehicle Logistics State
        (worker_mounted ?w - worker ?v - fenwick) ; Worker is driving the forklift
        (carrying ?v - fenwick ?p - package)      ; Package is loaded on the forks
        (forklift_empty ?v - fenwick)             ; Forklift forks are clear
        
        ;; Package Typology & State
        (is_mono ?p - package)                    ; Standard, single-SKU unit load
        (is_mixed ?p - package)                   ; Mixed-SKU unit load requiring sorting
        (contains ?p - package ?item - object)     ; Item batch inside a mixed package
        (empty ?p - package)                      ; Target sorting pallet is empty
        
        ;; PDA & Structural Prep States
        (pda_idle ?w - worker)                    ; Worker device hasn't been booted
        (pda_setup_complete ?w - worker)          ; Worker is authenticated and ready
        (physical_pallet_type ?p - package ?t - pallet_type) ; Assigned profile
        (has_interlayer ?p - package)             ; Stability sheet applied
        
        ;; Processing Pipeline Milestones
        (product_scanned ?p - package)            ; Stage 1: Inbound registration
        (prepared ?p - package)                   ; Stage 2: Quality/Breakdown sorting complete
        (controlled ?p - package)                 ; Stage 3: Compliance & safety checked
        (loaded ?p - package)                     ; Stage 4: Staged inside shipping dock
        
        ;; Zone Layout Definitions
        (is_truck ?l - loc)
        (is_arrival_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
        (is_empty_pallet_zone ?l - loc)           ; Storage for raw picking bases
    )
    
    (:functions
        (total-cost)                     ; Metric calculation for planner optimization
    )

    ;; ==========================================
    ;; PDA & PALLET PREPARATION PROCESS
    ;; ==========================================

    ;; Stage 0A: Boot up administrative session on foot in control zone
    (:action pda_initialize_and_setup
        :parameters (?w - worker ?l - loc)
        :precondition (and 
            (at ?w ?l) 
            (is_control_zone ?l) 
            (pda_idle ?w)
        )
        :effect (and 
            (not (pda_idle ?w))
            (pda_setup_complete ?w)
            (increase (total-cost) 2)
        )
    )

    ;; Stage 0B: Define the structure of the target pallet before sorting
    (:action retrieve_empty_pallet_for_picking
        :parameters (?w - worker ?p - package ?t - pallet_type ?l - loc)
        :precondition (and 
            (at ?w ?l) 
            (at ?p ?l)
            (is_empty_pallet_zone ?l)
            (empty ?p)
            (pda_setup_complete ?w)
        )
        :effect (and 
            (physical_pallet_type ?p ?t)
            (increase (total-cost) 5)
        )
    )

    ;; Stage 0C: Layer reinforcement requirement for safety
    (:action apply_interlayer_sheet
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and 
            (at ?w ?l) 
            (at ?p ?l)
            (empty ?p)
            (not (has_interlayer ?p))
            (pda_setup_complete ?w)
        )
        :effect (and 
            (has_interlayer ?p)
            (increase (total-cost) 3)
        )
    )

    ;; ==========================================
    ;; VEHICLE & NAVIGATIONAL ACTIONS
    ;; ==========================================

    (:action walk_on_foot
        :parameters (?w - worker ?from - loc ?to - loc)
        :precondition (and (at ?w ?from) (connected ?from ?to))
        :effect (and 
            (not (at ?w ?from)) 
            (at ?w ?to)
            (increase (total-cost) 10)
        )
    )

    (:action wait_one_timestep
        :parameters (?w - worker ?l - loc)
        :precondition (or (at ?w ?l) (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l))))
        :effect (and (increase (total-cost) 0))
    )

    (:action mount_fenwick
        :parameters (?w - worker ?v - fenwick ?l - loc)
        :precondition (and (at ?w ?l) (at ?v ?l))
        :effect (and 
            (not (at ?w ?l)) 
            (worker_mounted ?w ?v)
            (increase (total-cost) 5)
        )
    )

    (:action dismount_fenwick
        :parameters (?w - worker ?v - fenwick ?l - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?l))
        :effect (and 
            (at ?w ?l) 
            (not (worker_mounted ?w ?v))
            (increase (total-cost) 5)
        )
    )

    (:action drive_fenwick
        :parameters (?w - worker ?v - fenwick ?from - loc ?to - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?from) (connected ?from ?to))
        :effect (and 
            (not (at ?v ?from)) 
            (at ?v ?to)
            (increase (total-cost) 20)
        )
    )

    ;; ==========================================
    ;; PHYSICAL PALLET HANDLING
    ;; ==========================================

    (:action load_forklift
        :parameters (?w - worker ?v - fenwick ?p - package ?l - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?l) (at ?p ?l) (forklift_empty ?v))
        :effect (and 
            (not (at ?p ?l)) 
            (carrying ?v ?p) 
            (not (forklift_empty ?v))
            (increase (total-cost) 5)
        )
    )

    (:action unload_forklift
        :parameters (?w - worker ?v - fenwick ?p - package ?l - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?l) (carrying ?v ?p))
        :effect (and 
            (at ?p ?l) 
            (not (carrying ?v ?p)) 
            (forklift_empty ?v)
            (increase (total-cost) 5)
        )
    )

    ;; ==========================================
    ;; CORE WAREHOUSE PROCESSING PIPELINE
    ;; ==========================================

    (:action scan_product
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and 
            (at ?p ?l)
            (pda_setup_complete ?w)
            (or (at ?w ?l) 
                (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l))))
        )
        :effect (and 
            (product_scanned ?p)
            (increase (total-cost) 1)
        )
    )

    (:action sort_into_new_palette
        :parameters (?w - worker ?mixed_pal - package ?item - object ?target_pal - package ?l - loc)
        :precondition (and 
            (at ?w ?l) (at ?mixed_pal ?l) (at ?target_pal ?l)
            (is_mixed ?mixed_pal) 
            (contains ?mixed_pal ?item) 
            (empty ?target_pal)
            (has_interlayer ?target_pal)
            (pda_setup_complete ?w)
            (is_arrival_zone ?l)
        )
        :effect (and 
            (not (contains ?mixed_pal ?item))
            (not (empty ?target_pal))
            (is_mono ?target_pal)
            (increase (total-cost) 15)
        )
    )

    (:action mark_prepared
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and 
            (at ?p ?l) (product_scanned ?p) (is_mono ?p) (is_prep_zone ?l)
            (pda_setup_complete ?w)
            (or (at ?w ?l) 
                (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l))))
        )
        :effect (and 
            (prepared ?p)
            (increase (total-cost) 2)
        )
    )

    (:action mark_controlled
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and 
            (at ?p ?l) (prepared ?p) (is_control_zone ?l)
            (pda_setup_complete ?w)
            (or (at ?w ?l) 
                (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l))))
        )
        :effect (and 
            (controlled ?p)
            (increase (total-cost) 2)
        )
    )

    (:action mark_loaded
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and 
            (at ?p ?l) (controlled ?p) (is_shipping_dock ?l)
            (pda_setup_complete ?w)
            (or (at ?w ?l) 
                (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l))))
        )
        :effect (and 
            (loaded ?p)
            (increase (total-cost) 2)
        )
    )
)