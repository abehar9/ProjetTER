(define (domain Project_TER)
    (:requirements :strips :typing :action-costs :disjunctive-preconditions)
    (:types loc worker fenwick package)
    (:predicates
        (at ?obj - object ?l - loc)
        (connected ?l1 - loc ?l2 - loc)
        (worker_mounted ?w - worker ?v - fenwick)
        (carrying ?v - fenwick ?p - package)
        (forklift_empty ?v - fenwick)
        (is_mono ?p - package)
        (is_mixed ?p - package)
        (contains ?p - package ?item - object)
        (empty ?p - package)
        (product_scanned ?p - package)
        (prepared ?p - package)
        (controlled ?p - package)
        (loaded ?p - package)
        (is_truck ?l - loc)
        (is_arrival_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
    )
    (:functions (total-cost))

    ;; Operational Actions
    (:action mount_fenwick
        :parameters (?w - worker ?v - fenwick ?l - loc)
        :precondition (and (at ?w ?l) (at ?v ?l))
        :effect (and (not (at ?w ?l)) (worker_mounted ?w ?v) (increase (total-cost) 5)))

    (:action dismount_fenwick
        :parameters (?w - worker ?v - fenwick ?l - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?l))
        :effect (and (at ?w ?l) (not (worker_mounted ?w ?v)) (increase (total-cost) 5)))

    (:action drive_fenwick
        :parameters (?w - worker ?v - fenwick ?from - loc ?to - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?from) (connected ?from ?to))
        :effect (and (not (at ?v ?from)) (at ?v ?to) (increase (total-cost) 50)))

    (:action load_forklift
        :parameters (?w - worker ?v - fenwick ?p - package ?l - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?l) (at ?p ?l) (forklift_empty ?v))
        :effect (and (not (at ?p ?l)) (carrying ?v ?p) (not (forklift_empty ?v)) (increase (total-cost) 5)))

    (:action unload_forklift
        :parameters (?w - worker ?v - fenwick ?p - package ?l - loc)
        :precondition (and (worker_mounted ?w ?v) (at ?v ?l) (carrying ?v ?p))
        :effect (and (at ?p ?l) (not (carrying ?v ?p)) (forklift_empty ?v) (increase (total-cost) 5)))

    ;; Processing Actions (Restored with necessary logical chaining)
    (:action scan_product
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and (at ?p ?l) (or (at ?w ?l) (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l) (forklift_empty ?v)))))
        :effect (and (product_scanned ?p) (increase (total-cost) 1)))

    (:action sort_into_new_palette
        :parameters (?w - worker ?mixed_pal - package ?item - object ?target_pal - package ?l - loc)
        :precondition (and (at ?w ?l) (at ?mixed_pal ?l) (at ?target_pal ?l) (is_mixed ?mixed_pal) (contains ?mixed_pal ?item) (empty ?target_pal) (is_arrival_zone ?l))
        ;; Logic fix: ensure the sorted palette inherits necessary status for the next steps
        :effect (and (not (contains ?mixed_pal ?item)) (not (empty ?target_pal)) (is_mono ?target_pal) (product_scanned ?target_pal) (prepared ?target_pal) (increase (total-cost) 15)))

    (:action mark_prepared
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and (at ?p ?l) (product_scanned ?p) (is_mono ?p) (is_prep_zone ?l) (or (at ?w ?l) (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l) (forklift_empty ?v)))))
        :effect (and (prepared ?p) (increase (total-cost) 2)))

    (:action mark_controlled
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and (at ?p ?l) (prepared ?p) (is_control_zone ?l) (or (at ?w ?l) (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l) (forklift_empty ?v)))))
        :effect (and (controlled ?p) (increase (total-cost) 2)))

    (:action mark_loaded
        :parameters (?w - worker ?p - package ?l - loc)
        :precondition (and (at ?p ?l) (controlled ?p) (is_shipping_dock ?l) (or (at ?w ?l) (exists (?v - fenwick) (and (worker_mounted ?w ?v) (at ?v ?l) (forklift_empty ?v)))))
        :effect (and (loaded ?p) (increase (total-cost) 2)))
)