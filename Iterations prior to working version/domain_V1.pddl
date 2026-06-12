(define (domain warehouse)
  (:requirements :strips :typing :negative-preconditions)
  (:types product product-type command worker)
  
  (:predicates 
      (in-inventory ?p - product)
      (assigned ?p - product ?c - command)
      (free ?w - worker)
      (working-on ?w - worker ?c - command)
      (command-complete ?c - command)
      (order-label-printed ?c - command)
      (command-in-progress ?c - command)
      (type-scanned ?t - product-type ?c - command) ;; Scanned a type for a specific command
      (order-label-scanned ?c - command)
      (is-type ?p - product ?t - product-type)      ;; Links item to type
  )

  (:action New-mission-PDA
      :parameters (?w - worker ?c - command)
      :precondition (and (free ?w) (not (command-complete ?c)) (not (command-in-progress ?c)))
      :effect (and (not (free ?w)) (working-on ?w ?c) (command-in-progress ?c))
  )

  (:action Print-Order-Label
      :parameters (?w - worker ?c - command)
      :precondition (and (working-on ?w ?c) (not (order-label-printed ?c)))
      :effect (order-label-printed ?c)
  )

  ;; Scan the TYPE, not the item.
  (:action Scan-Item-Type-Barcode
      :parameters (?t - product-type ?c - command ?w - worker)
      :precondition (working-on ?w ?c)
      :effect (type-scanned ?t ?c)
  )

  (:action add-to-order
      :parameters (?p - product ?t - product-type ?c - command ?w - worker)
      :precondition (and (working-on ?w ?c) 
                         (order-label-printed ?c) 
                         (is-type ?p ?t)
                         (type-scanned ?t ?c) 
                         (in-inventory ?p))
      :effect (and (not (in-inventory ?p)) (assigned ?p ?c))
  )

  (:action finish-order-scanned
      :parameters (?w - worker ?c - command)
      :precondition (and (working-on ?w ?c) (order-label-printed ?c))
      :effect (and (free ?w) (not (working-on ?w ?c)) (not (command-in-progress ?c)) (command-complete ?c) (order-label-scanned ?c))
  )
)