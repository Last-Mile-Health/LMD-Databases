use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_geo_community_in_program;

create view lastmile_ncha.view_base_geo_community_in_program as 

select *
from lastmile_ncha.view_base_geo_community
where active_position like 'Y'
;