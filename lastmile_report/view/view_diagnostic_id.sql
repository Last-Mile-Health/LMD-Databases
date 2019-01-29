use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_id;

create view lastmile_report.view_diagnostic_id as

select * from lastmile_report.view_diagnostic_de_id

union all

select * from lastmile_report.view_diagnostic_odk_id
;
