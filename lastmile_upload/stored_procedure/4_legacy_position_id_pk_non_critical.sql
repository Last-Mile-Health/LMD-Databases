use lastmile_upload;

drop procedure if exists lastmile_upload.4_legacy_position_id_pk_non_critical;

create procedure lastmile_upload.4_legacy_position_id_pk_non_critical()

begin

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 4_legacy_position_id_pk_non_critical' );

-- 1. critical: odk_vaccineTracker ---------------------------------------

-- alter table lastmile_upload.odk_vaccineTracker add column position_id_pk integer unsigned null after SupervisedchaID;
update lastmile_upload.odk_vaccineTracker a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.SupervisedchaID ) like m.position_id )
;

-- alter table lastmile_upload.odk_vaccineTracker add column chss_position_id_pk integer unsigned null after chssID;
update lastmile_upload.odk_vaccineTracker a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chssID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: odk_vaccineTracker' );


-- 2. lastmile_archive.chwdb_odk_chw_restock

-- alter table lastmile_archive.chwdb_odk_chw_restock add column position_id_pk integer unsigned null after supervisedChwID;
update lastmile_archive.chwdb_odk_chw_restock a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.supervisedChwID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: chwdb_odk_chw_restock' );


-- 3. non-critical: lastmile_archive.chwdb_odk_vaccine_tracker --------------------------------------- 

-- alter table lastmile_upload.odk_vaccineTracker add column position_id_pk integer unsigned null after SupervisedchaID;
update lastmile_archive.chwdb_odk_vaccine_tracker a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.chwID ) like m.position_id )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: chwdb_odk_vaccine_tracker' );


-- 4. non-critical: lastmile_archive.staging_chwMonthlyServiceReportStep1 --------------------------------------- 

-- alter table lastmile_archive.staging_chwMonthlyServiceReportStep1  add column position_id_pk integer unsigned null after chwID;
update lastmile_archive.staging_chwMonthlyServiceReportStep1 a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.chwID ) like m.position_id )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: staging_chwMonthlyServiceReportStep1' );


-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 4_legacy_position_id_pk_non_critical' );


end; -- end stored procedure
