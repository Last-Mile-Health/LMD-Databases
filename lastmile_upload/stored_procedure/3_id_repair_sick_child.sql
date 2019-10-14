use lastmile_upload;

drop procedure if exists lastmile_upload.3_id_repair_sick_child;

/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_cha.temp_view_base_history_moh_lmh_cha_id table and the lastmile_cha.view_base_history_moh_lmh_chss_id view,
  depending on whether it's a cha or chss.
  
  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.3_id_repair_sick_child()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 3_id_repair_sick_child' );


-- Reload the table temp_view_base_history_moh_lmh_cha_id.  Note: there is no chss table, the view is fast enough for now.

drop table if exists lastmile_cha.temp_view_base_history_moh_lmh_cha_id;

create table lastmile_cha.temp_view_base_history_moh_lmh_cha_id as 
select * from lastmile_cha.view_base_history_moh_lmh_cha_id;

-- 1. odk_sickChildForm ---------------------------------------

update lastmile_upload.odk_sickChildForm set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );


update lastmile_upload.odk_sickChildForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.chwID = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_sickChildForm' );


-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 3_id_repair_sick_child' );

end; -- end stored procedure
