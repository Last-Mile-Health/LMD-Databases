use lastmile_develop;

drop view if exists lastmile_develop.view_qgis_registration_year_max_rivercess;

create view lastmile_develop.view_qgis_registration_year_max_rivercess as 

select
      trim( community_id )      as community_id, 
      trim( position_id )      as position_id, 
      max( registration_year )  as registration_year,
      max( registration_date )  as registration_date
      
from lastmile_develop.view_qgis_registration_year_rivercess
group by trim( community_id ), trim( position_id )
;