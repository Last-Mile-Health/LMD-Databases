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
      position_id_lmh,
      
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
      
      -- Beginning of the CHSS info
      
      chss_position_begin_date,
      chss_cha_supervision_begin_date                         as chss_supervision_begin_date,
      
      chss_position_id,
      chss_person_id,
      chss_person_id_lmh,
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
      chss_county,
      
      -- Beginning of the QAO info
      
      qao_position_begin_date,
      qao_chss_supervision_begin_date                         as qao_supervision_begin_date,
      
      qao_position_id,
      qao_person_id,
      qao_person_id_lmh,
      concat( qao_first_name, ' ', qao_last_name )          as qao,
      
      qao_position_person_begin_date,
      qao_hire_date,

      qao_birth_date,
      qao_gender,
      qao_phone_number,
      qao_phone_number_alternate,
           
      qao_health_facility_id,
      qao_health_facility,
      
      qao_health_district_id,
      qao_health_district,
      
      qao_county_id,
      qao_county
      
      
from view_position_cha_geo_community_person
;
