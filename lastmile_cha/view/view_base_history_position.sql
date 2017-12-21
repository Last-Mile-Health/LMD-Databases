use lastmile_cha;

drop view if exists view_base_history_position;

create view view_base_history_position as

select
      j.title                   as job,
      p.position_id,
      p.position_id_lmh,
      p.begin_date,
      p.end_date,
      p.health_facility_id,
      f.health_facility,
      f.health_district_id,
      h.health_district,
      h.county_id,
      c.county
        
from `position`                               as p
    left outer join job                       as j  on p.job_id = j.job_id
    left outer join health_facility           as f  on trim( p.health_facility_id ) like trim( f.health_facility_id )
        left outer join health_district       as h  on f.health_district_id = h.health_district_id
            left outer join county            as c  on h.county_id = c.county_id
;