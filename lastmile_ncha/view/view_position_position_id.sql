use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_position_id;

create view lastmile_ncha.view_position_position_id as
select
      position_id_pk, 
      position_id,
      job_id, 
      begin_date, -- begin_date from table position
      position_id_begin_date,
      health_facility_id,
      cohort,
      note
      
from lastmile_ncha.view_history_position_position_id
where ( end_date is null ) and ( position_id_end_date is null )
;