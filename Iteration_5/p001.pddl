;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: Basic warehouse test
;;
;; Purpose:
;; This scenario models a full warehouse processing pipeline with:
;;   - Standard mono packages
;;   - Mixed packages that must be split into multiple products
;;   - Target pallets used to receive sorted items
;;
;; Key workflow:
;;   Arrival → Sorting → Processing → Control → Shipping
;;
;; Core rules:
;;   - Mixed packages must be decomposed into individual items
;;   - Items must be placed into target pallets
;;   - Every package must pass scanning before shipping
;;
;; Optimization goal:
;;   Minimize total operational cost
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem WAREHOUSE_TEST_BASIC)

(:domain Project_TER)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OBJECTS
;;
;; LOCATIONS:
;;   loc_truck     : Incoming delivery truck area
;;   loc_arrival   : Receiving / unloading zone
;;   loc_prep      : Preparation area
;;   loc_control   : Quality control zone
;;   loc_shipping  : Final shipping dock
;;
;; WORKER:
;;   cariste1      : Warehouse operator
;;
;; VEHICLE:
;;   fenwick1      : Forklift vehicle used for transport
;;
;; PACKAGES:
;;   pal_mono      : Standard incoming package
;;   pal_mixed     : Mixed package requiring splitting
;;
;; TARGET PALLETS:
;;   pal_target1   : Empty pallet to receive sorted product
;;   pal_target2   : Empty pallet to receive sorted product
;;
;; MIXED CONTENT ITEMS:
;;   item_batch_a  : Item inside mixed package
;;   item_batch_b  : Item inside mixed package
;;
;; STANDARD OBJECT:
;;   mono_product  : Single product contained in pal_mono
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:objects
    ;; Locations
    loc_truck loc_arrival loc_prep loc_control loc_shipping - loc

    ;; Worker and forklift
    cariste1 - worker
    fenwick1 - fenwick

    ;; Incoming packages
    pal_mono - package
    pal_mixed - package

    ;; Empty target pallets (for sorting output)
    pal_target1 - package
    pal_target2 - package

    ;; Mixed package contents
    item_batch_a item_batch_b - object

    ;; Mono product content
    mono_product - object
)

(:init

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL CONDITIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (is_mono pal_mono)
    (is_mixed pal_mixed)

    (forklift_empty fenwick1)

    (= (total-cost) 0)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL POSITIONS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (at cariste1 loc_truck)
    (at fenwick1 loc_truck)

    (at pal_mono loc_truck)
    (at pal_mixed loc_truck)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PACKAGE CONTENT STRUCTURE
    ;;
    ;; Mono package contains a single product
    ;; Mixed package contains multiple items that must be split
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (contains pal_mono mono_product)

    (contains pal_mixed item_batch_a)
    (contains pal_mixed item_batch_b)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; TARGET PALLETS (EMPTY STORAGE UNITS)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (at pal_target1 loc_arrival)
    (at pal_target2 loc_arrival)

    (empty pal_target1)
    (empty pal_target2)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; WAREHOUSE TOPOLOGY
    ;;
    ;; Bidirectional connections between all zones
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
;; The scenario is complete when:
;;   - Mono package is successfully shipped
;;   - Target pallets are loaded with processed items
;;   - All packages have passed scanning validation
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:goal (and

    ;; Main delivery requirement
    (loaded pal_mono)

    ;; Sorted outputs must be shipped
    (loaded pal_target1)
    (loaded pal_target2)

    ;; Traceability requirement (all items must be scanned)
    (product_scanned pal_mono)
    (product_scanned pal_target1)
    (product_scanned pal_target2)
))

(:metric minimize (total-cost))

)