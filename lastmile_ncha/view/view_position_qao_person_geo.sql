use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_qao_person_geo;

create view lastmile_ncha.view_position_qao_person_geo as

select
      pr.position_id,
      pr.position_begin_date,

      pr.position_filled,
      pr.position_filled_last_date,
      
      pr.position_person_begin_date,
      pr.hire_date,
      pr.person_id,
      pr.person_id_lmh,
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate

      -- qgl.health_facility_id_list,
      -- qgl.health_facility_list,
      -- qgl.health_district_list,
      -- qgl.county_list
      
from lastmile_ncha.view_position_qao_person_info as pr
    -- left outer join   lastmile_ncha.view_position_qao_geo_list                as qgl  on pr.position_id like qgl.position_id
;