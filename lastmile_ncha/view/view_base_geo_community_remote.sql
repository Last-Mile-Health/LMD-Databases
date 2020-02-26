use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_geo_community_remote;

create view lastmile_ncha.view_base_geo_community_remote as 
select *
from lastmile_ncha.view_base_geo_community
where health_facility_proximity like 'remote'
;