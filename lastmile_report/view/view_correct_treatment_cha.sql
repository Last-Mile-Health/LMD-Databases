use lastmile_report;

drop view if exists lastmile_report.view_correct_treatment_cha;

create view lastmile_report.view_correct_treatment_cha as 

select
      ( year( trim( c.date_form ) ) * 10000 ) + ( month( trim( c.date_form  )) * 100 ) + 1 as date_key, -- set date_key to first day of month for every record 
      trim( c.cha_id ) as position_id,
      c.*
from lastmile_upload.de_case_scenario as c
;