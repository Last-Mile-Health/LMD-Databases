use lastmile_datamart;

drop view if exists view_fact_restock_cha;

create view view_fact_restock_cha as

select
      r.record_id,
      ( year( r.manualDate ) * 10000 ) + ( month( r.manualDate  ) * 100 ) + day( r.manualDate ) as date_key,
      
      if( trim( r.supervisedChaID ) is null or trim( r.supervisedChaID ) like '', 
          trim( r.chaID ), 
          trim( r.supervisedChaID ) )  as position_id,
      
      -- 1.
      r.stockOnHand_ORS,
      r.restockType_ORS,
      r.partialRestock_ORS,
      r.stockOutReason_ORS,
      r.fullStock_ORS,
      if( r.stockOnHand_ORS like '0', 1, 0 )      as stockout_ORS,
      
      -- 2.
      r.stockOnHand_ACT25mg,
      r.restockType_ACT25mg,
      r.partialRestock_ACT25mg,
      r.stockOutReason_ACT25mg,
      r.fullStock_ACT25mg,
      if( r.stockOnHand_ACT25mg like '0', 1, 0 )  as stockout_ACT25mg,
  
    -- 3.
      r.stockOnHand_ACT50mg,
      r.restockType_ACT50mg,
      r.partialRestock_ACT50mg,
      r.stockOutReason_ACT50mg,
      r.fullStock_ACT50mg,
      if( r.stockOnHand_ACT50mg like '0', 1, 0 )  as stockout_ACT50mg,
      
      -- 4.
      r.stockOnHand_ZincSulfate,
      r.restockType_ZincSulfate,
      r.partialRestock_ZincSulfate,
      r.stockOutReason_ZincSulfate,
      r.fullStock_ZincSulfate,
      if( ( r.stockOnHand_ZincSulfate like '0' ) and 
          ( ( r.stockOnHand_ZincSulfate_Infidelity like '0' ) or ( isnull( r.stockOnHand_ZincSulfate_Infidelity ) ) ),
          1,
          0
      ) as stockout_ZincSulfate,
      
      -- 5.
      r.stockOnHand_Amoxicillin250mg,
      r.restockType_Amoxicillin250mg,
      r.partialRestock_Amoxicillin250mg,
      r.stockOutReason_Amoxicillin250mg,
      r.fullStock_Amoxicillin250mg,
      if( ( r.stockOnHand_Amoxicillin250mg like '0' ) and 
          ( ( r.stockOnHand_Amoxicillin250mg_suspension like '0'    )  or ( isnull( r.stockOnHand_Amoxicillin250mg_suspension  ) ) ) 
          ,
          1,
          0 
      ) as stockout_Amoxicillin250mg
      
from lastmile_datamart.view_fact_restock_cha_union as r
    inner join lastmile_cha.`position` as p on (  -- if supervisedChaID is a null or an empty string then use chaID; otherwise use supervisedChaID
                                                  if( trim( r.supervisedChaID ) is null or trim( r.supervisedChaID ) like '', 
                                                      trim( r.chaID ), 
                                                      trim( r.supervisedChaID ) )
                                                      
                                                    -- compare to position_id in position table in lastmile_cha
                                                    like trim( p.position_id ) 
                                                )
                                                and
                                                ( trim( p.job_id ) like '1' )  -- type CHA   

where not ( r.manualDate is null or trim( r.manualDate ) like '' )
; -- end of view