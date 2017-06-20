use lastmile_program;
  
drop view if exists view_registration;

create view view_registration as 

select
      g1.community_id, 
      g1.cha_id, 
      g1.registration_year,
      
      g1.total_household,
      g1.total_household_member,
      
      g1.total_zero_eleven_month_male,
      g1.total_zero_eleven_month_female,
  
      g1.total_one_five_year_male,
      g1.total_one_five_year_female,
  
      g1.total_six_fourteen_year_male,
      g1.total_six_fourteen_year_female,
  
      g1.total_fifteen_forty_nine_year_male,
      g1.total_fifteen_forty_nine_year_female,
  
      g1.total_fifty_plus_year_male,
      g1.total_fifty_plus_year_female
      
from view_registration_year as g1
    left outer join view_registration_year as g2 on ( trim( g1.community_id ) like trim( g2.community_id  )  ) and 
                                                    ( trim( g1.cha_id )       like trim( g2.cha_id        )  ) and
                                                    ( g1.registration_year    > g2.registration_year      )
group by trim( g1.community_id ), trim( g1.cha_id )
having count( * ) >= 1
;