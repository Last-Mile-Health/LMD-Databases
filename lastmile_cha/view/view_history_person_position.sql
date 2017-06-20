use lastmile_cha;

drop view if exists view_history_person_position;

create view view_history_person_position as 

select
      trim( r.person_id )                                       as person_id,
      
      -- CHA IDs will now be reused as CHAs come and go, so make position_id the public staff_id
      -- CHSS IDs will still be unique so person_id will be their staff_id for now.
      -- Likewise, for CHWLs, their person_id will be unique and diplayed as the public staff_ld
      case p.job
          when 'CHA'  then trim( pr.position_id )
          when 'CHSS' then trim( pr.person_id )
          when 'CHWL' then trim( substring_index( trim( pr.person_id ), '|', 1 ) )
         
          -- case where person is in the person table but they have not been assigned a position yet. 
          else trim( substring_index( trim( r.person_id ), '|', 1 ) )
    
      end as staff_id,
      
      concat( trim( r.first_name ), ' ', trim( r.last_name ) )  as full_name,
      r.birth_date,
      trim( r.gender )                                          as gender,
      trim( r.phone_number )                                    as phone_number,
      trim( r.phone_number_alternate )                          as phone_number_alternate, 
   
      p.job,
      trim( pr.position_id )                                    as position_id,
      p.position_active,
      p.position_begin_date,
      p.position_end_date,
      
      -- position person relationship active Y/N
      if( pr.end_date is null, 'Y', 'N' )                       as position_person_active,
      pr.begin_date                                             as position_person_begin_date,
      pr.end_date                                               as position_person_end_date,
      trim( l.reason_left )                                     as reason_left,
      trim( pr.reason_left_description )                        as reason_left_description,
      
      p.health_facility_id,
      p.health_facility,
      p.cohort,
      p.health_district_id,
      p.health_district,
      p.county_id,
      p.county

from person as r
    left outer join position_person                 as pr on trim( r.person_id )    like  trim( pr.person_id )
        left outer join reason_left                 as l  on pr.reason_left_id      =     l.reason_left_id
        left outer join view_history_position_geo   as p  on trim( pr.position_id ) like  p.position_id
;