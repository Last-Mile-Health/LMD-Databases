use lastmile_ncha;

drop view if exists lastmile_ncha.view_community_cha;

create view lastmile_ncha.view_community_cha as
select
      pc.community_id,
      group_concat( pc.position_id      order by pc.position_id separator ', '    ) as position_id_list,
      group_concat( pc.position_id_pk   order by pc.position_id separator ', '    ) as position_id_pk_list,
      
      count( pc.position_id )                                                   as position_count,
      group_concat( pc.person_id    order by pc.position_id   separator ', '  ) as person_id_list,
      count( pc.person_id )                                                     as person_count,
      group_concat( pc.full_name    order by pc.position_id   separator ', '  ) as cha_list 
      
from lastmile_ncha.view_position_community_cha as pc
group by pc.community_id
;