use lastmile_cha;

-- Description: View shows all the community data, the health facilities associated with communities, 
-- and all the geographic data, such as districts, health districts and counties.

-- The county, health district, district, and community tables' foreign key relationship are  mandatory, so a 
-- inner join is used.

-- The community and health facility table foreign key relationship is not mandatory, so a left outer join is used.

drop view if exists view_geo_community;

create view view_geo_community as

select
      k.county_id,
      trim( k.county )                        as county,
      
      h.health_district_id,
      trim( h.health_district )               as health_district,
      
      d.district_id,
      trim( d.district )                      as district,
      
      trim( c.health_facility_id )            as community_health_facility_id,
      trim( f.health_facility )               as community_health_facility,
      
      trim( c.community_id )                  as community_id,
      trim( c.community )                     as community,
      
      trim( c.community_alternate )           as community_alternate,
      trim( c.health_facility_proximity )     as health_facility_proximity,
      c.health_facility_km,
      c.x,
      c.y,
      trim( c.household_map_count )           as household_map_count,
      c.motorbike_access ,
      trim( c.cell_reception )                as cell_reception,
      trim( c.mining_community )              as mining_community,
      trim( c.lms_2015 )                      as lms_2015,
      trim( c.lms_2016 )                      as lms_2016,
      c.archived,
      trim( c.note )                          as note
      
from county as k
    inner join health_district as h on k.county_id = h.county_id
        inner join district as d on h.health_district_id = d.health_district_id
            inner join community as c on d.district_id = c.district_id
                left outer join health_facility as f on trim( c.health_facility_id ) like trim( f.health_facility_id )
;