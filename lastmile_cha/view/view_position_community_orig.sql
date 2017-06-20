use lastmile_cha;

-- view of all active positions and the commuunities they are assigned to.

drop view if exists view_position_community_orig;

create view view_position_community_orig as 

select
      trim( position_id ) as position_id,
      substring_index( trim( position_id_orig ), '-', 1 ) as community_id_orig,
      
      community_id,
      begin_date
      
from position_community as pc
where pc.end_date is null
;