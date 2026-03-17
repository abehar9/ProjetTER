(define (domain logistique-dpc)
    (:requirements :typing)

    (:types 
        palette 
        tire-palette 
        agent
        zone
    )

    (:predicates 
        (agent-est-dans ?ag - agent ?z - zone)
        (palette-est-dans ?p - palette ?z - zone)  
        (agent-porte ?ag - agent ?p - palette)     
        (mains-libres ?ag - agent)               
    )

    (:action ramasser-palette
        :parameters (?ag - agent ?p - palette ?z - zone)
        
        :precondition (and 
            (agent-est-dans ?ag ?z)    
            (palette-est-dans ?p ?z)   
            (mains-libres ?ag)    
        )
        
        :effect (and 
            (agent-porte ?ag ?p)      
            (not (mains-libres ?ag))  
            (not (palette-est-dans ?p ?z)) 
        )
    )

    (:action se-deplacer
        :parameters (?ag - agent ?z1 - zone ?z2 - zone)
        
        :precondition (and 
            (agent-est-dans ?ag ?z1)
        )
        
        :effect (and 
            (agent-est-dans ?ag ?z2)
            (not (agent-est-dans ?ag ?z1))
        )
    )

    (:action poser-palette
        :parameters (?ag - agent ?p - palette ?z - zone)
        
        :precondition (and 
            (agent-est-dans ?ag ?z)
            (agent-porte ?ag ?p)
        )
        
        :effect (and 
            (palette-est-dans ?p ?z)
            (not (agent-porte ?ag ?p))
            (mains-libres ?ag)
        )
    )
)