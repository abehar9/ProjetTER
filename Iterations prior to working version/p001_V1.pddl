(define (problem daily-orders)
  (:domain warehouse)
  (:objects 
      a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 - product
      b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 - product
      c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 - product
      typeA typeB typeC - product-type
      cmd1 cmd2 cmd3 - command
      worker1 worker2 - worker
  )
  
  (:init 
      ;; Workers are ready
      (free worker1)
      (free worker2)
      
      ;; Inventory stock
      (in-inventory a1) (in-inventory a2) (in-inventory a3) (in-inventory a4) (in-inventory a5)
      (in-inventory a6) (in-inventory a7) (in-inventory a8) (in-inventory a9) (in-inventory a10)
      (in-inventory b1) (in-inventory b2) (in-inventory b3) (in-inventory b4) (in-inventory b5)
      (in-inventory b6) (in-inventory b7) (in-inventory b8) (in-inventory b9) (in-inventory b10)
      (in-inventory c1) (in-inventory c2) (in-inventory c3) (in-inventory c4) (in-inventory c5)
      (in-inventory c6) (in-inventory c7) (in-inventory c8) (in-inventory c9) (in-inventory c10)

      ;; Define product types
      (is-type a1 typeA) (is-type a2 typeA) (is-type a3 typeA) (is-type a4 typeA) (is-type a5 typeA)
      (is-type a6 typeA) (is-type a7 typeA) (is-type a8 typeA) (is-type a9 typeA) (is-type a10 typeA)
      (is-type b1 typeB) (is-type b2 typeB) (is-type b3 typeB) (is-type b4 typeB) (is-type b5 typeB)
      (is-type b6 typeB) (is-type b7 typeB) (is-type b8 typeB) (is-type b9 typeB) (is-type b10 typeB)
      (is-type c1 typeC) (is-type c2 typeC) (is-type c3 typeC) (is-type c4 typeC) (is-type c5 typeC)
      (is-type c6 typeC) (is-type c7 typeC) (is-type c8 typeC) (is-type c9 typeC) (is-type c10 typeC)
  )
  
  (:goal (and 
      ;; Command 1: 2a, 1b, 1c
      (assigned a1 cmd1) (assigned a2 cmd1) (assigned b1 cmd1) (assigned c1 cmd1)
      (command-complete cmd1) (order-label-scanned cmd1)
      
      ;; Command 2: 3b, 1c
      (assigned b2 cmd2) (assigned b3 cmd2) (assigned b4 cmd2) (assigned c2 cmd2)
      (command-complete cmd2) (order-label-scanned cmd2)
      
      ;; Command 3: 5a
      (assigned a3 cmd3) (assigned a4 cmd3) (assigned a5 cmd3) (assigned a6 cmd3) (assigned a7 cmd3)
      (command-complete cmd3) (order-label-scanned cmd3)
  ))
)