use lastmile_report;

drop view if exists lastmile_report.view_odk_position_id_cha_routine_visit;

create view lastmile_report.view_odk_position_id_cha_routine_visit as 
select 
      year(   a.visitDate )   as year_report,
      month(  a.visitDate )   as month_report,
      trim( a.chaID )         as position_id,
      count( * )              as number_record
        
from lastmile_upload.odk_routineVisit a
    left outer join lastmile_report.mart_view_base_history_position b on trim( a.chaID ) like b.position_id
where a.visitDate >= date_sub( current_date(), INTERVAL 6 month )
group by year( a.visitDate ), month( a.visitDate ), trim( a.chaID )
;