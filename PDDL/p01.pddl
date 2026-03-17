(define (problem P01)
(:domain WAREHOUSE)
(:objects
    pkg1 - package
    p1 - person
    a1 - arrivaldoc
    s1 - storage
    l1 - loadingdoc
)

(:init
    (at pkg1 a1)
    (at p1 a1)
    (hands-empty p1)
    (connected a1 s1) (connected s1 a1) ; Path between Arrival and Storage
    (connected s1 l1) (connected l1 s1) ; Path between Storage and Loading
)

(:goal 
    (and 
        (at pkg1 l1) 
        (processed pkg1)
        (at p1 a1)

    )
)
)