use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_person_position_id_pk_position_id_last;

create view lastmile_ncha.view_history_person_position_id_pk_position_id_last  as
select
      -- The last position_id_pk for a person
      pr.person_id,
      pr.position_id_pk,
      pr.begin_date       as position_person_begin_date,
      pr.end_date         as position_person_end_date,
         
      -- The last position_id for the last position_id_pk for a person
      substring_index( group_concat( distinct trim( pid.position_id ) order by pid.begin_date desc separator ',' ), ',', 1 ) as position_id,
      
      max( pid.begin_date )  as position_id_begin_date,
      
      if( 
          substring_index( group_concat( coalesce( pid.end_date, 'null' ) order by pid.begin_date desc separator ',' ), ',', 1 ) like 'null', 
          null,  
          substring_index( group_concat( pid.end_date order by pid.begin_date desc separator ',' ), ',', 1 )
      )
      as position_id_end_date
           
from lastmile_ncha.view_history_person_position_id_pk_last as pr
    left outer join lastmile_ncha.position_id as pid on ( pr.position_id_pk = pid.position_id_pk ) and 
    
                                                           
                                                        ( 
                                                          -- case 1. both end dates are null
                                                          ( ( pr.end_date is null ) and ( pid.end_date is null ) ) 
                                                          or
                                                          
                                                          -- case 2. position_id_end_date is null and position_person_end_date has a value
                                                          ( not ( pr.end_date is null ) and ( pid.end_date is null ) and ( pid.begin_date <= pr.end_date ) ) 
                                                          or
                                                          
                                                          -- case 3. position_person_end_date is null and position_id_end_date has a value                         
                                                          ( not ( pid.end_date is null ) and ( pr.end_date is null ) and ( pr.begin_date <= pid.end_date ) )
                                                          or
                                                          
                                                          -- case 4-7. Four cases where both the position_person and position_id end_dates have values.
                                                          -- see description of four cases below.
                                                          (
                          
                                                            ( not ( pr.end_date is null ) and not ( pid.end_date is null ) ) and 
                                                            ( 
                                                              -- case 4.
                                                              ( pr.begin_date >= pid.begin_date and pr.end_date <= pid.end_date ) or
                                                              
                                                              -- case 5.
                                                              ( pr.begin_date <= pid.begin_date and pid.end_date <- pr.end_date ) or
                                                              
                                                              -- case 6.
                                                              ( pr.begin_date <= pid.begin_date and pid.begin_date <= pr.end_date and pr.end_date <= pid.end_date ) or
                                                              
                                                              -- case 7.
                                                              ( pid.begin_date <= pr.begin_date and pr.begin_date <= pid.end_date and pr.end_date >= pid.end_date )
                                                                                                                          
                                                            )                                                                                                                  
                                                          )                                                          
                                                        )
                                                         
group by pr.person_id, pr.position_id_pk, pr.begin_date, pr.end_date
;


