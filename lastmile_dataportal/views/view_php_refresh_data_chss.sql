use lastmile_dataportal;

drop view if exists view_php_refresh_data_chss;

create view view_php_refresh_data_chss as

select 
      person_id                             as chss_id,
      concat( first_name, ' ', last_name )  as chss
from lastmile_cha.view_position_chss_person
where not person_id is null
;