use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_sup;

create view lastmile_report.view_chss_tool_completion_sup AS 
select 
      trim(  u.chssID     ) as chss_id,
      year(  u.manualDate ) as `year`,
      month( u.manualDate ) as `month`,
      count( * )            as `num_supervision_visit_logs`
      
from lastmile_upload.odk_supervisionVisitLog as u
where trim(  u.chssID ) <> '' and u.meta_fabricated <> 1
group by `year`, `month`, trim( u.chssID )
    
union
  
select 
      trim(   s.ccsID       ) as chss_id,
      year(   s.manualDate  ) as `year`,
      month(  s.manualDate  ) as `month`,
      COUNT( * )              as num_supervision_visit_logs

from lastmile_archive.staging_odk_supervisionvisitlog as s
where ( trim( s.ccsID ) <> '' )
group by `year`, `month`, trim( s.ccsID )
;