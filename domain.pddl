(define (domain entrepot_reception)
  (:requirements :strips :typing :durative-actions :quantified-preconditions)
  
  (:types
    zone cariste pallet
  )

  (:predicates
    (at-cariste ?c - cariste ?z - zone)
    (at-pallet ?p - pallet ?z - zone)
    (in-truck ?p - pallet)
    (scanned-arrival ?p - pallet)
    (is-mono ?p - pallet)
    (is-mixed ?p - pallet)
    (is-exploded ?p - pallet)
    (belongs-to ?pe - pallet ?pm - pallet)
    (unwrapped ?p - pallet)
    (product-sorted ?pe - pallet)
    (wrapped ?p - pallet)
    (ready-for-label ?p - pallet)
    (label-attached ?p - pallet)
    (holding ?c - cariste ?p - pallet)
    (label-scanned ?p - pallet)
    (stored ?p - pallet)
    
    (available ?c - cariste)
    (is-arrival-zone ?z - zone)
    (is-storage-zone ?z - zone)
  )

  ;; 1. Déchargement du camion
  (:durative-action unload-pallet
    :parameters (?c - cariste ?p - pallet ?to - zone)
    :duration (= ?duration 48)
    :condition (and 
      (at start (available ?c))
      (at start (in-truck ?p))
      (over all (at-cariste ?c ?to))
      (over all (is-arrival-zone ?to))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at start (not (in-truck ?p)))
      (at end (at-pallet ?p ?to))
      (at end (available ?c))
    )
  )

  ;; 2. Scanner à l'arrivée 
  (:durative-action scan-arrival
    :parameters (?c - cariste ?p - pallet ?z - zone)
    :duration (= ?duration 10)
    :condition (and 
      (at start (available ?c))
      (over all (at-cariste ?c ?z))
      (at start (at-pallet ?p ?z))
      (over all (not (exists (?pa - pallet) (in-truck ?pa))))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at end (scanned-arrival ?p))
      (at end (available ?c))
    )
  )

  ;; 3. Préparer la palette Mono
  (:durative-action prepare-mono
    :parameters (?c - cariste ?p - pallet ?z - zone)
    :duration (= ?duration 5)
    :condition (and 
      (at start (available ?c))
      (over all (at-cariste ?c ?z))
      (at start (at-pallet ?p ?z))
      (at start (is-mono ?p))
      (at start (scanned-arrival ?p))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at end (ready-for-label ?p))
      (at end (available ?c))
    )
  )

  ;; 4. Défiler la palette mixte
  (:durative-action unwrap-mixed
    :parameters (?c - cariste ?p - pallet ?z - zone)
    :duration (= ?duration 60)
    :condition (and 
      (at start (available ?c))
      (at start (is-mixed ?p))
      (at start (scanned-arrival ?p))
      (over all (at-cariste ?c ?z))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at end (unwrapped ?p))
      (at end (available ?c))
    )
  )

  ;; 5. Tri et éclatement
  (:durative-action sort-to-exploded
    :parameters (?c - cariste ?pm - pallet ?pe - pallet ?z - zone)
    :duration (= ?duration 120)
    :condition (and 
      (at start (available ?c))
      (at start (is-mixed ?pm))
      (at start (unwrapped ?pm))
      (at start (is-exploded ?pe))
      (at start (belongs-to ?pe ?pm))
      (over all (at-cariste ?c ?z))
      (over all (at-pallet ?pm ?z))
      (over all (at-pallet ?pe ?z))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at end (product-sorted ?pe))
      (at end (available ?c))
    )
  )


  ;; 6. Filmer la nouvelle palette éclatée 
  (:durative-action wrap-exploded
    :parameters (?c - cariste ?pe - pallet ?z - zone)
    :duration (= ?duration 42)
    :condition (and 
      (at start (available ?c))
      (at start (is-exploded ?pe))
      (at start (product-sorted ?pe))
      (at start (not (wrapped ?pe)))   
      (over all (at-cariste ?c ?z))
      (over all (is-arrival-zone ?z))  
    )
    :effect (and 
      (at start (not (available ?c)))
      (at end (wrapped ?pe))
      (at end (ready-for-label ?pe))
      (at end (available ?c))
    )
  )

  ;; 7. Imprimer et coller le support
  (:durative-action print-and-stick-label
    :parameters (?c - cariste ?p - pallet ?z - zone)
    :duration (= ?duration 30)
    :condition (and 
      (at start (available ?c))
      (at start (ready-for-label ?p))
      (at start (at-pallet ?p ?z))
      (over all (at-cariste ?c ?z))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at end (label-attached ?p))
      (at end (available ?c))
    )
  )

  ;; 8. Prendre la palette avec le Fenwick 
  (:durative-action load-pallet
    :parameters (?c - cariste ?p - pallet ?z - zone)
    :duration (= ?duration 15)
    :condition (and 
      (at start (available ?c))
      (at start (at-pallet ?p ?z))
      (at start (label-attached ?p))
      (over all (at-cariste ?c ?z))
    )
    :effect (and 
      (at start (not (available ?c))) 
      (at start (not (at-pallet ?p ?z)))
      (at end (holding ?c ?p))
    )
  )

  ;; 9. Scanner le code-barres du support (PDA)
  (:durative-action scan-label-pda
    :parameters (?c - cariste ?p - pallet)
    :duration (= ?duration 10)
    :condition (and 
      (at start (holding ?c ?p))
    )
    :effect (and 
      (at end (label-scanned ?p))
    )
  )

  ;; 10. Déposer au Stockage 
  (:durative-action move-and-deposit
    :parameters (?c - cariste ?p - pallet ?from - zone ?to - zone)
    :duration (= ?duration 540)
    :condition (and 
      (at start (holding ?c ?p))
      (at start (label-scanned ?p))
      (at start (at-cariste ?c ?from))
      (over all (is-storage-zone ?to))
    )
    :effect (and 
      (at start (not (at-cariste ?c ?from)))
      (at end (at-cariste ?c ?to))
      (at end (not (holding ?c ?p)))
      (at end (at-pallet ?p ?to))
      (at end (available ?c)) 
    )
  )

  ;; 11. Scanner l'emplacement final (PDA)
  (:durative-action scan-location
    :parameters (?c - cariste ?p - pallet ?z - zone)
    :duration (= ?duration 10)
    :condition (and 
      (at start (available ?c))
      (at start (at-pallet ?p ?z))
      (at start (label-scanned ?p)) 
      (over all (at-cariste ?c ?z))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at end (stored ?p))
      (at end (available ?c))
    )
  )

  ;; 12. Déplacement à vide du cariste
  (:durative-action move-cariste
    :parameters (?c - cariste ?from - zone ?to - zone)
    :duration (= ?duration 60)
    :condition (and 
      (at start (available ?c))
      (at start (at-cariste ?c ?from))
    )
    :effect (and 
      (at start (not (available ?c)))
      (at start (not (at-cariste ?c ?from)))
      (at end (at-cariste ?c ?to))
      (at end (available ?c))
    )
  )
)