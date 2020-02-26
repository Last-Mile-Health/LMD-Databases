use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_cha_community_list;

create view lastmile_ncha.view_position_cha_community_list as

select
      pc.position_id_pk,
      pc.position_id,
      min(  pc.begin_date )                                                                 as begin_date,
      
      group_concat( pc.begin_date             order by trim( c.community ) separator ', ' ) as begin_date_list,                                                                           
      group_concat( trim( c.community_id )    order by trim( c.community ) separator ', ' ) as community_id_list,
      group_concat( trim( c.community   )     order by trim( c.community ) separator ', ' ) as community_list
      
from lastmile_ncha.view_position_community as pc
    left outer join lastmile_ncha.community as c on trim( pc.community_id ) like trim( c.community_id )
-- where pc.end_date is null
group by pc.position_id_pk, pc.position_id
;
-- There should always be a 1:1 relationship between position_id_pk and position_id in resultset from 
-- view_position, because it is built on view_position, which are current positions with end_date 
-- equal to null, both in position table and position_id table.  In position_id table there cannot be
-- two instances of the same position_id_pk with two different position_id(s) with end_date equal to null.

-- When a position has multiple communities it is serving, show the earliest date as the begin date, but then also
-- show a list of communities, IDs, and their begin dates, ordered by communities.