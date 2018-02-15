use lastmile_cha;

drop view if exists view_position_cha_id_community_id;

create view view_position_cha_id_community_id as

select
      p.position_id,
      pc.community_id
      
from view_position_cha as p
    left outer join position_community as pc on p.position_id like trim( pc.position_id )
where pc.end_date is null
;       