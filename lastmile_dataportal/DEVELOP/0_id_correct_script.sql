/*
select * from lastmile_report.view_diagnostic_id_correct
where ( meta_form_date >= '2020-05-01' and id_type like 'chss' ) and
(
-- table_name like 'de_case_scenario_2'
-- table_name like 'de_cha_monthly_service_report'
-- table_name like 'de_chss_commodity_distribution'
-- table_name like 'de_chss_monthly_service_report'
-- table_name like 'odk_chaRestock'
)
*/

select * from lastmile_report.view_diagnostic_id_correct 
where ( meta_form_date >= '2020-05-01' and id_type like 'cha' ) and
(
-- table_name like 'de_cha_monthly_service_report'
table_name like 'odk_chaRestock'
)
