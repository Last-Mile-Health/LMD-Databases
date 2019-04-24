use lastmile_cha;

drop view if exists view_community_geo_position_cha;

create view view_community_geo_position_cha as 

select
      pc.community_id,
      c.community,
      pc.position_id,
      
      a.health_facility_id,
      f.health_facility,
      f.health_district,
      f.county,
      
      s.position_supervisor_id                    as chss_position_id, 
      concat( ps.first_name, ' ', ps.last_name )  as chss,
      concat( a.first_name, ' ', a.last_name )    as cha
      
from lastmile_cha.view_position_community as pc
    left outer join lastmile_cha.community as c on pc.community_id = c.community_id
    
    left outer join lastmile_cha.view_position_person as a on ( pc.position_id like a.position_id ) and a.job_id like '1'
        left outer join lastmile_cha.view_geo_health_facility as f on a.health_facility_id = f.health_facility_id
    
    left outer join lastmile_cha.view_position_cha_supervisor as s on ( pc.position_id like s.position_id )
        left outer join lastmile_cha.view_position_person as ps on ( s.position_supervisor_id like ps.position_id ) and ps.job_id like '3'
;