/*
 * view_position
 *
 * Returns all active positions from the position table.
 *
 * For a position to be active, its end_date must be null.
 *
*/

use lastmile_ncha;

drop view if exists lastmile_ncha.view_position;

create view lastmile_ncha.view_position as

select
      p.position_id_pk,
      trim( pid.position_id )           as position_id,     
      trim( j.title )                   as job,
            p.job_id,
            p.begin_date                as position_begin_date,
            -- p.end_date                  as position_end_date,
      trim( pid.health_facility_id )    as health_facility_id,
      trim( f.health_facility)          as health_facility,
      trim( f.description )             as health_facility_description,
      trim( pid.cohort )                as cohort

from lastmile_ncha.`position` as p
    left outer join lastmile_ncha.job as j on trim( p.job_id ) like trim( j.job_id )
    left outer join lastmile_ncha.position_id as pid on ( p.position_id_pk = pid.position_id_pk ) and ( pid.end_date is null )
        left outer join lastmile_ncha.health_facility as f on trim( pid.health_facility_id ) like trim( f.health_facility_id )
where p.end_date is null
;

