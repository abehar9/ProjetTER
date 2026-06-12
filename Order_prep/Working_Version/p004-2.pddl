(define (problem warehouse-test2)

  (:domain warehouse)

  (:objects

      worker1 - worker

      cmd1 cmd2 - command

      typeA typeB - product-type

      locStart locA locB - location

      a1 a2 b1 b2 - product

  )

  (:init

      ;; worker position
      (free worker1)
      (at worker1 locStart)

      ;; start location
      (start-loc locStart)

      ;; type zones
      (type-zone typeA locA)
      (type-zone typeB locB)

      ;; products and locations
      (is-type a1 typeA)
      (is-type a2 typeA)

      (is-type b1 typeB)
      (is-type b2 typeB)

      (at-loc a1 locA)
      (at-loc a2 locA)

      (at-loc b1 locB)
      (at-loc b2 locB)

      ;; inventory
      (in-inventory a1)
      (in-inventory a2)
      (in-inventory b1)
      (in-inventory b2)

      ;; command requirements
      (requires-type cmd1 typeA)
      (requires-type cmd1 typeB)

      (requires-type cmd2 typeA)
      (requires-type cmd2 typeB)

          ;; weights by type
      (= (weight typeA) 1)
      (= (weight typeB) 2)

    ;; worker loads
      (= (worker-load worker1) 0)
      (= (worker-load worker2) 0)

    )

    (:goal
        (and
            (command-complete cmd1)
            (command-complete cmd2)

            ;; FORCE actual picking
            (assigned a1 cmd1)
            (assigned b1 cmd1)

            (assigned a2 cmd2)
            (assigned b2 cmd2)
        )
    )   

)