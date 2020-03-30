use lastmile_upload;

drop procedure if exists lastmile_upload.4_ncha_id_repair_non_critical;
/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_ncha.temp_view_history_position_position_id_cha_update table and the lastmile_ncha.temp_view_history_position_position_id_chss_update 
  view, depending on whether it's a cha or chss.  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.4_ncha_id_repair_non_critical()

begin

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 4_ncha_id_repair_non_critical' );

-- 1. critical: odk_vaccineTracker ---------------------------------------

update lastmile_upload.odk_vaccineTracker 
    set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.odk_vaccineTracker 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.odk_vaccineTracker a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.SupervisedchaID = m.position_id_nchap, a.position_id_pk = m.position_id_pk
        
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )   
;


update lastmile_upload.odk_vaccineTracker a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chssID = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap        
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_vaccineTracker' );



-- 2. lastmile_archive.chwdb_odk_chw_restock

update lastmile_archive.chwdb_odk_chw_restock 
    set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted ), position_id_pk = null;
        

update lastmile_archive.chwdb_odk_chw_restock a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.supervisedChwID = m.position_id_nchap, a.position_id_pk = m.position_id_pk 
    
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'chwdb_odk_chw_restock' );



-- 3. non-critical: lastmile_archive.chwdb_odk_vaccine_tracker --------------------------------------- 

-- added cha_id_original

update lastmile_archive.chwdb_odk_vaccine_tracker 
    set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted ), position_id_pk = null;


update lastmile_archive.chwdb_odk_vaccine_tracker a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.chwID = m.position_id_nchap, a.position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'chwdb_odk_vaccine_tracker' );


-- 4. non-critical: lastmile_archive.staging_chwMonthlyServiceReportStep1 --------------------------------------- 

update lastmile_archive.staging_chwMonthlyServiceReportStep1 
    set cha_id_inserted_format = lastmile_upload.nchap_id_format( chwID_inserted ), position_id_pk = null;


update lastmile_archive.staging_chwMonthlyServiceReportStep1 a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.chwID = m.position_id_nchap, a.position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'staging_chwMonthlyServiceReportStep1' );




-- 3. non-critical: de_direct_observation ---------------------------------------

/* * No longer updating this table.  Only contains 7 records that are over 2 years old.
   * Owen 3/13/2020
   
update lastmile_upload.de_direct_observation set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_direct_observation set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_direct_observation a, lastmile_ncha.temp_view_person_position_cha_id_update m

    set a.cha_id = m.position_id_last
    
where ( trim( a.cha_id_inserted_format ) like m.position_id_last  ) or 
      ( trim( a.cha_id_inserted_format ) like m.position_id       )
;


update lastmile_upload.de_direct_observation a, lastmile_ncha.temp_view_person_position_chss_id_update m

    set a.chss_id = m.position_id
    
where trim( a.chss_id_inserted_format ) like m.position_id 
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_direct_observation' );

*** */

-- 4. non-critical: de_register_review ---------------------------------------

/* * No longer updating this table.  Only contains 55 records that are over 2 years old.
   * Owen 3/13/2020

update lastmile_upload.de_register_review set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_register_review set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_register_review a, lastmile_ncha.temp_view_person_position_cha_id_update m

    set a.cha_id = m.position_id_last
    
where ( trim( a.cha_id_inserted_format ) like m.position_id_last  ) or 
      ( trim( a.cha_id_inserted_format ) like m.position_id       )
;


update lastmile_upload.de_register_review a, lastmile_ncha.temp_view_person_position_chss_id_update m

    set a.chss_id = m.position_id 
    
where trim( a.chss_id_inserted_format ) like m.position_id
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_register_review' );

*/

-- 5. non-critical: odk_FieldArrivalLogForm ---------------------------------------

/* * No longer updating this table.  Zero records.
   * Owen 3/13/2020


update lastmile_upload.odk_FieldArrivalLogForm  set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.odk_FieldArrivalLogForm set lmh_id_inserted_format = lastmile_upload.nchap_id_format( lmh_id_inserted );


update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_ncha.temp_view_person_position_cha_id_update m

    set a.SupervisedCHAID = m.position_id_last
    
where ( trim( a.cha_id_inserted_format ) like m.position_id_last  ) or 
      ( trim( a.cha_id_inserted_format ) like m.position_id       ) 
;


-- check both cha and chss nchap id mapping table and view

update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_ncha.temp_view_person_position_cha_id_update m

    set a.LMHID = m.position_id_last 

where ( trim( a.cha_id_inserted_format ) like m.position_id_last  ) or 
      ( trim( a.cha_id_inserted_format ) like m.position_id       )
;    


update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_ncha.temp_view_person_position_chss_id_update m

    set a.LMHID = m.position_id 
    
where trim( a.lmh_id_inserted_format ) like m.position_id         
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_FieldArrivalLogForm' );

*/

-- 6. non-critical: odk_FieldIncidentReportForm ---------------------------------------

/* * No longer updating this table.  Zero records.
   * Owen 3/13/2020


update lastmile_upload.odk_FieldIncidentReportForm set id_number_inserted_format = lastmile_upload.nchap_id_format( id_number_inserted );


update lastmile_upload.odk_FieldIncidentReportForm a, lastmile_ncha.temp_view_person_position_cha_id_update m

    set a.IDNumber = m.position_id_last
    
where ( trim( a.id_number_inserted_format ) like m.position_id_last  ) or 
      ( trim( a.id_number_inserted_format ) like m.position_id       )
;


update lastmile_upload.odk_FieldIncidentReportForm a, lastmile_ncha.temp_view_person_position_chss_id_update m

    set a.IDNumber = m.position_id
    
where trim( a.id_number_inserted_format ) like m.position_id
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_FieldIncidentReportForm' );

*/

-- 7. non-critical: odk_OSFKAPSurvey ---------------------------------------

-- There is no chss or cha id in this table.


-- 8. non-critical: odk_QAO_CHSSQualityAssuranceForm ---------------------------------------

/* * No longer updating this table.  Zero records.
   * Owen 3/13/2020

update lastmile_upload.odk_QAO_CHSSQualityAssuranceForm set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.odk_QAO_CHSSQualityAssuranceForm a, lastmile_ncha.temp_view_person_position_chss_id_update m

    set a.chss_id = m.position_id
    
where trim( a.chss_id_inserted_format ) like m.position_id
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_QAO_CHSSQualityAssuranceForm' );

*/

-- 9. non-critical: odk_communityEngagementLog --------------------------------------- 

/* * No longer updating this table.  Only contains 1 records over 2 years old.
   * Owen 3/13/2020

update lastmile_upload.odk_communityEngagementLog set data_collector_id_inserted_format = lastmile_upload.nchap_id_format( data_collector_id_inserted );

update lastmile_upload.odk_communityEngagementLog a, lastmile_ncha.temp_view_person_position_cha_id_update m

    set a.data_collector_id = m.position_id_last

where ( trim( a.data_collector_id_inserted_format ) like m.position_id_last  ) or 
      ( trim( a.data_collector_id_inserted_format ) like m.position_id       )
;


update lastmile_upload.odk_communityEngagementLog a, lastmile_ncha.temp_view_person_position_chss_id_update m

    set a.data_collector_id = m.position_id 
    
where trim( a.data_collector_id_inserted_format ) like m.position_id       
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_communityEngagementLog' );

*/

-- odk_osf_routine --------------------------------------- 

-- No fields contain cha or chss ids




-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 4_ncha_id_repair_non_critical' );

end; -- end stored procedure
