use lastmile_report;

drop view if exists lastmile_report.view_kobo_ifi;

create view lastmile_report.view_kobo_ifi as 
select

      `month`,
      `year`,
      county,
      lastmile_report.territory_id( county_id, 2 )  as territory_id,
      
      sum( numReports )                                                   as numReports,
      sum( restockedInLastMonth )                                         as restockedInLastMonth,
      sum( restockedInLast3Months )                                       as restockedInLast3Months,
      sum( supervisedLastMonth )                                          as supervisedLastMonth,
      sum( receivedLastIncentiveOnTime )                                  as receivedLastIncentiveOnTime,
      
      sum( coalesce( life_saving_in_stock, 0 ) )                          as number_life_saving_in_stock,
      
      sum( coalesce( act_50_135_mg_tablet_in_stock, 0 ) )                 as number_act_50_135_mg_tablet_in_stock,
      sum( coalesce( act_25_67_5_mg_tablet_in_stock, 0 ) )                as number_act_25_67_5_mg_tablet_in_stock,
      
      sum( coalesce( act_25_or_50_mg_tablet_in_stock, 0 ) )               as number_act_25_or_50_mg_tablet_in_stock,
      sum( coalesce( amox_250_mg_dispersible_tablet_in_stock, 0 ) )       as number_amox_250_mg_dispersible_tablet_in_stock,
      sum( coalesce( ors_20_6_1l_sachet_in_stock, 0 ) )                   as number_ors_20_6_1l_sachet_in_stock,
      sum( coalesce( zinc_sulfate_20_mg_scored_tablet_in_stock, 0 ) )     as number_zinc_sulfate_20_mg_scored_tablet_in_stock,
      
      sum( coalesce( service_delivery_question_correct_1_4, 0 ) )         as number_service_delivery_question_correct_1_4,
      sum( coalesce( correct_treatment ) )                                as number_correct_treatment
   
from lastmile_report.view_kobo_ifi_calculations as c
group by county , `month`, `year`
;