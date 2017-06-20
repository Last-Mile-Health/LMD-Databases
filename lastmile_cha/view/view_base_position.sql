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
      cha_id                      as staff_id,
      cha                         as full_name,
      
      position_filled,
      position_filled_last_date
      
from view_base_position_cha

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
      chss_id                   as staff_id,
      chss                      as full_name,
      
      position_filled,
      position_filled_last_date
      
from view_base_position_chss
;

