use lastmile_upload;

drop procedure if exists lastmile_upload.2_ncha_id_repair_routine_visit;
/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_ncha.temp_view_person_position_cha_id_update table and the lastmile_ncha.view_person_position_cha_id_update 
  view, depending on whether it's a cha or chss.  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.2_ncha_id_repair_routine_visit()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 2_ncha_id_repair_routine_visit' );

-- 1. odk_routineVisit ---------------------------------------

-- First, attempt to repair value in the _inserted field
update  lastmile_upload.odk_routineVisit set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update  lastmile_upload.odk_routineVisit a, lastmile_ncha.temp_view_person_position_cha_id_update m
    
    set a.chaID = m.position_id_last 

where ( trim( a.cha_id_inserted_format ) like m.position_id_last  ) or 
      ( trim( a.cha_id_inserted_format ) like m.position_id       )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_routineVisit' );

-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 2_ncha_id_repair_routine_visit' );

end; -- end stored procedure
