use lastmile_report;

drop function if exists valid_day_month_year;

create function valid_day_month_year( p_day     varchar( 255 ),
                                      p_month   varchar( 255 ),
                                      p_year    varchar( 255 ) ) returns tinyint

begin

declare return_day    tinyint default 0;
declare month_number  tinyint default 0;

if  p_day           is null or 
    p_month         is null or 
    p_year          is null or 
    trim( p_day )   like '' or
    trim( p_month ) like '' or
    trim( p_year )  like ''
then

    set return_day = 1;
    
elseif  ( cast( trim( p_day  ) as unsigned ) between 1 and 31 )  and 
        ( cast( trim( p_year ) as unsigned ) >= 0 )
then 

    if ( cast( trim( p_month ) as unsigned ) between 1 and 12  ) 
    then
    
        if cast( trim( p_day ) as unsigned ) <= day( last_day( concat( trim( p_year ) , '/', trim( p_month ) , '/', '1' ) ) )
        then
            set return_day = cast( trim( p_day ) as unsigned );
        else 
            set return_day = day( last_day( concat( trim( p_year ) , '/', trim( p_month ) , '/', '1' ) ) );
        end if;
       
    else
    
        case trim( p_month )
            when 'JANUARY'    then set month_number = 1;
            when 'FEBRUARY'   then set month_number = 2;
            when 'MARCH'      then set month_number = 3;
            when 'APRIL'      then set month_number = 4;
            when 'MAY'        then set month_number = 5;
            when 'JUNE'       then set month_number = 6;
            when 'JULY'       then set month_number = 7;
            when 'AUGUST'     then set month_number = 8;
            when 'SEPTEMBER'  then set month_number = 9;
            when 'OCTOBER'    then set month_number = 10;
            when 'NOVEMBER'   then set month_number = 11;
            when 'DECEMBER'   then set month_number = 12;              
            else set month_number = 0;               
        end case;
        
        if month_number = 0 then -- invalid month name or integer
        
            set return_day = 0;
            
        elseif ( month_number between 1 and 12 ) and ( trim( p_day )  <= day( last_day( concat( trim( p_year ) , '/', month_number, '/', '1' ) ) ) )
        then
            
            set return_day = cast( trim( p_day ) as unsigned );
            
        else 
            
           set return_day = day( last_day( concat( trim( p_year ) , '/', month_number, '/', '1' ) ) );
           
        end if;
              
    end if;
        
else
    set return_day = 0;
end if;

return return_day;

end;