use lastmile_cha;

drop view if exists view_position_qao_person;

create view view_position_qao_person as

select
      p.position_id,
      p.position_begin_date,
      p.health_facility_id,
      p.health_facility,
      p.health_facility_description,

      pr.position_person_begin_date,
      pr.person_id,
      pr.person_id_lmh,
      
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate
      
from view_position_qao as p
    left outer join view_position_person as pr on p.position_id like pr.position_id
;