;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: test_volume
;;
;; Description:
;; This problem models a warehouse processing scenario involving both
;; standard packages and a mixed palette.
;;
;; Initial inventory:
;;   - 2 mono packages (m1, m2)
;;   - 1 mixed palette (mix1)
;;
;; Business workflow:
;;
;; Mono Packages:
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
;; Mixed Palette:
;;     Unload
;;         ↓
;;     Split into v1 and v2
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
;;   - Both mono packages must be loaded.
;;   - The mixed palette must be processed (split).
;;   - The resulting standard packages (v1 and v2) must be loaded.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem test_volume)

    (:domain Project_TER)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;
    ;; LOCATIONS
    ;;
    ;; truck_dock      : Incoming truck location.
    ;; arrival_zone    : Receiving/unloading area.
    ;; rack_storage    : Storage area.
    ;; prep_zone       : Package preparation area.
    ;; control_zone    : Inspection and quality-control area.
    ;; shipping_dock   : Outgoing shipping location.
    ;;
    ;; WORKER
    ;;
    ;; cariste1        : Warehouse operator responsible for moving packages.
    ;;
    ;; MONO PACKAGES
    ;;
    ;; m1, m2          : Standard mono-product packages.
    ;;
    ;; MIXED PACKAGE
    ;;
    ;; mix1            : Mixed palette that must be split.
    ;;
    ;; STANDARD PACKAGES
    ;;
    ;; v1, v2          : Packages created after splitting mix1.
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

        ;; Worker
        cariste1 - worker

        ;; Mono packages
        m1
        m2 - mono

        ;; Mixed palette
        mix1 - mixed

        ;; Standard packages created after splitting
        v1
        v2 - standard
    )

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL WORKER POSITION
        ;;
        ;; The worker starts at the truck dock where incoming
        ;; packages are located.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at cariste1 truck_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WAREHOUSE LAYOUT
        ;;
        ;; Locations are connected in both directions so that
        ;; the worker can move forward with packages and return
        ;; empty when necessary.
        ;;
        ;; Layout:
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
        ;; Assigns operational roles to warehouse locations.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_arrival_zone arrival_zone)

        (is_storage_zone rack_storage)

        (is_prep_zone prep_zone)

        (is_control_zone control_zone)

        (is_shipping_dock shipping_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL PACKAGE LOCATIONS
        ;;
        ;; All packages start inside the incoming truck area.
        ;;
        ;; m1 and m2 are mono packages.
        ;; mix1 is a mixed palette that must be split before
        ;; entering storage.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (on m1 truck_dock)
        (on m2 truck_dock)
        (on mix1 truck_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PACKAGE CLASSIFICATION
        ;;
        ;; Identifies mix1 as a mixed palette.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_mixed mix1)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;
    ;; Success conditions:
    ;;
    ;; 1. Mono package m1 must be loaded.
    ;; 2. Mono package m2 must be loaded.
    ;; 3. Mixed palette mix1 must have been processed (split).
    ;; 4. Standard package v1 must be loaded.
    ;; 5. Standard package v2 must be loaded.
    ;;
    ;; This ensures that all incoming goods have completed the
    ;; warehouse workflow and are ready for shipment.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and

            ;; Mono packages shipped
            (loaded m1)
            (loaded m2)

            ;; Mixed palette processed
            (processed mix1)

            ;; Generated packages shipped
            (loaded v1)
            (loaded v2)
        )
    )
)