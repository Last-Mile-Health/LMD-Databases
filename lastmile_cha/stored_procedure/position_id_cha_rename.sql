use lastmile_cha;

/*
    Author: Owen Eddin
    This procedrue renames a CHA position_id to a new position_id in the lastmile_cha schema.
    
    All parameters should be strings, even the end_date.  
    
    If any of the position id(s) is an integer, treat it like a string and wrap it in in single quotes.
    
    Only assign an end_date parameter value if the position is being obsoleted; otherwise, put a null for end_date so the
    end_dates for all tables will not be set.

    Note: The p_old_position_id_chss is not implemented.  There are currently no cases where there is more than one 
          CHSS position ID for a CHA position ID.  Need to think this through some more.
*/

drop procedure if exists position_id_cha_rename;

delimiter $$

create procedure position_id_cha_rename(  in p_health_facility_id   varchar( 255 ), 
                                          in p_old_position_id_cha  varchar( 255 ), 
                                          in p_new_position_id_cha  varchar( 255 ),
                                          in p_end_date_cha         varchar( 255 ),
                                          in p_old_position_id_chss varchar( 255 ),
                                          in p_new_position_id_chss varchar( 255 ) )
                                       -- set end_date to null if the position is not being obsoleted
begin

    set @p_health_facility_id   = p_health_facility_id;
    set @p_old_position_id_cha  = p_old_position_id_cha;
    set @p_new_position_id_cha  = p_new_position_id_cha;
    set @p_end_date_cha         = p_end_date_cha;
    
    set @p_old_position_id_chss = p_old_position_id_chss;
    set @p_new_position_id_chss = p_new_position_id_chss;
     
    insert into `position` ( position_id, position_id_lmh, health_facility_id, job_id, begin_date, end_date )
    select
          trim( @p_new_position_id_cha ),   
          trim( position_id_lmh ), 
          @p_health_facility_id, 
          job_id,  
          begin_date, 
          if( end_date is null, if( @p_end_date_cha is null, end_date, trim( @p_end_date_cha ) ), end_date ) as end_date
    from `position` 
    where trim( position_id ) like trim( @p_old_position_id_cha )
    ;

    insert into position_person ( position_id, person_id, begin_date, end_date )
    select                            
          trim( @p_new_position_id_cha ), 
          person_id, 
          begin_date, 
          if( end_date is null, if( @p_end_date_cha is null, end_date, trim( @p_end_date_cha ) ), end_date ) as end_date
    from position_person where trim( position_id ) like trim( @p_old_position_id_cha )
    ;

    insert into position_supervisor ( position_id, position_supervisor_id, begin_date, end_date )
    select                            
          trim( @p_new_position_id_cha ), 
          trim( @p_new_position_id_chss ),  
          begin_date, 
          if( end_date is null, if( @p_end_date_cha is null, end_date, trim( @p_end_date_cha ) ), end_date ) as end_date
    from position_supervisor 
    where trim( position_id ) like trim( @p_old_position_id_cha )                            
    ;

    insert into position_community ( position_id, community_id, begin_date, end_date )
    select                            
          trim( @p_new_position_id_cha ), 
          community_id, 
          begin_date, 
          if( end_date is null, if( @p_end_date_cha is null, end_date, trim( @p_end_date_cha ) ), end_date ) as end_date
    from position_community where trim( position_id ) like trim( @p_old_position_id_cha )
    ;

    -- Now, delete the old postion_id
    delete from position_community  where trim( position_id ) like trim( @p_old_position_id_cha );
    delete from position_supervisor where trim( position_id ) like trim( @p_old_position_id_cha );
    delete from position_person     where trim( position_id ) like trim( @p_old_position_id_cha );
    delete from `position`          where trim( position_id ) like trim( @p_old_position_id_cha );


end$$

delimiter;