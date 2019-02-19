use lastmile_report;

drop view if exists lastmile_report.view_home_birth;

create view lastmile_report.view_home_birth as

select
      trim( leading '0' from m.year_reported  )                     as `Year`,
      trim( leading '0' from m.month_reported )                     as `Month`,
      trim( m.county )                                              as County,
      trim( m.health_facility )                                     as Facility,
      concat( trim( m.cha_name ), ' ', '(', trim( m.cha_id ), ')' ) as `CHA name`,
      trim( m.num_births_home )                                     as `Home births`
      
from lastmile_report.view_base_msr as m
where coalesce( m.num_births_home, 0 ) > 0 -- and year_reported >= 2018
order by  
          cast( trim( leading '0' from m.year_reported  ) as unsigned ) desc, 
          cast( trim( leading '0' from m.month_reported ) as unsigned ) desc, 
          trim( county )asc, 
          trim( m.health_facility ) asc, 
          trim( cha_name ) asc
;

