use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_position_id_month;

create view lastmile_report.view_chss_tool_completion_position_id_month as
select
      a.`year`,
      a.`month`,
      pid.county,
      pid.position_id,
      
      pid.position_id_begin_date,
      pid.position_id_end_date
      
from lastmile_ncha.view_history_position_geo as pid 
    cross join lastmile_report.view_chss_tool_completion_months as a
where ( pid.job like 'CHSS' ) and
      ( 
        ( pid.position_id_begin_date <= concat( a.`year`, '-', a.`month`, '-', '01' ) ) and

        ( ( pid.position_id_end_date is null ) or ( pid.position_id_end_date >= concat( a.`year`, '-', a.`month`, '-', '01' ) )
        )
      )
;