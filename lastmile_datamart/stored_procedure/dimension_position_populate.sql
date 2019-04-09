use lastmile_datamart;

drop procedure if exists dimension_position_populate;

create procedure dimension_position_populate( in  begin_date        date, 
                                              in  end_date          date,
                                              in  unit              varchar(10),
                                              in  position_status   varchar(10) )
                                                                                           
begin

/*
 *
 * Step 1. populate the dimension_date table
 *
*/
call lastmile_datamart.dimension_date_populate('2012-10-01', current_date() );


/*
 * Step 2.
 * These two views are queried repeatedly in the dimension_position_snapshot() stored procedure.  Since MySQL does
 * not support materialized view, we need to take snapshots of the views to speed up the performance of joining these
 * two views with dimension_position

 * Add the position_supervisor_id for CHA here because the CHSS-CHA position assignments are fixed.  There is no
 * date field to be checked.
 *
*/

drop table if exists lastmile_datamart.materialize_view_history_position_person_cha;
create table lastmile_datamart.materialize_view_history_position_person_cha as 
select 
      a.*
      -- s.position_supervisor_id
      
from lastmile_cha.view_history_position_person_cha as a
;

create index index_begin_end_date on 
lastmile_datamart.materialize_view_history_position_person_cha( position_person_begin_date, position_person_end_date );
 
drop table if exists lastmile_datamart.materialize_view_history_position_geo;
create table lastmile_datamart.materialize_view_history_position_geo as
select
      p.*,
      s.position_supervisor_id
from lastmile_cha.view_history_position_geo as p
    left outer join lastmile_cha.position_supervisor as s on p.position_id like trim( s.position_id ) and  p.job like 'CHA'
;

create index index_job_begin_end_date on 
lastmile_datamart.materialize_view_history_position_geo( job, position_begin_date, position_end_date );


/*
 * Debug the dimension_position_snapshot() stored procedure, which gets called repeatedly by the 
 * dimension_position_populate() stored procedure.  You need to go into the source code and 
 * comment out the select * from faux_cursor_* statement.  Maybe put in a parameter debug switch.
*/
-- call lastmile_datamart.dimension_position_snapshot( '2019-03-31', 'ALL' );


/* 
 * Step 3.
 *
 * Populate dimenension_position with CHA position data
 *
*/

call lastmile_datamart.dimension_position_populate_cha( begin_date, end_date, unit, position_status );



/*
 * Step 4.
 *
 * Populate dimension_position with CHSS position data. 
 *
*/

drop table if exists lastmile_datamart.materialize_view_history_position_person_chss;

create table lastmile_datamart.materialize_view_history_position_person_chss as 
select  
      ( year(   s.position_person_begin_date  ) * 10000 ) + 
      ( month(  s.position_person_begin_date  ) * 100   ) + 
        day(    s.position_person_begin_date  ) as position_person_begin_date_key,
      
      ( year(   s.position_person_end_date  ) * 10000 ) + 
      ( month(  s.position_person_end_date  ) * 100   ) + 
        day(    s.position_person_end_date  ) as position_person_end_date_key,
      s.*
      
from lastmile_cha.view_history_position_person_chss as s;

create index index_chss_begin_end_date on 
lastmile_datamart.materialize_view_history_position_person_chss( position_id, position_person_begin_date_key, position_person_end_date_key );

update lastmile_datamart.dimension_position d, lastmile_datamart.materialize_view_history_position_person_chss s
  
  set d.chss_person_id                  = s.person_id,
      d.chss_full_name                  = s.full_name,
      d.chss_position_person_begin_date = s.position_person_begin_date,
      d.chss_position_person_end_date   = s.position_person_end_date,
      
      d.chss_position_begin_date        = s.position_begin_date,
      d.chss_position_end_date          = s.position_end_date,
      d.chss_birth_date                 = s.birth_date ,
      d.chss_gender                     = s.gender ,
      d.chss_phone_number               = s.phone_number ,
      d.chss_phone_number_alternate     = s.phone_number_alternate ,
      d.chss_reason_left                = s.reason_left ,
      d.chss_reason_left_description    = s.reason_left_description 

where ( d.chss_position_id like s.position_id )           and 
      ( s.position_person_begin_date_key <= d.date_key )  and 
      ( ( s.position_person_end_date_key is null ) or ( s.position_person_end_date_key >= d.date_key ) )
;


/*
 * Step 5.
 *
 * Populate dimension_position with QAO position data. 
 *
*/

-- Create temp table of supervisor position with begin/end dates as date keys (integers)
drop table if exists lastmile_datamart.temp_position_supervisor;

create table lastmile_datamart.temp_position_supervisor as
select
      begin_date,
      end_date,
      
      ( year( begin_date  ) * 10000 ) + ( month( begin_date ) * 100 ) + day( begin_date ) as begin_date_key,
      ( year( end_date    ) * 10000 ) + ( month( end_date   ) * 100 ) + day( end_date   ) as end_date_key,
        
      trim( position_id )               as position_id,
      trim( position_supervisor_id )    as position_supervisor_id
       
from lastmile_cha.position_supervisor
;

create index index_position_supervisor_begin_end_date on 
lastmile_datamart.temp_position_supervisor( position_id, position_supervisor_id, begin_date_key, end_date_key );

update lastmile_datamart.dimension_position d, lastmile_datamart.temp_position_supervisor s
  
  set d.qao_position_id                     = s.position_supervisor_id,
      d.qao_position_supervisor_begin_date  = s.begin_date,
      d.qao_position_supervisor_end_date    = s.end_date

where ( d.chss_position_id like s.position_id ) and 
      ( s.begin_date_key <= d.date_key )        and 
      ( ( s.end_date_key is null ) or ( s.end_date_key >= d.date_key ) )   
;

drop table if exists lastmile_datamart.materialize_view_history_position_person_qao;

create table lastmile_datamart.materialize_view_history_position_person_qao as 
select  
        ( year( q.position_person_begin_date  ) * 10000 ) + ( month( q.position_person_begin_date ) * 100 ) + day( q.position_person_begin_date ) as position_person_begin_date_key,
        ( year( q.position_person_end_date    ) * 10000 ) + ( month( q.position_person_end_date   ) * 100 ) + day( q.position_person_end_date   ) as position_person_end_date_key,
        q.*
        
from lastmile_cha.view_history_position_person_qao as q;

create index index_qao_begin_end_date on 
lastmile_datamart.materialize_view_history_position_person_qao( position_id, position_person_begin_date_key, position_person_end_date_key );

update lastmile_datamart.dimension_position d, lastmile_datamart.materialize_view_history_position_person_qao s
  
  set d.qao_person_id                   = s.person_id,
      d.qao_full_name                   = s.full_name,
      d.qao_position_begin_date         = s.position_begin_date,
      d.qao_position_end_date           = s.position_end_date,
      d.qao_position_person_begin_date  = s.position_person_begin_date,
      d.qao_position_person_end_date    = s.position_person_end_date,
           
      d.qao_birth_date                  = s.birth_date,
      d.qao_gender                      = s.gender,
      d.qao_phone_number                = s.phone_number,
      d.qao_phone_number_alternate      = s.phone_number_alternate, 
      d.qao_reason_left                 = s.reason_left,
      d.qao_reason_left_description     = s.reason_left_description 
           
where ( d.qao_position_id like s.position_id )            and 
      ( s.position_person_begin_date_key <= d.date_key )  and 
      ( ( s.position_person_end_date_key is null ) or ( s.position_person_end_date_key >= d.date_key ) )
;

end;
/* End of stored procedure */
