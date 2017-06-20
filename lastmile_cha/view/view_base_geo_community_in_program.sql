use lastmile_cha;

drop view if exists view_base_geo_community_in_program;

create view view_base_geo_community_in_program as 

select *
from view_base_geo_community
where not cha_id_list is null
;