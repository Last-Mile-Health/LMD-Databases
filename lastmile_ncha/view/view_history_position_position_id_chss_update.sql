use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_position_id_chss_update;

create view lastmile_ncha.view_history_position_position_id_chss_update as

select 
      p.position_id_pk, 
      p.begin_date, 
      p.end_date,
      
      p.position_id, 
      p.position_id as position_id_nchap,
      p.position_id_begin_date, 
      p.position_id_end_date, 
      p.health_facility_id, 
      p.cohort
      
from lastmile_ncha.view_history_position_position_id as p
where position_id like '%-%' and job_id like '3'
;