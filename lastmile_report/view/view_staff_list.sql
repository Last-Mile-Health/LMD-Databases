use lastmile_report;

drop view if exists view_staff_list;

create view view_staff_list as 

select
      county,
      health_district,
      health_facility,
      
      chss,
      chss_id,
     
      cha,
      cha_id,

      community_list,
      community_id_list
      
from lastmile_cha.view_base_position_cha
order by county, health_district, health_facility, chss, cha, community_list
;
