use lastmile_cha;

drop procedure if exists snapshot_cha;

create procedure snapshot_cha( in snapshot_date date )
begin

select 
      -- For CHA, the cha_id is the same value as the position_id.  Developers should choose one or the other depending on how
      -- they want to use the data.  Use the cha_id for reportting and the position_id for tying resultset to other records
      -- internal to the the database.
      pr.position_id,
      pr.position_active,
      pr.position_begin_date,
      position_end_date,
      
      pr.position_person_active,
      pr.position_person_begin_date,
      pr.position_person_end_date,
      
      pr.person_id,
      pr.cha_id,
      
      pr.full_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate, 
      
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
      
      -- Note: More work needs to be done here.  When there is a one-to-one relationship between a CHA and a community, then
      -- we can estimate the community population by multiplying the household_map_count by 6.  However, when there is a 
      -- many-to-one relationships between more than one CHA and a community, say New Creek (62) with 6 CHAs, we can't do that. 
      pc.household_map_count,
      
      pc.total_household,
      pc.total_household_member,
      
      pc.cha_count
         
from view_history_position_person_cha as pr
    left outer join ( 
                      select
                              hpc.position_id,
                              group_concat( hpc.position_community_begin_date   )                                             as position_community_begin_date_list,
                              group_concat( hpc.position_community_end_date     )                                             as position_community_end_date_list,
                              group_concat( hpc.community_id  order by cast( hpc.community_id as unsigned ) separator ', ' )  as community_id_list,
                              group_concat( hpc.community     order by cast( hpc.community_id as unsigned ) separator ', ' )  as community_list,
                              
                              sum( hpc.household_map_count )  as household_map_count,                       
                              sum( g.total_household )        as total_household,
                              sum( g.total_household_member ) as total_household_member,
                              
                              cc.cha_count
                              
                      from view_history_position_community as hpc
                            left outer join (                            
                                              -- This code block is pulled directly from the view lastmile_program.view_registration.  The only difference is the
                                              -- "where g1.registration_date <= @snapshot_date " clause at the bottom, which discards registration data 
                                              -- from the self-join of lastmile_program.view_registration_year if it comes after the snapshot_date.

                                              -- The view lastmile_program.view_registration "bubbles" registration records from previous years to the "top" of 
                                              -- the self-join of lastmile_program.view_registration_year.  It is record of the latest registration data for a
                                              -- cha_id and community_id pair.  Querying and conditioning on it directly would cause some records to be discarded
                                              -- because their registration date came after the snapshot_date, even though there we older records that would have
                                              -- matched because they were registered before the snapshot date.
                                              -- Therefore, we need to duplicate the lastmile_program.view_registration code here and condition on the snapshot date.
                            
                                              select
                                                    g1.community_id, 
                                                    g1.cha_id, 
                                                    g1.registration_year,
      
                                                    g1.registration_date,
      
                                                    g1.total_household,
                                                    g1.total_household_member,
      
                                                    g1.total_zero_eleven_month_male,
                                                    g1.total_zero_eleven_month_female,
  
                                                    g1.total_one_five_year_male,
                                                    g1.total_one_five_year_female,
  
                                                    g1.total_six_fourteen_year_male,
                                                    g1.total_six_fourteen_year_female,
  
                                                    g1.total_fifteen_forty_nine_year_male,
                                                    g1.total_fifteen_forty_nine_year_female,
  
                                                    g1.total_fifty_plus_year_male,
                                                    g1.total_fifty_plus_year_female
      
                                              from lastmile_program.view_registration_year as g1
                                                    left outer join lastmile_program.view_registration_year as g2 on  ( trim( g1.community_id ) like trim( g2.community_id  )  ) and 
                                                                                                                      ( trim( g1.cha_id )       like trim( g2.cha_id        )  ) and
                                                                                                                      ( g1.registration_year    > g2.registration_year      )
                                              where g1.registration_date <= snapshot_date 
                                              group by trim( g1.community_id ), trim( g1.cha_id )
                                              having count( * ) >= 1
                                               
                                            ) as g on ( hpc.position_id like g.cha_id ) and ( hpc.community_id like g.community_id )
                      
                            left outer join (
                                              select 
                                        
                                                    hpcc.community_id, 
                                                    count( * ) as cha_count
                                              
                                              from view_history_position_community as hpcc
                                              where ( hpcc.position_community_begin_date  <= snapshot_date ) and ( ( hpcc.position_community_end_date  is  null ) or ( hpcc.position_community_end_date  > snapshot_date ) )
                                              group by hpcc.community_id
    
                                             ) as cc on hpc.community_id = cc.community_id
                      
                      where ( hpc.position_community_begin_date  <= snapshot_date ) and ( ( hpc.position_community_end_date  is null ) or ( hpc.position_community_end_date > snapshot_date ) )
                      group by hpc.position_id   
  
                    ) as pc on pr.position_id like pc.position_id
                    
where 
      ( ( pr.position_begin_date <= snapshot_date ) and ( ( pr.position_end_date is null ) or ( pr.position_end_date > snapshot_date ) ) ) 
      and 
      ( ( pr.position_person_begin_date is null )  or  ( ( pr.position_person_begin_date <= snapshot_date ) and ( ( pr.position_person_end_date is null ) or ( pr.position_person_end_date  > snapshot_date ) ) ) )
;

end
;