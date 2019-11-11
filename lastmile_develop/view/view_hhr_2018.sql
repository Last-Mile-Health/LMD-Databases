use lastmile_develop;

drop view if exists lastmile_develop.view_hhr_2018;

create view lastmile_develop.view_hhr_2018 as

select 
      b.county, 
      b.health_district, 
      b.health_facility_id, 
      b.health_facility, 
      b.chss_position_id, 
      b.chss,
      b.cohort,
      b.position_id, 
      b.cha,
      group_concat( distinct b.community_id order by b.community_id separator ', ' ) as community_id_list,
      group_concat( distinct b.community    order by b.community_id separator ', ' ) as community_list,
      sum( b.hhr_household_count )   as hhr_2018
from lastmile_cha.view_base_position_cha_household_registration as b
where ( b.cohort is null ) or not ( b.cohort like '%UNICEF%' )
group by  b.county, 
          b.health_district, 
          b.health_facility_id, 
          b.health_facility, 
          b.chss_position_id, 
          b.chss, 
          b.cohort,
          b.position_id, 
          b.cha
;