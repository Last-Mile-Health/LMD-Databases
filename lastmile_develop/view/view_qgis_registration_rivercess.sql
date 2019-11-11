use lastmile_develop;
  
drop view if exists lastmile_develop.view_qgis_registration_rivercess;

create view lastmile_develop.view_qgis_registration_rivercess as 

select
      m.community_id, 
      m.position_id, 
      m.registration_year,
      y.registration_date,
      y.total_household
      
from lastmile_develop.view_qgis_registration_year_max_rivercess as m
    left outer join lastmile_develop.view_qgis_registration_year_rivercess as y on  m.community_id      like  y.community_id and 
                                                                                    m.position_id       like  y.position_id and
                                                                                    m.registration_year =     y.registration_year
;
