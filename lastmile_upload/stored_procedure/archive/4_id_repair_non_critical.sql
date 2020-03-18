use lastmile_upload;

drop procedure if exists lastmile_upload.4_id_repair_non_critical;

/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_cha.temp_view_base_history_moh_lmh_cha_id table and the lastmile_cha.view_base_history_moh_lmh_chss_id view,
  depending on whether it's a cha or chss.
  
  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.4_id_repair_non_critical()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 4_id_repair_non_critical' );


-- Reload the table temp_view_base_history_moh_lmh_cha_id.  Note: there is no chss table, the view is fast enough for now.

drop table if exists lastmile_cha.temp_view_base_history_moh_lmh_cha_id;

create table lastmile_cha.temp_view_base_history_moh_lmh_cha_id as 
select * from lastmile_cha.view_base_history_moh_lmh_cha_id;


-- 1. non-critical: lastmile_archive table NCHAP ID updates go here.

update lastmile_archive.chwdb_odk_chw_restock set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );


update lastmile_archive.chwdb_odk_chw_restock a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.supervisedChwID = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'chwdb_odk_chw_restock' );


-- 2. non-critical: lastmile_archive.chwdb_odk_vaccine_tracker --------------------------------------- 

update lastmile_archive.chwdb_odk_vaccine_tracker set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );


update lastmile_archive.chwdb_odk_vaccine_tracker a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.chwID = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'chwdb_odk_vaccine_tracker' );



-- 3. non-critical: de_direct_observation ---------------------------------------

update lastmile_upload.de_direct_observation set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_direct_observation set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_direct_observation a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.de_direct_observation a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_direct_observation' );


-- 4. non-critical: de_register_review ---------------------------------------

update lastmile_upload.de_register_review set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_register_review set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_register_review a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.de_register_review a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_register_review' );


-- 5. non-critical: odk_FieldArrivalLogForm ---------------------------------------

update lastmile_upload.odk_FieldArrivalLogForm  set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.odk_FieldArrivalLogForm set lmh_id_inserted_format = lastmile_upload.nchap_id_format( lmh_id_inserted );


update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.SupervisedCHAID = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

-- check both cha and chss nchap id mapping table and view

update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.LMHID = if( m.cha_id_historical is null, trim( a.lmh_id_inserted_format ), m.position_id )
    
where ( trim( a.lmh_id_inserted_format ) like m.position_id ) or ( trim( a.lmh_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.LMHID = if( m.chss_id_historical is null, trim( a.lmh_id_inserted_format ), m.position_id )
    
where ( trim( a.lmh_id_inserted_format ) like m.position_id ) or ( trim( a.lmh_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_FieldArrivalLogForm' );


-- 6. non-critical: odk_FieldIncidentReportForm ---------------------------------------

update lastmile_upload.odk_FieldIncidentReportForm set id_number_inserted_format = lastmile_upload.nchap_id_format( id_number_inserted );


update lastmile_upload.odk_FieldIncidentReportForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.IDNumber = if( m.cha_id_historical is null, trim( a.id_number_inserted_format ), m.position_id )
    
where ( trim( a.id_number_inserted_format ) like m.position_id ) or ( trim( a.id_number_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.odk_FieldIncidentReportForm a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.IDNumber = if( m.chss_id_historical is null, trim( a.id_number_inserted_format ), m.position_id )
    
where ( trim( a.id_number_inserted_format ) like m.position_id ) or ( trim( a.id_number_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_FieldIncidentReportForm' );

-- 7. non-critical: odk_OSFKAPSurvey ---------------------------------------

-- There is no chss or cha id in this table.

-- non-critical: odk_QAO_CHSSQualityAssuranceForm ---------------------------------------

update lastmile_upload.odk_QAO_CHSSQualityAssuranceForm set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.odk_QAO_CHSSQualityAssuranceForm a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_QAO_CHSSQualityAssuranceForm' );


-- 8. non-critical: odk_communityEngagementLog --------------------------------------- 

update lastmile_upload.odk_communityEngagementLog       set data_collector_id_inserted_format = lastmile_upload.nchap_id_format( data_collector_id_inserted );


update lastmile_upload.odk_communityEngagementLog a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.data_collector_id = if( m.cha_id_historical is null, trim( a.data_collector_id_inserted_format ), m.position_id )
    
where ( trim( a.data_collector_id_inserted_format ) like m.position_id ) or ( trim( a.data_collector_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.odk_communityEngagementLog a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.data_collector_id = if( m.chss_id_historical is null, trim( a.data_collector_id_inserted_format ), m.position_id )
    
where ( trim( a.data_collector_id_inserted_format ) like m.position_id ) or ( trim( a.data_collector_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_communityEngagementLog' );


-- odk_osf_routine --------------------------------------- 

-- No fields contain cha or chss ids


-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 4_id_repair_non_critical' );

end; -- end stored procedure
