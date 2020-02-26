use lastmile_ncha;

drop view if exists lastmile_ncha.view_geo_community_primary;
 
create view lastmile_ncha.view_geo_community_primary as 
select substring_index( community_id_list, ',', 1 ) as community_id_primary 
from lastmile_ncha.view_base_cha
group by community_id_primary;

-- note: should we be using view_base_position_cha