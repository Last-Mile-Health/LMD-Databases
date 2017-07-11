use lastmile_cha;

drop procedure if exists snapshot_position_cha;

/*  Returns a resultset of all CHA positions, tthe person assigned to the positions, the communities being served, 
 *  and the the CHA catchment populations and households.
 *
 *  Parameters
 *              snapshot_date:    Point in time of snapshot.
                position_status:  
                                  'FILLED'  returns all postions that had a person assigned to them on snapshot_date.
                                  'OPEN'    returns all postions that did not have a person assigned to them on snapshot_date.
                                  Any string or value other than 'FILLED' or 'OPEN' returns all positions, regardless of whether they
                                  are open or filled.
 
*/

create procedure snapshot_position_cha( in snapshot_date date, in position_status varchar(255) )
begin

-- If position_status is anything other than 'FILLED' or 'OPEN' then set it to 'ALL'.
if ( position_status is null ) or not ( ( position_status like 'FILLED' ) or ( position_status like 'OPEN' ) ) then

  set position_status = 'ALL';
  
end if;

select 
      -- geography     
      p.county,
      p.health_district,
      p.cohort,
      p.health_facility_id,
      p.health_facility,
      
      -- position 
      p.job,
      -- For CHAs, the cha_id is the same value as the position_id.  Developers should choose one or the other depending on how
      -- they want to use the data.  Use the cha_id for reportting and the position_id for tying this resultset to other records
      -- internal to the the database.
      p.position_id,
      p.position_begin_date,
      p.position_end_date,
      
      -- person/CHA
      r.person_id,
      r.cha_id,
      r.full_name,
      r.birth_date,
      r.gender,
      r.phone_number,
      r.phone_number_alternate, 
      r.position_person_begin_date,
      r.position_person_end_date,
      r.reason_left,
      r.reason_left_description,
      
      pc.community_id_list,
      pc.community_list,
      pc.position_community_begin_date_list,
      pc.position_community_end_date_list,
      
      pc.community_count,         -- Number of communities in CHA's catchment.  This could be zero if the CHA does not have an entry in position_community table.
      pc.household_map_count,     -- Number of households in CHA's catchment from the community table mapping field. 
      pc.total_household,         -- Number of households in CHA's catchment from the registration table. 
      pc.total_household_member,  -- Number of household members in CHA's catchment from the registration table.
      pc.cha_count                -- Number CHAs assigned to a community
      
from view_history_position_geo as p
    left outer join ( select
                            pr.position_id,
                            pr.person_id,
                            pr.cha_id,
                            pr.full_name,
                            pr.birth_date,
                            pr.gender,
                            pr.phone_number,
                            pr.phone_number_alternate, 
     
                            pr.position_person_begin_date,
                            pr.position_person_end_date,
      
                            pr.reason_left,
                            pr.reason_left_description
                       
                      from view_history_position_person_cha as pr
                      where 
                            ( pr.position_person_begin_date <= snapshot_date ) 
                            and 
                            ( ( pr.position_person_end_date is null ) or ( pr.position_end_date > snapshot_date ) ) 
     
                    ) as r on p.position_id like r.position_id
 
 
    left outer join ( 
                      select
                              hpc.position_id,
                              group_concat( hpc.position_community_begin_date   )                                             as position_community_begin_date_list,
                              group_concat( hpc.position_community_end_date     )                                             as position_community_end_date_list,
                              group_concat( hpc.community_id  order by cast( hpc.community_id as unsigned ) separator ', ' )  as community_id_list,
                              group_concat( hpc.community     order by cast( hpc.community_id as unsigned ) separator ', ' )  as community_list,
                              sum( if(hpc.community_id is null, 0, 1 ) )                                                      as community_count,
                                                         
                              sum( hpc.household_map_count )  as household_map_count,                       
                              sum( g.total_household )        as total_household,
                              sum( g.total_household_member ) as total_household_member,
                              
                              cc.cha_count
                              
                      from view_history_position_community as hpc
                            left outer join (                            
                                              -- This code block is pulled directly from the view lastmile_program.view_registration.  The only difference is the
                                              -- "where g1.registration_date <= snapshot_date " clause at the bottom, which discards registration data 
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
  
                    ) as pc on p.position_id like pc.position_id
                    
-- Conditional clause for positions active during snapshot date.                    
where ( p.job like 'CHA' ) and ( ( p.position_begin_date <= snapshot_date ) and ( ( p.position_end_date is null ) or ( p.position_end_date > snapshot_date ) ) )

and case
        when  position_status like 'ALL'  then position_status        
        when  not r.person_id is    null  then 'FILLED'
        when      r.person_id is    null  then 'OPEN'
        else position_status -- This condition can never happen.
    end
    like position_status 
;

end
;