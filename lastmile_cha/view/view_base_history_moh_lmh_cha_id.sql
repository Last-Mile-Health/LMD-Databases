use lastmile_cha;

/*
  This view maps position_id(s) to historical cha_id that we used in our LMH ID System
  
  Note: When we stop running the nightly event to update the upload tables with new NCHAP_IDs, this view should be left around
  for historical reasons.  However, we will want to DROP the person_id_lmh column from the person table (it should be identical 
  to person_id and we should LEAVE position_id_lmh as the position ID key that points back to historical CHW IDs, which were 
  unique to persons in the old LMH ID system.
  
  We should recode this view to drop the person_id_lmh to person_id.  All the update statements in the procedure called from the
  event will disappear.
  
  This view is too slow.  When joined to view_base_position_cha it takes about a minute and 45 secs to run.  I created a "temp" 
  table to act as a stand in for it.  The execution time drops down to about 2-4 secs.
*/

drop view if exists lastmile_cha.view_base_history_moh_lmh_cha_id;

create view lastmile_cha.view_base_history_moh_lmh_cha_id as

select

      p.position_id,
       
      if( p.position_id_lmh is null or  trim( p.position_id_lmh ) like '', 
      
          null,
          
          if( p.position_id_lmh like r.person_id_lmh, p.position_id_lmh, r.person_id_lmh ) 
      
      ) as cha_id_historical,
      
      p.position_id_lmh,
      p.begin_date        as position_begin_date,
      p.end_date          as position_end_date,
      
      pr.begin_date       as position_person_begin_date,
      pr.end_date         as position_person_end_date,
      
      r.person_id,
      r.person_id_lmh
      
from lastmile_cha.position as p
    left outer join lastmile_cha.position_person as pr on p.position_id  like pr.position_id
        left outer join lastmile_cha.person      as r  on pr.person_id   like r.person_id
where ( p.job_id = 1 ) 
;

