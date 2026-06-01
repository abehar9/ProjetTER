(define (problem WAREHOUSE_SCALED_BATCH)
    (:domain Project_TER)
    (:objects 
        loc_truck loc_arrival loc_prep loc_control loc_shipping - loc
        cariste1 - worker             ;; Added second worker
        fenwick1 - fenwick             ;; Added second forklift
        pal_1 pal_2 pal_3 pal_4 pal_5 - package ;; Scaled package list
        pal_t1 pal_t2 pal_t3 - package          ;; Scaled target list
        item_a item_b item_c item_d - object

        mono_product - object
    )

    (:init
        (forklift_empty fenwick1) 
        (= (total-cost) 0)

        (at cariste1 loc_truck)
        (at fenwick1 loc_truck)


        ;; Packages
        (is_mono pal_1) (is_mono pal_2) (is_mono pal_3) (is_mono pal_4)
        (is_mixed pal_5)

        (contains pal_1 mono_product)

        
        (at pal_1 loc_truck) 

        ;; Target Pallets
        (at pal_t1 loc_arrival) (empty pal_t1)
        (at pal_t2 loc_arrival) (empty pal_t2)
        (at pal_t3 loc_arrival) (empty pal_t3)

        ;; Topology (defined once)
        (connected loc_truck loc_arrival)
        (connected loc_arrival loc_truck)
        (connected loc_arrival loc_prep)
        (connected loc_prep loc_arrival)
        (connected loc_prep loc_control)
        (connected loc_control loc_prep)
        (connected loc_control loc_shipping)
        (connected loc_shipping loc_control)

        ;; Functional Zone Declarations
        (is_truck loc_truck)
        (is_arrival_zone loc_arrival)
        (is_prep_zone loc_prep)
        (is_control_zone loc_control)
        (is_shipping_dock loc_shipping)

    )

    (:goal (and 
        (loaded pal_1)
        (product_scanned pal_1) ;;(loaded pal_2) (loaded pal_3) (loaded pal_4) 
        ;;(loaded pal_t1) (loaded pal_t2) (loaded pal_t3)
    ))

    (:metric minimize (total-cost))
)
