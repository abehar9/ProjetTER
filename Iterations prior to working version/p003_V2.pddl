(define (problem two-command-warehouse)
  (:domain warehouse)
  (:objects 
      a1 a2 b1 b2 - product
      typeA typeB - product-type
      cmd1 cmd2 - command
      worker1 - worker
      locStart locA locB - location
  )
  
  (:init 
      (free worker1)
      (at worker1 locStart)
      (start-loc locStart)
      
      ;; Inventory items
      (in-inventory a1) (in-inventory a2) (in-inventory b1) (in-inventory b2)
      
      ;; Mapping
      (at-loc a1 locA) (at-loc a2 locA) 
      (at-loc b1 locB) (at-loc b2 locB)
      (is-type a1 typeA) (is-type a2 typeA) 
      (is-type b1 typeB) (is-type b2 typeB)
      
      ;; Zones
      (type-zone typeA locA) (type-zone typeB locB)
  )
  
  (:goal (and 
      (command-complete cmd1)
      (command-complete cmd2)
      (assigned a1 cmd1) (assigned b1 cmd1)
      (assigned a2 cmd2) (assigned b2 cmd2)
  ))
)
