use lastmile_report;

-- month day = 1 means first day of month
-- 39 is the average number of households per cha. (39 x 6 = 234)  Should be 39.166666 x 6 or 235 population per CHA.

select 
      d.date_key,
      p.county,
      sum( coalesce( r.total_household, 0 ) ) * 6 as population
from lastmile_datamart.dimension_date as d
    inner join lastmile_datamart.dimension_position as p on d.date_key = p.date_key
        left outer join lastmile_program.view_registration_date as r on ( r.position_id_pk = p.position_id_pk ) and
                                                                        ( r.date_key <= p.date_key )
        
where ( d.month_day = 1 ) and
      ( p.cohort is null or not ( p.cohort like 'UNICEF' ) ) and
      ( d.date_key >= 20200101 )
group by d.date_key, p.county
;


-- change the join view registration code to sum the last household value for the position_id_pk that is less than the current date key.
-- by last household value for position_id_pk the last registration date.
