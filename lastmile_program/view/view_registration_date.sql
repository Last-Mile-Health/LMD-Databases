use lastmile_program;

drop view if exists lastmile_program.view_registration_date;

create view lastmile_program.view_registration_date as 

select
      --  Records are going to be aggregated and sum'ed based on year and position_id_pk.
      year( registrationDate )                                                                as registration_year,
      position_id_pk,
      max( registrationDate )                                                                 as  registration_date,
      
      ( year(   max( registrationDate ) ) * 10000 ) + 
      ( month(  max( registrationDate ) ) * 100   ) + 
        day(    max( registrationDate ) )                                                     as date_key,

      --  Add these fields for metadata to help with debug
      group_concat( distinct chaID          order by registrationDate desc separator ', ' )   as position_id_list,
      group_concat( distinct chaName        order by registrationDate desc separator ', ' )   as cha_list,
      group_concat( distinct community      order by registrationDate desc separator ', ' )   as community_list,
      group_concat( distinct communityID    order by registrationDate desc separator ', ' )   as community_id_list,
      group_concat( distinct healthFacility order by registrationDate desc separator ', ' )   as health_facility_list,
      group_concat( distinct healthDistrict order by registrationDate desc separator ', ' )   as health_district_list,
      
      sum( cast( 1_1_A_total_number_households as unsigned ) )                                as total_household,
      sum( cast( 1_1_B_total_household_members as unsigned ) )                                as total_household_member,
                                                    
      sum( cast( 1_1_C_total_zero_eleven_months_male as unsigned ) )                          as total_zero_eleven_month_male,
      sum( cast( 1_1_D_total_zero_eleven_months_female as unsigned ) )                        as total_zero_eleven_month_female,
  
      sum( cast( 1_1_E_total_one_five_years_male as unsigned ) )                              as total_one_five_year_male,
      sum( cast( 1_1_F_total_one_five_years_female as unsigned ) )                            as total_one_five_year_female,
  
      sum( cast( 1_1_G_total_six_fourteen_years_male as unsigned ) )                          as total_six_fourteen_year_male,
      sum( cast( 1_1_H_total_six_fourteen_years_female as unsigned ) )                        as total_six_fourteen_year_female,
  
      sum( cast( 1_1_I_total_fifteen_forty_nine_years_male as unsigned ) )                    as total_fifteen_forty_nine_year_male,
      sum( cast( 1_1_J_total_fifteen_forty_nine_years_female as unsigned ) )                  as total_fifteen_forty_nine_year_female,
  
      sum( cast( 1_1_K_total_fifty_plus_years_male as unsigned ) )                            as total_fifty_plus_year_male,
      sum( cast( 1_1_L_total_fifty_plus_years_female as unsigned ) )                          as total_fifty_plus_year_female
  
from lastmile_upload.de_chaHouseholdRegistration
where valid = 1
group by registration_year, position_id_pk
;