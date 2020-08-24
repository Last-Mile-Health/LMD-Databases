use lastmile_dataportal;

select
      r.report_id,
      r.report_name,
--      r.header_note,
      
      ro.display_order,
      ro.indicators_table,
      ro.territories_table,
      ro.territories_chart,
      ro.ro_name,
      ro.ro_description,
      ro.ro_source,
      
      substring_index( trim( ro.indicators_table ), ',', 1 )  as ro_ind_id_first,
      i1.ind_name                                             as i1_ind_name,
      i1.ind_category                                         as i1_category,
      
      substring_index( trim( ro.indicators_table ), ',', -1 ) as ro_ind_id_last,
      i2.ind_name                                             as i2_ind_name,
      i2.ind_category                                         as i2_category
      
from tbl_reports as r
    left outer join tbl_report_objects as ro on r.report_id = ro.report_id
        left outer join tbl_indicators as i1 on  substring_index( trim( ro.indicators_table ), ',',  1 ) = i1.ind_id
        left outer join tbl_indicators as i2 on  substring_index( trim( ro.indicators_table ), ',', -1 ) = i2.ind_id

where r.archived = 0 and ro.archived = 0 -- and r.report_id = 12
order by r.report_name asc, ro.display_order asc 
;