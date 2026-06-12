(define (domain Project_TER)

    (:requirements :strips :typing :negative-preconditions :action-costs)

    (:types
        loc worker fenwick - object
        package - object
        mono mixed standard - package
    )

    (:functions
        (total-cost)
    )

    (:predicates

        ;; POSITIONING
        (at ?obj - object ?l - loc)
        (on ?y - package ?f - fenwick)
        (driving ?w - worker ?f - fenwick)
        (occupied ?f - fenwick)

        ;; PACKAGE STATE
        (arrived ?y - package)
        (labeled ?y - package)
        (product_scanned ?y - package)
        (loc_scanned ?l - loc)

        (prepared ?y - package)
        (controlled ?y - package)
        (loaded ?y - package)

        ;; STRUCTURE
        (connected ?l1 - loc ?l2 - loc)

        ;; MIXED HANDLING
        (is_mixed ?y - package)
        (is_split ?y - mixed)
        (processed ?y - mixed)

        ;; ZONES
        (is_truck ?l - loc)
        (is_arrival_zone ?l - loc)
        (is_storage_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: unload_from_truck
    ;;
    ;; Purpose:
    ;;     Move a package from the incoming truck into the warehouse.
    ;;
    ;; Preconditions:
    ;;     - Worker is driving a fenwick.
    ;;     - Fenwick is at truck location.
    ;;     - Package is at truck location.
    ;;     - Fenwick is not occupied.
    ;;
    ;; Effects:
    ;;     - Package is moved to arrival zone.
    ;;     - Package is marked as arrived.
    ;;     - Cost increases.
    ;;
    ;; Workflow Stage:
    ;;     Entry / receiving stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action unload_from_truck
        :parameters (?w - worker ?f - fenwick ?y - package ?truck - loc ?arrival - loc)
        :precondition (and
            (is_truck ?truck)
            (is_arrival_zone ?arrival)
            (connected ?truck ?arrival)
            (driving ?w ?f)
            (at ?f ?truck)
            (at ?y ?truck)
            (not (occupied ?f))
        )
        :effect (and
            (not (at ?y ?truck))
            (at ?y ?arrival)
            (arrived ?y)
            (increase (total-cost) 10)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mount_fenwick
    ;;
    ;; Purpose:
    ;;     Worker gets onto a fenwick vehicle.
    ;;
    ;; Preconditions:
    ;;     - Worker and fenwick are at the same location.
    ;;
    ;; Effects:
    ;;     - Worker begins driving fenwick.
    ;;     - Cost increases.
    ;;
    ;; Workflow Stage:
    ;;     Preparation for transport.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mount_fenwick
        :parameters (?w - worker ?f - fenwick ?l - loc)
        :precondition (and
            (at ?w ?l)
            (at ?f ?l)
        )
        :effect (and
            (not (at ?w ?l))
            (driving ?w ?f)
            (increase (total-cost) 5)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: dismount_fenwick
    ;;
    ;; Purpose:
    ;;     Worker leaves the fenwick.
    ;;
    ;; Preconditions:
    ;;     - Worker is driving fenwick.
    ;;     - Fenwick is at a location.
    ;;
    ;; Effects:
    ;;     - Worker returns to ground movement.
    ;;     - Fenwick is no longer occupied.
    ;;
    ;; Workflow Stage:
    ;;     Transition between driving and walking.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action dismount_fenwick
        :parameters (?w - worker ?f - fenwick ?l - loc)
        :precondition (and
            (driving ?w ?f)
            (at ?f ?l)
            (not (occupied ?f))
        )
        :effect (and
            (at ?w ?l)
            (not (driving ?w ?f))
            (increase (total-cost) 5)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: drive_fenwick
    ;;
    ;; Purpose:
    ;;     Move fenwick between connected locations.
    ;;
    ;; Preconditions:
    ;;     - Worker is driving fenwick.
    ;;     - Fenwick is at starting location.
    ;;     - Locations are connected.
    ;;
    ;; Effects:
    ;;     - Fenwick changes location.
    ;;     - Previous scan is invalidated.
    ;;     - Cost increases significantly.
    ;;
    ;; Workflow Stage:
    ;;     Transportation stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action drive_fenwick
        :parameters (?w - worker ?f - fenwick ?from - loc ?to - loc)
        :precondition (and
            (driving ?w ?f)
            (at ?f ?from)
            (connected ?from ?to)
        )
        :effect (and
            (not (at ?f ?from))
            (at ?f ?to)
            (not (loc_scanned ?from))
            (increase (total-cost) 20)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: scan_product
    ;;
    ;; Purpose:
    ;;     Verify and record a product scan.
    ;;
    ;; Preconditions:
    ;;     - Package is at location.
    ;;     - Worker is present or driving nearby.
    ;;
    ;; Effects:
    ;;     - Product is marked as scanned.
    ;;     - Cost increases slightly.
    ;;
    ;; Workflow Stage:
    ;;     Traceability validation.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action scan_product
        :parameters (?w - worker ?y - package ?l - loc)
        :precondition (and
            (at ?y ?l)
            (or
                (at ?w ?l)
                (exists (?f - fenwick)
                    (and (driving ?w ?f) (at ?f ?l))
                )
            )
        )
        :effect (and
            (product_scanned ?y)
            (increase (total-cost) 1)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: scan_location
    ;;
    ;; Purpose:
    ;;     Record that a location has been verified.
    ;;
    ;; Preconditions:
    ;;     - Worker is at location or driving through it.
    ;;
    ;; Effects:
    ;;     - Location is marked as scanned.
    ;;
    ;; Workflow Stage:
    ;;     Traceability system.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action scan_location
        :parameters (?w - worker ?l - loc)
        :precondition (or
            (at ?w ?l)
            (exists (?f - fenwick)
                (and (driving ?w ?f) (at ?f ?l))
            )
        )
        :effect (and
            (loc_scanned ?l)
            (increase (total-cost) 1)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: print_and_label
    ;;
    ;; Purpose:
    ;;     Attach barcode label to package.
    ;;
    ;; Preconditions:
    ;;     - Package is at arrival zone.
    ;;     - Worker is present.
    ;;     - Package is not yet labeled.
    ;;
    ;; Effects:
    ;;     - Package becomes traceable.
    ;;
    ;; Workflow Stage:
    ;;     Entry identification stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action print_and_label
        :parameters (?w - worker ?y - package ?l - loc)
        :precondition (and
            (at ?y ?l)
            (at ?w ?l)
            (is_arrival_zone ?l)
            (not (labeled ?y))
        )
        :effect (and
            (labeled ?y)
            (increase (total-cost) 2)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mark_prepared
    ;;
    ;; Purpose:
    ;;     Mark package as ready for inspection.
    ;;
    ;; Preconditions:
    ;;     - Package is labeled.
    ;;     - Product and location are scanned.
    ;;     - Package is in prep zone.
    ;;
    ;; Effects:
    ;;     - Package becomes prepared.
    ;;
    ;; Workflow Stage:
    ;;     Preparation stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mark_prepared
        :parameters (?w - worker ?y - package ?l - loc)
        :precondition (and
            (at ?w ?l)
            (at ?y ?l)
            (is_prep_zone ?l)
            (loc_scanned ?l)
            (product_scanned ?y)
            (labeled ?y)
        )
        :effect (and
            (prepared ?y)
            (increase (total-cost) 2)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mark_controlled
    ;;
    ;; Purpose:
    ;;     Perform quality inspection on package.
    ;;
    ;; Preconditions:
    ;;     - Package is prepared.
    ;;     - Scans are valid.
    ;;     - Location is control zone.
    ;;
    ;; Effects:
    ;;     - Package is approved for shipping.
    ;;
    ;; Workflow Stage:
    ;;     Quality control stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mark_controlled
        :parameters (?w - worker ?y - package ?l - loc)
        :precondition (and
            (at ?w ?l)
            (at ?y ?l)
            (is_control_zone ?l)
            (loc_scanned ?l)
            (product_scanned ?y)
            (prepared ?y)
        )
        :effect (and
            (controlled ?y)
            (increase (total-cost) 2)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: mark_loaded
    ;;
    ;; Purpose:
    ;;     Final step: ship package out of warehouse.
    ;;
    ;; Preconditions:
    ;;     - Package passed control.
    ;;     - Package is at shipping dock.
    ;;
    ;; Effects:
    ;;     - Package is marked as loaded.
    ;;     - Package is considered shipped.
    ;;
    ;; Workflow Stage:
    ;;     Final shipping stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action mark_loaded
        :parameters (?w - worker ?y - package ?l - loc)
        :precondition (and
            (at ?w ?l)
            (at ?y ?l)
            (is_shipping_dock ?l)
            (loc_scanned ?l)
            (product_scanned ?y)
            (controlled ?y)
        )
        :effect (and
            (loaded ?y)
            (increase (total-cost) 2)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: split_mixed_palette
    ;;
    ;; Purpose:
    ;;     Split a mixed package into standard packages.
    ;;
    ;; Preconditions:
    ;;     - Package is at arrival zone.
    ;;     - Package has not been split.
    ;;
    ;; Effects:
    ;;     - Mixed package disappears.
    ;;     - Two standard packages are created.
    ;;
    ;; Workflow Stage:
    ;;     Special handling stage (pre-processing).
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action split_mixed_palette
        :parameters (?w - worker ?ymix - mixed ?y1 - standard ?y2 - standard ?l - loc)
        :precondition (and
            (at ?w ?l)
            (is_arrival_zone ?l)
            (at ?ymix ?l)
            (not (is_split ?ymix))
        )
        :effect (and
            (is_split ?ymix)
            (processed ?ymix)
            (not (at ?ymix ?l))
            (at ?y1 ?l)
            (at ?y2 ?l)
            (arrived ?y1)
            (arrived ?y2)
            (increase (total-cost) 10)
        )
    )
)