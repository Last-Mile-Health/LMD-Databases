use lastmile_report;

drop view if exists lastmile_report.view_kobo_ifi_community;

create view lastmile_report.view_kobo_ifi_community as 
select
      _uuid                           as meta_uuid,
      county,
      
      year(   `date` )                as `year`,
      month(  `date` )                as `month`,
      
      `date`,
      supplyrestockdate,
     
      supervision_last4wks,
      incentive_correct,
      incentive_ontime,
        
      supply_act50_stock,
      supply_act25_stock,
      supply_amox_stock,
      supply_ors_stock,
      supply_zinc_stock,
   
      sd_scenario_1,
      sd_scenario_2,
      sd_scenario_3,
      sd_scenario_4,

      me_correct_form1,
      me_correct_form2,
      me_correct_form3,
      me_bold_form1,
      me_bold_form2,
      me_bold_form3
      
from lastmile_upload.kobo_ifi_community_covid

union all

select 
      _uuid                           as meta_uuid,
      county,
      
      year(   `date` )                as `year`,
      month(  `date` )                as `month`,
      `date`,
      supplyrestockdate,
     
      supervision_last4wks,
      incentive_correct,
      incentive_ontime,
        
      supply_act50_stock,
      supply_act25_stock,
      supply_amox_stock,
      supply_ors_stock,
      supply_zinc_stock,
   
      sd_scenario_1,
      sd_scenario_2,
      sd_scenario_3,
      sd_scenario_4,

      me_correct_form1,
      me_correct_form2,
      me_correct_form3,
      me_bold_form1,
      me_bold_form2,
      me_bold_form3
      
from lastmile_upload.kobo_ifi_community
;