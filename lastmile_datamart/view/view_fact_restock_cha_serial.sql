use lastmile_datamart;

drop view if exists view_fact_restock_cha_serial;

create view view_fact_restock_cha_serial as
                                            
-- 1.
select
      record_id,
      date_key,
      position_id,
      
      'ors'                     as commodity_type,
      stockOnHand_ORS           as stock_on_hand,
      restockType_ORS           as restock_type,
      partialRestock_ORS        as restock_partial,
      stockOutReason_ORS        as stock_out_reason,
      fullStock_ORS             as fullstock,  
      stockout_ORS              as stockout
       
from view_fact_restock_cha

union all

-- 2.
select
      record_id,
      date_key,
      position_id,
      
      'act_25_mg'               as commodity_type,
      stockOnHand_ACT25mg       as stock_on_hand,
      restockType_ACT25mg       as restock_type,
      partialRestock_ACT25mg    as restock_partial,
      stockOutReason_ACT25mg    as stock_out_reason,
      fullStock_ACT25mg         as fullstock,
      stockout_ACT25mg          as stockout
      
from view_fact_restock_cha

union all

-- 3.
select
      record_id,
      date_key,
      position_id,
      
      'act_50_mg'               as commodity_type,
      stockOnHand_ACT50mg       as stock_on_hand,
      restockType_ACT50mg       as restock_type,
      partialRestock_ACT50mg    as restock_partial,
      stockOutReason_ACT50mg    as stock_out_reason,
      fullStock_ACT50mg         as fullstock,
      stockout_ACT50mg          as stockout
     
from view_fact_restock_cha

union all

-- 4.
select
      record_id,
      date_key,
      position_id,
      
      'zinc_sulfate'                    as commodity_type,
      stockOnHand_ZincSulfate           as stock_on_hand,
      restockType_ZincSulfate           as restock_type,
      partialRestock_ZincSulfate        as restock_partial,
      stockOutReason_ZincSulfate        as stock_out_reason,
      fullStock_ZincSulfate             as fullstock,
      stockout_ZincSulfate              as stockout
      
from view_fact_restock_cha


union all

-- 5.
select
      record_id,
      date_key,
      position_id,
      
      'amoxicillin_250_mg'                  as commodity_type,
      stockOnHand_Amoxicillin250mg          as stock_on_hand,
      restockType_Amoxicillin250mg          as restock_type,
      partialRestock_Amoxicillin250mg       as restock_partial,
      stockOutReason_Amoxicillin250mg       as stock_out_reason,
      fullStock_Amoxicillin250mg            as fullstock,
      stockout_Amoxicillin250mg             as stockout
      
from view_fact_restock_cha

;