use lastmile_cha;

drop view if exists view_community_cha;

create view view_community_cha as

select

      pc.community_id,
      group_concat( pc.position_id order by pc.position_id separator ', ' )  as cha_id_list,
      count( * )                                                             as cha_count
      
from view_position_community as pc
group by pc.community_id
;
      

