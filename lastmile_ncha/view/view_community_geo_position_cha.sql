use lastmile_ncha;

drop view if exists lastmile_ncha.view_community_geo_position_cha;

create view lastmile_ncha.view_community_geo_position_cha as 
select
      pc.community_id,
      c.community,
      pc.position_id_pk,
      pc.position_id,
      
      pc.health_facility_id,
      f.health_facility,
      f.health_district,
      f.county,
      
      s.position_supervisor_id_pk                 as chss_position_id_pk,
      s.position_supervisor_id                    as chss_position_id, 
      concat( ps.first_name, ' ', ps.last_name )  as chss,
      concat( a.first_name, ' ', a.last_name )    as cha
      
from lastmile_ncha.view_position_community as pc
    left outer join lastmile_ncha.community                   as c  on pc.community_id = c.community_id
    left outer join lastmile_ncha.view_geo_health_facility    as f  on pc.health_facility_id like f.health_facility_id
    left outer join lastmile_ncha.view_position_person        as a  on pc.position_id_pk = a.position_id_pk
   left outer join lastmile_ncha.view_position_cha_supervisor as s  on pc.position_id_pk = s.position_id_pk 
        left outer join lastmile_ncha.view_position_person    as ps on s.position_supervisor_id_pk = ps.position_id_pk
;