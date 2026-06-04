(define (problem entrepot_reception_prob)
  (:domain entrepot_reception)
  
  (:objects
    zone_arrivage stockage_rack bureau - zone
    cariste1 cariste2 cariste3 - cariste
    p_mono1 p_mix1 p_eclatee1 p_eclatee2 - pallet
  )
  
  (:init
    ;; Rôles et types des zones
    (is-arrival-zone zone_arrivage)
    (is-storage-zone stockage_rack)
    
    ;; Disponibilité initiale des caristes
    (at-cariste cariste1 zone_arrivage)
    (available cariste1)
    (at-cariste cariste2 zone_arrivage)
    (available cariste2)
    (at-cariste cariste3 zone_arrivage)
    (available cariste3)
    
    ;; États des palettes dans le camion
    (in-truck p_mono1)
    (is-mono p_mono1)
    
    (in-truck p_mix1)
    (is-mixed p_mix1)
    
    ;; Préparation des palettes vides au sol à l'arrivage
    (at-pallet p_eclatee1 zone_arrivage)
    (is-exploded p_eclatee1)
    (belongs-to p_eclatee1 p_mix1)
    
    (at-pallet p_eclatee2 zone_arrivage)
    (is-exploded p_eclatee2)
    (belongs-to p_eclatee2 p_mix1)
  )
  
  (:goal (and
    (stored p_mono1)
    (stored p_eclatee1)
    (stored p_eclatee2)
    (at-pallet p_mono1 stockage_rack)
    (at-pallet p_eclatee1 stockage_rack)
    (at-pallet p_eclatee2 stockage_rack)
  ))
  
  (:metric minimize (total-time))
)