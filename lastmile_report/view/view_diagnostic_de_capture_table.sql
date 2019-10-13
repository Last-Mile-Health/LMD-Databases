use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_de_create_table;

create view lastmile_report.view_diagnostic_de_create_table as
select
      year_create,
      month_create,
      table_name,
      count( * ) as number_create
from lastmile_report.view_diagnostic_de_create_subquery
group by year_create, month_create, table_name
;