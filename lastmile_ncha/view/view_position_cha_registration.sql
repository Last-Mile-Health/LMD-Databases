use lastmile_ncha;
  
drop view if exists lastmile_ncha.view_position_cha_registration;

create view lastmile_ncha.view_position_cha_registration as 

select
      pc.position_id,

      sum( g.total_household )                        as total_household,
      sum( g.total_household_member )                 as total_household_member,
      
      sum( g.total_zero_eleven_month_male )           as total_zero_eleven_month_male,
      sum( g.total_zero_eleven_month_female )         as total_zero_eleven_month_female,
  
      sum( g.total_one_five_year_male )               as total_one_five_year_male,
      sum( g.total_one_five_year_female )             as total_one_five_year_female,
  
      sum( g.total_six_fourteen_year_male )           as total_six_fourteen_year_male,
      sum( g.total_six_fourteen_year_female )         as total_six_fourteen_year_female,
  
      sum( g.total_fifteen_forty_nine_year_male )     as total_fifteen_forty_nine_year_male,
      sum( g.total_fifteen_forty_nine_year_female )   as total_fifteen_forty_nine_year_female,
  
      sum( g.total_fifty_plus_year_male )             as total_fifty_plus_year_male,
      sum( g.total_fifty_plus_year_female )           as total_fifty_plus_year_female
      

from lastmile_ncha.view_position_cha_id_community_id as pc
    left outer join lastmile_program.view_registration as g on ( pc.position_id like g.position_id ) and ( pc.community_id = cast( g.community_id as unsigned) )
group by pc.position_id
;