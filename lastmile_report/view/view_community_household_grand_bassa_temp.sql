use lastmile_report;

drop view if exists lastmile_report.view_community_household_grand_bassa_temp;

create view lastmile_report.view_community_household_grand_bassa_temp as 

select

      c.community_id,
      group_concat( distinct c.number_cha order by c.position_id asc separator ', ' )                               as number_cha, 
      group_concat( distinct c.map_number_household_community_position order by c.position_id asc separator ', ' )  as map_number_household_community_position,
      group_concat( distinct c.registration_year order by c.position_id asc separator ', ' )                        as registration_year,	
      group_concat( distinct c.total_household order by c.position_id asc separator ', ' )                          as total_household,
      group_concat( distinct c.cohort order by c.position_id asc separator ', ' )                                   as cohort,
      group_concat( distinct c.cha order by c.position_id asc separator ', ' )                                      as cha,
      group_concat( distinct c.gender order by c.position_id asc separator ', ' )                                   as gender,
      group_concat( distinct c.birth_date order by c.position_id asc separator ', ' )                               as birth_date,
      group_concat( distinct c.phone_number order by c.position_id asc separator ', ' )                             as phone_number,
      group_concat( distinct c.chss_position_id order by c.position_id asc separator ', ' )                         as chss_position_id,
      group_concat( distinct c.chss order by c.position_id asc separator ', ' )                                     as chss,
      group_concat( distinct c.chss_gender order by c.position_id asc separator ', ' )                              as chss_gender,
      group_concat( distinct c.chss_birth_date order by c.position_id asc separator ', ' )                          as chss_birth_date,
      group_concat( distinct c.chss_phone_number  order by c.position_id asc separator ', ' )                       as chss_phone_number

from lastmile_report.view_community_household as c
where community_id >= 3000
group by c.community_id
;