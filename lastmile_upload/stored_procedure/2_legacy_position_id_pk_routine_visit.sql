use lastmile_upload;

drop procedure if exists lastmile_upload.2_legacy_position_id_pk_routine_visit;

create procedure lastmile_upload.2_legacy_position_id_pk_routine_visit()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 2_legacy_position_id_pk_routine_visit' );

-- alter table lastmile_upload.odk_routineVisit add column position_id_pk integer unsigned null after chaID;
update lastmile_upload.odk_routineVisit a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.chaID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_routineVisit' );

-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 2_legacy_position_id_pk_routine_visit' );

end; -- end stored procedure
