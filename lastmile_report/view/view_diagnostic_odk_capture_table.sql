use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_odk_capture_table;

create view lastmile_report.view_diagnostic_odk_capture_table as

select
      year_capture,
      month_capture,
      table_name,
      count( * ) as number_capture
from lastmile_report.view_diagnostic_odk_capture_subquery
group by year_capture, month_capture, table_name
;