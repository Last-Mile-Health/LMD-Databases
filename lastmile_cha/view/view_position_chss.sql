use lastmile_cha;

drop view if exists view_position_chss;

create view view_position_chss as

select
      p.position_id,
      p.position_begin_date,
      p.health_facility_id,
      p.health_facility,
      p.health_facility_description
from view_position as p
where p.job like 'CHSS'
;