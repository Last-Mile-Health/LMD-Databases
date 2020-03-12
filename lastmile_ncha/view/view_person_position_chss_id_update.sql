use lastmile_ncha;

drop view if exists lastmile_ncha.view_person_position_chss_id_update;

create view lastmile_ncha.view_person_position_chss_id_update as

select
      pr.position_id_pk,
      l.position_id_last, -- last is not used for CHSS for same reason, see note below.
      pr.position_id,
      pr.person_id,
      pr.person_id_lmh,
      
      /* Note:  I copied the cha code over here.  For now, we are not going to allow the CHSS position IDs
       *        to be given a different ID.  It doesn't make sense to give CHSS positions different IDs
                becaause then you would need to give every one of the CHAs different IDs to conform to the 
                new CHSS position ID.
                
                For example, what if you wanted to switch the IDs of the two CHSSs in ITI?
                
                So the CHSS catchment BB01-001 covers would start using BB01-002 and BB01-002 would 
                start using BB01-001.  You would have to change all of the CHA IDs.  So -01 to -10 
                whould start using -20 to -29 and -20 to -29 would start using -01 to -10.
                
                Doesn't make sense that you would ever start doing this.
        
      */
      
      -- pr.person_id as chss_id_historical,
      -- if( pr.position_id like pr.person_id_lmh, pr.position_id, pr.person_id_lmh ) as chss_id_historical,
      
      pr.position_begin_date,
      pr.position_end_date,
      
      pr.position_id_begin_date,
      pr.position_id_end_date,
      
      pr.position_person_begin_date,
      pr.position_person_end_date
      
from lastmile_ncha.view_history_person_position_chss as pr
    left outer join lastmile_ncha.view_history_position_id_last as l on pr.position_id_pk like l.position_id_pk
;