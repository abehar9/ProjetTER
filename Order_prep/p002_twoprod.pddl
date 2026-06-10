(define (problem daily-orders)
  (:domain warehouse)
  (:objects 
      a1 a2 a3 b1 b2 - product
      typeA typeB - product-type
      cmd1 - command
      worker1 - worker
      locStart locA locB - location
  )
  
  (:init 
      (free worker1) (at worker1 locStart) (start-loc locStart)
      
      (in-inventory a1) (in-inventory a2) (in-inventory a3) (in-inventory b1) (in-inventory b2)
      (is-type a1 typeA) (is-type a2 typeA) (is-type a3 typeA) (is-type b1 typeB) (is-type b2 typeB)
      (at-loc a1 locA) (at-loc a2 locA) (at-loc a3 locA) (at-loc b1 locB) (at-loc b2 locB)
      (type-zone typeA locA) (type-zone typeB locB)
  )
  
  (:goal (and 
      (command-complete cmd1)
      (order-label-scanned typeA cmd1)
      (order-label-scanned typeB cmd1)
  ))
)