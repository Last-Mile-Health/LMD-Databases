use lastmile_upload;

drop procedure if exists lastmile_upload.3_ncha_id_repair_sick_child;
/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_ncha.temp_view_person_position_cha_id_update table and the lastmile_ncha.temp_view_history_position_position_id_chss_update 
  view, depending on whether it's a cha or chss.  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.3_ncha_id_repair_sick_child()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 3_ncha_id_repair_sick_child' );

-- 1. odk_sickChildForm ---------------------------------------

-- First, attempt to repair value in the _inserted field

update lastmile_upload.odk_sickChildForm 
    set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted ),
        position_id_pk = null -- always set to null
;

update lastmile_upload.odk_sickChildForm a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.chwID = m.position_id_nchap,  a.position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )
      
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_sickChildForm' );


-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 3_ncha_id_repair_sick_child' );

end; -- end stored procedure
