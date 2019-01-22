use lastmile_report;

drop procedure if exists snapshot_position_cha;

/*  Returns a resultset of all CHA positions, the persons assigned to the positions, the communities being served, 
 *  and the the CHA catchment populations and households.
 *
 *  Parameters
 *
 * snapshot_date:    Point in time of snapshot.
 * position_status:  'FILLED' returns all postions that had a person assigned to them on snapshot_date.
 *                   'OPEN'   returns all postions that did not have a person assigned to them on snapshot_date.
 *                   'ALL'    returns all positions, regardless of whether they are open or filled.  Actually, 
 *                            any string or value other than 'FILLED' or 'OPEN' returns all positions.
 *
*/

create procedure snapshot_position_cha( in snapshot_date date, in position_status varchar(255) )
begin

-- If position_status is anything other than 'FILLED' or 'OPEN' then set it to 'ALL'.
if ( position_status is null ) or not ( ( position_status like 'FILLED' ) or ( position_status like 'OPEN' ) ) then

  set position_status = 'ALL';
  
end if;

-- Apparently, MySQL does not support calling a stored procedure and storing its resultset in a cursor.  
-- Dynamically creating a temporary table and storing the resultset in it maybe an acceptable workaround.

drop temporary table if exists faux_cursor_snapshot_position_cha;

create temporary table faux_cursor_snapshot_position_cha as

select 

      p.position_id,
      p.position_begin_date,
      p.position_end_date,
      
      -- geography     
      p.county,
      p.health_district,
      p.cohort,
      p.health_facility_id,
      p.health_facility,
        
      -- person/CHA
      r.person_id,
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
      
      cha_catchment_population( pc.total_household_member, pc.total_household, pc.position_community_count, pc.household_map_count, pc.position_count ) as population,
      cha_catchment_household(  pc.total_household, pc.position_community_count, pc.household_map_count, pc.position_count )                            as household,
      
      pc.total_household_member,  -- Number of household members in CHA's catchment from the registration table.
      pc.total_household,         -- Number of households in CHA's catchment from the registration table. 
      
      pc.position_community_count,         -- Number of communities in CHA's catchment.  This could be zero if the CHA does not have an entry in position_community table.
      pc.household_map_count,     -- Number of households in CHA's catchment from the community table mapping field. 

      pc.position_count,          -- Number CHAs assigned to a community
      
      /*  If you want to the calculate the total number of communities in some some geographical region or cohort by the number
          of commmunities that are assigned to a positon, you have to factor in the cases where there are more than 1 positions
          assigned to a community; otherwise, you will be "double counting" communities. 
      
      */    
      if( pc.position_count > 0, pc.position_community_count/pc.position_count , 0 ) as  position_community_count_proportional 
        
from lastmile_cha.view_history_position_geo as p
    left outer join ( select
                            pr.position_id,
                            pr.person_id,
                            pr.full_name,
                            pr.birth_date,
                            pr.gender,
                            pr.phone_number,
                            pr.phone_number_alternate, 
     
                            pr.position_person_begin_date,
                            pr.position_person_end_date,
      
                            pr.reason_left,
                            pr.reason_left_description
                       
                      from lastmile_cha.view_history_position_person_cha as pr
                      where 
                            ( pr.position_person_begin_date <= snapshot_date ) 
                            and 
                            ( ( pr.position_person_end_date is null ) or ( pr.position_person_end_date > snapshot_date ) ) 
     
                    ) as r on p.position_id like r.position_id
 
 
    left outer join ( 
                      select
                              hpc.position_id,
                              group_concat( hpc.position_community_begin_date order by cast( hpc.community_id as unsigned ) separator ', ' ) as position_community_begin_date_list,
                              group_concat( hpc.position_community_end_date   order by cast( hpc.community_id as unsigned ) separator ', ' ) as position_community_end_date_list,
                              group_concat( hpc.community_id                  order by cast( hpc.community_id as unsigned ) separator ', ' ) as community_id_list,
                              group_concat( hpc.community                     order by cast( hpc.community_id as unsigned ) separator ', ' ) as community_list,
                              sum( if(hpc.community_id is null, 0, 1 ) )  as position_community_count,
                                                         
                              sum( hpc.household_map_count )              as household_map_count,                       
                              sum( g.total_household )                    as total_household,
                              sum( g.total_household_member )             as total_household_member,
                              
                              cc.position_count
                              
                      from lastmile_cha.view_history_position_community as hpc
                            left outer join (                            
                                              -- This code block is pulled directly from the view lastmile_program.view_registration.  The only difference is the
                                              -- "where m.registration_date <= snapshot_date " clause at the bottom, which discards registration data 
                                              -- if it comes after the snapshot_date.

                                              -- The view lastmile_program.view_registration "bubbles" registration records from previous years to the "top".  
                                              -- It is the record of the latest registration data for a
                                              -- position_id and community_id pair.  Querying and conditioning on it directly would cause some records to be discarded
                                              -- because their registration dates came after the snapshot_date, even though there were older records that would have
                                              -- matched because they were registered before the snapshot date.
                                              -- Therefore, we need to duplicate the lastmile_program.view_registration code here and condition on the snapshot date.
                            
                                              select
                                                    m.community_id, 
                                                    m.position_id, 
                                                    m.registration_year,
      
                                                    y.registration_date,
      
                                                    y.total_household,
                                                    y.total_household_member,
      
                                                    y.total_zero_eleven_month_male,
                                                    y.total_zero_eleven_month_female,
  
                                                    y.total_one_five_year_male,
                                                    y.total_one_five_year_female,
  
                                                    y.total_six_fourteen_year_male,
                                                    y.total_six_fourteen_year_female,
  
                                                    y.total_fifteen_forty_nine_year_male,
                                                    y.total_fifteen_forty_nine_year_female,
  
                                                    y.total_fifty_plus_year_male,
                                                    y.total_fifty_plus_year_female
      
                                              from lastmile_program.view_registration_year_max as m
                                                  left outer join lastmile_program.view_registration_year as y on m.community_id       like  y.community_id        and 
                                                                                                                  m.position_id        like  y.position_id         and
                                                                                                                  m.registration_year  =     y.registration_year
                                              where m.registration_date <= snapshot_date
                                               
                                            ) as g on ( hpc.position_id like g.position_id ) and ( hpc.community_id like g.community_id )
                      
                            left outer join (                                           
                                              select 
                                        
                                                    hpcc.community_id, 
                                                    count( * ) as position_count
                                              
                                              from lastmile_cha.view_history_position_community as hpcc
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

-- Use to debug this procedure.  Dump rows of temporary table.
-- select * from faux_cursor_snapshot_position_cha;

end
;