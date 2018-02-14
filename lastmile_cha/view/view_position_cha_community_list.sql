use lastmile_cha;

drop view if exists view_position_cha_community_list;

create view view_position_cha_community_list as

select
      trim( pc.position_id )                                                                as position_id,
      min(  pc.begin_date )                                                                 as begin_date,
      
      group_concat( pc.begin_date             order by trim( c.community ) separator ', ' ) as begin_date_list,                                                                           
      group_concat( trim( c.community_id )    order by trim( c.community ) separator ', ' ) as community_id_list,
      group_concat( trim( c.community   )     order by trim( c.community ) separator ', ' ) as community_list
      
from position_community as pc
    left outer join community as c on trim( pc.community_id ) like trim( c.community_id )
where pc.end_date is null
group by trim( pc.position_id )
;
-- When a position has multiple communities it is serving, show the earliest date as the begin date, but then also
-- show a list of communities, IDs, and their begin dates, ordered by communities.