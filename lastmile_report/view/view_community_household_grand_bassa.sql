use lastmile_report;

drop view if exists lastmile_report.view_community_household_grand_bassa;

create view lastmile_report.view_community_household_grand_bassa as 

select

      m.master_list_id,
      'Grand Bassa' as county,
      m.health_district,
      m.health_facility,
      m.health_facility_id,
      m.community_id,
      m.community,
      m.community_alternate,
      m.x,
      m.y,
      m.health_facility_proximity,
      m.health_facility_km,
      m.household_map_count as map_household_community,
 	
      c.number_cha, 
      c.map_number_household_community_position,
      c.registration_year,	
      c.total_household,
      
      m.motorbike_access,
      m.cell_reception,
      m.mining_community,
      m.note,
      m.archived,
      m.position_id,
      
      c.cohort,
      c.cha,
      c.gender,
      c.birth_date,
      c.phone_number,
      c.chss_position_id,
      c.chss,
      c.chss_gender,
      c.chss_birth_date,
      c.chss_phone_number

from lastmile_temp.view_community_grand_bassa_master as m
    left outer join lastmile_report.view_community_household_grand_bassa_temp as c on m.community_id = c.community_id
where not ( m.position_id is null )
;
