use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_cha;

create view lastmile_ncha.view_position_cha as

select
      p.position_id_pk,
      p.position_id,
      p.position_begin_date,
      p.health_facility_id,
      p.health_facility,
      p.health_facility_description,
      p.cohort
from lastmile_ncha.view_position as p
where p.job like 'CHA'
;