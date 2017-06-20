use lastmile_cha;

drop view if exists view_position_chss_person_geo;

create view view_position_chss_person_geo as

select
      pr.position_id,
      pr.position_begin_date,
      pr.health_facility_id,
      pr.health_facility,
      
      if( pr.position_person_begin_date is null, 'N', 'Y' )                                         as position_filled,
      if( pr.position_person_begin_date is null, d.end_date_last, pr.position_person_begin_date )   as position_filled_last_date,
      
      pr.position_person_begin_date,
      rf.begin_date                       as hire_date,
      pr.person_id,
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate,

      gf.cohort,
      gf.health_district,
      gf.health_district_id,
      gf.county_id,
      gf.county,
      
      t.module
      
from view_position_chss_person as pr
    left outer join   view_history_position_last_date           as d    on pr.position_id         like d.position_id
    left outer join   view_history_position_person_first        as rf   on pr.person_id           like rf.person_id 
    left outer join   view_geo_health_facility                  as gf   on pr.health_facility_id  like gf.health_facility_id
    left outer join   lastmile_program.view_train_chss_module   as t    on pr.person_id           like t.chss_id
;