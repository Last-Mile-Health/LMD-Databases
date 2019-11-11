use lastmile_develop;

drop view if exists lastmile_develop.view_qgis_community_household_position_rivercess;

create view lastmile_develop.view_qgis_community_household_position_rivercess as

select

      a.county,
      a.health_district,
      a.health_facility,
      a.health_facility_id,
      
      pc.community_id,
      c.community,
      c.community_alternate,
      c.x,
      c.y,
      c.health_facility_proximity,
      c.health_facility_km,
      c.household_map_count as map_household_community,
      n.number_cha,
      round( coalesce( c.household_map_count, 0 ) / n.number_cha, 0 ) as map_number_household_community_position,
      
      r.registration_year,
      r.total_household,
  
      c.motorbike_access,
      c.cell_reception,
      c.mining_community,
      c.note,
      c.archived,
      
      pc.position_id,
      a.cohort,
      
      a.cha,
      a.gender,
      a.birth_date,
      a.phone_number,
      
      a.chss_position_id,
      a.chss,
      a.chss_gender,
      a.chss_birth_date,
      a.chss_phone_number
      
from lastmile_cha.view_position_community as pc
    left outer join lastmile_cha.community as c on                            ( pc.community_id = c.community_id )
    left outer join lastmile_report.view_community_cha_count as n on          ( pc.community_id = n.community_id )
    left outer join lastmile_develop.view_qgis_registration_rivercess as r on ( ( pc.position_id like r.position_id ) and 
                                                                                ( pc.community_id = r.community_id ) )
    left outer join lastmile_cha.view_base_position_cha_basic_info as a on    ( pc.position_id = a.position_id )
where a.county like 'Rivercess'
order by pc.position_id asc;