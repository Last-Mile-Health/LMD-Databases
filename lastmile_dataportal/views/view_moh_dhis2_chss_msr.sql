use lastmile_dataportal;

drop view if exists view_moh_dhis2_chss_msr;

create view view_moh_dhis2_chss_msr as

select month_report, year_report, indicator_name, ind_id, '1_1' as territory_id, `1_1` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_2' as territory_id, `1_2` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_3' as territory_id, `1_3` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_4' as territory_id, `1_4` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_5' as territory_id, `1_5` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_6' as territory_id, `1_6` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_7' as territory_id, `1_7` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_8' as territory_id, `1_8` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_9' as territory_id, `1_9` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_10' as territory_id, `1_10` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_11' as territory_id, `1_11` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_12' as territory_id, `1_12` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_13' as territory_id, `1_13` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_14' as territory_id, `1_14` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix

union all

select month_report, year_report, indicator_name, ind_id, '1_15' as territory_id, `1_15` as value
from lastmile_dataportal.view_moh_dhis2_chss_msr_matrix
;