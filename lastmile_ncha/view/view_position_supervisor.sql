use lastmile_ncha;

/*
 * 
 * Author: Owen Eddins
 * Date: March 31, 2020
 *
 * Returns the historical position_id-position_supervisor_id assignments
 *
 * Mimics the lastmile_cha.position_supervisor table, which held the supervisory assignemnts when
 * the NCHAP IDs uniquely identified positions.  Because the county teams periodically undergo CHA-CHSS
 * position reassignments, we went back and redesigned the lastmile_cha data maodel to allow positions
 * to be assigned different NCHAP IDs over time, with some limitations.  
 *
 * Currently, CHA positions can be assigned different NCHAP IDs over time, but an ID cannot be reused.
 * For example, the CHA position that is currently assigned BB01-01 could be assigned a different NCHAP Id, 
 * such as BB01-49, but the ID BB01-01 could not be reused and reassigned to a different CHA position.
 * This may change in the future, but for now, we don't want different CHAs using the same ID at different
 * points in time.  We may need to revisit this in the future once a CHSS catchment has undergone muultiple
 * reassignments and we run out of CHA IDs for that CHSS postion.  However, we could just stop using that
 * CHSS position ID altogether and give the CHSS a new position ID and all the CHA positions new IDs 
 * as well.  This would be disruptive, but in a different way.
 *
 * Another limitation is that CHSS positions are fixed, for now, and cannot be assigned new IDs.  There is nothing
 * inherent in the current lastmile_ncha data model that restricts this, but that underlying assumption is
 * this won't happen.  This assumption (and not reusing CHA position IDs) built into the views and dimension_position
 * tables.
 *
 * If those limits are changed, we will have to go back and recode those views and stored procedures.
 * 
 *
*/

drop view if exists lastmile_ncha.view_position_supervisor;

create view lastmile_ncha.view_position_supervisor as 
select 
      ps.position_id_pk,
      ps.position_supervisor_id_pk,
      
      ps.begin_date       as position_supervisor_id_pk_begin_date,
      ps.end_date         as position_supervisor_id_pk_end_date,

      pida.position_id,
      pida.begin_date     as position_id_begin_date,
      pida.end_date       as position_id_end_date,
      
      pids.position_id    as position_supervisor_id,
      pids.begin_date     as position_supervisor_id_begin_date,
      pids.end_date       as position_supervisor_id_end_date
      
from lastmile_ncha.position_supervisor as ps
    left outer join lastmile_ncha.position_id as pida on ps.position_id_pk = pida.position_id_pk
    left outer join lastmile_ncha.position_id as pids on ps.position_supervisor_id_pk = pids.position_id_pk
where (     ( ps.end_date is null ) and     ( pida.end_date is null ) ) or
      ( not ( ps.end_date is null ) and not ( pida.end_date is null ) ) or
      (     ( ps.end_date is null ) and not ( pida.end_date is null ) and ( pida.end_date >= ps.begin_date ) )  
;      
