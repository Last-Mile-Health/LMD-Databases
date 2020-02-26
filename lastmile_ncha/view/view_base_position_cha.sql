use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_position_cha;

create view lastmile_ncha.view_base_position_cha as
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
      
      position_id_pk,
      position_id,    
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
      
      chss_position_id_pk,
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
            
      -- Beginning of the QAO info
      
      qao_position_begin_date,
      qao_chss_supervision_begin_date                         as qao_supervision_begin_date,
      
      qao_position_id_pk,
      qao_position_id,
      qao_person_id,
      qao_person_id_lmh,
      concat( qao_first_name, ' ', qao_last_name )          as qao,
      
      qao_position_person_begin_date,
      qao_hire_date,

      qao_birth_date,
      qao_gender,
      qao_phone_number,
      qao_phone_number_alternate
           
from lastmile_ncha.view_position_cha_geo_community_person
;
