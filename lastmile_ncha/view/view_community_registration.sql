use lastmile_ncha;

-- View of all commuunities, the CHAs asssigned to them, and the household and member registration counts.

drop view if exists lastmile_ncha.view_community_registration;

create view lastmile_ncha.view_community_registration as 

select
      pc.community_id,
      group_concat( pc.position_id        order by pc.position_id separator ', ' )  as position_id_list,
      group_concat( pc.position_id_pk     order by pc.position_id separator ', ' )  as position_id_pk_list,
      group_concat( g.registration_year   order by pc.position_id separator ', ' )  as registration_year_list, 
      
      sum( g.total_household )                      as total_household, 
      sum( g.total_household_member )               as total_household_member,
      
      sum( g.total_zero_eleven_month_male )         as total_zero_eleven_month_male, 
      sum( g.total_zero_eleven_month_female )       as total_zero_eleven_month_female, 
      sum( g.total_one_five_year_male )             as total_one_five_year_male, 
      sum( g.total_one_five_year_female )           as total_one_five_year_female, 
      sum( g.total_six_fourteen_year_male )         as total_six_fourteen_year_male, 
      sum( g.total_six_fourteen_year_female )       as total_six_fourteen_year_female, 
      sum( g.total_fifteen_forty_nine_year_male )   as total_fifteen_forty_nine_year_male, 
      sum( g.total_fifteen_forty_nine_year_female ) as total_fifteen_forty_nine_year_female, 
      sum( g.total_fifty_plus_year_male )           as total_fifty_plus_year_male, 
      sum( g.total_fifty_plus_year_female )         as total_fifty_plus_year_female
      
from lastmile_ncha.view_position_community as pc 
        left outer join lastmile_program.view_registration as g on  ( pc.community_id = cast( g.community_id as unsigned ) ) and 
                                                                    ( pc.position_id  like g.position_id )
group by pc.community_id
;