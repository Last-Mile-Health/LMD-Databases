use lastmile_upload;

drop view if exists lastmile_upload.view_log_update_nchap_id_last;

create view lastmile_upload.view_log_update_nchap_id_last as
select table_name, max( meta_date_time ) as meta_date_time
from lastmile_upload.log_update_nchap_id
group by table_name
;

drop view if exists lastmile_upload.view_upload_update_nchap_id_date;

create view lastmile_upload.view_upload_update_nchap_id_date as

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_case_scenario a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_case_scenario'

union all

select  'cha'                     as id_type,
        a.cha_id                  as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_case_scenario a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_case_scenario'

;
