use lastmile_report;

drop view if exists lastmile_report.view_community_household;

create view lastmile_report.view_community_household as 
select

      -- community_grand_bassa_master.master_list_id: (1172) 
      cast( if( c.community_id >= 3000, substring_index( substring_index( c.note, ')', 1 ), '(', -1 ) , null ) as unsigned ) as master_list_id,
    
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
      round( ( coalesce( c.household_map_count, 0 ) / n.number_cha ), 0 ) as map_number_household_community_position,
      r.registration_year,
      r.total_household,
      
      c.motorbike_access,
      c.cell_reception,
      c.mining_community,
      c.note,
      c.archived,
    
      pc.position_id,
    
      a.cohort,
      concat( a.first_name, ' ', a.last_name ) as cha,
      a.gender,
      a.birth_date,
      a.phone_number,
      a.chss_position_id,
      concat( a.chss_first_name, ' ', a.chss_last_name ) as chss,
      a.chss_gender,
      a.chss_birth_date,
      a.chss_phone_number
        
from lastmile_ncha.view_position_community as pc
    left outer join lastmile_ncha.community as c on pc.community_id = c.community_id
    left outer join lastmile_report.view_community_cha_count as n on pc.community_id = n.community_id
    left outer join lastmile_program.view_registration as r on pc.position_id like r.position_id and pc.community_id = r.community_id
    left outer join lastmile_ncha.view_base_position_cha_basic_info as a on pc.position_id = a.position_id
order by pc.position_id

