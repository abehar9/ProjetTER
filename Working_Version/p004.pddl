;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: warehouse-3cmd-3types (Fully Documented Standard Version)
;;
;; Purpose:
;; This problem instance models a warehouse execution scenario where:
;;   - 2 workers execute 3 independent commands (orders)
;;   - Each command requires all 3 product types (A, B, C)
;;   - Each product type contains 24 items
;;   - Workers must pick and assign products while respecting zone rules
;;
;; Scale:
;;   - 2 workers
;;   - 3 commands
;;   - 72 products total (24 × 3 types)
;;   - 3 product-type zones
;;
;; Goal:
;;   - Fully assign all required products to each command
;;   - Mark all commands as complete
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem warehouse-3cmd-3types)
(:domain warehouse)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; OBJECTS
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:objects

        ;; WORKERS
        worker1 worker2 - worker

        ;; COMMANDS (ORDERS)
        cmd1 cmd2 cmd3 - command

        ;; PRODUCT TYPES (WAREHOUSE ZONES)
        typeA typeB typeC - product-type

        ;; LOCATIONS (WAREHOUSE STRUCTURE)
        locStart locA locB locC - location

        ;; PRODUCTS TYPE A (24 items)
        a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16
        a17 a18 a19 a20 a21 a22 a23 a24 - product

        ;; PRODUCTS TYPE B (24 items)
        b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16
        b17 b18 b19 b20 b21 b22 b23 b24 - product

        ;; PRODUCTS TYPE C (24 items)
        c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 c16
        c17 c18 c19 c20 c21 c22 c23 c24 - product
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; INITIAL STATE
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:init

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; WORKER INITIAL STATE
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (free worker1)
        (free worker2)

        (at worker1 locStart)
        (at worker2 locStart)

        (start-loc locStart)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; TYPE ZONES (WAREHOUSE STRUCTURE)
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        (type-zone typeA locA)
        (type-zone typeB locB)
        (type-zone typeC locC)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PRODUCT TYPE ASSIGNMENTS
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; TYPE A PRODUCTS
        (is-type a1 typeA)  (is-type a2 typeA)  (is-type a3 typeA)  (is-type a4 typeA)
        (is-type a5 typeA)  (is-type a6 typeA)  (is-type a7 typeA)  (is-type a8 typeA)
        (is-type a9 typeA)  (is-type a10 typeA) (is-type a11 typeA) (is-type a12 typeA)
        (is-type a13 typeA) (is-type a14 typeA) (is-type a15 typeA) (is-type a16 typeA)
        (is-type a17 typeA) (is-type a18 typeA) (is-type a19 typeA) (is-type a20 typeA)
        (is-type a21 typeA) (is-type a22 typeA) (is-type a23 typeA) (is-type a24 typeA)

        ;; TYPE B PRODUCTS
        (is-type b1 typeB)  (is-type b2 typeB)  (is-type b3 typeB)  (is-type b4 typeB)
        (is-type b5 typeB)  (is-type b6 typeB)  (is-type b7 typeB)  (is-type b8 typeB)
        (is-type b9 typeB)  (is-type b10 typeB) (is-type b11 typeB) (is-type b12 typeB)
        (is-type b13 typeB) (is-type b14 typeB) (is-type b15 typeB) (is-type b16 typeB)
        (is-type b17 typeB) (is-type b18 typeB) (is-type b19 typeB) (is-type b20 typeB)
        (is-type b21 typeB) (is-type b22 typeB) (is-type b23 typeB) (is-type b24 typeB)

        ;; TYPE C PRODUCTS
        (is-type c1 typeC)  (is-type c2 typeC)  (is-type c3 typeC)  (is-type c4 typeC)
        (is-type c5 typeC)  (is-type c6 typeC)  (is-type c7 typeC)  (is-type c8 typeC)
        (is-type c9 typeC)  (is-type c10 typeC) (is-type c11 typeC) (is-type c12 typeC)
        (is-type c13 typeC) (is-type c14 typeC) (is-type c15 typeC) (is-type c16 typeC)
        (is-type c17 typeC) (is-type c18 typeC) (is-type c19 typeC) (is-type c20 typeC)
        (is-type c21 typeC) (is-type c22 typeC) (is-type c23 typeC) (is-type c24 typeC)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PRODUCT LOCATIONS
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; ALL TYPE A PRODUCTS IN LOC A
        (at-loc a1 locA)  (at-loc a2 locA)  (at-loc a3 locA)  (at-loc a4 locA)
        (at-loc a5 locA)  (at-loc a6 locA)  (at-loc a7 locA)  (at-loc a8 locA)
        (at-loc a9 locA)  (at-loc a10 locA) (at-loc a11 locA) (at-loc a12 locA)
        (at-loc a13 locA) (at-loc a14 locA) (at-loc a15 locA) (at-loc a16 locA)
        (at-loc a17 locA) (at-loc a18 locA) (at-loc a19 locA) (at-loc a20 locA)
        (at-loc a21 locA) (at-loc a22 locA) (at-loc a23 locA) (at-loc a24 locA)

        ;; ALL TYPE B PRODUCTS IN LOC B
        (at-loc b1 locB)  (at-loc b2 locB)  (at-loc b3 locB)  (at-loc b4 locB)
        (at-loc b5 locB)  (at-loc b6 locB)  (at-loc b7 locB)  (at-loc b8 locB)
        (at-loc b9 locB)  (at-loc b10 locB) (at-loc b11 locB) (at-loc b12 locB)
        (at-loc b13 locB) (at-loc b14 locB) (at-loc b15 locB) (at-loc b16 locB)
        (at-loc b17 locB) (at-loc b18 locB) (at-loc b19 locB) (at-loc b20 locB)
        (at-loc b21 locB) (at-loc b22 locB) (at-loc b23 locB) (at-loc b24 locB)

        ;; ALL TYPE C PRODUCTS IN LOC C
        (at-loc c1 locC)  (at-loc c2 locC)  (at-loc c3 locC)  (at-loc c4 locC)
        (at-loc c5 locC)  (at-loc c6 locC)  (at-loc c7 locC)  (at-loc c8 locC)
        (at-loc c9 locC)  (at-loc c10 locC) (at-loc c11 locC) (at-loc c12 locC)
        (at-loc c13 locC) (at-loc c14 locC) (at-loc c15 locC) (at-loc c16 locC)
        (at-loc c17 locC) (at-loc c18 locC) (at-loc c19 locC) (at-loc c20 locC)
        (at-loc c21 locC) (at-loc c22 locC) (at-loc c23 locC) (at-loc c24 locC)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; INVENTORY STATE (ALL PRODUCTS AVAILABLE)
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; TYPE A INVENTORY
        (in-inventory a1)  (in-inventory a2)  (in-inventory a3)  (in-inventory a4)
        (in-inventory a5)  (in-inventory a6)  (in-inventory a7)  (in-inventory a8)
        (in-inventory a9)  (in-inventory a10) (in-inventory a11) (in-inventory a12)
        (in-inventory a13) (in-inventory a14) (in-inventory a15) (in-inventory a16)
        (in-inventory a17) (in-inventory a18) (in-inventory a19) (in-inventory a20)
        (in-inventory a21) (in-inventory a22) (in-inventory a23) (in-inventory a24)

        ;; TYPE B INVENTORY
        (in-inventory b1)  (in-inventory b2)  (in-inventory b3)  (in-inventory b4)
        (in-inventory b5)  (in-inventory b6)  (in-inventory b7)  (in-inventory b8)
        (in-inventory b9)  (in-inventory b10) (in-inventory b11) (in-inventory b12)
        (in-inventory b13) (in-inventory b14) (in-inventory b15) (in-inventory b16)
        (in-inventory b17) (in-inventory b18) (in-inventory b19) (in-inventory b20)
        (in-inventory b21) (in-inventory b22) (in-inventory b23) (in-inventory b24)

        ;; TYPE C INVENTORY
        (in-inventory c1)  (in-inventory c2)  (in-inventory c3)  (in-inventory c4)
        (in-inventory c5)  (in-inventory c6)  (in-inventory c7)  (in-inventory c8)
        (in-inventory c9)  (in-inventory c10) (in-inventory c11) (in-inventory c12)
        (in-inventory c13) (in-inventory c14) (in-inventory c15) (in-inventory c16)
        (in-inventory c17) (in-inventory c18) (in-inventory c19) (in-inventory c20)
        (in-inventory c21) (in-inventory c22) (in-inventory c23) (in-inventory c24)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; COMMAND REQUIREMENTS
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; EACH COMMAND REQUIRES ALL TYPES (A, B, C)
        (requires-type cmd1 typeA) (requires-type cmd1 typeB) (requires-type cmd1 typeC)
        (requires-type cmd2 typeA) (requires-type cmd2 typeB) (requires-type cmd2 typeC)
        (requires-type cmd3 typeA) (requires-type cmd3 typeB) (requires-type cmd3 typeC)
    )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; GOAL STATE
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (:goal
        (and

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; ALL COMMANDS MUST BE COMPLETED
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            (command-complete cmd1)
            (command-complete cmd2)
            (command-complete cmd3)

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; ALL PRODUCTS MUST BE ASSIGNED
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            ;; COMMAND 1
            (assigned a1 cmd1) (assigned a2 cmd1) (assigned a3 cmd1) (assigned a4 cmd1)
            (assigned a5 cmd1) (assigned a6 cmd1) (assigned a7 cmd1) (assigned a8 cmd1)
            (assigned b1 cmd1) (assigned b2 cmd1) (assigned b3 cmd1) (assigned b4 cmd1)
            (assigned b5 cmd1) (assigned b6 cmd1) (assigned b7 cmd1) (assigned b8 cmd1)
            (assigned c1 cmd1) (assigned c2 cmd1) (assigned c3 cmd1) (assigned c4 cmd1)
            (assigned c5 cmd1) (assigned c6 cmd1) (assigned c7 cmd1) (assigned c8 cmd1)

            ;; COMMAND 2
            (assigned a9 cmd2) (assigned a10 cmd2) (assigned a11 cmd2) (assigned a12 cmd2)
            (assigned a13 cmd2) (assigned a14 cmd2) (assigned a15 cmd2) (assigned a16 cmd2)
            (assigned b9 cmd2) (assigned b10 cmd2) (assigned b11 cmd2) (assigned b12 cmd2)
            (assigned b13 cmd2) (assigned b14 cmd2) (assigned b15 cmd2) (assigned b16 cmd2)
            (assigned c9 cmd2) (assigned c10 cmd2) (assigned c11 cmd2) (assigned c12 cmd2)
            (assigned c13 cmd2) (assigned c14 cmd2) (assigned c15 cmd2) (assigned c16 cmd2)

            ;; COMMAND 3
            (assigned a17 cmd3) (assigned a18 cmd3) (assigned a19 cmd3) (assigned a20 cmd3)
            (assigned a21 cmd3) (assigned a22 cmd3) (assigned a23 cmd3) (assigned a24 cmd3)
            (assigned b17 cmd3) (assigned b18 cmd3) (assigned b19 cmd3) (assigned b20 cmd3)
            (assigned b21 cmd3) (assigned b22 cmd3) (assigned b23 cmd3) (assigned b24 cmd3)
            (assigned c17 cmd3) (assigned c18 cmd3) (assigned c19 cmd3) (assigned c20 cmd3)
            (assigned c21 cmd3) (assigned c22 cmd3) (assigned c23 cmd3) (assigned c24 cmd3)
        )
    )
)
