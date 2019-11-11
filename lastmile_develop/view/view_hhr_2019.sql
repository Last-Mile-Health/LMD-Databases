use lastmile_develop;

drop view if exists lastmile_develop.view_hhr_2019;

create view lastmile_develop.view_hhr_2019 as 

select
      registration_year,
      position_id,
      sum( total_household ) as hhr_2019

from lastmile_develop.view_registration_2019
group by registration_year, position_id
;