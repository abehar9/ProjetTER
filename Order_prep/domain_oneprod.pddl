(define (domain warehouse)
  (:requirements :strips :typing :negative-preconditions :universal-preconditions :quantified-preconditions :disjunctive-preconditions)
  (:types product product-type command worker location)
  
  (:predicates 
      (at ?w - worker ?l - location)
      (in-inventory ?p - product)
      (assigned ?p - product ?c - command)
      (free ?w - worker)
      (working-on ?w - worker ?c - command)
      (command-complete ?c - command)
      
      (mission-started ?c - command)
      (label-printed ?c - command)
      (ready-to-move ?c - command)
      (type-scanned ?t - product-type ?c - command)
      (checkpoint-verified ?t - product-type ?c - command)
      
      (is-type ?p - product ?t - product-type)
      (at-loc ?p - product ?l - location)
      (type-zone ?t - product-type ?l - location)
      (start-loc ?l - location)
      (items-picked-for-type ?t - product-type ?c - command)
      (picked ?p - product ?c - command)
)

  (:action New-mission-PDA
      :parameters (?w - worker ?c - command ?l - location)
      :precondition (and (free ?w) (at ?w ?l) (start-loc ?l) (not (mission-started ?c)))
      :effect (and (not (free ?w)) (working-on ?w ?c) (mission-started ?c))
  )

  (:action Print-Order-Label
      :parameters (?w - worker ?c - command ?l - location)
      :precondition (and (working-on ?w ?c) (at ?w ?l) (start-loc ?l) (not (label-printed ?c)))
      :effect (and (label-printed ?c) (ready-to-move ?c))
  )

(:action move
      :parameters (?w - worker ?from - location ?to - location)
      :precondition (and (at ?w ?from))
      :effect (and (not (at ?w ?from)) (at ?w ?to))
  )

  (:action Scan-Item-Type
      :parameters (?w - worker ?c - command ?t - product-type ?l - location)
      :precondition (and (working-on ?w ?c) (at ?w ?l) (type-zone ?t ?l) (not (type-scanned ?t ?c)))
      :effect (type-scanned ?t ?c)
  )

  (:action add-to-order
      :parameters (?w - worker ?c - command ?p - product ?t - product-type ?l - location)
      :precondition (and (working-on ?w ?c) (at ?w ?l) (at-loc ?p ?l) (type-scanned ?t ?c) (is-type ?p ?t) (in-inventory ?p))
      :effect (and (not (in-inventory ?p)) (assigned ?p ?c))
  )

  (:action Scan-Checkpoint
      :parameters (?w - worker ?c - command ?t - product-type ?l - location)
      :precondition (and 
          (working-on ?w ?c) 
          (at ?w ?l) 
          (type-zone ?t ?l) 
          (type-scanned ?t ?c)
          ;; FORCE: Every product that is at this location AND is of this type
          ;; MUST have been removed from inventory (assigned).
          (forall (?p - product) 
              (imply (and (is-type ?p ?t) (at-loc ?p ?l)) 
                     (not (in-inventory ?p))))
      )
      :effect (and (checkpoint-verified ?t ?c) (ready-to-move ?c))
    )


  (:action finish-command
      :parameters (?w - worker ?c - command)
      :precondition (and (working-on ?w ?c) 
                         (forall (?t - product-type) 
                             (imply (exists (?p - product) (is-type ?p ?t)) (checkpoint-verified ?t ?c))))
      :effect (and (free ?w) (not (working-on ?w ?c)) (command-complete ?c))
  )
)