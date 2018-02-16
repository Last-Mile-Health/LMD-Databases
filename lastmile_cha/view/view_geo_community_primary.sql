use lastmile_cha;

drop view if exists view_geo_community_primary;
 
create view view_geo_community_primary as 
select substring_index( community_id_list, ',', 1 ) as community_id_primary 
from view_base_cha 
group by community_id_primary;