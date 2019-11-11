use lastmile_datamart;

-- set @begin_date     = '2019-03-01';
-- set @begin_date     = '2012-10-01';
-- set @begin_date     = '2019-01-01';

set @begin_date       = '2012-10-01';
set @end_date         = current_date();
set @unit             = 'DAY';
set @position_status  = 'ALL';


call dimension_position_populate( @begin_date, @end_date, @unit, @position_status );

/*
truncate fact_restock_cha_commodity;
insert into fact_restock_cha_commodity (  record_id, 
                                          date_key, 
                                          position_id, 
                                          commodity_type, 
                                          stock_on_hand, 
                                          restock_type, 
                                          restock_partial, 
                                          stock_out_reason, 
                                          fullstock, stockout, 
                                          meta_insert_date_time 
                                       )
select  
      record_id, 
      date_key, 
      position_id, 
      commodity_type,
      stock_on_hand, 
      restock_type, 
      restock_partial, 
      stock_out_reason,
      fullstock,
      stockout,
      null
from view_fact_restock_cha_commodity;
*/

