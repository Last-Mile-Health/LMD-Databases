use lastmile_cha;

drop view if exists view_position_person;

create view view_position_person as

select

      pr.position_id,
      pr.begin_date               as position_person_begin_date,

      r.person_id,
      r.first_name,
      r.last_name,
      r.other_name,
      r.birth_date,
      r.gender,
      r.phone_number,
      r.phone_number_alternate
      
from position_person as pr
    left outer join person as r on  pr.person_id = r.person_id 
where pr.end_date is null -- only return active position_person records
;