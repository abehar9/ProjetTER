(define (domain Project_TER)
    (:requirements :strips :typing :negative-preconditions)
    
    (:types 
        loc package worker - object
    )
    
    (:predicates 
        (on ?y - package ?l - loc)
        (at ?w - worker ?l - loc)
        (arrived ?y - package)
        (prepared ?y - package)
        (controlled ?y - package)
        (loaded ?y - package)
        (connected ?l1 - loc ?l2 - loc)
        
        ;; Zone Roles
        (is_arrival_zone ?l - loc)
        (is_storage_zone ?l - loc)
        (is_prep_zone ?l - loc)
        (is_control_zone ?l - loc)
        (is_shipping_dock ?l - loc)
    )

    ;; Empty move for the cariste
    (:action worker_travel
        :parameters (?w - worker ?from - loc ?to - loc)
        :precondition (and (at ?w ?from) (connected ?from ?to))
        :effect (and (not (at ?w ?from)) (at ?w ?to))
    )

    ;; 1. UNLOAD: Only if NOT arrived yet
    (:action unload
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)
        :precondition (and 
            (at ?w ?from) (on ?y ?from) 
            (not (arrived ?y)) 
            (is_arrival_zone ?to)
            (connected ?from ?to))
        :effect (and 
            (not (on ?y ?from)) (on ?y ?to)
            (not (at ?w ?from)) (at ?w ?to)
            (arrived ?y))
    )

    ;; 2. STOCKAGE: Only if arrived but NOT prepared yet
    (:action stockage
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)
        :precondition (and 
            (at ?w ?from) (on ?y ?from) 
            (arrived ?y)
            (not (prepared ?y))
            (is_storage_zone ?to)
            (connected ?from ?to))
        :effect (and 
            (not (on ?y ?from)) (on ?y ?to)
            (not (at ?w ?from)) (at ?w ?to))
    )

    ;; 3. PREPARE: Only if NOT controlled yet
    (:action prepare_command
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)
        :precondition (and 
            (at ?w ?from) (on ?y ?from) 
            (not (controlled ?y))
            (is_prep_zone ?to)
            (connected ?from ?to))
        :effect (and 
            (not (on ?y ?from)) (on ?y ?to)
            (not (at ?w ?from)) (at ?w ?to)
            (prepared ?y))
    )

    ;; 4. CONTROL: Only if prepared but NOT loaded yet
    (:action control_check
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)
        :precondition (and 
            (at ?w ?from) (on ?y ?from) 
            (prepared ?y)
            (not (loaded ?y))
            (is_control_zone ?to)
            (connected ?from ?to))
        :effect (and 
            (not (on ?y ?from)) (on ?y ?to)
            (not (at ?w ?from)) (at ?w ?to)
            (controlled ?y))
    )

    ;; 5. LOAD: Only if controlled
    (:action load_truck
        :parameters (?w - worker ?y - package ?from - loc ?to - loc)
        :precondition (and 
            (at ?w ?from) (on ?y ?from) 
            (controlled ?y)
            (is_shipping_dock ?to)
            (connected ?from ?to))
        :effect (and 
            (not (on ?y ?from)) (on ?y ?to)
            (not (at ?w ?from)) (at ?w ?to)
            (loaded ?y))
    )
)