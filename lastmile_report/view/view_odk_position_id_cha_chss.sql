use lastmile_report;

drop view if exists lastmile_report.view_odk_position_id_cha_chss;

create view lastmile_report.view_odk_position_id_cha_chss as
select 
      'CHSS'            as job,
      year_report, 
      month_report, 

      county,    
      health_district,
      health_facility,
      
      qao,
      chss_position_id,
      chss,
      sum( number_sick_child_record ) as number_sick_child_record
      
from lastmile_report.view_odk_position_id_cha as d
group by year_report, month_report, county, health_district, health_facility, qao, chss_position_id
-- order by cast( year_report as unsigned ) desc, cast( month_report as unsigned ) desc, county asc, health_district asc, health_facility asc, chss_position_id asc
;