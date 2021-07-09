use lastmile_report;

drop view if exists lastmile_report.view_qgis_grand_bassa_assign_community_id;

create view lastmile_report.view_qgis_grand_bassa_assign_community_id as

select
      pc.community_id
from lastmile_ncha.position_community as pc
where pc.community_id >= 3000 and pc.end_date is null
group by pc.community_id
;
