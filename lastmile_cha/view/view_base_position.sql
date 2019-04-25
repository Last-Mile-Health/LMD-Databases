/*
  This view does not work on Windows MySQL.  Because the two views it is buitlt on are themselves built on self-joins,
  it returns zeron records.  It works fine on our production Linux instance of MySQL.  Not sure if this is a problem 
  with the specific version of MySQL we are using on Windows or 

*/

use lastmile_cha;

drop view if exists view_base_position;

create view view_base_position as

select
      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      'CHA'                       as job,
      position_id,
      cha                         as full_name,
      
      position_filled,
      position_filled_last_date
      
from view_base_position_cha_basic_info

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
      position_id,
      chss                      as full_name,
      
      position_filled,
      position_filled_last_date
      
from view_base_position_chss
;

