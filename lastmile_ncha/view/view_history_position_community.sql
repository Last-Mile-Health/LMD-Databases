use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_community;

create view lastmile_ncha.view_history_position_community as 
select
      pc.position_id_pk                           as position_id_pk,
      pl.position_id_last                         as position_id,
      pc.community_id,
      pc.begin_date                               as position_community_begin_date,
      pc.end_date                                 as position_community_end_date,
      
      trim( c.community )                         as community,
      c.household_map_count,
      
      c.community_alternate,
      c.health_facility_id                        as community_health_facility_id,
      c.health_facility_proximity                 as community_health_facility_proximity,
      c.health_facility_km                        as community_health_facility_km,
      c.x,
      c.y,
      c.motorbike_access,
      c.cell_reception,
      c.mining_community,
      c.lms_2015,
      c.lms_2016,
      c.archived,
      c.note
      
from lastmile_ncha.position_community as pc
    left outer join lastmile_ncha.view_history_position_id_last as pl on pc.position_id_pk = pl.position_id_pk
    left outer join lastmile_ncha.community as c on pc.community_id =  c.community_id
;