(define (problem warehouse-safe)

(:domain warehouse)

(:objects
    worker1 - worker
    cmd1 cmd2 - command
    typeA typeB - product-type
    locStart locA locB - location
    a1 a2 a3 b1 b2 b3 - product
)

(:init

    (free worker1)
    (at worker1 locStart)
    (start-loc locStart)

    (type-zone typeA locA)
    (type-zone typeB locB)

    (is-type a1 typeA)
    (is-type a2 typeA)
    (is-type a3 typeA)

    (is-type b1 typeB)
    (is-type b2 typeB)
    (is-type b3 typeB)

    (at-loc a1 locA)
    (at-loc a2 locA)
    (at-loc a3 locA)

    (at-loc b1 locB)
    (at-loc b2 locB)
    (at-loc b3 locB)

    (in-inventory a1)
    (in-inventory a2)
    (in-inventory a3)

    (in-inventory b1)
    (in-inventory b2)
    (in-inventory b3)

    ;; requirements
    (required-type cmd1 typeA)
    (required-type cmd1 typeB)

    (required-type cmd2 typeA)
    (required-type cmd2 typeB)
)

(:goal
    (and
        (command-complete cmd1)
        (command-complete cmd2)
    )
)
)