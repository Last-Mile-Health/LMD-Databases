use lastmile_report;

drop view if exists lastmile_report.view_qgis_grand_bassa_community_master_id;

create view lastmile_report.view_qgis_grand_bassa_community_master_id as 

select
      a.community,
      m.town_name,
      if(  a.community like m.town_name, 'Y', 'N' ) as community_match,
      
      a.community_id,
      m.community_id      as community_id_m,
      if( a.community_id = m.community_id, 'Y','N' ) as community_id_match,
      
      a.master_list_id,
      m.master_list_id    as master_list_id_m,
      if( a.master_list_id = m.master_list_id, 'Y','N' ) as master_list_id_match
      
from lastmile_report.view_qgis_grand_bassa_community as a
    left outer join lastmile_temp.community_grand_bassa_master as m on cast( a.master_list_id as unsigned ) = cast( m.master_list_id as unsigned )
;