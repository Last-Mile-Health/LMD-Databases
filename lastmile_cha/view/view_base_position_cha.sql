use lastmile_cha;

drop view if exists view_base_position_cha;

create view view_base_position_cha as

select
      county_id,
      county,
      
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      position_filled,
      position_filled_last_date,
      
      position_id,
      
      position_id                                 as cha_id,   -- position_id is now the same as cha_id
      person_id,
      concat( first_name, ' ', last_name )        as cha,
      position_person_begin_date,
      position_begin_date,
          
      -- cha person fields
      hire_date,
      
      birth_date,
      gender,
      phone_number,
      phone_number_alternate,
      
      community_id_list,
      community_list,
      
      -- household registration data from paper forms
      total_household,
      total_household_member,
      
      -- CHA Training completed
      module,
    
      chss_position_begin_date,
      
      chss_cha_supervision_begin_date                         as chss_supervision_begin_date,
      
      chss_position_id,
      chss_position_id                                        as chss_id,
      chss_person_id,
      concat( chss_first_name, ' ', chss_last_name )          as chss,
      
      chss_position_person_begin_date,
      chss_hire_date,

      chss_birth_date,
      chss_gender,
      chss_phone_number,
      chss_phone_number_alternate,
      
      chss_module,
      
      chss_health_facility_id,
      chss_health_facility,
      
      chss_health_district_id,
      chss_health_district,
      
      chss_county_id,
      chss_county
      
from view_position_cha_geo_community_person
;