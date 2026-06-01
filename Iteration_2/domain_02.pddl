;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DOMAIN: Project_TER
;;
;; Description:
;; This domain models a logistics terminal (TER) where packages are processed
;; through several warehouse stages before shipment.
;;
;; The domain supports two types of package flows:
;;
;; 1. Standard Packages
;;    Unload -> Storage -> Preparation -> Control -> Loading
;;
;; 2. Mixed Packages
;;    Unload -> Split Mixed Palette -> Storage -> Preparation
;;    -> Control -> Loading
;;
;; Mixed palettes contain multiple product categories and must be split into
;; standard packages before continuing through the normal workflow.
;;
;; Workers are responsible for transporting packages between connected
;; warehouse locations.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain Project_TER)

    (:requirements :strips :typing :negative-preconditions)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; TYPES
    ;;
    ;; loc
    ;;     Warehouse locations and operational areas.
    ;;
    ;; worker
    ;;     Employee responsible for handling packages.
    ;;
    ;; package
    ;;     Generic package type.
    ;;
    ;; mono
    ;;     Single-product package.
    ;;
    ;; mixed
    ;;     Mixed palette containing multiple product categories.
    ;;     Must be split before storage.
    ;;
    ;; standard
    ;;     Standard package created after splitting a mixed palette.
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
    ;; (on ?package ?location)
    ;;     Package is located at a specific location.
    ;;
    ;; (at ?worker ?location)
    ;;     Worker is located at a specific location.
    ;;
    ;; (arrived ?package)
    ;;     Package has entered the warehouse workflow.
    ;;
    ;; (prepared ?package)
    ;;     Package has completed preparation.
    ;;
    ;; (controlled ?package)
    ;;     Package has passed inspection.
    ;;
    ;; (loaded ?package)
    ;;     Package has been loaded for shipment.
    ;;
    ;; (connected ?location1 ?location2)
    ;;     Direct path exists between two locations.
    ;;
    ;; (is_mixed ?package)
    ;;     Package is identified as a mixed palette.
    ;;
    ;; (is_split ?mixed_package)
    ;;     Mixed palette has already been separated.
    ;;
    ;; (processed ?mixed_package)
    ;;     Splitting process has been completed.
    ;;
    ;; Zone predicates define warehouse roles.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:predicates

        ;; Package location
        (on ?y - package ?l - loc)

        ;; Worker location
        (at ?w - worker ?l - loc)

        ;; Package status
        (arrived ?y - package)
        (prepared ?y - package)
        (controlled ?y - package)
        (loaded ?y - package)

        ;; Navigation
        (connected ?l1 - loc ?l2 - loc)

        ;; Mixed package management
        (is_mixed ?y - package)
        (is_split ?y - mixed)
        (processed ?y - mixed)

        ;; Warehouse zones
        (is_arrival_zone ?l - loc)
        (is_storage_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: worker_travel
    ;;
    ;; Purpose:
    ;;     Move a worker between two connected locations.
    ;;
    ;; Preconditions:
    ;;     - Worker is at the source location.
    ;;     - Source and destination are connected.
    ;;
    ;; Effects:
    ;;     - Worker leaves source location.
    ;;     - Worker arrives at destination.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action worker_travel
        :parameters (?w - worker ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (at ?w ?from))
                (at ?w ?to)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: unload
    ;;
    ;; Purpose:
    ;;     Receive a package into the warehouse.
    ;;
    ;; Preconditions:
    ;;     - Worker and package are together.
    ;;     - Package has not already arrived.
    ;;     - Destination is an arrival zone.
    ;;     - Locations are connected.
    ;;
    ;; Effects:
    ;;     - Package enters the warehouse system.
    ;;     - Package becomes marked as arrived.
    ;;     - Worker moves with the package.
    ;;
    ;; Workflow Stage:
    ;;     First stage of processing.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action unload
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)
                (not (arrived ?y))
                (is_arrival_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (arrived ?y)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: split_mixed_palette
    ;;
    ;; Purpose:
    ;;     Split a mixed palette into standard palettes.
    ;;
    ;; Business Rule:
    ;;     Mixed palettes cannot enter storage directly.
    ;;     They must first be separated into standard packages.
    ;;
    ;; Preconditions:
    ;;     - Worker is present.
    ;;     - Mixed palette is in an arrival zone.
    ;;     - Mixed palette has arrived.
    ;;     - Mixed palette has not already been split.
    ;;
    ;; Effects:
    ;;     - Mixed palette is marked as split.
    ;;     - Mixed palette is marked as processed.
    ;;     - Original mixed palette disappears.
    ;;     - Two standard packages are created.
    ;;     - New packages inherit the arrived status.
    ;;
    ;; Workflow Stage:
    ;;     Optional stage for mixed palettes only.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action split_mixed_palette
        :parameters (?w - worker ?ymix - mixed ?y1 - standard ?y2 - standard ?l - loc)

        :precondition
            (and
                (at ?w ?l)
                (is_arrival_zone ?l)
                (on ?ymix ?l)
                (arrived ?ymix)
                (not (is_split ?ymix))
            )

        :effect
            (and
                (is_split ?ymix)
                (processed ?ymix)

                (not (on ?ymix ?l))

                (on ?y1 ?l)
                (arrived ?y1)

                (on ?y2 ?l)
                (arrived ?y2)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: stockage
    ;;
    ;; Purpose:
    ;;     Move a package into storage.
    ;;
    ;; Business Rule:
    ;;     Mixed palettes cannot be stored directly.
    ;;     Only standard packages may enter storage.
    ;;
    ;; Preconditions:
    ;;     - Package has arrived.
    ;;     - Package is not mixed.
    ;;     - Package has not been prepared.
    ;;     - Destination is a storage zone.
    ;;
    ;; Effects:
    ;;     - Package is moved to storage.
    ;;     - Worker moves with the package.
    ;;
    ;; Workflow Stage:
    ;;     Storage stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action stockage
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (arrived ?y)
                (not (is_mixed ?y))
                (not (prepared ?y))

                (is_storage_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: prepare_command
    ;;
    ;; Purpose:
    ;;     Prepare a package for shipment.
    ;;
    ;; Preconditions:
    ;;     - Worker and package are together.
    ;;     - Package has not already been controlled.
    ;;     - Destination is a preparation zone.
    ;;
    ;; Effects:
    ;;     - Package becomes prepared.
    ;;     - Package is moved to preparation area.
    ;;     - Worker moves with package.
    ;;
    ;; Workflow Stage:
    ;;     Preparation stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action prepare_command
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (not (controlled ?y))

                (is_prep_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (prepared ?y)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: control_check
    ;;
    ;; Purpose:
    ;;     Inspect and validate a prepared package.
    ;;
    ;; Preconditions:
    ;;     - Package is prepared.
    ;;     - Package has not already been loaded.
    ;;     - Destination is a control zone.
    ;;
    ;; Effects:
    ;;     - Package passes inspection.
    ;;     - Package becomes controlled.
    ;;     - Worker moves with package.
    ;;
    ;; Workflow Stage:
    ;;     Quality-control stage.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action control_check
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (prepared ?y)
                (not (loaded ?y))

                (is_control_zone ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (controlled ?y)
            )
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ACTION: load_truck
    ;;
    ;; Purpose:
    ;;     Load a validated package onto an outgoing shipment location.
    ;;
    ;; Preconditions:
    ;;     - Package has passed control.
    ;;     - Destination is a shipping dock.
    ;;
    ;; Effects:
    ;;     - Package becomes loaded.
    ;;     - Package reaches final shipment stage.
    ;;     - Worker moves with package.
    ;;
    ;; Workflow Stage:
    ;;     Final stage of the process.
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:action load_truck
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)

        :precondition
            (and
                (at ?w ?from)
                (on ?y ?from)

                (controlled ?y)

                (is_shipping_dock ?to)
                (connected ?from ?to)
            )

        :effect
            (and
                (not (on ?y ?from))
                (on ?y ?to)

                (not (at ?w ?from))
                (at ?w ?to)

                (loaded ?y)
            )
    )
)