(define (problem warehouse-two-workers-assigned)

(:domain warehouse)

(:objects

    worker1 worker2 - worker

    cmd1 cmd2 - command

    typeA typeB - product-type

    locStart locA locB - location

    ;; products
    a1 a2 a3 a4 - product
    b1 b2 b3 b4 - product

)

(:init

    ;; workers
    (free worker1)
    (free worker2)

    (at worker1 locStart)
    (at worker2 locStart)

    (start-loc locStart)

    ;; zones
    (type-zone typeA locA)
    (type-zone typeB locB)

    ;; product typing
    (is-type a1 typeA)
    (is-type a2 typeA)
    (is-type a3 typeA)
    (is-type a4 typeA)

    (is-type b1 typeB)
    (is-type b2 typeB)
    (is-type b3 typeB)
    (is-type b4 typeB)

    ;; locations
    (at-loc a1 locA)
    (at-loc a2 locA)
    (at-loc a3 locA)
    (at-loc a4 locA)

    (at-loc b1 locB)
    (at-loc b2 locB)
    (at-loc b3 locB)
    (at-loc b4 locB)

    ;; inventory
    (in-inventory a1)
    (in-inventory a2)
    (in-inventory a3)
    (in-inventory a4)

    (in-inventory b1)
    (in-inventory b2)
    (in-inventory b3)
    (in-inventory b4)

    ;; command requirements
    (requires-type cmd1 typeA)
    (requires-type cmd1 typeB)

    (requires-type cmd2 typeA)
    (requires-type cmd2 typeB)

    ;; =====================================================
    ;; 🔥 CRITICAL PART: EXPLICIT PRODUCT ASSIGNMENT
    ;; =====================================================



)

(:goal
    (and
        (command-complete cmd1)
        (command-complete cmd2)

        (assigned a1 cmd1)
        (assigned a2 cmd1)

        (assigned b1 cmd1)
        (assigned b2 cmd1)

        ;; CMD2 gets second half
        (assigned a3 cmd2)
        (assigned a4 cmd2)

        (assigned b3 cmd2)
        (assigned b4 cmd2)
    )
)

)