use lastmile_cha;

drop procedure if exists position_id_cha_new;

delimiter $$

/* Must have a valid person_id and CHSS position_id for procedure to work.
   community_id(s) are optional; they can all be nulls.
*/

create procedure position_id_cha_new( in p_health_facility_id   varchar( 255 ),   
                                      in p_position_id          varchar( 255 ),                                                                   
                                      in p_begin_date           varchar( 255 ), -- use this date for all tables
                                      
                                      in p_position_id_chss     varchar( 255 ),
                                      
                                      in p_person_id            int,
                                      
                                      in p_community_id_1       int,
                                      in p_community_id_2       int,
                                      in p_community_id_3       int,
                                      in p_community_id_4       int,
                                      in p_community_id_5       int )
                                      

begin

    set @p_health_facility_id   = p_health_facility_id;
    set @p_position_id          = p_position_id;
    set @p_begin_date           = p_begin_date;
    
    set @p_position_id_chss     = p_position_id_chss;
    
    set @p_community_id_1       = p_community_id_1;
    set @p_community_id_2       = p_community_id_2;
    set @p_community_id_3       = p_community_id_3;
    set @p_community_id_4       = p_community_id_4;
    set @p_community_id_5       = p_community_id_5;
    
    set @p_person_id            = p_person_id;

    insert into position  (                        position_id,            health_facility_id,    job_id,    begin_date )
    values                (               trim( @p_position_id ), trim( @p_health_facility_id ),  1,      @p_begin_date )
    ;

    insert into position_person (                  position_id,      person_id,    begin_date )
    values                      (         trim( @p_position_id ), @p_person_id, @p_begin_date )
    ;

    insert into position_supervisor (              position_id,      position_supervisor_id,   begin_date )
    values                          (     trim( @p_position_id ), @p_position_id_chss,      @p_begin_date )
    ;

    if not @p_community_id_1 is null then

        insert into position_community (           position_id,      community_id,      begin_date )
        values                          ( trim( @p_position_id ), @p_community_id_1, @p_begin_date )
        ;
        
    end if;
    
    if not @p_community_id_2 is null then

        insert into position_community (           position_id,      community_id,      begin_date )
        values                          ( trim( @p_position_id ), @p_community_id_2, @p_begin_date )
        ;
        
    end if;
  
    if not @p_community_id_3 is null then

        insert into position_community (           position_id,      community_id,      begin_date )
        values                          ( trim( @p_position_id ), @p_community_id_3, @p_begin_date )
        ;
        
    end if;
  
    if not @p_community_id_4 is null then

        insert into position_community (           position_id,      community_id,      begin_date )
        values                          ( trim( @p_position_id ), @p_community_id_4, @p_begin_date )
        ;
        
    end if;
 
    if not @p_community_id_5 is null then

        insert into position_community (           position_id,      community_id,      begin_date )
        values                          ( trim( @p_position_id ), @p_community_id_5, @p_begin_date )
        ;
        
    end if;
 
end$$

delimiter;
