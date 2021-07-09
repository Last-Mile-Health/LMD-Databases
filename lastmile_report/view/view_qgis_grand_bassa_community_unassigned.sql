use lastmile_report;

drop view if exists lastmile_report.view_qgis_grand_bassa_community_unassigned;

create view lastmile_report.view_qgis_grand_bassa_community_unassigned as
select
      m.*
from lastmile_temp.community_grand_bassa_master as m
    left outer join lastmile_report.view_qgis_grand_bassa_assign_master_list_id as i on m.master_list_id = i.master_list_id
where i.master_list_id is null
;