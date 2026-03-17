(define (problem P02)
(:domain WAREHOUSE)
(:objects
    pkg1 - package
    pkg2 - package
    pkg3 - package
    p1 - person
    p2 - person
    a1 - arrivaldoc
    s1 - storage
    l1 - loadingdoc
)

(:init
    (at pkg1 a1)
    (at pkg2 a1)
    (at pkg3 a1)
    (at p1 a1)
    (at p2 s1)
    (hands-empty p1)
    (hands-empty p2)
    (connected a1 s1) (connected s1 a1) ; Path between Arrival and Storage
    (connected s1 l1) (connected l1 s1) ; Path between Storage and Loading
)

(:goal 
    (and 
        (at pkg1 l1) 
        (at pkg2 l1) 
        (at pkg3 l1) 
        (processed pkg1)
        (processed pkg2)
        (processed pkg3)
        (at p1 a1)
        (at p2 s1)

    )
)

)