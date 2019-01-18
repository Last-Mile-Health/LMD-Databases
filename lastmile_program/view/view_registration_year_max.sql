use lastmile_program;
  
drop view if exists view_registration_year_max;

create view view_registration_year_max as 

select
      g1.community_id, 
      g1.position_id, 
      max( g1.registration_year ) as registration_year 
from view_registration_year as g1
group by g1.community_id, g1.position_id 
;