(define (problem PREP-TASK-V2)
    (:domain PROJECT_TER)
    (:objects 
        prod-a prod-b - product
        p1 p2 - package
        arr-zone prep-zone dep-zone - location
    )

    (:init 
        (= (capacity p1) 7)
        (= (capacity p2) 7)
        (= (total-in-package p1) 3)
        (= (total-in-package p2) 2)
        (= (count-in-package prod-a p1) 3)
        (= (count-in-package prod-b p2) 2)

        (at-loc p1 prep-zone)
        (at-loc p2 prep-zone)
        (at-loc prod-a arr-zone) ;; Ensure initial locations are set
    )

    (:goal (and 
        (>= (count-in-package prod-a p1) 5)
        (>= (count-in-package prod-b p2) 5)
    ))
)