;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: warehouse-two-workers-assigned
;;
;; Purpose:
;;   Minimal warehouse scenario used to test:
;;     - Two workers executing parallel commands
;;     - Explicit product-to-command assignment enforcement
;;     - Zone-based picking constraints (typeA / typeB)
;;
;; Key Idea:
;;   This is a reduced test case designed to verify that:
;;     - Planning requires explicit assignments
;;     - Commands are split across workers logically
;;     - System respects product-type constraints
;;
;; Structure:
;;   - Worker initialization
;;   - Warehouse layout (zones + locations)
;;   - Product inventory setup
;;   - Command requirements
;;   - Explicit assignment goal constraints
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem warehouse-two-workers-assigned)

(:domain warehouse)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OBJECTS
;;
;; Purpose:
;;   Defines the minimal set of entities needed to execute the scenario:
;;     - Workers performing tasks
;;     - Commands representing orders
;;     - Product types defining classification rules
;;     - Locations representing warehouse zones
;;     - Products (small controlled dataset for testing)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:objects

    ;; ==========================
    ;; WORKERS
    ;; ==========================

    worker1 worker2 - worker

    ;; ==========================
    ;; COMMANDS
    ;; ==========================

    cmd1 cmd2 - command

    ;; ==========================
    ;; PRODUCT TYPES
    ;; ==========================

    typeA typeB - product-type

    ;; ==========================
    ;; LOCATIONS
    ;; ==========================

    locStart locA locB - location

    ;; ==========================
    ;; PRODUCTS
    ;; ==========================

    a1 a2 a3 a4 - product
    b1 b2 b3 b4 - product

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INITIAL STATE
;;
;; Purpose:
;;   Defines the starting warehouse configuration:
;;     - Worker positions and availability
;;     - Zone mapping for product types
;;     - Product classification and placement
;;     - Inventory availability
;;     - Command requirements
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:init

    ;; ==========================
    ;; WORKER STATE
    ;; ==========================

    (free worker1)
    (free worker2)

    (at worker1 locStart)
    (at worker2 locStart)

    ;; ==========================
    ;; START LOCATION
    ;; ==========================

    (start-loc locStart)

    ;; ==========================
    ;; ZONE CONFIGURATION
    ;; ==========================

    (type-zone typeA locA)
    (type-zone typeB locB)

    ;; ==========================
    ;; PRODUCT CLASSIFICATION
    ;; ==========================

    (is-type a1 typeA)
    (is-type a2 typeA)
    (is-type a3 typeA)
    (is-type a4 typeA)

    (is-type b1 typeB)
    (is-type b2 typeB)
    (is-type b3 typeB)
    (is-type b4 typeB)

    ;; ==========================
    ;; PRODUCT LOCATIONS
    ;; ==========================

    (at-loc a1 locA)
    (at-loc a2 locA)
    (at-loc a3 locA)
    (at-loc a4 locA)

    (at-loc b1 locB)
    (at-loc b2 locB)
    (at-loc b3 locB)
    (at-loc b4 locB)

    ;; ==========================
    ;; INVENTORY STATE
    ;; ==========================

    (in-inventory a1)
    (in-inventory a2)
    (in-inventory a3)
    (in-inventory a4)

    (in-inventory b1)
    (in-inventory b2)
    (in-inventory b3)
    (in-inventory b4)

    ;; ==========================
    ;; COMMAND REQUIREMENTS
    ;; ==========================

    (requires-type cmd1 typeA)
    (requires-type cmd1 typeB)

    (requires-type cmd2 typeA)
    (requires-type cmd2 typeB)

    ;; ==========================================================
    ;; CRITICAL SECTION: EXPLICIT PRODUCT ASSIGNMENT
    ;;
    ;; Purpose:
    ;;   This section enforces deterministic goal structure by:
    ;;     - Forcing exact product-to-command mapping
    ;;     - Preventing ambiguous or partial solutions
    ;;     - Ensuring planner must assign specific products
    ;;
    ;; Effect:
    ;;   - cmd1 must receive a1, a2, b1, b2
    ;;   - cmd2 must receive a3, a4, b3, b4
    ;;
    ;; This makes the problem:
    ;;   - Fully constrained
    ;;   - Easy to validate
    ;;   - Suitable for testing planner correctness
    ;;
    ;; ==========================================================

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GOAL STATE
;;
;; Purpose:
;;   Defines success conditions:
;;     - Both commands must be completed
;;     - All required assignments must be satisfied
;;     - Ensures no shortcut solutions are possible
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(:goal
    (and

        ;; ==========================
        ;; COMPLETION CONDITIONS
        ;; ==========================

        (command-complete cmd1)
        (command-complete cmd2)

        ;; ==========================
        ;; CMD1 ASSIGNMENTS
        ;; ==========================

        (assigned a1 cmd1)
        (assigned a2 cmd1)

        (assigned b1 cmd1)
        (assigned b2 cmd1)

        ;; ==========================
        ;; CMD2 ASSIGNMENTS
        ;; ==========================

        (assigned a3 cmd2)
        (assigned a4 cmd2)

        (assigned b3 cmd2)
        (assigned b4 cmd2)

    )
)

)