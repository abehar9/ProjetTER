(define (problem warehouse-two-workers-48-products)

(:domain warehouse)

(:objects

    ;; workers
    worker1 worker2 - worker

    ;; commands
    cmd1 cmd2 - command

    ;; product types
    typeA typeB - product-type

    ;; locations
    locStart locA locB - location

    ;; type A products
    a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12
    a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 - product

    ;; type B products
    b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12
    b13 b14 b15 b16 b17 b18 b19 b20 b21 b22 b23 b24 - product
)

(:init

    ;; workers
    (free worker1)
    (free worker2)

    (at worker1 locStart)
    (at worker2 locStart)

    ;; start location
    (start-loc locStart)

    ;; zones
    (type-zone typeA locA)
    (type-zone typeB locB)

    ;; ==========================
    ;; PRODUCT TYPES
    ;; ==========================

    (is-type a1 typeA)
    (is-type a2 typeA)
    (is-type a3 typeA)
    (is-type a4 typeA)
    (is-type a5 typeA)
    (is-type a6 typeA)
    (is-type a7 typeA)
    (is-type a8 typeA)
    (is-type a9 typeA)
    (is-type a10 typeA)
    (is-type a11 typeA)
    (is-type a12 typeA)
    (is-type a13 typeA)
    (is-type a14 typeA)
    (is-type a15 typeA)
    (is-type a16 typeA)
    (is-type a17 typeA)
    (is-type a18 typeA)
    (is-type a19 typeA)
    (is-type a20 typeA)
    (is-type a21 typeA)
    (is-type a22 typeA)
    (is-type a23 typeA)
    (is-type a24 typeA)

    (is-type b1 typeB)
    (is-type b2 typeB)
    (is-type b3 typeB)
    (is-type b4 typeB)
    (is-type b5 typeB)
    (is-type b6 typeB)
    (is-type b7 typeB)
    (is-type b8 typeB)
    (is-type b9 typeB)
    (is-type b10 typeB)
    (is-type b11 typeB)
    (is-type b12 typeB)
    (is-type b13 typeB)
    (is-type b14 typeB)
    (is-type b15 typeB)
    (is-type b16 typeB)
    (is-type b17 typeB)
    (is-type b18 typeB)
    (is-type b19 typeB)
    (is-type b20 typeB)
    (is-type b21 typeB)
    (is-type b22 typeB)
    (is-type b23 typeB)
    (is-type b24 typeB)

    ;; ==========================
    ;; LOCATIONS
    ;; ==========================

    (at-loc a1 locA)
    (at-loc a2 locA)
    (at-loc a3 locA)
    (at-loc a4 locA)
    (at-loc a5 locA)
    (at-loc a6 locA)
    (at-loc a7 locA)
    (at-loc a8 locA)
    (at-loc a9 locA)
    (at-loc a10 locA)
    (at-loc a11 locA)
    (at-loc a12 locA)
    (at-loc a13 locA)
    (at-loc a14 locA)
    (at-loc a15 locA)
    (at-loc a16 locA)
    (at-loc a17 locA)
    (at-loc a18 locA)
    (at-loc a19 locA)
    (at-loc a20 locA)
    (at-loc a21 locA)
    (at-loc a22 locA)
    (at-loc a23 locA)
    (at-loc a24 locA)

    (at-loc b1 locB)
    (at-loc b2 locB)
    (at-loc b3 locB)
    (at-loc b4 locB)
    (at-loc b5 locB)
    (at-loc b6 locB)
    (at-loc b7 locB)
    (at-loc b8 locB)
    (at-loc b9 locB)
    (at-loc b10 locB)
    (at-loc b11 locB)
    (at-loc b12 locB)
    (at-loc b13 locB)
    (at-loc b14 locB)
    (at-loc b15 locB)
    (at-loc b16 locB)
    (at-loc b17 locB)
    (at-loc b18 locB)
    (at-loc b19 locB)
    (at-loc b20 locB)
    (at-loc b21 locB)
    (at-loc b22 locB)
    (at-loc b23 locB)
    (at-loc b24 locB)

    ;; ==========================
    ;; INVENTORY
    ;; ==========================

    (in-inventory a1)  (in-inventory a2)
    (in-inventory a3)  (in-inventory a4)
    (in-inventory a5)  (in-inventory a6)
    (in-inventory a7)  (in-inventory a8)
    (in-inventory a9)  (in-inventory a10)
    (in-inventory a11) (in-inventory a12)
    (in-inventory a13) (in-inventory a14)
    (in-inventory a15) (in-inventory a16)
    (in-inventory a17) (in-inventory a18)
    (in-inventory a19) (in-inventory a20)
    (in-inventory a21) (in-inventory a22)
    (in-inventory a23) (in-inventory a24)

    (in-inventory b1)  (in-inventory b2)
    (in-inventory b3)  (in-inventory b4)
    (in-inventory b5)  (in-inventory b6)
    (in-inventory b7)  (in-inventory b8)
    (in-inventory b9)  (in-inventory b10)
    (in-inventory b11) (in-inventory b12)
    (in-inventory b13) (in-inventory b14)
    (in-inventory b15) (in-inventory b16)
    (in-inventory b17) (in-inventory b18)
    (in-inventory b19) (in-inventory b20)
    (in-inventory b21) (in-inventory b22)
    (in-inventory b23) (in-inventory b24)

    ;; ==========================
    ;; COMMAND REQUIREMENTS
    ;; ==========================

    (requires-type cmd1 typeA)
    (requires-type cmd1 typeB)

    (requires-type cmd2 typeA)
    (requires-type cmd2 typeB)

)

(:goal
(and

    (command-complete cmd1)
    (command-complete cmd2)

    ;; CMD1 gets A1-A12 and B1-B12

    (assigned a1 cmd1)
    (assigned a2 cmd1)
    (assigned a3 cmd1)
    (assigned a4 cmd1)
    (assigned a5 cmd1)
    (assigned a6 cmd1)
    (assigned a7 cmd1)
    (assigned a8 cmd1)
    (assigned a9 cmd1)
    (assigned a10 cmd1)
    (assigned a11 cmd1)
    (assigned a12 cmd1)

    (assigned b1 cmd1)
    (assigned b2 cmd1)
    (assigned b3 cmd1)
    (assigned b4 cmd1)
    (assigned b5 cmd1)
    (assigned b6 cmd1)
    (assigned b7 cmd1)
    (assigned b8 cmd1)
    (assigned b9 cmd1)
    (assigned b10 cmd1)
    (assigned b11 cmd1)
    (assigned b12 cmd1)

    ;; CMD2 gets A13-A24 and B13-B24

    (assigned a13 cmd2)
    (assigned a14 cmd2)
    (assigned a15 cmd2)
    (assigned a16 cmd2)
    (assigned a17 cmd2)
    (assigned a18 cmd2)
    (assigned a19 cmd2)
    (assigned a20 cmd2)
    (assigned a21 cmd2)
    (assigned a22 cmd2)
    (assigned a23 cmd2)
    (assigned a24 cmd2)

    (assigned b13 cmd2)
    (assigned b14 cmd2)
    (assigned b15 cmd2)
    (assigned b16 cmd2)
    (assigned b17 cmd2)
    (assigned b18 cmd2)
    (assigned b19 cmd2)
    (assigned b20 cmd2)
    (assigned b21 cmd2)
    (assigned b22 cmd2)
    (assigned b23 cmd2)
    (assigned b24 cmd2)

)
)

)