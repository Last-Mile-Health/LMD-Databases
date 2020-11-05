use lastmile_report;

drop view if exists lastmile_report.view_odk_position_id_cha_sick_child;

create view lastmile_report.view_odk_position_id_cha_sick_child as 
select 
      year(   a.manualDate )  as year_report,
      month(  a.manualDate )  as month_report,
      trim( a.chwID )         as position_id,
      count( * )              as number_record
        
from lastmile_upload.odk_sickChildForm a
    left outer join lastmile_report.mart_view_base_history_position b on trim( a.chwID ) like b.position_id
group by year( a.manualDate ), month( a.manualDate ), trim( a.chwID )
;