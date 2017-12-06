use lastmile_cha;

drop view if exists view_history_person_geo;

create view view_history_person_geo as

select
      trim( r.person_id )                               as person_id,
      
      -- CHA IDs will now be reused as CHAs come and go, so make position_id the public staff_id
      -- CHSS IDs will still be unique so person_id will be their staff_id for now.
      -- Likewise, for CHWLs, their person_id will be unique and diplayed as the public staff_ld
      case pl.job
      
          when 'CHA'  then trim( pl.position_id )
          when 'CHSS' then trim( pl.position_id )
          when 'CHWL' then trim( substring_index( trim( r.person_id ), '|', 1 ) )
          
          -- case where person is in the person table but they have not been assigned a position yet. 
          else trim( substring_index( trim( r.person_id ), '|', 1 ) )
          
      end as staff_id,
      
      trim( concat( r.first_name, ' ', r.last_name ) )  as full_name,
      r.birth_date,
      trim( r.gender )                                  as gender,
      trim( r.phone_number )                            as phone_number,
      trim( r.phone_number_alternate )                  as phone_number_alternate,
      
      pl.job,
      rl.position_id,
      rl.begin_date                         as position_person_begin_date,
      rl.end_date                           as position_person_end_date,
      if( rl.end_date is null, 'Y', 'N' )   as position_person_active, 
      
      pl.health_facility,
      pl.health_facility_id,
      pl.cohort,
      pl.health_district,
      pl.health_district_id,
      pl.county,
      pl.county_id,
      
      pf.job                                as job_first,
      rf.position_id                        as position_id_first,
      rf.begin_date                         as position_person_begin_date_first,
      rf.end_date                           as position_person_end_date_first,
      if( rf.end_date is null, 'Y', 'N' )   as position_person_active_first 
      
from person as r
    left outer join       view_history_position_person_last     as rl on r.person_id              like rl.person_id
        left outer join   view_history_position_geo             as pl on rl.position_id           like pl.position_id
    left outer join       view_history_position_person_first    as rf on r.person_id              like rf.person_id
        left outer join   view_history_position_geo             as pf on rf.position_id           like pf.position_id
;