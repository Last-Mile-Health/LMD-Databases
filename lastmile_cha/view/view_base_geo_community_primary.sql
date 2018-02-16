use lastmile_cha;

drop view if exists view_base_geo_community_primary;

create view view_base_geo_community_primary as 
select 
      a.county_id,
      a.county,
      a.health_district_id,
      a.health_district,
      a.district_id,
      a.district,
      a.community_health_facility_id,
      a.community_health_facility,
      a.community_id,
      a.community,
      a.community_alternate,
      a.health_facility_proximity,
      a.health_facility_km,
      a.x,
      a.y AS y,
      a.motorbike_access,
      a.cell_reception,
      a.mining_community,
      a.lms_2015,
      a.lms_2016,
      a.archived,
      a.note,
      a.population,
      a.household_total,
      a.active_position,
      a.active_cha,
      a.service_level,
      a.position_id_list,
      a.position_count
      
 from lastmile_cha.view_base_geo_community a 
    join lastmile_cha.view_geo_community_primary b on a.community_id = b.community_id_primary
 where a.archived <> 1
 ;
 