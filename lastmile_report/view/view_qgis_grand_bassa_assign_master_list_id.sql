use lastmile_report;

drop view if exists lastmile_report.view_qgis_grand_bassa_assign_master_list_id;

create view lastmile_report.view_qgis_grand_bassa_assign_master_list_id as

select 
      c.master_list_id
from lastmile_report.view_qgis_grand_bassa_community as c
    left outer join lastmile_report.view_qgis_grand_bassa_assign_community_id as a on c.community_id = a.community_id
where not ( a.community_id is null )