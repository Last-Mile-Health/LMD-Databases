use lastmile_cha;

-- view of all active positions and the commuunities they are assigned to.

drop view if exists view_position_community;

create view view_position_community as 

select

      trim( position_id ) as position_id,
      community_id,
      begin_date
      
from position_community as pc
where pc.end_date is null
;