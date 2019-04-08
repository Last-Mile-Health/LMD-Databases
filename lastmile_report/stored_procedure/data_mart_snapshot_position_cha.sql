use lastmile_report;

drop procedure if exists data_mart_snapshot_position_cha;

create procedure data_mart_snapshot_position_cha( in  begin_date        date, 
                                                  in  end_date          date,
                                                  in  unit              varchar( 255 ),
                                                  in  position_status   varchar( 255 ) )
                                                
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
        truncate data_mart_snapshot_position_cha;

        set loop_date = begin_date;

        while loop_date <= end_date do

            call snapshot_position_cha( loop_date, position_status );

            insert into data_mart_snapshot_position_cha
            select
                  null, -- placeholder for id, which is auto incremented
                  position_status, 
                  
                  -- Integer representation of date. (e.g. 20190331 for March 31, 2019
                ( year( loop_date ) * 10000 ) + ( month( loop_date ) * 100 ) + day( loop_date ) as date_key,
                
                  loop_date, 
                  t.*,
                  null  -- placeholder for meta_insert_date_time
            from faux_cursor_snapshot_position_cha as t;
   
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