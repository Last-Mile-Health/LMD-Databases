use lastmile_datamart;

drop procedure if exists lastmile_datamart.dimension_position_snapshot;

/*  Returns a resultset of all CHA positions at a point in time, the persons assigned to the positions, 
 *  and the geographical information associated with the positions, including the health facility
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
          
create procedure lastmile_datamart.dimension_position_snapshot( in snapshot_date    date, 
                                                                in position_status  varchar(10) )
begin

/* If position_status is anything other than 'FILLED' or 'OPEN' then set it to 'ALL'. */

if ( position_status is null ) or not ( ( position_status like 'FILLED' ) or ( position_status like 'OPEN' ) ) then

  set position_status = 'ALL';
  
end if;

/* 
 * MySQL 5.6 does not support calling a stored procedure and storing its resultset in a cursor.  Dynamically creating 
 * a temporary table and storing the resultset in it is an acceptable workaround.
*/

drop temporary table if exists lastmile_datamart.faux_cursor_dimension_position;

create temporary table lastmile_datamart.faux_cursor_dimension_position as

select 

      ( year( snapshot_date ) * 10000 ) + ( month( snapshot_date ) * 100 ) + day( snapshot_date ) as date_key,
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
      
      p.position_supervisor_id
     
from lastmile_datamart.materialize_view_history_position_geo as p
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
                        
                      from lastmile_datamart.materialize_view_history_position_person_cha as pr
                      where 
                            ( pr.position_person_begin_date <= snapshot_date ) 
                            and 
                            ( ( pr.position_person_end_date is null ) or ( pr.position_person_end_date >= snapshot_date ) ) 
     
                    ) as r on p.position_id like r.position_id
       
-- Conditional clause for positions active during snapshot date.                    
where ( p.job like 'CHA' ) and ( ( p.position_begin_date <= snapshot_date ) and ( ( p.position_end_date is null ) or ( p.position_end_date >= snapshot_date ) ) )

and case
        when  position_status like 'ALL'  then position_status        
        when  not r.person_id is    null  then 'FILLED'
        when      r.person_id is    null  then 'OPEN'
        else position_status -- This condition can never happen.
    end
    like position_status 
;
-- Use to debug this procedure.  Dump rows from temporary table.
-- select * from lastmile_datamart.faux_cursor_dimension_position;

end;
