use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_cha_person;

create view lastmile_ncha.view_position_cha_person as

select
      p.position_id_pk,
      p.position_id,
      p.position_begin_date,
      p.health_facility_id,
      p.health_facility,
      p.health_facility_description,
      p.cohort,

      pr.position_person_begin_date,
      pr.person_id,
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate
      
from lastmile_ncha.view_position_cha as p
    left outer join lastmile_ncha.view_position_person as pr on p.position_id_pk like pr.position_id_pk
;