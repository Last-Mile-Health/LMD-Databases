use lastmile_cha;

drop view if exists view_history_position_person;

create view view_history_position_person as 

select

      p.job,
      p.position_id,
      p.position_active,
      p.position_begin_date,
      p.position_end_date,

      r.person_id,
      concat( trim( r.first_name ), ' ', trim( r.last_name ) )  as full_name,
      r.birth_date,
      trim( r.gender )                                          as gender,
      trim( r.phone_number )                                    as phone_number,
      trim( r.phone_number_alternate )                          as phone_number_alternate, 
         
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

from view_history_position_geo      as p
    left outer join position_person as pr on p.position_id      like trim( pr.position_id )
        left outer join person      as r  on pr.person_id       = r.person_id
        left outer join reason_left as l  on pr.reason_left_id  = l.reason_left_id 
;
