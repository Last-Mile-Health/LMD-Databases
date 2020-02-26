/*
  This view does not work on Windows MySQL, because the views being "unioned" have underlying self-joins in them, although
  this may have changed since I (Owen) recoded them.
  
  What happens on Windows MySQL (5.6) is it returns zero records.
  
  
  It works fine on our production Linux instance of MySQL.  
  
  Not sure if this is a problem with the specific version of MySQL we are using on Windoww
  for development or not.

*/

use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_position;

create view lastmile_ncha.view_base_position as

select
      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      'CHA'                       as job,
      position_id_pk,
      position_id,
      cha                         as full_name,
      
      position_filled,
      position_filled_last_date
      
from lastmile_ncha.view_base_position_cha

union all

select

      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      'CHSS'                    as job,
      position_id_pk,
      position_id,
      chss                      as full_name,
      
      position_filled,
      position_filled_last_date
      
from lastmile_ncha.view_base_position_chss
;

