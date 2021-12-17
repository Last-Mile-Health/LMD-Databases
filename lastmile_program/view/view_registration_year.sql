use lastmile_program;

drop view if exists lastmile_program.view_registration_year;

create view lastmile_program.view_registration_year as 

select
      year( trim( g.registrationDate ) )                                        as registration_year,
      trim( g.communityID )                                                     as community_id,
      trim( g.chaID )                                                           as position_id,
      
      max( trim( g.registrationDate ) )                                         as  registration_date,

      sum( cast( g.1_1_A_total_number_households as unsigned ) )                as total_household,
      sum( cast( g.1_1_B_total_household_members as unsigned ) )                as total_household_member,
                                                    
      sum( cast( g.1_1_C_total_zero_eleven_months_male as unsigned ) )          as total_zero_eleven_month_male,
      sum( cast( g.1_1_D_total_zero_eleven_months_female as unsigned ) )        as total_zero_eleven_month_female,
  
      sum( cast( g.1_1_E_total_one_five_years_male as unsigned ) )              as total_one_five_year_male,
      sum( cast( g.1_1_F_total_one_five_years_female as unsigned ) )            as total_one_five_year_female,
  
      sum( cast( g.1_1_G_total_six_fourteen_years_male as unsigned ) )          as total_six_fourteen_year_male,
      sum( cast( g.1_1_H_total_six_fourteen_years_female as unsigned ) )        as total_six_fourteen_year_female,
  
      sum( cast( g.1_1_I_total_fifteen_forty_nine_years_male as unsigned ) )    as total_fifteen_forty_nine_year_male,
      sum( cast( g.1_1_J_total_fifteen_forty_nine_years_female as unsigned ) )  as total_fifteen_forty_nine_year_female,
  
      sum( cast( g.1_1_K_total_fifty_plus_years_male as unsigned ) )            as total_fifty_plus_year_male,
      sum( cast( g.1_1_L_total_fifty_plus_years_female as unsigned ) )          as total_fifty_plus_year_female
  
from lastmile_upload.de_chaHouseholdRegistration as g
group by registration_year, community_id, position_id
;
