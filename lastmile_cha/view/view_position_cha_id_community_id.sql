use lastmile_cha;

drop view if exists view_position_cha_id_community_id;

create view view_position_cha_id_community_id as

select
      p.position_id,
 --     position_id now holds the "external" cha_id value, which is being reused, so we no longer need to link to person_id.
 --     substring_index( pr.person_id, '|', 1)      as person_id,
      trim( pc.community_id )                     as community_id
      
from view_position_cha as p
--    left outer join view_position_cha_person      as pr on p.position_id like pr.position_id
    left outer join position_community            as pc on p.position_id like trim( pc.position_id )
where pc.end_date is null
;       