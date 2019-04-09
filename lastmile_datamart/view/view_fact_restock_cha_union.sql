use lastmile_datamart;

drop view if exists view_fact_restock_cha_union;

create view view_fact_restock_cha_union as

select 
      chaRestockID                                    as record_id,
      trim( manualDate )                              as manualDate,
      trim( supervisedChaID )                         as supervisedChaID,
      trim( chaID )                                   as chaID,
      
      -- 1.
      trim( stockOnHand_ORS )                         as stockOnHand_ORS,
      trim( restockType_ORS )                         as restockType_ORS,
      trim( partialRestock_ORS )                      as partialRestock_ORS,
      trim( stockOutReason_ORS )                      as stockOutReason_ORS,
      trim( fullStock_ORS )                           as fullStock_ORS,
      
      -- 2.
      trim( stockOnHand_ACT25mg )                     as stockOnHand_ACT25mg,
      trim( restockType_ACT25mg )                     as restockType_ACT25mg,
      trim( partialRestock_ACT25mg )                  as partialRestock_ACT25mg,
      trim( stockOutReason_ACT25mg )                  as stockOutReason_ACT25mg,
      trim( fullStock_ACT25mg )                       as fullStock_ACT25mg,
      
      -- 3. 
      trim( stockOnHand_ACT50mg )                     as stockOnHand_ACT50mg,
      trim( restockType_ACT50mg )                     as restockType_ACT50mg,
      trim( partialRestock_ACT50mg )                  as partialRestock_ACT50mg,
      trim( stockOutReason_ACT50mg )                  as stockOutReason_ACT50mg,
      trim( fullStock_ACT50mg )                       as fullStock_ACT50mg,
      
      -- 4.
      trim( stockOnHand_ZincSulfate )                 as stockOnHand_ZincSulfate,
      trim( restockType_ZincSulfate )                 as restockType_ZincSulfate,
      trim( partialRestock_ZincSulfate )              as partialRestock_ZincSulfate,
      trim( stockOutReason_ZincSulfate )              as stockOutReason_ZincSulfate,
      trim( fullStock_ZincSulfate )                   as fullStock_ZincSulfate,
      trim( stockOnHand_ZincSulfate_Infidelity )      as stockOnHand_ZincSulfate_Infidelity,
      
      -- 5.
      trim( stockOnHand_Amoxicillin250mg )            as stockOnHand_Amoxicillin250mg,
      trim( restockType_Amoxicillin250mg )            as restockType_Amoxicillin250mg,
      trim( partialRestock_Amoxicillin250mg )         as partialRestock_Amoxicillin250mg,
      trim( stockOutReason_Amoxicillin250mg )         as stockOutReason_Amoxicillin250mg,
      trim( fullStock_Amoxicillin250mg )              as fullStock_Amoxicillin250mg,
      trim( stockOnHand_Amoxicillin250mg_suspension ) as  stockOnHand_Amoxicillin250mg_suspension
        
       
from lastmile_upload.odk_chaRestock

union all

select

      chwRestockID                            as record_id,
      trim( manualDate )                      as manualDate,
      trim( supervisedChwID )                 as supervisedChaID,
      null                                    as chaID, 
      
      -- 1.
      trim( stockOnHand_ORS )                 as stockOnHand_ORS,
      trim( restockType_ORS )                 as restockType_ORS,
      trim( partialRestock_ORS )              as partialRestock_ORS,
      trim( stockOutReason_ORS )              as stockOutReason_ORS,
      trim( fullStock_ORS )                   as fullStock_ORS,
      
      -- 2.
      trim( stockOnHand_ACT25mg )             as stockOnHand_ACT25mg,
      trim( restockType_ACT25mg )             as restockType_ACT25mg,
      trim( partialRestock_ACT25mg )          as partialRestock_ACT25mg,
      trim( stockOutReason_ACT25mg )          as stockOutReason_ACT25mg,
      trim( fullStock_ACT25mg )               as fullStock_ACT25mg,
        
      -- 3.
      trim( stockOnHand_ACT50mg )             as stockOnHand_ACT50mg,
      trim( restockType_ACT50mg )             as restockType_ACT50mg,
      trim( partialRestock_ACT50mg )          as partialRestock_ACT50mg,
      trim( stockOutReason_ACT50mg )          as stockOutReason_ACT50mg,
      trim( fullStock_ACT50mg )               as fullStock_ACT50mg,
      
      -- 4.
      trim( stockOnHand_ZincSulfate )         as stockOnHand_ZincSulfate,
      trim( restockType_ZincSulfate )         as restockType_ZincSulfate,
      trim( partialRestock_ZincSulfate )      as partialRestock_ZincSulfate,
      trim( stockOutReason_ZincSulfate )      as stockOutReason_ZincSulfate,
      trim( fullStock_ZincSulfate )           as fullStock_ZincSulfate,
      null                                    as stockOnHand_ZincSulfate_Infidelity,
      
      -- 5.
      trim( stockOnHand_amoxicillin250mg )    as stockOnHand_amoxicillin250mg,
      trim( restockType_amoxicillin250mg )    as restockType_amoxicillin250mg,
      trim( partialRestock_amoxicillin250mg ) as partialRestock_amoxicillin250mg,
      trim( stockOutReason_amoxicillin250mg ) as stockOutReason_amoxicillin250mg,
      trim( fullStock_amoxicillin250mg )      as fullStock_amoxicillin250mg,
      null                                    as stockOnHand_Amoxicillin250mg_suspension

from lastmile_archive.chwdb_odk_chw_restock
;