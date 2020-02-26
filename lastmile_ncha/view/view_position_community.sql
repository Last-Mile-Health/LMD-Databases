use lastmile_ncha;

-- view of all active positions and the commuunities they are assigned to.

drop view if exists lastmile_ncha.view_position_community;

create view lastmile_ncha.view_position_community as 

select
      pc.position_id_pk,
      p.position_id,
      pc.community_id,
      pc.begin_date,
      p.health_facility_id

from lastmile_ncha.position_community as pc
    left outer join lastmile_ncha.view_position as p on pc.position_id_pk = p.position_id_pk
where pc.end_date is null
;