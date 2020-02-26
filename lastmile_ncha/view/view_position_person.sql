use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_person;

create view lastmile_ncha.view_position_person as

select
      pr.position_id_pk,
      pr.begin_date               as position_person_begin_date,

      r.person_id,
      trim( r.person_id_lmh )     as person_id_lmh,
      
      r.first_name,
      r.last_name,
      r.other_name,
      r.birth_date,
      r.gender,
      r.phone_number,
      r.phone_number_alternate
        
from lastmile_ncha.position_person as pr
    left outer join lastmile_ncha.person as r on pr.person_id = r.person_id
where pr.end_date is null
-- only return active position_person records
;