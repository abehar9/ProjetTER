;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: WAREHOUSE_BATCH_VOLUME
;;
;; Purpose:
;; This scenario models a high-volume warehouse workflow where multiple
;; mono packages and a mixed package are processed in parallel.
;;
;; Key idea:
;; The system simulates batch logistics with:
;;   - Multiple identical processing pipelines
;;   - Two workers and two forklifts
;;   - Mixed and mono package handling
;;
;; Workflow:
;;   Arrival → Preparation → Control → Shipping
;;
;; Core rules:
;;   - All mono packages must be fully processed and loaded
;;   - Mixed package must be split and processed indirectly via targets
;;   - Every package must be scanned before shipment
;;
;; Optimization goal:
;;   Minimize total operational cost across all parallel tasks
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem WAREHOUSE_BATCH_VOLUME)

(:domain Project_TER)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OBJECTS
;;
;; LOCATIONS:
;;   loc_truck     : Incoming delivery zone
;;   loc_arrival   : Receiving area
;;   loc_prep      : Preparation zone
;;   loc_control   : Quality control zone
;;   loc_shipping  : Final dispatch area
;;
;; WORKERS:
;;   cariste1      : Worker handling truck-side operations
;;   cariste2      : Worker handling processing operations
;;
;; FORKLIFTS:
;;   fenwick1      : Forklift 1
;;   fenwick2      : Forklift 2
;;
;; PACKAGES:
;;   pal_mono      : Mono package 1
;;   pal_mono_2    : Mono package 2
;;   pal_mono_3    : Mono package 3
;;   pal_mixed     : Mixed package requiring decomposition
;;   pal_target1   : Output pallet 1
;;   pal_target2   : Output pallet 2
;;
;; PRODUCTS:
;;   mono_product      : Content of pal_mono
;;   mono_product_2    : Content of pal_mono_2
;;   mono_product_3    : Content of pal_mono_3
;;   item_batch_a      : Mixed package item
;;   item_batch_b      : Mixed package item
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:objects

    ;; Locations
    loc_truck loc_arrival loc_prep loc_control loc_shipping - loc

    ;; Workers
    cariste1 cariste2 - worker

    ;; Forklifts
    fenwick1 fenwick2 - fenwick

    ;; Packages
    pal_mono pal_mono_2 pal_mono_3 pal_mixed pal_target1 pal_target2 - package

    ;; Product contents
    mono_product mono_product_2 mono_product_3 - object
    item_batch_a item_batch_b - object
)

(:init

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL CONDITIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (= (total-cost) 0)

    (forklift_empty fenwick1)
    (forklift_empty fenwick2)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL POSITIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (at cariste1 loc_truck)
    (at fenwick1 loc_truck)

    (at cariste2 loc_prep)
    (at fenwick2 loc_prep)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL PACKAGE LOCATIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (at pal_mono loc_truck)
    (at pal_mono_2 loc_truck)
    (at pal_mono_3 loc_truck)
    (at pal_mixed loc_truck)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PACKAGE CONTENT STRUCTURE
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (is_mono pal_mono)
    (contains pal_mono mono_product)

    (is_mono pal_mono_2)
    (contains pal_mono_2 mono_product_2)

    (is_mono pal_mono_3)
    (contains pal_mono_3 mono_product_3)

    (is_mixed pal_mixed)
    (contains pal_mixed item_batch_a)
    (contains pal_mixed item_batch_b)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; TARGET PALLETS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (at pal_target1 loc_arrival)
    (at pal_target2 loc_arrival)

    (empty pal_target1)
    (empty pal_target2)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; WAREHOUSE TOPOLOGY
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (connected loc_truck loc_arrival)
    (connected loc_arrival loc_truck)

    (connected loc_arrival loc_prep)
    (connected loc_prep loc_arrival)

    (connected loc_prep loc_control)
    (connected loc_control loc_prep)

    (connected loc_control loc_shipping)
    (connected loc_shipping loc_control)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ZONE DEFINITIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (is_truck loc_truck)
    (is_arrival_zone loc_arrival)
    (is_prep_zone loc_prep)
    (is_control_zone loc_control)
    (is_shipping_dock loc_shipping)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GOAL STATE
;;
;; Success conditions:
;;   - All mono packages must be loaded
;;   - Target pallets must be loaded
;;   - Every package must pass scanning validation
;;
;; Meaning:
;;   This ensures full batch processing integrity across parallel flows.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:goal (and

    ;; Mono deliveries
    (loaded pal_mono)
    (loaded pal_mono_2)
    (loaded pal_mono_3)

    ;; Mixed output
    (loaded pal_target1)
    (loaded pal_target2)

    ;; Traceability validation
    (product_scanned pal_mono)
    (product_scanned pal_mono_2)
    (product_scanned pal_mono_3)
    (product_scanned pal_target1)
    (product_scanned pal_target2)
))

(:metric minimize (total-cost))
)