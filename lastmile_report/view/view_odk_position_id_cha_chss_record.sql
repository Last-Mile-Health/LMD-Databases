use lastmile_report;

drop view if exists lastmile_report.view_odk_position_id_cha_chss_record;

create view lastmile_report.view_odk_position_id_cha_chss_record as
select 
      job,
      year_report, 
      month_report, 

      county,    
      health_district,
      health_facility,
      
      qao,
      chss_position_id,
      chss,
       
      position_id,
      cha,
      community_id_list,
      community_list,
      number_sick_child_record
      
from lastmile_report.view_odk_position_id_cha

union all

select 
      job,
      year_report, 
      month_report, 

      county,    
      health_district,
      health_facility,
      
      qao,
      chss_position_id,
      chss,
       
      null as position_id,
      null as cha,
      null as community_id_list,
      null as community_list,
      number_sick_child_record
      
from lastmile_report.view_odk_position_id_cha_chss

order by cast( year_report as unsigned ) desc, cast( month_report as unsigned ) desc, county asc, health_district asc, health_facility asc, chss_position_id asc, job asc, position_id
;