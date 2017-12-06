use lastmile_cha;

drop view if exists view_geo_community_cha_population;

create view view_geo_community_cha_population as 

select

      c.county_id,
      c.county,
      
      c.health_district_id,
      c.health_district,
      
      c.district_id,
      c.district,
      
      c.community_health_facility_id,
      c.community_health_facility,
      
      c.community_id,
      c.community,
      c.community_alternate,
      c.health_facility_proximity,
      c.health_facility_km,
      c.x,
      c.y,
      
      c.motorbike_access,
      c.cell_reception,
      c.mining_community,
      c.lms_2015,
      c.lms_2016,
      c.archived,
      c.note,
      
      -- If a household registration has never been completed for a community estimate population from the household
      -- mapping value in community table, six persons per household.
      if( g.total_household_member is null, c.household_map_count * 6, g.total_household_member ) as population,
      if( g.total_household is null, c.household_map_count, g.total_household )                   as household_total,
      
      c.household_map_count,
      g.total_household             as registration_total_household,
      g.total_household_member      as registration_total_household_member,
      g.cha_id_list                 as registration_cha_id_list,
      g.registration_year_list,
      
      a.position_id_list,
      a.position_count,
      if( a.position_id_list is null, 'N', 'Y' )              as active_position,
      
      a.person_id_list,
      a.person_count,
      if( a.person_id_list is null, 'N', 'Y' )                as active_cha
      
from view_geo_community as c
    left outer join view_community_registration as g on c.community_id = g.community_id
    left outer join view_community_cha          as a on c.community_id = a.community_id
;