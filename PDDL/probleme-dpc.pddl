(define (problem mission-stockage-1)
    (:domain logistique-dpc)
    (:objects 
        employe1 - agent
        pal1 - palette
        reception - zone
        stockage - zone
    )

    (:init 
       
        (agent-est-dans employe1 reception)
        (palette-est-dans pal1 reception)
        (mains-libres employe1)
    )

    (:goal 
      
        (and 
            (palette-est-dans pal1 stockage)
        )
    )
)