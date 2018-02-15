use lastmile_cha;

drop view if exists view_position_community_cha;

create view view_position_community_cha as

select
      pc.community_id,
      pc.position_id,
      pc.begin_date as position_community_begin_date,
      
      pr.position_begin_date,
      pr.health_facility_id,
      pr.health_facility,
      
      pr.person_id,
      concat( pr.first_name, ' ', pr.last_name ) as full_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate
      
from view_position_community as pc
    left outer join view_position_cha_person as pr on pc.position_id like pr.position_id
;