use lastmile_report;

drop view if exists lastmile_report.view_correct_treatment_cha;

create view lastmile_report.view_correct_treatment_cha as 

select
      -- Set date_key to first day of month for every record.  For v2 of form, day, month, year are all discrete fields.
      
      ( cast( coalesce( trim( c.year_report   ), 0 ) as unsigned ) * 10000  ) + 
      ( cast( coalesce( trim( c.month_report  ), 0 ) as unsigned ) * 100    ) + 1 as date_key, 
      
      trim( c.cha_id ) as position_id
      
from lastmile_upload.de_case_scenario_2 as c

union all

select
      ( year( trim( c.date_form ) ) * 10000 ) + ( month( trim( c.date_form  )) * 100 ) + 1 as date_key, -- set date_key to first day of month for every record 
      trim( c.cha_id ) as position_id
from lastmile_upload.de_case_scenario as c
;