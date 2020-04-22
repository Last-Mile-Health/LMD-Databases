use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_msr_chss;

create view lastmile_report.view_chss_tool_completion_msr_chss as

select 
        trim( u.chss_id )       as  chss_id,
        cast( u.month_reported  as unsigned ) as month_reported,
        cast( u.year_reported   as unsigned ) as year_reported,
        
        -- There should never be more than one CHSS MSR per CHSS, so don't actually add the number of CHSS MSRs
        -- turned in by CHSS, just make sure there is > 0
        1                       as num_chss_msrs
        
       
        
from lastmile_upload.de_chss_monthly_service_report as u
group by  trim( u.chss_id ), 
          cast( u.year_reported   as unsigned ),
          cast( u.month_reported  as unsigned )
          