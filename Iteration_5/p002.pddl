;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: Two_Workers
;;
;; Purpose:
;; This scenario models a warehouse system with two workers and two forklifts
;; working in parallel to speed up logistics operations.
;;
;; Key idea:
;; Tasks can be distributed between workers to improve efficiency:
;;   - One worker can focus on transport
;;   - Another can focus on preparation/control steps
;;
;; Workflow:
;;   Arrival → Storage → Preparation → Control → Shipping
;;
;; System rules:
;;   - Mixed packages must be split into separate items
;;   - Target pallets must receive processed items
;;   - All shipments must be scanned before loading
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem Two_Workers)

(:domain Project_TER)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OBJECTS
;;
;; LOCATIONS:
;;   loc_truck     : Incoming delivery area
;;   loc_arrival   : Receiving zone
;;   loc_prep      : Preparation area
;;   loc_control   : Quality control zone
;;   loc_shipping  : Final shipping dock
;;
;; WORKERS:
;;   cariste1      : Worker operating near truck side
;;   cariste2      : Worker operating near processing zones
;;
;; FORKLIFTS:
;;   fenwick1      : Forklift assigned to worker 1
;;   fenwick2      : Forklift assigned to worker 2
;;
;; PACKAGES:
;;   pal_mono      : Standard incoming package
;;   pal_mixed     : Mixed package requiring splitting
;;
;; TARGET PALLETS:
;;   pal_target1   : Output pallet 1 (sorted product)
;;   pal_target2   : Output pallet 2 (sorted product)
;;
;; MIXED CONTENT:
;;   item_batch_a  : Item inside mixed package
;;   item_batch_b  : Item inside mixed package
;;
;; STANDARD PRODUCT:
;;   mono_product  : Content of pal_mono
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:objects

    ;; Locations
    loc_truck loc_arrival loc_prep loc_control loc_shipping - loc

    ;; Workers
    cariste1 cariste2 - worker

    ;; Forklifts
    fenwick1 fenwick2 - fenwick

    ;; Incoming packages
    pal_mono - package
    pal_mixed - package

    ;; Output pallets
    pal_target1 - package
    pal_target2 - package

    ;; Mixed package contents
    item_batch_a item_batch_b - object

    ;; Mono package content
    mono_product - object
)

(:init

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL CONDITIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (is_mono pal_mono)
    (is_mixed pal_mixed)

    ;; Only one forklift starts empty (partial constraint scenario)
    (forklift_empty fenwick1)

    (= (total-cost) 0)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL POSITIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Worker 1 starts at truck zone (incoming logistics)
    (at cariste1 loc_truck)
    (at fenwick1 loc_truck)

    ;; Worker 2 starts closer to processing zones
    (at cariste2 loc_prep)
    (at fenwick2 loc_prep)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL PACKAGE LOCATIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (at pal_mono loc_truck)
    (at pal_mixed loc_truck)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PACKAGE CONTENT STRUCTURE
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (contains pal_mono mono_product)

    (contains pal_mixed item_batch_a)
    (contains pal_mixed item_batch_b)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; TARGET PALLETS (READY FOR PROCESSING)
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
;;   - Mono package must be loaded
;;   - Both target pallets must be loaded
;;   - Traceability checks must be completed (scanning)
;;
;; Interpretation:
;;   The system validates parallel execution with two workers
;;   ensuring full warehouse throughput efficiency.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:goal (and

    ;; Main product delivered
    (loaded pal_mono)

    ;; Processed outputs delivered
    (loaded pal_target1)
    (loaded pal_target2)

    ;; Traceability requirement
    (product_scanned pal_mono)
    (product_scanned pal_target1)
    (product_scanned pal_target2)
))

(:metric minimize (total-cost))
)