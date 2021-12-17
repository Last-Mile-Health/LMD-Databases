use lastmile_program;

drop view if exists lastmile_program.view_registration_year_max;

create view lastmile_program.view_registration_year_max as 

select
      g1.community_id, 
      g1.position_id, 
      max( g1.registration_year ) as registration_year,
      max( g1.registration_date ) as registration_date
from lastmile_program.view_registration_year as g1
group by g1.community_id, g1.position_id 
;
