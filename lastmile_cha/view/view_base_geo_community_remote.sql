use lastmile_cha;

drop view if exists view_base_geo_community_remote;

create view view_base_geo_community_remote as 

select *
from view_base_geo_community
where health_facility_proximity like 'remote'
;