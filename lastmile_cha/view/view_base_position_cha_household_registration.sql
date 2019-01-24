use lastmile_cha;

drop view if exists view_base_position_cha_household_registration;
create view view_base_position_cha_household_registration as

select
      f.county,
      f.health_district,
      
      f.health_facility_id,
      f.health_facility,
      
      cp.position_id                                        as chss_position_id,
      concat( cp.first_name, ' ', cp.last_name )            as chss,
      pp.phone_number                                       as chss_phone_number,
      
      pc.position_id,
      concat( pp.first_name, ' ', pp.last_name )            as cha,
      pp.phone_number,
      
      pp.cohort,
      
      pc.community_id,
      c.community,
      
      r.registration_date                                   as hhr_registration_date,
      r.total_household                                     as hhr_household_count,
      r.total_household_member                              as hhr_member_count,
      
      round( c.household_map_count / a.person_count, 0 )    as map_household_count_per_cha,
      a.person_count                                        as number_cha_assigned_community,
      c.household_map_count                                 as map_household_count,
      c.health_facility_km                                  as map_distance_kem_facility,
      c.health_facility_proximity                           as map_proximity_facility,
      c.X                                                   as map_X,
      c.Y                                                   as map_Y
      
from lastmile_cha.view_position_cha_id_community_id             as  pc

    left outer join lastmile_cha.community                      as  c   on  pc.community_id           =     c.community_id
    
    left outer join lastmile_program.view_registration          as  r   on  pc.position_id            like  r.position_id   and
                                                                            pc.community_id           =     r.community_id
                                                                    
    left outer join lastmile_cha.view_community_cha             as  a   on  pc.community_id           =     a.community_id
    
    left outer join lastmile_cha.view_position_cha_person       as  pp  on  pc.position_id            like  pp.position_id
        left outer join lastmile_cha.view_geo_health_facility   as  f   on  pp.health_facility        like  f.health_facility
    
    left outer join lastmile_cha.view_position_cha_supervisor   as  s   on  pc.position_id            like  s.position_id
        left outer join lastmile_cha.view_position_chss_person  as  cp  on  s.position_supervisor_id  like  cp.position_id

order by f.county, f.health_district, f.health_facility, cp.position_id, pc.position_id, pc.community_id
;

