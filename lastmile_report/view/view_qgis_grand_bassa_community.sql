use lastmile_report;

drop view if exists lastmile_report.view_qgis_grand_bassa_community;

create view lastmile_report.view_qgis_grand_bassa_community as
select 
      c.community, 
      c.community_id,  
      trim( substring_index( substring_index( c.note, '(', -1 ), ')', 1 ) ) as master_list_id
from lastmile_ncha.community as c
where community_id >= 3000 -- grand bassa community_id greater than equal to 3000