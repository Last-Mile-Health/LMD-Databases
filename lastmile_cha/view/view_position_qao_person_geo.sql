use lastmile_cha;

drop view if exists view_position_qao_person_geo;

create view view_position_qao_person_geo as

select
      pr.position_id,
      pr.position_begin_date,

      if( pr.position_person_begin_date is null, 'N', 'Y' )                                         as position_filled,
      if( pr.position_person_begin_date is null, d.end_date_last, pr.position_person_begin_date )   as position_filled_last_date,
      
      pr.position_person_begin_date,
      rf.begin_date                       as hire_date,
      pr.person_id,
      pr.person_id_lmh,
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate,

      qgl.health_facility_id_list,
      qgl.health_facility_list,
      qgl.health_district_list,
      qgl.county_list
      
from view_position_qao_person as pr
    left outer join   view_history_position_last_date           as d    on pr.position_id like d.position_id
    left outer join   view_history_position_person_first        as rf   on pr.person_id    =   rf.person_id 
    left outer join   view_position_qao_geo_list                as qgl  on pr.position_id like qgl.position_id
;