use lastmile_cha;

/*
  This view maps position_id(s) to historical chss_id that we used in our LMH ID System
  
  Note: When we stop running the nightly event to update the upload tables with new NCHAP_IDs, this view should be left around
  for historical reasons.  However, we will want to DROP the person_id_lmh column from the person table (it should be identical 
  to person_id and we should LEAVE position_id_lmh as the position ID key that points back to historical CHSS IDs, which were 
  unique to persons in the old LMH ID system.
 
*/

drop view if exists lastmile_cha.view_base_history_moh_lmh_chss_id;

create view lastmile_cha.view_base_history_moh_lmh_chss_id as

select
      trim( p.position_id ) as position_id,
      trim( pr.person_id )  as chss_id_historical,
      trim( pr.person_id )  as person_id
from lastmile_cha.position as p
    left outer join lastmile_cha.position_person as pr on trim( p.position_id ) like trim( pr.position_id ) 
where ( p.job_id = 3 )
;

