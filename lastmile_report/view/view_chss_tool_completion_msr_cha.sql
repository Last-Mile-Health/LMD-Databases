use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_msr_cha;

create view lastmile_report.view_chss_tool_completion_msr_cha as 
select  
      trim( chss_id )                     as chss_id,
      cast( month_reported  as unsigned ) as month_reported,
      cast( year_reported   as unsigned ) as year_reported,
      count( * )                          as num_cha_msrs
      
from lastmile_upload.de_cha_monthly_service_report
group by  trim( chss_id ),
          cast( year_reported   as unsigned ),
          cast( month_reported  as unsigned )
;