;java -cp ../build/libs/pddl4j-4.0.0.jar fr.uga.pddl4j.planners.statespace.FF domainsimple.pddl p01.pddl
;why this heuristic, what makes LPG different? force to stop at storage
;sequential solver is needed to model tasks at the same time, since this solver generates a sequential plan so doing things in parallel doesn't matter
(define (domain WAREHOUSE)
    (:requirements :strips :typing :negative-preconditions)
    (:types 
        package person - physobj
        carrier - person
        arrivaldoc storage loadingdoc - place
        place - object
        physobj - object
    )

    (:predicates (at ?obj - object ?loc - place)
    (carrying ?p - person ?pkg - package) ; Is the person holding the package?
    (hands-empty ?p - person) ; Is the person free to pick something up?
    (processed ?pkg - package) ;     package most be processed
    (connected ?from - place ?to - place)
    )
    
    (:action pick-up
        :parameters (?pkg - package ?p - person ?loc - place)
        :precondition (and (at ?pkg ?loc)(at ?p ?loc)(hands-empty ?p))
        :effect (and(not (at ?pkg ?loc)) (not (hands-empty ?p)) (carrying ?p ?pkg)))
        
    ;; Action: Carrier moves from one place to another
    (:action move
        :parameters (?p - person ?from - place ?to - place)
        :precondition (and (at ?p ?from) (connected ?from ?to)) ; <--- Must be connected!
        :effect (and (not (at ?p ?from)) (at ?p ?to))
    )

    ;; Action: Carrier drops the package at the new location
;; NEW ACTION: Only works when the person is at a 'storage' type location
    (:action process-package
        :parameters (?p - person ?pkg - package ?loc - storage) 
        :precondition (and (at ?p ?loc) (carrying ?p ?pkg))
        :effect (processed ?pkg)
    )

    (:action drop-off
        :parameters (?p - person ?pkg - package ?loc - place)
        :precondition (and (at ?p ?loc) (carrying ?p ?pkg))
        :effect (and (at ?pkg ?loc) (hands-empty ?p) (not (carrying ?p ?pkg)))
    )
)
    
 
            
        
    
