use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_position_id;

create view lastmile_ncha.view_history_position_position_id as
select
      p.position_id_pk, 
      p.job_id, 
      p.begin_date, 
      p.end_date,
      
      pid.position_id,
      pid.begin_date            as position_id_begin_date,
      pid.end_date              as position_id_end_date,
      pid.health_facility_id,
      pid.cohort,
      pid.note
      
from lastmile_ncha.`position` as p
    left outer join lastmile_ncha.position_id as pid on p.position_id_pk = pid.position_id_pk
;