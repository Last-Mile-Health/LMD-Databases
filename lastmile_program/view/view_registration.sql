use lastmile_program;
  
drop view if exists view_registration;

create view view_registration as 

select
      m.community_id, 
      m.position_id, 
      m.registration_year,
      
      y.registration_date,
      
      y.total_household,
      y.total_household_member,
      
      y.total_zero_eleven_month_male,
      y.total_zero_eleven_month_female,
  
      y.total_one_five_year_male,
      y.total_one_five_year_female,
  
      y.total_six_fourteen_year_male,
      y.total_six_fourteen_year_female,
  
      y.total_fifteen_forty_nine_year_male,
      y.total_fifteen_forty_nine_year_female,
  
      y.total_fifty_plus_year_male,
      y.total_fifty_plus_year_female
      
from lastmile_program.view_registration_year_max as m
    left outer join lastmile_program.view_registration_year as y on m.community_id       like  y.community_id        and 
                                                                    m.position_id        like  y.position_id         and
                                                                    m.registration_year  =     y.registration_year
;
