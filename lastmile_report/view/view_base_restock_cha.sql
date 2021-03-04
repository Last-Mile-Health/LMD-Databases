use lastmile_report;

drop view if exists lastmile_report.view_base_restock_cha;

create view lastmile_report.view_base_restock_cha as

select 
      -- a.chaRestockID,
      a.cha_id,
      a.county,
      a.county_id,
      a.territory_id,
      a.`month`,
      a.`year`,
      
      ( a.`year` * 10000 ) + ( a.`month` * 100 ) + 1 as date_key,
      
      if( ( -- ( ( a.stockOnHand_ZincSulfate   = 0 ) and ( ( a.stockOnHand_ZincSulfate_Infidelity = 0 ) or isnull( a.stockOnHand_ZincSulfate_Infidelity ) ) ) or           
            -- ( ( a.stockOnHand_Amoxicillin250mg = 0 ) and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0   ) or isnull( a.stockOnHand_Amoxicillin250mg_suspension ) ) ) or
            ( a.stockout_zinc_sulfate       = 1 ) or
            ( a.stockout_amoxicillin_250_mg = 1 ) or
            ( a.stockOnHand_ACT25mg         = 0 ) or 
            ( a.stockOnHand_ACT50mg         = 0 ) or 
            ( a.stockOnHand_ORS             = 0 ) 
          ),      
          1, 0
      ) as any_stockout_life_saving,
               
               
      -- any_stockouts_essentials
      -- PPE Covid-19: for now, do not AND disposable gloves and gloves Covid19 together because they are considered two separate "bins".
      if( -- ( ( a.stockOnHand_ZincSulfate       = 0 ) and ( ( a.stockOnHand_ZincSulfate_Infidelity = 0 ) or isnull( a.stockOnHand_ZincSulfate_Infidelity ) ) ) or            
          -- ( ( a.stockOnHand_Amoxicillin250mg  = 0 ) and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0 ) or isnull( a.stockOnHand_Amoxicillin250mg_suspension  ) ) ) or              
          -- ( ( a.stockOnHand_Paracetamol100mg  = 0 ) and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0 ) or isnull( a.stockOnHand_Paracetamol100mg_suspension ) ) ) or
          ( a.stockout_zinc_sulfate           = 1 ) or
          ( a.stockout_amoxicillin_250_mg     = 1 ) or
          ( a.stockout_paracetamol_100mg      = 1 ) or
          ( a.stockOnHand_ACT25mg             = 0 ) or 
          ( a.stockOnHand_ACT50mg             = 0 ) or  
          ( a.stockOnHand_ORS                 = 0 ) or  
          ( a.stockOnHand_muacStrap           = 0 ) or 
          ( a.stockOnHand_MalariaRDT          = 0 ) or 
          ( a.stockOnHand_disposableGloves    = 0 )     
          , 1, 0
        ) as any_stockouts_essentials,
      
      
      -- num_stockouts_essentials
      -- if( ( a.stockOnHand_Paracetamol100mg  = 0 ) and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0 ) or isnull( a.stockOnHand_Paracetamol100mg_suspension  ) ), 1, 0 ) +
      -- if( ( a.stockOnHand_ZincSulfate       = 0 ) and ( ( a.stockOnHand_ZincSulfate_Infidelity      = 0 ) or isnull( a.stockOnHand_ZincSulfate_Infidelity       ) ), 1, 0 ) +  
      -- if( ( a.stockOnHand_Amoxicillin250mg  = 0 ) and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0 ) or isnull( a.stockOnHand_Amoxicillin250mg_suspension  ) ), 1, 0 ) + 
      a.stockout_zinc_sulfate       + 
      a.stockout_amoxicillin_250_mg +
      a.stockout_paracetamol_100mg  +
      if( ( a.stockOnHand_ACT25mg           = 0 ), 1, 0 ) + 
      if( ( a.stockOnHand_ACT50mg           = 0 ), 1, 0 ) +            
      if( ( a.stockOnHand_ORS               = 0 ), 1, 0 ) + 
      if( ( a.stockOnHand_muacStrap         = 0 ), 1, 0 ) + 
      if( ( a.stockOnHand_MalariaRDT        = 0 ), 1, 0 ) + 
      if( ( a.stockOnHand_disposableGloves  = 0 ), 1, 0 )
      as num_stockouts_essentials,
      
      -- stockout essentials, including PPE
      -- any_stockouts_essentials_ppe
      if( -- ( ( a.stockOnHand_ZincSulfate       = 0 ) and ( ( a.stockOnHand_ZincSulfate_Infidelity      = 0 ) or isnull( a.stockOnHand_ZincSulfate_Infidelity       ) ) ) or            
          -- ( ( a.stockOnHand_Amoxicillin250mg  = 0 ) and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0 ) or isnull( a.stockOnHand_Amoxicillin250mg_suspension  ) ) ) or              
          -- ( ( a.stockOnHand_Paracetamol100mg  = 0 ) and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0 ) or isnull( a.stockOnHand_Paracetamol100mg_suspension  ) ) ) or            
          ( a.stockout_zinc_sulfate           = 1 ) or
          ( a.stockout_amoxicillin_250_mg     = 1 ) or
          ( a.stockout_paracetamol_100mg      = 1 ) or         
          ( a.stockOnHand_ACT25mg             = 0 ) or 
          ( a.stockOnHand_ACT50mg             = 0 ) or  
          ( a.stockOnHand_ORS                 = 0 ) or  
          ( a.stockOnHand_muacStrap           = 0 ) or 
          ( a.stockOnHand_MalariaRDT          = 0 ) or
          
          -- ( a.stockOnHand_disposableGloves    = 0 ) or
          -- ( a.stockOnHand_glovesCovid19       = 0 ) or    -- PPE Covid-19
          
          -- Only count gloves as stocked out if both regular and covid19 extra sum to zero
          ( a.stockOnHand_disposable_gloves_regular_covid19 = 0 ) or
          ( a.stockOnHand_surgicalMask                      = 0 )       -- PPE Covid-19       
          , 1, 0
        ) as any_stockouts_essentials_ppe,
      
      
      -- num_stockouts_essentials_ppe
      -- if( ( a.stockOnHand_Paracetamol100mg  = 0 ) and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0 ) or isnull( a.stockOnHand_Paracetamol100mg_suspension  ) ), 1, 0 ) +        
      -- if( ( a.stockOnHand_ZincSulfate       = 0 ) and ( ( a.stockOnHand_ZincSulfate_Infidelity      = 0 ) or isnull( a.stockOnHand_ZincSulfate_Infidelity       ) ), 1, 0 ) +  
      -- if( ( a.stockOnHand_Amoxicillin250mg  = 0 ) and ( ( a.stockOnHand_Amoxicillin250mg_suspension = 0 ) or isnull( a.stockOnHand_Amoxicillin250mg_suspension  ) ), 1, 0 ) + 
 
      a.stockout_zinc_sulfate       + 
      a.stockout_amoxicillin_250_mg +
      a.stockout_paracetamol_100mg  +
      if( ( a.stockOnHand_ACT25mg           = 0 ), 1, 0 ) + 
      if( ( a.stockOnHand_ACT50mg           = 0 ), 1, 0 ) +            
      if( ( a.stockOnHand_ORS               = 0 ), 1, 0 ) + 
      if( ( a.stockOnHand_muacStrap         = 0 ), 1, 0 ) + 
      if( ( a.stockOnHand_MalariaRDT        = 0 ), 1, 0 ) + 
      -- if( ( a.stockOnHand_disposableGloves  = 0 ), 1, 0 ) +
      -- if( ( a.stockOnHand_glovesCovid19     = 0 ), 1, 0 ) + -- PPE Covid-19
      
      -- Only count gloves as stocked out if both regular and covid19 extra sum to zero
      if( ( a.stockOnHand_disposable_gloves_regular_covid19   = 0 ), 1, 0 ) +
      if( ( a.stockOnHand_surgicalMask                        = 0 ), 1, 0 )   -- PPE Covid-19
      as num_stockouts_essentials_ppe,
  
      if( a.stockOnHand_microlut            = 0, 1, 0 ) as stockout_microlut,
      if( a.stockOnHand_microgynon          = 0, 1, 0 ) as stockout_microgynon,
      if( a.stockOnHand_maleCondom          = 0, 1, 0 ) as stockout_maleCondom,
      if( a.stockOnHand_femaleCondom        = 0, 1, 0 ) as stockout_femaleCondom,
      if( a.stockOnHand_disposableGloves    = 0, 1, 0 ) as stockout_disposableGloves,
      
      if( a.stockOnHand_ACT25mg             = 0, 1, 0 ) as stockout_ACT25mg,   
      if( a.stockOnHand_ACT50mg             = 0, 1, 0 ) as stockout_ACT50mg,
      
      -- if( a.stockOnHand_ACT25mg = 0 or a.stockOnHand_ACT50mg = 0, 1, 0 ) as stockout_ACT_25mg_50mg,
      a.stockout_act_25mg_50mg as stockout_ACT_25mg_50mg,
      
      if( a.stockOnHand_artesunateSuppository = 0, 1, 0 ) as stockout_artesunateSuppository,
           
      -- if( ( ( a.stockOnHand_Amoxicillin250mg = 0 )                  and 
      --      ( 
      --        ( a.stockOnHand_Amoxicillin250mg_suspension = 0    )  or 
      --        ISNULL( a.stockOnHand_Amoxicillin250mg_suspension  ) 
      --      ) 
      --    ),
      --    1,
      --    0 
      -- ) as stockout_Amoxicillin250mg,
      
      a.stockout_amoxicillin_250_mg as stockout_Amoxicillin250mg,
      
      if( a.stockOnHand_ORS = 0, 1, 0 ) as stockout_ORS,
      
      -- if( ( ( a.stockOnHand_ZincSulfate = 0 ) and ( ( a.stockOnHand_ZincSulfate_Infidelity = 0 )  or 
      --                                              ISNULL( a.stockOnHand_ZincSulfate_Infidelity ) ) 
      --    ),
      --    1,
      --    0
      -- ) as stockout_ZincSulfate,
      
      a.stockout_zinc_sulfate as stockout_ZincSulfate,
      
      -- if( ( ( a.stockOnHand_Paracetamol100mg = 0 ) and ( ( a.stockOnHand_Paracetamol100mg_suspension = 0 ) or 
      --                                                    ISNULL( a.stockOnHand_Paracetamol100mg_suspension ) ) 
      --    ),
      --    1,
      --    0 
      -- ) as stockout_Paracetamol100mg,
      a.stockout_paracetamol_100mg as stockout_Paracetamol100mg,
      
      
      if( a.stockOnHand_MalariaRDT      = 0, 1, 0 ) as stockout_MalariaRDT,
      if( a.stockOnHand_muacStrap       = 0, 1, 0 ) as stockout_muacStrap,   
      if( a.stockOnHand_dispensingBags  = 0, 1, 0 ) as stockout_dispensingBags,
      if( a.stockOnHand_safetyBox       = 0, 1, 0 ) as stockout_safetyBox,
      
      -- PPE Covid-19
      -- For restock form verisions before 4.0.0 these two fields will be null.  
      if( a.stockOnHand_surgicalMask    = 0, 1, 0 )                     as stockout_surgicalMask,
      if( a.stockOnHand_glovesCovid19   = 0, 1, 0 )                     as stockout_glovesCovid19,
      if( a.stockOnHand_disposable_gloves_regular_covid19   = 0, 1, 0 ) as stockout_disposable_gloves_regular_covid19
      
from lastmile_report.view_restock_cha_month a
-- where a.`year` = 2021
;