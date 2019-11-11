use lastmile_report;

drop view if exists lastmile_report.view_community_cha_count;

create view lastmile_report.view_community_cha_count as
select community_id, count( * ) as number_cha
from lastmile_cha.view_position_community
group by community_id