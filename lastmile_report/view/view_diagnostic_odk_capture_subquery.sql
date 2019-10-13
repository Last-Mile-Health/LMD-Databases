use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_odk_capture_subquery;

create view lastmile_report.view_diagnostic_odk_capture_subquery as
select
      year(   meta_form_date )  as year_capture,
      month(  meta_form_date )  as month_capture,
      table_name,
      pk_id
from lastmile_report.view_diagnostic_odk_id_unfiltered
where meta_form_date >= '2012-10-01' and meta_form_date <= now()
group by year( meta_form_date ), month( meta_form_date ), table_name, pk_id
;