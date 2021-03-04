use lastmile_report;

drop view if exists lastmile_report.view_restock_union;

create view lastmile_report.view_restock_union as
select 
      chaRestockID,
      
      trim( meta_UUID )                                 as meta_UUID,
      trim( meta_autoDate )                             as meta_autoDate,
      trim( meta_dataEntry_startTime )                  as meta_dataEntry_startTime,
      trim( meta_dataEntry_endTime )                    as meta_dataEntry_endTime,
      trim( meta_dataSource )                           as meta_dataSource,
      trim( meta_formVersion )                          as meta_formVersion,
      trim( meta_deviceID )                             as meta_deviceID,
      trim( manualDate )                                as manualDate,
      
      -- check if supervisedChaID or chaID has value, use it, otherwise null
      if( ( isnull( supervisedChaID ) or ( trim( supervisedChaID ) like '' ) ),
          if( ( isnull( chaID ) or ( trim( chaID ) like '' ) ), 
              null, 
              trim( chaID ) 
          ),
          trim( supervisedChaID )
      ) as supervisedChaID,
        
      trim( communityID )                               as communityID,
      
      -- ACT 25 and 50 mg
      trim( stockOnHand_ACT25mg )                       as stockOnHand_ACT25mg,
      trim( stockOnHand_ACT50mg )                       as stockOnHand_ACT50mg,
 
      -- for a restock event is the CHA stocked out of both ACT 25mg and ACT 50mg
      case
          -- 1. when both fields are null or blank string, no stock outs have occured
          when ( ( stockOnHand_ACT25mg            is null ) or ( trim( stockOnHand_ACT25mg ) like '' ) ) and 
               ( ( stockOnHand_ACT50mg is null ) or ( trim( stockOnHand_ACT50mg )  like '' ) ) 
          then 0
                                
          -- 2. when two fields are null or a blank string, only the not null or blank string is tested for zero.
          when ( ( stockOnHand_ACT25mg is null ) or ( trim( stockOnHand_ACT25mg ) like '' ) )
          then 0
          
          when ( ( stockOnHand_ACT50mg is null ) or ( trim( stockOnHand_ACT50mg ) like '' ) )
          then 0
  
          -- 3.  When neither field is null and both fields are zero
          when cast( stockOnHand_ACT25mg as unsigned ) = 0 and cast( stockOnHand_ACT50mg as unsigned ) = 0
          then 1
          
          else 0
          
      end as stockout_act_25mg_50mg,
      
      trim( stockOnHand_Amoxicillin250mg )              as stockOnHand_Amoxicillin250mg,
      trim( stockOnHand_Amoxicillin250mg_suspension )   as stockOnHand_Amoxicillin250mg_suspension,
      trim( stockOnHand_Amoxicillin250mg_strips )       as stockOnHand_Amoxicillin250mg_strips,
      case
          -- 1. when all three fields are null or blank string, no stock outs have occured
          when ( ( stockOnHand_Amoxicillin250mg            is null ) or ( trim( stockOnHand_Amoxicillin250mg )             like '' ) ) and 
               ( ( stockOnHand_Amoxicillin250mg_suspension is null ) or ( trim( stockOnHand_Amoxicillin250mg_suspension )  like '' ) ) and 
               ( ( stockOnHand_Amoxicillin250mg_strips     is null ) or ( trim( stockOnHand_Amoxicillin250mg_strips )      like '' ) ) 
          then 0
                                
          -- 2. when two fields are null or a blank string, only the not null or blank string is tested for zero.
          when ( ( stockOnHand_Amoxicillin250mg            is null ) or ( trim( stockOnHand_Amoxicillin250mg )             like '' ) ) and 
               ( ( stockOnHand_Amoxicillin250mg_suspension is null ) or ( trim( stockOnHand_Amoxicillin250mg_suspension )  like '' ) )
          then if( cast( stockOnHand_Amoxicillin250mg_strips as unsigned ) = 0, 1, 0 )
          
          when ( ( stockOnHand_Amoxicillin250mg        is null ) or ( trim( stockOnHand_Amoxicillin250mg )                 like '' ) ) and 
               ( ( stockOnHand_Amoxicillin250mg_strips is null ) or ( trim( stockOnHand_Amoxicillin250mg_strips )          like '' ) ) 
          then if( cast( stockOnHand_Amoxicillin250mg_suspension as unsigned ) = 0, 1, 0 )
          
          when ( ( stockOnHand_Amoxicillin250mg_suspension is null ) or ( trim( stockOnHand_Amoxicillin250mg_suspension )  like '' ) ) and 
               ( ( stockOnHand_Amoxicillin250mg_strips     is null ) or ( trim( stockOnHand_Amoxicillin250mg_strips )      like '' ) )
          then if( cast( stockOnHand_Amoxicillin250mg as unsigned ) = 0, 1 , 0 )
          
          -- 3. When only one field is null or blank
          when ( ( stockOnHand_Amoxicillin250mg is null ) or ( trim( stockOnHand_Amoxicillin250mg ) like '' ) )
          then if( cast( stockOnHand_Amoxicillin250mg_suspension as unsigned ) = 0 and cast( stockOnHand_Amoxicillin250mg_strips as unsigned ) = 0, 1, 0 )
          
          when ( ( stockOnHand_Amoxicillin250mg_suspension is null ) or ( trim( stockOnHand_Amoxicillin250mg_suspension ) like '' ) )
          then if( cast( stockOnHand_Amoxicillin250mg as unsigned ) = 0 and cast( stockOnHand_Amoxicillin250mg_strips as unsigned ) = 0, 1, 0 )
          
          when ( ( stockOnHand_Amoxicillin250mg_strips is null ) or ( trim( stockOnHand_Amoxicillin250mg_strips ) like '' ) )
          then if( cast( stockOnHand_Amoxicillin250mg as unsigned ) = 0 and cast( stockOnHand_Amoxicillin250mg_suspension as unsigned ) = 0, 1, 0 )
          
          -- 4.  When neither field is null or blank
          when cast( stockOnHand_Amoxicillin250mg as unsigned ) = 0 and cast( stockOnHand_Amoxicillin250mg_suspension as unsigned ) = 0 and cast( stockOnHand_Amoxicillin250mg_strips as unsigned ) = 0
          then 1
          
          else 0
          
      end as stockout_amoxicillin_250_mg,

      trim( stockOnHand_disposableGloves )              as stockOnHand_disposableGloves,
      trim( stockOnHand_MalariaRDT )                    as stockOnHand_MalariaRDT,
      trim( stockOnHand_maleCondom )                    as stockOnHand_maleCondom,
      trim( stockOnHand_microgynon )                    as stockOnHand_microgynon,
      trim( stockOnHand_muacStrap )                     as stockOnHand_muacStrap,
      trim( stockOnHand_ORS )                           as stockOnHand_ORS,
      
      trim( stockOnHand_Paracetamol100mg )              as stockOnHand_Paracetamol100mg,
      trim( stockOnHand_Paracetamol100mg_suspension )   as stockOnHand_Paracetamol100mg_suspension,
      case
          -- 1. when both fields are null or blank string, no stock outs have occured
          when ( ( stockOnHand_Paracetamol100mg            is null ) or ( trim( stockOnHand_Paracetamol100mg )             like '' ) ) and 
               ( ( stockOnHand_Paracetamol100mg_suspension is null ) or ( trim( stockOnHand_Paracetamol100mg_suspension )  like '' ) ) 
          then 0
                                
          -- 2. when two fields are null or a blank string, only the not null or blank string is tested for zero.
          when ( ( stockOnHand_Paracetamol100mg is null ) or ( trim( stockOnHand_Paracetamol100mg ) like '' ) )
          then if( cast( stockOnHand_Paracetamol100mg_suspension as unsigned ) = 0, 1, 0 )
          
          when ( ( stockOnHand_Paracetamol100mg_suspension is null ) or ( trim( stockOnHand_Paracetamol100mg_suspension ) like '' ) )
          then if( cast( stockOnHand_Paracetamol100mg as unsigned ) = 0, 1, 0 )
  
          -- 3.  When neither field is null
          when cast( stockOnHand_Paracetamol100mg as unsigned ) = 0 and cast( stockOnHand_Paracetamol100mg_suspension as unsigned ) = 0
          then 1
          
          else 0
          
      end as stockout_paracetamol_100mg,

      trim( stockOnHand_ZincSulfate )                   as stockOnHand_ZincSulfate,
      trim( stockOnHand_ZincSulfate_Infidelity )        as stockOnHand_ZincSulfate_Infidelity,
      case
          -- 1. when both fields are null or blank string, no stock outs have occured
          when ( ( stockOnHand_ZincSulfate            is null ) or ( trim( stockOnHand_ZincSulfate )             like '' ) ) and 
               ( ( stockOnHand_ZincSulfate_Infidelity is null ) or ( trim( stockOnHand_ZincSulfate_Infidelity )  like '' ) ) 
          then 0
                                
          -- 2. when two fields are null or a blank string, only the not null or blank string is tested for zero.
          when ( ( stockOnHand_ZincSulfate is null ) or ( trim( stockOnHand_ZincSulfate ) like '' ) )
          then if( cast( stockOnHand_ZincSulfate_Infidelity as unsigned ) = 0, 1, 0 )
          
          when ( ( stockOnHand_ZincSulfate_Infidelity is null ) or ( trim( stockOnHand_ZincSulfate_Infidelity ) like '' ) )
          then if( cast( stockOnHand_ZincSulfate as unsigned ) = 0, 1, 0 )
  
          -- 3.  When neither field is null
          when cast( stockOnHand_ZincSulfate as unsigned ) = 0 and cast( stockOnHand_ZincSulfate_Infidelity as unsigned ) = 0
          then 1
          
          else 0
          
      end as stockout_zinc_sulfate,

      trim( stockOnHand_artesunateSuppository )         as stockOnHand_artesunateSuppository,
      trim( stockOnHand_dispensingBags )                as stockOnHand_dispensingBags,
      trim( stockOnHand_femaleCondom )                  as stockOnHand_femaleCondom,
      trim( stockOnHand_microlut )                      as stockOnHand_microlut,
      trim( stockOnHand_safetyBox )                     as stockOnHand_safetyBox,
      
      -- COVID-19 PPE 
      trim( stockOnHand_surgicalMask )                  as stockOnHand_surgicalMask,
      trim( stockOnHand_glovesCovid19 )                 as stockOnHand_glovesCovid19,
      
      -- Add regular disposable glove and Covid19 extra glove to come up with cumlative gloves in stock.  The conditional functions
      -- are to accomodate nulls and empty strings in the fields because the value for regular and covid gloves were not filled in. 
      -- if( stockOnHand_disposableGloves is null or trim( stockOnHand_disposableGloves like '' ), 0, stockOnHand_disposableGloves ) +
      -- if( stockOnHand_glovesCovid19 is null or trim( stockOnHand_glovesCovid19 like '' ), 0, stockOnHand_glovesCovid19 )
      -- as stockOnHand_disposable_gloves_regular_covid19
      
      case
          -- 1. when both fields are null or blank string, stock on hand is null
          when ( ( stockOnHand_disposableGloves is null ) or ( trim( stockOnHand_disposableGloves ) like '' ) ) and 
               ( ( stockOnHand_glovesCovid19 is null ) or ( trim( stockOnHand_glovesCovid19 )  like '' ) ) 
          then null
                                
          -- 2. when regular disposible gloves is null or a blank string, then covid 19 disposible gloves contains the stock on hand
          when ( ( stockOnHand_disposableGloves is null ) or ( trim( stockOnHand_disposableGloves ) like '' ) )
          then stockOnHand_glovesCovid19
          
          -- 3. when covid disposible gloves is null, regular disposible gloves contains the stock on hand
          when ( ( stockOnHand_glovesCovid19 is null ) or ( trim( stockOnHand_glovesCovid19 ) like '' ) )
          then stockOnHand_disposableGloves
          
          -- 4. stock on hand is sum of reguglar and covid disposible gloves
          else cast( stockOnHand_disposableGloves as unsigned ) + cast( stockOnHand_glovesCovid19 as unsigned )

      end as stockOnHand_disposable_gloves_regular_covid19
      
           
