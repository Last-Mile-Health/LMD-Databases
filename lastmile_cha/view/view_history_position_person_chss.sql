use lastmile_cha;

drop view if exists view_history_position_person_chss;

create view view_history_position_person_chss as 

select
      position_id,                                    
      full_name,
      person_id,    
      position_person_begin_date,
      position_person_end_date,
      
      -- new fields
      position_active,
      position_begin_date,
      position_end_date,
 
      birth_date,
      gender,
      phone_number,
      phone_number_alternate, 
      position_person_active,
      reason_left,
      reason_left_description,
      health_facility_id,
      health_facility,    
      cohort,
      health_district_id,
      health_district,
      county_id,
      county
      
from view_history_position_person
where job like 'CHSS'
;