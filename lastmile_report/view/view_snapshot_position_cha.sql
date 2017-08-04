use lastmile_report;

drop view if exists view_snapshot_position_cha;

create view view_snapshot_position_cha as

select
      position_status, 
      snapshot_date, 
      cohort,
      count( * )                                                    as cha_count,
      round( sum( position_community_count_proportional ), 0 )      as community_count,
      sum( population )                                             as population,
      sum( household)                                               as household 

from data_mart_snapshot_position_cha 
group by position_status, snapshot_date, cohort 
order by position_status, snapshot_date, cohort
;