from lastmile_upload.odk_chaRestock

union all

select 
      chwRestockID,
      
      trim( meta_UUID )                     as meta_UUID,
      trim( meta_autoDate )                 as meta_autoDate,
      trim( meta_dataEntry_startTime )      as meta_dataEntry_startTime,
      trim( meta_dataEntry_endTime )        as meta_dataEntry_endTime,
      trim( meta_dataSource )               as meta_dataSource,
      trim( meta_formVersion )              as meta_formVersion,
      trim( meta_deviceID )                 as meta_deviceID,
      trim( manualDate )                    as manualDate,

      if( ( isnull( supervisedChwID ) or ( trim( supervisedChwID ) like '' ) ), 
          null, 
          trim( supervisedChwID ) 
      ) as supervisedChwID,
      
      trim( communityID )                   as communityID,
      
      -- ACT 25 and 50 mg
      trim( stockOnHand_ACT25mg )           as stockOnHand_ACT25mg,      
      trim( stockOnHand_ACT50mg )           as stockOnHand_ACT50mg,
       
      -- for a restock event is the CHA stocked out of both ACT 25mg and ACT 50mg
      case
          -- 1. when both fields are null or blank string, no stock outs have occured
          when ( ( stockOnHand_ACT25mg            is null ) or ( trim( stockOnHand_ACT25mg ) like '' ) ) and 
               ( ( stockOnHand_ACT50mg is null ) or ( trim( stockOnHand_ACT50mg )  like '' ) ) 
          then 0
                                
          -- 2. when two fields are null or a blank string, only the not null or blank string is tested for zero.
          when ( ( stockOnHand_ACT25mg is null ) or ( trim( stockOnHand_ACT25mg ) like '' ) )
          then 0
          
          when ( ( stockOnHand_ACT50mg is null ) or ( trim( stockOnHand_ACT50mg ) like '' ) )
          then 0
  
          -- 3.  When neither field is null and both fields are zero
          when cast( stockOnHand_ACT25mg as unsigned ) = 0 and cast( stockOnHand_ACT50mg as unsigned ) = 0
          then 1
          
          else 0
          
      end as stockout_act_25mg_50mg,
         
      trim( stockOnHand_amoxicillin250mg )  as stockOnHand_amoxicillin250mg,
      null                                  as stockOnHand_Amoxicillin250mg_suspension,
      null                                  as stockOnHand_Amoxicillin250mg_strips,
      
      case
          -- 1. when stockOnHand_Amoxicillin250mg is null or blank string, no stock outs have occured
          when ( ( stockOnHand_Amoxicillin250mg is null ) or ( trim( stockOnHand_Amoxicillin250mg ) like '' ) )  
          then 0
          
          -- 2.  When stockOnHand_Amoxicillin250mg is not null or blank and value is zero
          when cast( stockOnHand_Amoxicillin250mg as unsigned ) = 0 
          then 1       
          else 0 -- not a stockout   
          
      end as stockout_amoxicillin_250_mg,

      trim( stockOnHand_disposableGloves )  as stockOnHand_disposableGloves,
      trim( stockOnHand_MalariaRDT )        as stockOnHand_MalariaRDT,
      trim( stockOnHand_maleCondoms )       as stockOnHand_maleCondoms,
      trim( stockOnHand_microgynon )        as stockOnHand_microgynon,
      trim( stockOnHand_muacStrap )         as stockOnHand_muacStrap,
      trim( stockOnHand_ORS )               as stockOnHand_ORS,
      
      
      trim( stockOnHand_Paracetamol120mg )  as stockOnHand_Paracetamol120mg,
      null                                  as stockOnHand_Paracetamol100mg_suspension,
      case
          -- 1. when stockOnHand_Paracetamol120mg is null or blank string, no stock outs have occured
          when ( ( stockOnHand_Paracetamol120mg is null ) or ( trim( stockOnHand_Paracetamol120mg ) like '' ) )  
          then 0
          
          -- 2.  When stockOnHand_Paracetamol120mg is not null or blank and value is zero
          when cast( stockOnHand_Paracetamol120mg as unsigned ) = 0 
          then 1       
          else 0 -- not a stockout   
          
      end as stockout_paracetamol_100mg,     
       
      trim( stockOnHand_ZincSulfate )       as stockOnHand_ZincSulfate,
      null                                  as stockOnHand_ZincSulfate_Infidelity,
      case
          -- 1. when stockOnHand_ZincSulfate is null or blank string, no stock outs have occured
          when ( ( stockOnHand_ZincSulfate is null ) or ( trim( stockOnHand_ZincSulfate ) like '' ) )  
          then 0
          
          -- 2.  When stockOnHand_ZincSulfate is not null or blank and value is zero
          when cast( stockOnHand_ZincSulfate as unsigned ) = 0 
          then 1       
          else 0 -- not a stockout   
          
      end as stockout_zinc_sulfate,     
      
      null                                  as stockOnHand_artesunateSuppository,
      null                                  as stockOnHand_dispensingBags,
      null                                  as stockOnHand_femaleCondom,
      null                                  as stockOnHand_microlut,
      null                                  as stockOnHand_safetyBox,
      
      -- COVID-19 PPE stubs
      null                                  as stockOnHand_surgicalMask,
      null                                  as stockOnHand_glovesCovid19,
      null                                  as stockOnHand_disposable_gloves_regular_covid19

from lastmile_archive.chwdb_odk_chw_restock
;