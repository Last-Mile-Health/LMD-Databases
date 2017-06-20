use lastmile_cha;

drop view if exists view_history_position_geo;

create view view_history_position_geo as 

select
      f.county_id,
      trim( f.county )                    as county,
      f.health_district_id,
      trim( f.health_district )           as health_district,
      f.cohort,
      p.health_facility_id,
      f.health_facility,
      
      trim( j.title )                     as job,
      trim( p.position_id )               as position_id,
      if( p.end_date is null, 'Y', 'N' )  as position_active,  
      p.begin_date                        as position_begin_date,
      p.end_date                          as position_end_date
   
from `position` as p
    left outer join view_geo_health_facility  as f on trim( p.health_facility_id ) like  f.health_facility_id
    left outer join job                       as j on trim( p.job_id )             like  trim( j.job_id )
;