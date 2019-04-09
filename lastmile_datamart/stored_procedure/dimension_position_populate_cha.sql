use lastmile_datamart;

drop procedure if exists lastmile_datamart.dimension_position_populate_cha;

create procedure lastmile_datamart.dimension_position_populate_cha( in  begin_date        date, 
                                                                    in  end_date          date,
                                                                    in  unit              varchar(10),
                                                                    in  position_status   varchar(10) )
                                                                                           
begin

    declare loop_date date default begin_date;

    -- Checke parameters are all valid.
    if  ( not cast( begin_date as date  ) is null ) and 
        ( not cast( end_date as date    ) is null ) and
    
        ( ( upper( position_status ) like 'FILLED'  ) or 
          ( upper( position_status ) like 'OPEN'    ) or 
          ( upper( position_status ) like 'ALL' ) ) and
    
        ( ( upper( unit ) like 'DAY'      ) or 
          ( upper( unit ) like 'WEEK'     ) or 
          ( upper( unit ) like 'MONTH'    ) or 
          ( upper( unit ) like 'QUARTER'  ) or 
          ( upper( unit ) like 'YEAR'     ) ) then

        -- Parameters are all valid.  Continue executing procedure.

        -- delete all records from data mart.
        truncate lastmile_datamart.dimension_position;

        set loop_date = begin_date;

        while loop_date <= end_date do

            call lastmile_datamart.dimension_position_snapshot( loop_date, position_status );

            insert into lastmile_datamart.dimension_position
            select
            
                  -- CHA position data
                  t.*,
                  
                  -- CHSS position data
                  
                  null, 
                  null, 
                  null, 
                  null, 
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,                  
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  
                  null,
                  null,
                  null,         
                  null,                  
                  null,                  
                  null,
                                                                 
                  -- meta_insert_date_time stub
                  null
  
            from lastmile_datamart.faux_cursor_dimension_position as t;
   
            case upper( unit )
        
                when 'DAY'      then  set loop_date = date_add( loop_date, interval 1 day     );
                when 'WEEK'     then  set loop_date = date_add( loop_date, interval 1 week    );
                when 'MONTH'    then  set loop_date = date_add( loop_date, interval 1 month   );
                when 'QUARTER'  then  set loop_date = date_add( loop_date, interval 1 quarter );   
                when 'YEAR'     then  set loop_date = date_add( loop_date, interval 1 year    );
                else                  set loop_date = date_add( loop_date, interval 1 month   );
          
            end case;

        end while;
     
        select 1;
    
    else 
      
        select 0; 
        
    end if;
    
end;