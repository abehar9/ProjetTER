;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: test_traceability
;;
;; Description:
;; This problem models a warehouse workflow focused on strict traceability.
;;
;; Unlike simpler scenarios, this version requires that every final package
;; is not only delivered, but also properly scanned at the shipping dock.
;;
;; Key objectives:
;;   - Ensure full warehouse processing of all packages.
;;   - Enforce traceability through scanning at final destination.
;;   - Handle both standard and mixed packages.
;;
;; Mixed package rule:
;;   - pal_mixed must be split into two standard packages (v1 and v2).
;;
;; Traceability requirement:
;;   - Every delivered package must have a recorded scan at shipping_dock.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem test_traceability)

    (:domain Project_TER)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;
    ;; LOCATIONS
    ;;
    ;; truck_dock      : Entry point for incoming goods.
    ;; arrival_zone    : Unloading and receiving area.
    ;; rack_storage    : Storage zone for intermediate holding.
    ;; prep_zone       : Preparation area for shipment.
    ;; control_zone    : Quality inspection zone.
    ;; shipping_dock   : Final shipment location.
    ;;
    ;; WORKER
    ;;
    ;; cariste1        : Warehouse operator responsible for moving goods.
    ;;
    ;; PACKAGES
    ;;
    ;; pal_mono        : Standard mono-product package.
    ;; pal_mixed       : Mixed package that must be split.
    ;;
    ;; GENERATED PACKAGES
    ;;
    ;; v1, v2          : Standard packages created from splitting pal_mixed.
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

        ;; Packages
        pal_mono - mono

        ;; Mixed package
        pal_mixed - mixed

        ;; Standard packages created from split
        v1
        v2 - standard
    )

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL WORKER POSITION
        ;;
        ;; Worker starts at the truck dock where incoming goods arrive.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (at cariste1 truck_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WAREHOUSE TOPOLOGY
        ;;
        ;; All zones are connected bidirectionally to allow:
        ;;   - Forward movement of packages through workflow stages
        ;;   - Return movement of workers when needed
        ;;
        ;; Layout:
        ;;
        ;; truck_dock
        ;;     |
        ;; arrival_zone
        ;;     |
        ;; rack_storage
        ;;     |
        ;; prep_zone
        ;;     |
        ;; control_zone
        ;;     |
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
        ;; Assigns functional roles to warehouse locations.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (is_arrival_zone arrival_zone)
        (is_storage_zone rack_storage)
        (is_prep_zone prep_zone)
        (is_control_zone control_zone)
        (is_shipping_dock shipping_dock)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INITIAL PACKAGE STATE
        ;;
        ;; pal_mono and pal_mixed start in the truck and are not yet
        ;; processed, labeled, or scanned.
        ;;
        ;; This ensures that the planner must apply full workflow steps.
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (on pal_mono truck_dock)
        (on pal_mixed truck_dock)

        ;; Identify pal_mixed as a mixed palette requiring splitting
        (is_mixed pal_mixed)

        ;; Note:
        ;; No packages are labeled or scanned initially.
        ;; Traceability must be established during planning.
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;
    ;; Success conditions:
    ;;
    ;; 1. pal_mono must be fully loaded and shipped.
    ;; 2. v1 and v2 (from split) must be loaded and shipped.
    ;; 3. pal_mixed must have been processed (split).
    ;; 4. All delivered packages must have a final scan at shipping_dock.
    ;;
    ;; This enforces both completion AND traceability.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and

            ;; All packages delivered
            (loaded pal_mono)
            (loaded v1)
            (loaded v2)

            ;; Mixed processing requirement
            (processed pal_mixed)

            ;; Traceability requirement (final verification scan)
            (location_scanned pal_mono shipping_dock)
            (location_scanned v1 shipping_dock)
            (location_scanned v2 shipping_dock)
        )
    )
)