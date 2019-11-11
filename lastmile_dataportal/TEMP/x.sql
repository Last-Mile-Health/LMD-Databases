-- select * from tbl_indicators -- where ind_name like '%ODK%Supervision%' order by ind_id asc

-- select * from tbl_values where ind_id >= 790;
/*
insert into tbl_indicators (  ind_id, ind_name,	ind_format,	ind_category, ind_definition, ind_source,	archived,	notes )
select                        ind_id, ind_name,	ind_format,	ind_category, ind_definition, ind_source,	archived,	notes
from lastmile_scratchpad.chss_msr;
*/

/*
insert into tbl_report_objects (  

  report_id,
  display_order,
  indicators_table,
  indicators_chart,
  territories_table,
  territories_chart,
  labels_table,
  labels_chart,
  ro_name,
  ro_description,
  ro_source

)
select                        

  report_id,
  display_order,
  indicators_table,
  indicators_chart,
  territories_table,
  territories_chart,
  labels_table,
  labels_chart,
  ro_name,
  ro_description,
  ro_source

from lastmile_scratchpad.report;
*/

-- select * from tbl_indicators where ind_id >= 500 -- ind_id between 501 and 513 or ind_id between 720 and 733
select * from tbl_report_objects where report_id in ( 35,36 ) order by report_id, display_order;
