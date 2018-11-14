use lastmile_cha;

drop view if exists view_position;

create view view_position as

select
      trim( p.position_id )             as position_id,
      
      -- For CHA positions, this is valid.  For CHSSs, show the person_id_lmh for chss position id lmh
      trim( p.position_id_lmh )         as position_id_lmh,
      
      trim( j.title )                   as job,
            p.begin_date                as position_begin_date,
            p.end_date                  as position_end_date,
      trim( p.health_facility_id )      as health_facility_id,
      trim( f.health_facility)          as health_facility,
      trim( f.description )             as health_facility_description,
      trim( p.cohort )                  as cohort

from `position` as p
    left outer join job as j              on trim( p.job_id )             like trim( j.job_id )
    left outer join health_facility as f  on trim( p.health_facility_id ) like trim( f.health_facility_id )
where p.end_date is null
;

