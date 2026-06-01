(define (domain PROJECT_TER)
    (:requirements :strips :typing :fluents)
    (:types 
        product package location - object
        locatable - object
    )
    
    ;; Make products and packages inherit from locatable
    (:types product package - locatable)

    (:predicates 
        (at-loc ?obj - locatable ?l - location)
        (prepared ?p - package)
    )
    
    (:functions
        (count-in-package ?pr - product ?p - package)
        (total-in-package ?p - package)
        (capacity ?p - package)
    )

    (:action move-to-prep
        :parameters (?pr - product ?l-arr - location ?l-prep - location)
        :precondition (at-loc ?pr ?l-arr)
        :effect (and (not (at-loc ?pr ?l-arr)) (at-loc ?pr ?l-prep))
    )

    (:action sort-into-package
        :parameters (?pr - product ?p - package ?l - location)
        :precondition (and 
            (at-loc ?pr ?l) 
            (at-loc ?p ?l)
            (< (total-in-package ?p) (capacity ?p))
        )
        :effect (and 
            (increase (count-in-package ?pr ?p) 1)
            (increase (total-in-package ?p) 1)
            (not (at-loc ?pr ?l))
        )
    )
)