use lastmile_dataportal;

drop procedure if exists lastmile_dataportal.diagnostic_loader;

create procedure lastmile_dataportal.diagnostic_loader( in begin_date date, 
                                                        in end_date   date )
                                                
begin

    declare loop_date date default begin_date;

    -- Checke parameters are all valid.
    if  not ( cast( begin_date  as date ) is null ) and 
        not ( cast( end_date    as date ) is null ) then
        
        -- one-time materialization of loader views for performance
        call diagnostic_loader_materialize_view();
        
        -- Reload tbl_values_diagnostic every night
        truncate lastmile_dataportal.tbl_values_diagnostic;

        set loop_date = begin_date;

        while loop_date <= end_date do

            call diagnostic_load_month( month( loop_date ), year( loop_date ) );
                
            set loop_date = date_add( loop_date, interval 1 month );
                
        end while;
     
        select 1;
    
    else 
        -- return zero if invalide parameter date value
        select 0; 
        
    end if;
    
end;