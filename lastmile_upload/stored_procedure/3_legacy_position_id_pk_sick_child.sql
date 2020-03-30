use lastmile_upload;

drop procedure if exists lastmile_upload.3_legacy_position_id_pk_sick_child;

create procedure lastmile_upload.3_legacy_position_id_pk_sick_child()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 3_legacy_position_id_pk_sick_child' );

-- 1. odk_sickChildForm ---------------------------------------

-- alter table lastmile_upload.odk_sickChildForm add column position_id_pk integer unsigned null after chwID;
update lastmile_upload.odk_sickChildForm a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.chwID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: odk_sickChildForm' );


-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 3_legacy_position_id_pk_sick_child' );

end; -- end stored procedure
