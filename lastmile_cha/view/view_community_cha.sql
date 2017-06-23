use lastmile_cha;

drop view if exists view_community_cha;

create view view_community_cha as

select
      pc.community_id,

      group_concat( pc.position_id  order by cast( pc.position_id as unsigned ) separator ', ' )  as position_id_list,
      count( pc.position_id )                                                                     as position_count,
      
      group_concat( substring_index( pc.person_id, '|', 1 ) order by cast( substring_index( pc.person_id, '|', 1 ) as unsigned ) separator ', ' ) as cha_id_list,
      count( substring_index( pc.person_id, '|', 1 ) ) as cha_count
      
from view_position_community_cha as pc
group by pc.community_id
;
      

