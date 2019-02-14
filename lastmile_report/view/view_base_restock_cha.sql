use lastmile_report;

drop view if exists view_base_restock_cha;

create view view_base_restock_cha as

select 
      a.chaRestockID,
      a.cha_id,
      a.county,
      a.county_id,
      a.territory_id,
      a.`month`,
      a.`year`,
      
      if( ( ( a.stockOnHand_ACT25mg = 0 ) 
            or         
            ( a.stockOnHand_ACT50mg = 0 )            
            or            
            ( a.stockOnHand_ORS = 0 )            
            or            
            ( ( a.stockOnHand_ZincSulfate = 0 )       and ( ( a.stockOnHand_ZincSulfate_Infidelity = 0        ) or 
                                                            ISNULL( a.stockOnHand_ZincSulfate_Infidelity      ) ) )           
            or            
            ( ( a.stockOnHand_Amoxicillin250mg = 0 )  and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0   ) or 
                                                            ISNULL(a.stockOnHand_Amoxicillin250mg_suspension  ) ) )
            ),
            1,
            0) AS any_stockout_life_saving,
            
        
      if( ( ( a.stockOnHand_ACT25mg = 0 ) 
            or         
            ( a.stockOnHand_ACT50mg = 0 )            
            or         
            ( ( a.stockOnHand_Paracetamol100mg = 0 )  and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0   ) or 
                                                            ISNULL( a.stockOnHand_Paracetamol100mg_suspension ) ) )           
            or            
            ( a.stockOnHand_ORS = 0 )            
            or            
            ( ( a.stockOnHand_ZincSulfate = 0 )       and ( ( a.stockOnHand_ZincSulfate_Infidelity = 0        ) or 
                                                            ISNULL( a.stockOnHand_ZincSulfate_Infidelity      ) ) )           
            or            
            ( ( a.stockOnHand_Amoxicillin250mg = 0 )  and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0   ) or                                                
                                                            ISNULL(a.stockOnHand_Amoxicillin250mg_suspension  ) ) )              
            or              
            ( a.stockOnHand_muacStrap   = 0 )
            or 
            ( a.stockOnHand_MalariaRDT  = 0 )
            or 
            ( a.stockOnHand_disposableGloves = 0 )
            ),
            1,
            0) AS any_stockouts_essentials,
            
      ((((((( 
              ( if( ( a.stockOnHand_ACT25mg = 0 ), 1, 0 ) 
                + 
                if( ( a.stockOnHand_ACT50mg = 0 ), 1, 0 ) 
              ) +            
              if( ( ( a.stockOnHand_Paracetamol100mg = 0 )  and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0 ) or 
                                                                  ISNULL( a.stockOnHand_Paracetamol100mg_suspension ) ) ), 1, 0 ) 
              ) + 
              if( ( a.stockOnHand_ORS = 0), 1, 0 ) 
              ) + 
              if( ( ( a.stockOnHand_ZincSulfate = 0 )       and ( ( a.stockOnHand_ZincSulfate_Infidelity = 0 ) or 
                                                                  ISNULL( a.stockOnHand_ZincSulfate_Infidelity ) ) ), 1, 0 ) 
              ) +  
              if( ( ( a.stockOnHand_Amoxicillin250mg = 0 )  and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0 ) or 
                                                                  ISNULL(a.stockOnHand_Amoxicillin250mg_suspension ) ) ), 1, 0 ) 
              ) + 
              if( ( a.stockOnHand_muacStrap         = 0 ), 1, 0 ) 
              ) + 
              if( ( a.stockOnHand_MalariaRDT        = 0 ), 1, 0 ) 
              ) + 
              if( ( a.stockOnHand_disposableGloves  = 0 ), 1, 0 ) 
      ) AS num_stockouts_essentials,
      
      if( a.stockOnHand_microlut              = 0, 1, 0 ) as stockout_microlut,
      if( a.stockOnHand_microgynon            = 0, 1, 0 ) as stockout_microgynon,
      if( a.stockOnHand_maleCondom            = 0, 1, 0 ) as stockout_maleCondom,
      if( a.stockOnHand_femaleCondom          = 0, 1, 0 ) as stockout_femaleCondom,
      if( a.stockOnHand_disposableGloves      = 0, 1, 0 ) as stockout_disposableGloves,
      if( a.stockOnHand_ACT25mg               = 0, 1, 0 ) as stockout_ACT25mg,   
      if( a.stockOnHand_ACT50mg               = 0, 1, 0 ) as stockout_ACT50mg,
      
      if( a.stockOnHand_ACT25mg = 0 or a.stockOnHand_ACT50mg = 0, 1, 0 ) as stockout_ACT_25mg_50mg,
      
      if( a.stockOnHand_artesunateSuppository = 0, 1, 0 ) as stockout_artesunateSuppository,
            
      if( ( ( a.stockOnHand_Amoxicillin250mg = 0 )                  and 
            ( 
              ( a.stockOnHand_Amoxicillin250mg_suspension = 0    )  or 
              ISNULL( a.stockOnHand_Amoxicillin250mg_suspension  ) 
            ) 
          ),
          1,
          0 
      ) as stockout_Amoxicillin250mg,
      
      if( a.stockOnHand_ORS = 0, 1, 0 ) as stockout_ORS,
      
      if( ( ( a.stockOnHand_ZincSulfate = 0 ) and ( ( a.stockOnHand_ZincSulfate_Infidelity = 0 )  or 
                                                    ISNULL( a.stockOnHand_ZincSulfate_Infidelity ) ) 
          ),
          1,
          0
      ) as stockout_ZincSulfate,
      
      if( ( ( a.stockOnHand_Paracetamol100mg = 0 ) and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0 ) or 
                                                          ISNULL( a.stockOnHand_Paracetamol100mg_suspension ) ) 
          ),
          1,
          0 
      ) as stockout_Paracetamol100mg,
            
      if( a.stockOnHand_MalariaRDT            = 0, 1, 0 ) as stockout_MalariaRDT,
      if( a.stockOnHand_muacStrap             = 0, 1, 0 ) as stockout_muacStrap,   
      if( a.stockOnHand_dispensingBags        = 0, 1, 0 ) as stockout_dispensingBags,
      if( a.stockOnHand_safetyBox             = 0, 1, 0 ) as stockout_safetyBox
            
from lastmile_report.view_restock_cha_month a