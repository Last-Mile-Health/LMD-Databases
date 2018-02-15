use lastmile_cha;

drop view if exists view_history_position_person_cha;

create view view_history_position_person_cha as 

select
 
      position_id,
      position_active,
      position_begin_date,
      position_end_date,
 
      person_id,    
      full_name,
      birth_date,
      gender,
      phone_number,
      phone_number_alternate, 
      
      position_person_active,
      position_person_begin_date,
      position_person_end_date,
      
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
where job like 'CHA'
;