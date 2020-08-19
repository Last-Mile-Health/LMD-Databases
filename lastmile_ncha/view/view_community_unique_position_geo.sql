use lastmile_ncha;

drop view if exists lastmile_ncha.view_community_unique_position_geo;

create view lastmile_ncha.view_community_unique_position_geo as
select  

      community_id, 
      substring_index( group_concat( distinct community          order by community_id asc ), ',', 1 ) as community, 
      substring_index( group_concat( distinct health_facility_id order by community_id asc ), ',', 1 ) as health_facility_id, 
      substring_index( group_concat( distinct health_facility    order by community_id asc ), ',', 1 ) as health_facility, 
      substring_index( group_concat( distinct health_district    order by community_id asc ), ',', 1 ) as health_district,
      substring_index( group_concat( distinct county             order by community_id asc ), ',', 1 ) as county
      
from lastmile_ncha.view_community_geo_position_cha
group by community_id
