use lastmile_datamart;

drop view if exists view_fact_restock_cha_commodity;

create view view_fact_restock_cha_commodity as
                                            
select
      record_id,
      date_key,
      position_id,
      commodity_type,
      
      if( stock_on_hand   like '' or stock_on_hand < 0    , null, stock_on_hand   ) as stock_on_hand,
      restock_type,
      if( restock_partial like '' or restock_partial < 0  , null, restock_partial ) as restock_partial,
      stock_out_reason,
      if( fullstock       like '' or fullstock  < 0       , null, fullstock       ) as fullstock,
      if( stockout        like '' or stockout   < 0       , null, stockout        ) as stockout
      
from view_fact_restock_cha_serial
where not ( record_id is null ) and not ( date_key is null ) and not ( position_id is null ) and not ( commodity_type is null )
;
