use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_chss_person_geo;

create view lastmile_ncha.view_position_chss_person_geo as
select
      pr.position_id_pk,
      pr.position_id,
      pr.position_begin_date,
      pr.health_facility_id,
      pr.health_facility,
      
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
      pr.phone_number_alternate,

      -- gf.cohort,
      pr.cohort,
      gf.health_district,
      gf.health_district_id,
      gf.county_id,
      gf.county,
      
      pr.module
      
from lastmile_ncha.view_position_chss_person_info as pr
    left outer join lastmile_ncha.view_geo_health_facility as gf on pr.health_facility_id  like  gf.health_facility_id
    
;