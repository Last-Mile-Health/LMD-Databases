use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_position_id_cha_update;

create view lastmile_ncha.view_history_position_position_id_cha_update as
-- Create list of NCHAP IDs, which always have a hyphen.
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
where position_id like '%-%' and job_id like '1'

union all

/*
 * Map LMH integer IDs to NCHAP IDs.  This code replaces the position_id_lmh code from
 * the lastmile_cha schema.  
 * Note: With lastmile_ncha we no longer try to map old IDs in records to person IDs, like we did in lastmile_cha.
 * Those won't get overwritten with the new _ncha scripts.  They will be left for time immemorial. 
*/
select 
      p.position_id_pk, 
      p.begin_date, 
      p.end_date,
      
      p.position_id, 
      if( f.position_id_nchap is null, p.position_id, f.position_id_nchap ) as position_id_nchap,
      p.position_id_begin_date, 
      p.position_id_end_date, 
      p.health_facility_id, 
      p.cohort
      
from lastmile_ncha.view_history_position_position_id as p
    left outer join lastmile_ncha.view_history_position_position_id_nchap_first as f on p.position_id_pk = f.position_id_pk
where not ( position_id like '%-%' ) and job_id like '1'
;