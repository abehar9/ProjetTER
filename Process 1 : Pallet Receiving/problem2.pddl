(define (problem reception_entrepot_p2)
  (:domain entrepot_reception)
  
  (:objects
    ;; Les zones de l'entrepôt
    zone_arrivage bureau stockage_rack - zone
    
    ;; Les 3 caristes disponibles
    cariste1 cariste2 cariste3 - cariste
    
    ;; Les palettes d'origine et les 5 palettes éclatées issues du tri
    p_mono1 p_mix1 p_eclatee1 p_eclatee2 p_eclatee3 p_eclatee4 p_eclatee5 - pallet
  )

  (:init
    ;; --- Configurations géométriques des zones ---
    (is-arrival-zone zone_arrivage)
    (is-storage-zone stockage_rack)

    ;; --- Positions initiales des caristes (tous à l'arrivage) ---
    (at-cariste cariste1 zone_arrivage)
    (at-cariste cariste2 zone_arrivage)
    (at-cariste cariste3 zone_arrivage)
    
    ;; Disponibilité initiale des caristes
    (available cariste1)
    (available cariste2)
    (available cariste3)

    ;; --- États initiaux des palettes ---
    ;; Elles sont toutes les deux dans le camion au départ
    (in-truck p_mono1)
    (in-truck p_mix1)

    ;; Nature des palettes d'origine
    (is-mono p_mono1)
    (is-mixed p_mix1)

    ;; --- Configuration de la palette mixte (5 palettes éclatées) ---
    (is-exploded p_eclatee1)
    (is-exploded p_eclatee2)
    (is-exploded p_eclatee3)
    (is-exploded p_eclatee4)
    (is-exploded p_eclatee5)

    ;; Liens d'appartenance à la palette mixte d'origine
    (belongs-to p_eclatee1 p_mix1)
    (belongs-to p_eclatee2 p_mix1)
    (belongs-to p_eclatee3 p_mix1)
    (belongs-to p_eclatee4 p_mix1)
    (belongs-to p_eclatee5 p_mix1)

    ;; Position initiale des palettes éclatées (virtuellement présentes au sol à l'arrivage)
    (at-pallet p_eclatee1 zone_arrivage)
    (at-pallet p_eclatee2 zone_arrivage)
    (at-pallet p_eclatee3 zone_arrivage)
    (at-pallet p_eclatee4 zone_arrivage)
    (at-pallet p_eclatee5 zone_arrivage)
  )

  (:goal
    (and
      ;; L'objectif absolu : toutes les palettes doivent être scannées et stockées dans les racks
      (stored p_mono1)
      (stored p_eclatee1)
      (stored p_eclatee2)
      (stored p_eclatee3)
      (stored p_eclatee4)
      (stored p_eclatee5)
      
      ;; Optionnel : s'assurer que les caristes ont fini leurs mouvements et sont libérés
      (available cariste1)
      (available cariste2)
      (available cariste3)
    )
  )
)