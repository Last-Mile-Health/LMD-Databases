use lastmile_cha;

drop view if exists view_base_position_chss;

create view view_base_position_chss as

select

      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      position_id,
      position_begin_date,
      
      position_filled,
      position_filled_last_date,
      
      person_id,
      concat( first_name, ' ', last_name )  as chss,
      position_person_begin_date,
      hire_date,
      birth_date,
      gender,
      phone_number,
      phone_number_alternate,

      module
      
from view_position_chss_person_geo
;