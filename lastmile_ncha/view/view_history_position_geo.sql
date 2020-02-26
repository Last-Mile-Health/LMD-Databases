use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_geo;

create view lastmile_ncha.view_history_position_geo as 
select
      f.county_id,
      f.county,
      f.health_district_id,
      f.health_district,
      trim( pid.cohort )                    as cohort,
      pid.health_facility_id,
      f.health_facility,
      
      trim( j.title )                       as job,
      p.position_id_pk,
      trim( pid.position_id )               as position_id,
      if( p.end_date is null, 'Y', 'N' )    as position_active,  
      p.begin_date                          as position_begin_date,
      p.end_date                            as position_end_date,
      pid.begin_date                        as position_id_begin_date,
      pid.end_date                          as position_id_end_date,
      if( pid.end_date is null, 'Y', 'N' )  as position_id_active 
   
from lastmile_ncha.`position` as p
    left outer join lastmile_ncha.job                           as j    on trim( p.job_id ) like              trim( j.job_id )
    left outer join lastmile_ncha.position_id                   as pid  on p.position_id_pk =                 pid.position_id_pk
        left outer join lastmile_ncha.view_geo_health_facility  as f on trim( pid.health_facility_id ) like   f.health_facility_id
;   
    
    