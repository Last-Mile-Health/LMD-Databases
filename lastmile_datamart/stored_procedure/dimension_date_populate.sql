use lastmile_datamart;

drop procedure if exists dimension_date_populate;

create procedure dimension_date_populate( begin_date date, end_date date )

begin

  # Holds a flag so we can determine if the date is the last day of month
  declare month_day_last char( 1 );

  # Number of months to add to the date to get the current Fiscal date
  declare fiscal_year_month_offset int;

  # These two counters are used in our loop.
  declare date_counter date;    #Current date in loop
 
  declare fiscal_counter datetime;  #Fiscal Year Date in loop

  -- Set to the number of months to add to the current date to get the beginning of the fiscal year. 
  -- For example, if the fiscal year begins July 1, put a 6 there.  Negative values are also allowed, 
  -- thus if your 2010 Fiscal year begins in July of 2009, put a -6.
  set fiscal_year_month_offset = 6;

  # Start the counter at the begin date
  set date_counter = begin_date;
 
  -- Truncate: remove all rows from table.
  truncate dimension_date;

  while date_counter <= end_date do
  
    -- Calculate the current fiscal date as an offset of the current date in the loop
    set fiscal_counter = date_add( date_counter, interval fiscal_year_month_offset month );

    -- Set value for month_day_last
    if month( date_counter ) = month( date_add( date_counter, interval 1 day ) ) then
    
      set month_day_last = 'N';
      
    else
      set month_day_last = 'Y';
      
    end if;

    -- add a record into the date dimension table for this date
    insert into dimension_date (  date_key,
                                  date_lmh,
                                
                                  date_full,
                                  date_name, 
                                  date_us, 
                                  date_eu,
                                  week_day,
                                  week_day_name,
                                  month_day,
                                  year_day,
                                  weekday_weekend,
                                  year_week,
                                  month_name,
                                  year_month_number,
                                  month_day_last,
                                  calendar_quarter,
                                  calendar_year,
                                  calendar_year_month,
                                  calendar_year_quarter,
                                  fiscal_month_year,
                                  fiscal_quarter,
                                  fiscal_year,
                                  fiscal_year_month,
                                  fiscal_year_quarter
                                
    ) values  ( 
                ( year( date_counter ) * 10000 ) + ( month( date_counter ) * 100 ) + day( date_counter ),  -- calculate date_key
                date_format( date_counter , '%Y-%m-%d' ),
              
                date_counter,              
                date_format(  date_counter , '%Y/%m/%d' ),
                date_format(  date_counter , '%m/%d/%Y' ),
                date_format(  date_counter , '%d/%m/%Y' ),                    
                dayofweek(    date_counter  ), 
                dayname(      date_counter  ),
                dayofmonth(   date_counter  ),
                dayofyear(    date_counter  ),
              
                case dayname( date_counter )           
                  when 'Saturday' then 'weekend'
                  when 'Sunday'   then 'weekend'
                  else 'weekday'              
                end,
              
                weekofyear( date_counter ),
                monthname(  date_counter ),
                month(      date_counter ),
              
                month_day_last,
              
                quarter(    date_counter  ),
                year(       date_counter  ),
              
                concat( cast( year( date_counter ) as char( 4 ) ), '-', date_format( date_counter, '%m' ) ),
                concat( cast( year( date_counter ) as char( 4 ) ), 'Q', quarter( date_counter ) ),
                month(    fiscal_counter ),
                quarter(  fiscal_counter ),
                year(     fiscal_counter ),
                concat( cast( year( fiscal_counter ) as char( 4 ) ), '-', date_format( fiscal_counter, '%m' ) ),
                concat( cast( year( fiscal_counter ) as char( 4 ) ), 'Q', quarter( fiscal_counter ) )
              
              );

              -- increment the date counter for next pass through the loop
              set date_counter = date_add( date_counter, interval 1 day );
      
  end while;


end;