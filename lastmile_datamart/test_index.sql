select
      dp.county,
      dp.qao_position_id,
      dp.qao_full_name,
      dp.chss_position_id,
      dp.chss_full_name,
      
      dd.calendar_year,
      dd.month_name,
      commodity_type,
      count( * )          as number_restock_event,
      sum( stockout )     as number_stockout,
      
      ( sum( stockout ) / count( * ) ) * 100 as percent_stockout
      
from dimension_position dp
  inner join dimension_date             as dd on dp.date_key = dd.date_key
  inner join fact_restock_cha_commodity as r  on dp.date_key = r.date_key   and dp.position_id like r.position_id -- and commodity_type like 'ors'
-- where dp.date_key between 20190201 and 20190228
group by  dp.county, dp.qao_position_id, dp.qao_full_name, dp.chss_position_id, dp.chss_full_name, dd.calendar_year, dd.month_name, commodity_type
