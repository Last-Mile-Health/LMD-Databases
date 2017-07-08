use lastmile_cha;

drop procedure if exists snapshot_cha;

create procedure snapshot_cha( in snapshot_date date )
begin

select
      pr.person_id,
      pr.cha_id,
      
      pr.full_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate, 
 
      pr.position_id,
      pr.position_active,
      pr.position_begin_date,
      position_end_date,
      
      pr.position_person_active,
      pr.position_person_begin_date,
      pr.position_person_end_date,
      
      pr.reason_left,
      pr.reason_left_description,
      
      pr.health_facility_id,
      pr.health_facility,
      
      pr.cohort,
      pr.health_district_id,
      pr.health_district,
      pr.county_id,
      pr.county,
      
      pc.position_community_begin_date_list,
      pc.position_community_end_date_list,
      pc.community_id_list,
      pc.community_list,
      pc.household_map_count
         
from view_history_person_position_cha as pr
    left outer join ( select
                              position_id,
                              group_concat( position_community_begin_date   )                                        as position_community_begin_date_list,
                              group_concat( position_community_end_date     )                                        as position_community_end_date_list,
                              group_concat( community_id  order by cast( community_id as unsigned ) separator ', ' ) as community_id_list,
                              group_concat( community     order by cast( community_id as unsigned ) separator ', ' ) as community_list,
                              sum( household_map_count ) as household_map_count
                              
                      from view_history_position_community
                      where ( position_community_begin_date  <= snapshot_date ) and ( ( position_community_end_date  is null ) or ( position_community_end_date > snapshot_date ) )
                      group by position_id                    
                    ) as pc on pr.position_id like pc.position_id

where ( pr.position_begin_date        <= snapshot_date and ( ( pr.position_end_date        is null ) or ( pr.position_end_date         > snapshot_date ) ) ) and
      ( pr.position_person_begin_date <= snapshot_date and ( ( pr.position_person_end_date is null ) or ( pr.position_person_end_date  > snapshot_date ) ) )
;

end
;