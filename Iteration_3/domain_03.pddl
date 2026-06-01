;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN: Project_TER (Enhanced Version with Tracking System)
;;
;; Description:
;; This domain models a warehouse logistics system with strict tracking rules.
;;
;; In addition to normal warehouse processing, this version introduces:
;;
;;   1. Labeling System
;;      - Every package (except mixed ones) must be printed and labeled
;;        at the arrival zone before further processing.
;;
;;   2. Location Scanning System
;;      - Every time a package enters a new location, it must be scanned.
;;      - Scanning ensures traceability of package movements.
;;
;;   3. Mixed Package Handling
;;      - Mixed packages must be split into standard packages before
;;        entering the normal workflow.
;;
;; Workflow Overview:
;;
;;     Arrival
;;        ↓
;;     Labeling (mandatory)
;;        ↓
;;     Scan + Movement through zones
;;        ↓
;;     Storage → Preparation → Control → Shipping
;;
;; Mixed Workflow:
;;
;;     Arrival
;;        ↓
;;     Scan
;;        ↓
;;     Split into standard packages
;;        ↓
;;     Normal workflow (with scanning at each step)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain Project_TER)

    (:requirements :strips :typing :negative-preconditions)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; TYPES
    ;;
    ;; loc
    ;;     Represents warehouse locations (zones, docks, rooms).
    ;;
    ;; worker
    ;;     Warehouse employee who moves packages.
    ;;
    ;; package
    ;;     General package type.
    ;;
    ;; mono
    ;;     Single-product package.
    ;;
    ;; mixed
    ;;     Multi-product package that must be split before processing.
    ;;
    ;; standard
    ;;     Normal package (including those created from splitting).
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:types
        loc worker - object
        package - object
        mono mixed standard - package
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PREDICATES
    ;;
    ;; BASIC STATE
    ;;
    ;; (on ?package ?location)
    ;;     Package is physically located at a location.
    ;;
    ;; (at ?worker ?location)
    ;;     Worker is currently at a location.
    ;;
    ;; PACKAGE STATUS
    ;;
    ;; (arrived ?package)
    ;;     Package has entered the warehouse system.
    ;;
    ;; (labeled ?package)
    ;;     Package has been assigned a barcode label.
    ;;
    ;; (location_scanned ?package ?location)
    ;;     Confirms that the package was scanned at a location.
    ;;
    ;; (prepared ?package)
    ;;     Package has been prepared for shipment.
    ;;
    ;; (controlled ?package)
    ;;     Package has passed inspection.
    ;;
    ;; (loaded ?package)
    ;;     Package has been loaded onto shipping transport.
    ;;
    ;; CONNECTIVITY
    ;;
    ;; (connected ?l1 ?l2)
    ;;     Direct movement path exists between two locations.
    ;;
    ;; MIXED PACKAGE MANAGEMENT
    ;;
    ;; (is_mixed ?package)
    ;;     Package contains mixed contents.
    ;;
    ;; (is_split ?mixed)
    ;;     Mixed package has been split.
    ;;
    ;; (processed ?mixed)
    ;;     Mixed package has completed splitting process.
    ;;
    ;; ZONE TYPES
    ;;
    ;; (is_arrival_zone ?location)
    ;; (is_storage_zone ?location)
    ;; (is_prep_zone ?location)
    ;; (is_control_zone ?location)
    ;; (is_shipping_dock ?location)
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:predicates

        (on ?y - package ?l - loc)
        (at ?w - worker ?l - loc)

        (arrived ?y - package)

        (labeled ?y - package)
        (location_scanned ?y - package ?l - loc)

        (prepared ?y - package)
        (controlled ?y - package)
        (loaded ?y - package)

        (connected ?l1 - loc ?l2 - loc)

        (is_mixed ?y - package)
        (is_split ?y - mixed)
        (processed ?y - mixed)

        (is_arrival_zone ?l - loc)
        (is_storage_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: print_and_label
    ;;
    ;; Purpose:
    ;;     Assign a barcode label to a package.
    ;;
    ;; Requirement:
    ;;     Must be done at the arrival zone before processing begins.
    ;;
    ;; Effect:
    ;;     Package becomes labeled and traceable.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action print_and_label
        :parameters (?w - worker ?y - package ?l - loc)
        :precondition (and
            (at ?w ?l)
            (on ?y ?l)
            (is_arrival_zone ?l)
            (not (labeled ?y))
            (not (is_mixed ?y))
        )
        :effect (and
            (labeled ?y)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: scan_location
    ;;
    ;; Purpose:
    ;;     Record that a package is verified at a specific location.
    ;;
    ;; Requirement:
    ;;     Must happen after every movement for tracking.
    ;;
    ;; Effect:
    ;;     Stores location validation for the package.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action scan_location
        :parameters (?w - worker ?y - package ?l - loc)
        :precondition (and
            (at ?w ?l)
            (on ?y ?l)
            (labeled ?y)
        )
        :effect (and
            (location_scanned ?y ?l)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: worker_travel
    ;;
    ;; Purpose:
    ;;     Move worker between connected locations.
    ;;
    ;; Effect:
    ;;     Updates worker position only.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action worker_travel
        :parameters (?w - worker ?from - loc ?to - loc)
        :precondition (and
            (at ?w ?from)
            (connected ?from ?to)
        )
        :effect (and
            (not (at ?w ?from))
            (at ?w ?to)
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: unload
    ;;
    ;; Purpose:
    ;;     Bring package into warehouse system.
    ;;
    ;; Effect:
    ;;     Package enters arrival zone and is marked arrived.
    ;;     Forces scan reset so scanning must be redone.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action unload
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)
        :precondition (and
            (at ?w ?from)
            (on ?y ?from)
            (not (arrived ?y))
            (is_arrival_zone ?to)
            (connected ?from ?to)
        )
        :effect (and
            (not (on ?y ?from))
            (on ?y ?to)
            (not (at ?w ?from))
            (at ?w ?to)
            (arrived ?y)
            (not (location_scanned ?y ?to))
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTIONS (stockage, prepare, control, load)
    ;;
    ;; Each of these actions:
    ;;   - Moves a package through warehouse stages
    ;;   - Requires correct scan validation
    ;;   - Updates processing status
    ;;   - Forces re-scan at each new location
    ;;
    ;; Stages:
    ;;   Storage → Preparation → Control → Shipping
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action stockage
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)
        :precondition (and
            (at ?w ?from)
            (on ?y ?from)
            (labeled ?y)
            (location_scanned ?y ?from)
            (not (is_mixed ?y))
            (is_storage_zone ?to)
            (connected ?from ?to)
        )
        :effect (and
            (not (on ?y ?from))
            (on ?y ?to)
            (not (at ?w ?from))
            (at ?w ?to)
            (not (location_scanned ?y ?to))
        )
    )

    (:action prepare_command
        :parameters (?w - worker ?y - package ?from ?l - loc)
        :precondition (and
            (at ?w ?from)
            (on ?y ?from)
            (location_scanned ?y ?from)
            (is_prep_zone ?l)
            (connected ?from ?l)
        )
        :effect (and
            (not (on ?y ?from))
            (on ?y ?l)
            (not (at ?w ?from))
            (at ?w ?l)
            (prepared ?y)
            (not (location_scanned ?y ?l))
        )
    )

    (:action control_check
        :parameters (?w - worker ?y - package ?from ?l - loc)
        :precondition (and
            (at ?w ?from)
            (on ?y ?from)
            (prepared ?y)
            (location_scanned ?y ?from)
            (is_control_zone ?l)
            (connected ?from ?l)
        )
        :effect (and
            (not (on ?y ?from))
            (on ?y ?l)
            (not (at ?w ?from))
            (at ?w ?l)
            (controlled ?y)
            (not (location_scanned ?y ?l))
        )
    )

    (:action load_truck
        :parameters (?w - worker ?y - package ?from ?l - loc)
        :precondition (and
            (at ?w ?from)
            (on ?y ?from)
            (controlled ?y)
            (location_scanned ?y ?from)
            (is_shipping_dock ?l)
            (connected ?from ?l)
        )
        :effect (and
            (not (on ?y ?from))
            (on ?y ?l)
            (not (at ?w ?from))
            (at ?w ?l)
            (loaded ?y)
            (not (location_scanned ?y ?l))
        )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: split_mixed_palette
    ;;
    ;; Purpose:
    ;;     Split a mixed package into standard packages.
    ;;
    ;; Requirement:
    ;;     Must happen at arrival zone and after scanning.
    ;;
    ;; Effect:
    ;;     Mixed package disappears and becomes two standard packages.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action split_mixed_palette
        :parameters (?w - worker ?ymix - mixed ?y1 - standard ?y2 - standard ?l - loc)
        :precondition (and
            (at ?w ?l)
            (is_arrival_zone ?l)
            (on ?ymix ?l)
            (location_scanned ?ymix ?l)
            (not (is_split ?ymix))
        )
        :effect (and
            (is_split ?ymix)
            (processed ?ymix)
            (not (on ?ymix ?l))
            (on ?y1 ?l)
            (on ?y2 ?l)
            (arrived ?y1)
            (arrived ?y2)
            (not (labeled ?y1))
            (not (labeled ?y2))
        )
    )
)