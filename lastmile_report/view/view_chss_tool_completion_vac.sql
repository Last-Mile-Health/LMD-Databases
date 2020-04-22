use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_vac;

create view lastmile_report.view_chss_tool_completion_vac as
select 
      trim(   v.chssID        ) as chss_id,
      year(   v.meta_autoDate ) as `year`,
      month(  v.meta_autoDate ) as `month`,
      count( * ) as num_vaccine_trackers
      
from lastmile_upload.odk_vaccineTracker as v
where trim( v.chssID ) <> ''
group by `year`, `month`, trim( v.chssID )