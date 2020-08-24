use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_geo_community;

create view lastmile_ncha.view_base_geo_community as 

select

      county_id,
      county,
      
      health_district_id,
      health_district,
      
      district_id,
      district,
      
      community_health_facility_id,
      community_health_facility,
      
      community_id,
      community,
      community_alternate,
      health_facility_proximity,
      health_facility_km,
      x,
      y,
      
      motorbike_access,
      cell_reception,
      mining_community,
      lms_2015,
      lms_2016,
      archived,
      note,
      
      population,
      household_total,
      
      active_position,
      active_cha,
      
      if( active_position like 'N', 'None',
        if( active_cha like 'N', 'No CHA',
          if( person_count < position_count, 'Partial', 'Full' )
        )
      ) as service_level,
        
      position_id_pk_list,
      position_id_list,
      position_count,
      
      person_id_list,
      person_count,
      cha_list

from lastmile_ncha.view_geo_community_cha_population
;
