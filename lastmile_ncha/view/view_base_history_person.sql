use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_history_person;

create view lastmile_ncha.view_base_history_person as
select
      person_id,
      full_name,
      birth_date,
      gender,
      phone_number,
      phone_number_alternate,
      
      job,
      position_id,
      position_person_begin_date,
      position_person_end_date,
      position_person_active, 
      
      health_facility,
      health_facility_id,
      cohort,
      health_district,
      health_district_id,
      county,
      county_id,
      
      job_first,
      position_id_first,
      position_person_begin_date          as hire_date,
      position_person_end_date_first,
      position_person_active_first 
      
from lastmile_ncha.view_history_person_geo
;