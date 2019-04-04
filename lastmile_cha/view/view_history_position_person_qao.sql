use lastmile_cha;

drop view if exists view_history_position_person_qao;

create view view_history_position_person_qao as 

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

      county
      
from view_history_position_person
where job like 'QAO'
;