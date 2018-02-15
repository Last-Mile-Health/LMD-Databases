use lastmile_cha;

drop view if exists view_history_position_person_chss;

create view view_history_position_person_chss as 

select
      position_id,                                    
      full_name,
      person_id,    
      position_person_begin_date,
      position_person_end_date
from view_history_position_person
where job like 'CHSS'
;