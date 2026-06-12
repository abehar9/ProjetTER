;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROBLEM: warehouse-test
;;
;; Purpose:
;;   This problem instance defines a small warehouse execution scenario where:
;;     - One worker executes two commands
;;     - Products are distributed across type-based zones
;;     - Each command requires multi-type fulfillment
;;     - Goal is full completion of both commands with explicit assignments
;;
;; Structure:
;;   - Initial worker state and position
;;   - Warehouse layout (zones + locations)
;;   - Product inventory and placement
;;   - Command requirements
;;   - Goal conditions enforcing full execution
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (problem warehouse-test)

  (:domain warehouse)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; OBJECTS
  ;;
  ;; Purpose:
  ;;   Defines all entities in the warehouse system:
  ;;     - Workers executing commands
  ;;     - Commands representing orders
  ;;     - Product types for classification
  ;;     - Locations representing warehouse zones
  ;;     - Products to be picked
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (:objects

      worker1 - worker

      cmd1 cmd2 - command

      typeA typeB - product-type

      locStart locA locB - location

      a1 a2 b1 b2 - product

  )

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; INITIAL STATE
  ;;
  ;; Purpose:
  ;;   Defines the starting configuration of the warehouse:
  ;;     - Worker position and availability
  ;;     - Zone mapping for product types
  ;;     - Product placement in warehouse
  ;;     - Inventory availability
  ;;     - Command requirements
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (:init

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; WORKER STATE
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      (free worker1)
      (at worker1 locStart)

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; START LOCATION
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      (start-loc locStart)

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; ZONE CONFIGURATION
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      (type-zone typeA locA)
      (type-zone typeB locB)

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; PRODUCT CLASSIFICATION
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      (is-type a1 typeA)
      (is-type a2 typeA)

      (is-type b1 typeB)
      (is-type b2 typeB)

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; PRODUCT LOCATIONS
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      (at-loc a1 locA)
      (at-loc a2 locA)

      (at-loc b1 locB)
      (at-loc b2 locB)

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; INVENTORY STATE
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      (in-inventory a1)
      (in-inventory a2)
      (in-inventory b1)
      (in-inventory b2)

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; COMMAND REQUIREMENTS
      ;;
      ;; Purpose:
      ;;   Each command requires at least one product of each type.
      ;;   This forces multi-zone traversal and verification.
      ;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      (requires-type cmd1 typeA)
      (requires-type cmd1 typeB)

      (requires-type cmd2 typeA)
      (requires-type cmd2 typeB)

  )

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; GOAL STATE
  ;;
  ;; Purpose:
  ;;   Defines success conditions for the planning problem:
  ;;     - Both commands must be fully completed
  ;;     - Required products must be explicitly assigned
  ;;     - Ensures actual picking actions are performed
  ;;
  ;; Key Constraint:
  ;;   The goal enforces not just completion, but correctness of assignment.
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (:goal
      (and
          (command-complete cmd1)
          (command-complete cmd2)

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;; STRICT EXECUTION CHECK
          ;;
          ;; Purpose:
          ;;   Forces planners to actually perform pickup actions
          ;;   instead of shortcutting completion.
          ;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          (assigned a1 cmd1)
          (assigned b1 cmd1)

          (assigned a2 cmd2)
          (assigned b2 cmd2)
      )
  )

)