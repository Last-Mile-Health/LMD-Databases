use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_history_position;

create view lastmile_ncha.view_base_history_position as

select
      trim( j.title )                 as job,
      p.position_id_pk,
      p.begin_date,
      p.end_date,
      
      pid.position_id,
      pid.begin_date                  as position_id_begin_date,
      pid.end_date                    as position_id_end_date,
      
      trim( pid.health_facility_id )  as health_facility_id,
      trim( f.health_facility )       as health_facility,
      
      f.health_district_id,
      trim( h.health_district )       as health_district,
      pid.cohort,
      h.county_id,
      trim( c.county )                as county
        
from lastmile_ncha.`position`                               as p
    left outer join lastmile_ncha.job                       as j    on p.job_id = j.job_id
    left outer join lastmile_ncha.position_id               as pid  on p.position_id_pk = pid.position_id_pk
        left outer join lastmile_ncha.health_facility       as f    on trim( pid.health_facility_id ) like trim( f.health_facility_id )
            left outer join lastmile_ncha.health_district   as h    on f.health_district_id = h.health_district_id
                left outer join lastmile_ncha.county        as c    on h.county_id = c.county_id
;