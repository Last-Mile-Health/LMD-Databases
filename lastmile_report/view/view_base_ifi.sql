use lastmile_report;

drop view if exists view_base_ifi;

create view view_base_ifi as 
select

      `month`,
      `year`,
      county,
      lastmile_report.territory_id( view_ifi_calculations.county_id, 2 )  as territory_id,
      
      sum( numReports )                                                   as numReports,
      sum( restockedInLastMonth )                                         as restockedInLastMonth,
      sum( restockedInLast3Months )                                       as restockedInLast3Months,
      sum( supervisedLastMonth )                                          as supervisedLastMonth,
      sum( receivedLastIncentiveOnTime )                                  as receivedLastIncentiveOnTime,
      
      sum( coalesce( life_saving_in_stock, 0 ) )                          as number_life_saving_in_stock,
      sum( coalesce( act_50_135_mg_tablet_in_stock, 0 ) )                 as number_act_50_135_mg_tablet_in_stock
      
from lastmile_report.view_ifi_calculations
group by county , `month`, `year`
;