use lastmile_cha;

drop view if exists view_community_geo_position_cha;

create view view_community_geo_position_cha as 

select
      pc.community_id,
      c.community,
      
      pc.position_id,
      
      a.health_facility_id,
      a.health_facility,
      a.health_district,
      a.county,
    
      a.chss_position_id,
      a.chss,
      a.cha
      
     
from lastmile_cha.view_position_community as pc
    left outer join lastmile_cha.community as c on pc.community_id = c.community_id
    left outer join lastmile_cha.view_base_position_cha as a on pc.position_id = a.position_id
;