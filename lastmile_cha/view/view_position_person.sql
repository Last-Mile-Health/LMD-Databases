use lastmile_cha;

drop view if exists view_position_person;

create view view_position_person as

select

      trim( pr.position_id )      as position_id,
      pr.begin_date               as position_person_begin_date,

      r.person_id,
      trim( r.person_id_lmh )     as person_id_lmh,
      
      r.first_name,
      r.last_name,
      r.other_name,
      r.birth_date,
      r.gender,
      r.phone_number,
      r.phone_number_alternate,
      
      trim( p.job_id )            as job_id,
      trim( j.title )             as title,
      p.health_facility_id
      
from position_person as pr
    left outer join person          as r on pr.person_id            = r.person_id
        left outer join `position`  as p on trim( pr.position_id )  like trim( p.position_id )
            left outer join job     as j on trim( p.job_id )        like j.job_id
where pr.end_date is null -- only return active position_person records
;