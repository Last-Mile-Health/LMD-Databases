use lastmile_upload;

drop view if exists lastmile_upload.view_diagnostic_id;

create view lastmile_upload.view_diagnostic_id as

select * from lastmile_upload.view_diagnostic_de_id

union all

select * from lastmile_upload.view_diagnostic_odk_id
;
