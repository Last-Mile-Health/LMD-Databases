use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_chss;

create view lastmile_report.view_chss_tool_completion_chss as  

select 
      p.county,
      p.position_id     as chss_id,
      v.full_name       as chss,
      p.`month`,
      p.`year`,
      
      p.position_id_begin_date,
      p.position_id_end_date,
      v.position_person_begin_date,
      v.position_person_end_date
     
from lastmile_report.view_chss_tool_completion_position_id_month as p
    left outer join lastmile_ncha.view_history_position_person_chss as v on ( p.position_id like v.position_id ) and
    ( 
        ( v.position_person_begin_date <= concat( p.`year`, '-', p.`month`, '-', '01' ) ) and

        ( ( v.position_person_end_date is null ) or ( v.position_person_end_date >= concat( p.`year`, '-', p.`month`, '-', '01' ) )
        )
      )
;