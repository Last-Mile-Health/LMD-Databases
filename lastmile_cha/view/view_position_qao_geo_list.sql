use lastmile_cha;

drop view if exists view_position_qao_geo_list;

create view view_position_qao_geo_list as 
select
      pcs.position_supervisor_id as position_id,
      group_concat( distinct pcs.health_facility_id order by ghf.health_facility  asc separator ', ' ) as health_facility_id_list ,
      group_concat( distinct ghf.health_facility    order by ghf.health_facility  asc separator ', ' ) as health_facility_list,
      group_concat( distinct ghf.health_district    order by ghf.health_district  asc separator ', ' ) as health_district_list,
      group_concat( distinct ghf.county             order by ghf.county           asc separator ', ' ) as county_list,
      
        
from view_position_chss_supervisor as pcs
    left outer join view_geo_health_facility as ghf on pcs.health_facility_id = ghf.health_facility_id
where not ( pcs.position_supervisor_id is null )
group by pcs.position_supervisor_id
;