(define (problem entrepot_reception_realiste)
  (:domain entrepot_reception)
  
  (:objects
    zone_arrivage stockage_rack bureau - zone
    cariste1 cariste2 cariste3 - cariste
    
    ;; 5 Palettes Mono initiales
    p_mono1 p_mono2 p_mono3 p_mono4 p_mono5 - pallet
    
    ;; 7 Palettes Mixtes initiales
    p_mix1 p_mix2 p_mix3 p_mix4 p_mix5 p_mix6 p_mix7 - pallet
    
    ;; 32 Palettes éclatées vides prêtes à l'arrivage
    p_eclatee1 p_eclatee2 p_eclatee3 p_eclatee4 p_eclatee5
    p_eclatee6 p_eclatee7 p_eclatee8 p_eclatee9 p_eclatee10
    p_eclatee11 p_eclatee12 p_eclatee13 p_eclatee14 p_eclatee15
    p_eclatee16 p_eclatee17 p_eclatee18 p_eclatee19 p_eclatee20
    p_eclatee21 p_eclatee22 p_eclatee23 p_eclatee24 p_eclatee25
    p_eclatee26 p_eclatee27 p_eclatee28 p_eclatee29 p_eclatee30
    p_eclatee31 p_eclatee32 - pallet
  )
  
  (:init
    ;; Typage et configuration des zones de l'entrepôt
    (is-arrival-zone zone_arrivage)
    (is-storage-zone stockage_rack)
    
    ;; Configuration et disponibilité des 3 caristes au départ
    (at-cariste cariste1 zone_arrivage) (available cariste1)
    (at-cariste cariste2 zone_arrivage) (available cariste2)
    (at-cariste cariste3 zone_arrivage) (available cariste3)
    
    ;; --- ÉTAT INITIAL DU CAMION ---
    ;; Les 5 palettes Mono dans le camion
    (in-truck p_mono1) (is-mono p_mono1)
    (in-truck p_mono2) (is-mono p_mono2)
    (in-truck p_mono3) (is-mono p_mono3)
    (in-truck p_mono4) (is-mono p_mono4)
    (in-truck p_mono5) (is-mono p_mono5)
    
    ;; Les 7 palettes Mixtes dans le camion
    (in-truck p_mix1) (is-mixed p_mix1)
    (in-truck p_mix2) (is-mixed p_mix2)
    (in-truck p_mix3) (is-mixed p_mix3)
    (in-truck p_mix4) (is-mixed p_mix4)
    (in-truck p_mix5) (is-mixed p_mix5)
    (in-truck p_mix6) (is-mixed p_mix6)
    (in-truck p_mix7) (is-mixed p_mix7)
    
    ;; --- CONFIGURATION DES PALETTES VIDES AU SOL (Liaisons Batchs/Mix) ---
    ;; Distribution réaliste (Moyenne de 4.5 éclats par palette mixte)
    (at-pallet p_eclatee1 zone_arrivage) (is-exploded p_eclatee1) (belongs-to p_eclatee1 p_mix1)
    (at-pallet p_eclatee2 zone_arrivage) (is-exploded p_eclatee2) (belongs-to p_eclatee2 p_mix1)
    (at-pallet p_eclatee3 zone_arrivage) (is-exploded p_eclatee3) (belongs-to p_eclatee3 p_mix1)
    (at-pallet p_eclatee4 zone_arrivage) (is-exploded p_eclatee4) (belongs-to p_eclatee4 p_mix1)
    (at-pallet p_eclatee5 zone_arrivage) (is-exploded p_eclatee5) (belongs-to p_eclatee5 p_mix1)

    (at-pallet p_eclatee6 zone_arrivage) (is-exploded p_eclatee6) (belongs-to p_eclatee6 p_mix2)
    (at-pallet p_eclatee7 zone_arrivage) (is-exploded p_eclatee7) (belongs-to p_eclatee7 p_mix2)
    (at-pallet p_eclatee8 zone_arrivage) (is-exploded p_eclatee8) (belongs-to p_eclatee8 p_mix2)
    (at-pallet p_eclatee9 zone_arrivage) (is-exploded p_eclatee9) (belongs-to p_eclatee9 p_mix2)
    (at-pallet p_eclatee10 zone_arrivage) (is-exploded p_eclatee10) (belongs-to p_eclatee10 p_mix2)

    (at-pallet p_eclatee11 zone_arrivage) (is-exploded p_eclatee11) (belongs-to p_eclatee11 p_mix3)
    (at-pallet p_eclatee12 zone_arrivage) (is-exploded p_eclatee12) (belongs-to p_eclatee12 p_mix3)
    (at-pallet p_eclatee13 zone_arrivage) (is-exploded p_eclatee13) (belongs-to p_eclatee13 p_mix3)
    (at-pallet p_eclatee14 zone_arrivage) (is-exploded p_eclatee14) (belongs-to p_eclatee14 p_mix3)
    (at-pallet p_eclatee15 zone_arrivage) (is-exploded p_eclatee15) (belongs-to p_eclatee15 p_mix3)

    (at-pallet p_eclatee16 zone_arrivage) (is-exploded p_eclatee16) (belongs-to p_eclatee16 p_mix4)
    (at-pallet p_eclatee17 zone_arrivage) (is-exploded p_eclatee17) (belongs-to p_eclatee17 p_mix4)
    (at-pallet p_eclatee18 zone_arrivage) (is-exploded p_eclatee18) (belongs-to p_eclatee18 p_mix4)
    (at-pallet p_eclatee19 zone_arrivage) (is-exploded p_eclatee19) (belongs-to p_eclatee19 p_mix4)
    (at-pallet p_eclatee20 zone_arrivage) (is-exploded p_eclatee20) (belongs-to p_eclatee20 p_mix4)

    (at-pallet p_eclatee21 zone_arrivage) (is-exploded p_eclatee21) (belongs-to p_eclatee21 p_mix5)
    (at-pallet p_eclatee22 zone_arrivage) (is-exploded p_eclatee22) (belongs-to p_eclatee22 p_mix5)
    (at-pallet p_eclatee23 zone_arrivage) (is-exploded p_eclatee23) (belongs-to p_eclatee23 p_mix5)
    (at-pallet p_eclatee24 zone_arrivage) (is-exploded p_eclatee24) (belongs-to p_eclatee24 p_mix5)

    (at-pallet p_eclatee25 zone_arrivage) (is-exploded p_eclatee25) (belongs-to p_eclatee25 p_mix6)
    (at-pallet p_eclatee26 zone_arrivage) (is-exploded p_eclatee26) (belongs-to p_eclatee26 p_mix6)
    (at-pallet p_eclatee27 zone_arrivage) (is-exploded p_eclatee27) (belongs-to p_eclatee27 p_mix6)
    (at-pallet p_eclatee28 zone_arrivage) (is-exploded p_eclatee28) (belongs-to p_eclatee28 p_mix6)

    (at-pallet p_eclatee29 zone_arrivage) (is-exploded p_eclatee29) (belongs-to p_eclatee29 p_mix7)
    (at-pallet p_eclatee30 zone_arrivage) (is-exploded p_eclatee30) (belongs-to p_eclatee30 p_mix7)
    (at-pallet p_eclatee31 zone_arrivage) (is-exploded p_eclatee31) (belongs-to p_eclatee31 p_mix7)
    (at-pallet p_eclatee32 zone_arrivage) (is-exploded p_eclatee32) (belongs-to p_eclatee32 p_mix7)
  )
  
  (:goal (and
    ;; Objectif : Toutes les palettes Mono doivent être enregistrées et stockées dans le rack
    (stored p_mono1) (at-pallet p_mono1 stockage_rack)
    (stored p_mono2) (at-pallet p_mono2 stockage_rack)
    (stored p_mono3) (at-pallet p_mono3 stockage_rack)
    (stored p_mono4) (at-pallet p_mono4 stockage_rack)
    (stored p_mono5) (at-pallet p_mono5 stockage_rack)
    
    ;; Objectif : Les 32 palettes issues de l'éclatement doivent être enregistrées et stockées dans le rack
    (stored p_eclatee1) (at-pallet p_eclatee1 stockage_rack)
    (stored p_eclatee2) (at-pallet p_eclatee2 stockage_rack)
    (stored p_eclatee3) (at-pallet p_eclatee3 stockage_rack)
    (stored p_eclatee4) (at-pallet p_eclatee4 stockage_rack)
    (stored p_eclatee5) (at-pallet p_eclatee5 stockage_rack)
    (stored p_eclatee6) (at-pallet p_eclatee6 stockage_rack)
    (stored p_eclatee7) (at-pallet p_eclatee7 stockage_rack)
    (stored p_eclatee8) (at-pallet p_eclatee8 stockage_rack)
    (stored p_eclatee9) (at-pallet p_eclatee9 stockage_rack)
    (stored p_eclatee10) (at-pallet p_eclatee10 stockage_rack)
    (stored p_eclatee11) (at-pallet p_eclatee11 stockage_rack)
    (stored p_eclatee12) (at-pallet p_eclatee12 stockage_rack)
    (stored p_eclatee13) (at-pallet p_eclatee13 stockage_rack)
    (stored p_eclatee14) (at-pallet p_eclatee14 stockage_rack)
    (stored p_eclatee15) (at-pallet p_eclatee15 stockage_rack)
    (stored p_eclatee16) (at-pallet p_eclatee16 stockage_rack)
    (stored p_eclatee17) (at-pallet p_eclatee17 stockage_rack)
    (stored p_eclatee18) (at-pallet p_eclatee18 stockage_rack)
    (stored p_eclatee19) (at-pallet p_eclatee19 stockage_rack)
    (stored p_eclatee20) (at-pallet p_eclatee20 stockage_rack)
    (stored p_eclatee21) (at-pallet p_eclatee21 stockage_rack)
    (stored p_eclatee22) (at-pallet p_eclatee22 stockage_rack)
    (stored p_eclatee23) (at-pallet p_eclatee23 stockage_rack)
    (stored p_eclatee24) (at-pallet p_eclatee24 stockage_rack)
    (stored p_eclatee25) (at-pallet p_eclatee25 stockage_rack)
    (stored p_eclatee26) (at-pallet p_eclatee26 stockage_rack)
    (stored p_eclatee27) (at-pallet p_eclatee27 stockage_rack)
    (stored p_eclatee28) (at-pallet p_eclatee28 stockage_rack)
    (stored p_eclatee29) (at-pallet p_eclatee29 stockage_rack)
    (stored p_eclatee30) (at-pallet p_eclatee30 stockage_rack)
    (stored p_eclatee31) (at-pallet p_eclatee31 stockage_rack)
    (stored p_eclatee32) (at-pallet p_eclatee32 stockage_rack)
  ))
  
  (:metric minimize (total-time))
)