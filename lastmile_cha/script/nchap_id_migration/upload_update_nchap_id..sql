use lastmile_upload;

drop procedure if exists upload_update_nchap_id;

/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_cha.temp_view_base_history_moh_lmh_cha_id table and the lastmile_cha.view_base_history_moh_lmh_chss_id view,
  depending on whether it's a cha or chss.
  
  This procedure should be called nightly to upload the days inserted records.

*/

create procedure upload_update_nchap_id()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


-- The first thing you need to do is to reload the table temp_view_base_history_moh_lmh_cha_id.  Note: there is
-- no chss table, the view is fast enough for now.


drop table if exists lastmile_cha.temp_view_base_history_moh_lmh_cha_id;

create table lastmile_cha.temp_view_base_history_moh_lmh_cha_id as 
select * from lastmile_cha.view_base_history_moh_lmh_cha_id;


-- de_case_scenario --------------------------------------- 1.

update lastmile_upload.de_case_scenario a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.de_case_scenario a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_case_scenario' );


-- de_chaHouseholdRegistration --------------------------------------- 2.

update lastmile_upload.de_chaHouseholdRegistration g, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set g.chaID = if( m.cha_id_historical is null, trim( g.cha_id_inserted ), m.position_id )
    
where ( trim( g.cha_id_inserted ) like m.position_id ) or ( trim( g.cha_id_inserted ) like m.cha_id_historical )
;


update lastmile_upload.de_chaHouseholdRegistration g, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set g.chssID = if( m.chss_id_historical is null, trim( g.chss_id_inserted ), m.position_id )
    
where ( trim( g.chss_id_inserted ) like m.position_id ) or ( trim( g.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chaHouseholdRegistration' );

-- de_cha_monthly_service_report --------------------------------------- 3.

update lastmile_upload.de_cha_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;


update lastmile_upload.de_cha_monthly_service_report a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_cha_monthly_service_report' );

-- de_cha_status_change_form ---------------------------------------  4.

update lastmile_upload.de_cha_status_change_form a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;


update lastmile_upload.de_cha_status_change_form a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_cha_status_change_form' );

-- de_chss_commodity_distribution ---------------------------------------  5.

update lastmile_upload.de_chss_commodity_distribution a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_commodity_distribution' );

-- de_chss_monthly_service_report ---------------------------------------  6.

update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

-- CHAs 1-14 go here...

-- 1
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_1 = if( m.cha_id_historical is null, trim( a.cha_id_1_inserted ), m.position_id )
    
where ( trim( a.cha_id_1_inserted ) like m.position_id ) or ( trim( a.cha_id_1_inserted ) like m.cha_id_historical )
;

-- 2
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_2 = if( m.cha_id_historical is null, trim( a.cha_id_2_inserted ), m.position_id )
    
where ( trim( a.cha_id_2_inserted ) like m.position_id ) or ( trim( a.cha_id_2_inserted ) like m.cha_id_historical )
;

-- 3
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_3 = if( m.cha_id_historical is null, trim( a.cha_id_3_inserted ), m.position_id )
    
where ( trim( a.cha_id_3_inserted ) like m.position_id ) or ( trim( a.cha_id_3_inserted ) like m.cha_id_historical )
;

-- 4
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_4 = if( m.cha_id_historical is null, trim( a.cha_id_4_inserted ), m.position_id )
    
where ( trim( a.cha_id_4_inserted ) like m.position_id ) or ( trim( a.cha_id_4_inserted ) like m.cha_id_historical )
;

-- 5
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_5 = if( m.cha_id_historical is null, trim( a.cha_id_5_inserted ), m.position_id )
    
where ( trim( a.cha_id_5_inserted ) like m.position_id ) or ( trim( a.cha_id_5_inserted ) like m.cha_id_historical )
;

-- 6
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_6 = if( m.cha_id_historical is null, trim( a.cha_id_6_inserted ), m.position_id )
    
where ( trim( a.cha_id_6_inserted ) like m.position_id ) or ( trim( a.cha_id_6_inserted ) like m.cha_id_historical )
;

-- 7
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_7 = if( m.cha_id_historical is null, trim( a.cha_id_7_inserted ), m.position_id )
    
where ( trim( a.cha_id_7_inserted ) like m.position_id ) or ( trim( a.cha_id_7_inserted ) like m.cha_id_historical )
;

-- 8
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_8 = if( m.cha_id_historical is null, trim( a.cha_id_8_inserted ), m.position_id )
    
where ( trim( a.cha_id_8_inserted ) like m.position_id ) or ( trim( a.cha_id_8_inserted ) like m.cha_id_historical )
;

-- 9
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_9 = if( m.cha_id_historical is null, trim( a.cha_id_9_inserted ), m.position_id )
    
where ( trim( a.cha_id_9_inserted ) like m.position_id ) or ( trim( a.cha_id_9_inserted ) like m.cha_id_historical )
;

-- 10
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_10 = if( m.cha_id_historical is null, trim( a.cha_id_10_inserted ), m.position_id )
    
where ( trim( a.cha_id_10_inserted ) like m.position_id ) or ( trim( a.cha_id_10_inserted ) like m.cha_id_historical )
;

-- 11
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_11 = if( m.cha_id_historical is null, trim( a.cha_id_11_inserted ), m.position_id )
    
where ( trim( a.cha_id_11_inserted ) like m.position_id ) or ( trim( a.cha_id_11_inserted ) like m.cha_id_historical )
;

-- 12
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_12 = if( m.cha_id_historical is null, trim( a.cha_id_12_inserted ), m.position_id )
    
where ( trim( a.cha_id_12_inserted ) like m.position_id ) or ( trim( a.cha_id_12_inserted ) like m.cha_id_historical )
;

-- 13
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_13 = if( m.cha_id_historical is null, trim( a.cha_id_13_inserted ), m.position_id )
    
where ( trim( a.cha_id_13_inserted ) like m.position_id ) or ( trim( a.cha_id_13_inserted ) like m.cha_id_historical )
;

-- 14
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_14 = if( m.cha_id_historical is null, trim( a.cha_id_14_inserted ), m.position_id )
    
where ( trim( a.cha_id_14_inserted ) like m.position_id ) or ( trim( a.cha_id_14_inserted ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_monthly_service_report' );

-- de_direct_observation --------------------------------------- 7.

update lastmile_upload.de_direct_observation a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.de_direct_observation a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_direct_observation' );


-- de_register_review ---------------------------------------  8.

update lastmile_upload.de_register_review a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.de_register_review a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_register_review' );

-- odk_FieldArrivalLogForm ---------------------------------------  9.

update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.SupervisedCHAID = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

-- check both cha and chss nchap id mapping table and view

update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.LMHID = if( m.cha_id_historical is null, trim( a.lmh_id_inserted ), m.position_id )
    
where ( trim( a.lmh_id_inserted ) like m.position_id ) or ( trim( a.lmh_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.odk_FieldArrivalLogForm a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.LMHID = if( m.chss_id_historical is null, trim( a.lmh_id_inserted ), m.position_id )
    
where ( trim( a.lmh_id_inserted ) like m.position_id ) or ( trim( a.lmh_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_FieldArrivalLogForm' );


-- odk_FieldIncidentReportForm ---------------------------------------  10.

update lastmile_upload.odk_FieldIncidentReportForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.IDNumber = if( m.cha_id_historical is null, trim( a.id_number_inserted ), m.position_id )
    
where ( trim( a.id_number_inserted ) like m.position_id ) or ( trim( a.id_number_inserted ) like m.cha_id_historical )
;

update lastmile_upload.odk_FieldIncidentReportForm a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.IDNumber = if( m.chss_id_historical is null, trim( a.id_number_inserted ), m.position_id )
    
where ( trim( a.id_number_inserted ) like m.position_id ) or ( trim( a.id_number_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_FieldIncidentReportForm' );

-- odk_OSFKAPSurvey ---------------------------------------

-- There is no chss or cha id in this table.

-- odk_QAO_CHSSQualityAssuranceForm ---------------------------------------  11.

update lastmile_upload.odk_QAO_CHSSQualityAssuranceForm a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_QAO_CHSSQualityAssuranceForm' );

-- odk_chaRestock ---------------------------------------  12.

update lastmile_upload.odk_chaRestock a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.supervisedChaID = if( m.cha_id_historical is null, trim( a.supervised_cha_id_inserted ), m.position_id )
    
where ( trim( a.supervised_cha_id_inserted ) like m.position_id ) or ( trim( a.supervised_cha_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.odk_chaRestock a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.chaID = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.odk_chaRestock a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chssID = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_chaRestock' );

-- odk_communityEngagementLog ---------------------------------------  13.

update lastmile_upload.odk_communityEngagementLog a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.data_collector_id = if( m.cha_id_historical is null, trim( a.data_collector_id_inserted ), m.position_id )
    
where ( trim( a.data_collector_id_inserted ) like m.position_id ) or ( trim( a.data_collector_id_inserted ) like m.cha_id_historical )
;


update lastmile_upload.odk_communityEngagementLog a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.data_collector_id = if( m.chss_id_historical is null, trim( a.data_collector_id_inserted ), m.position_id )
    
where ( trim( a.data_collector_id_inserted ) like m.position_id ) or ( trim( a.data_collector_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_communityEngagementLog' );

-- odk_osf_routine --------------------------------------- 

-- No fields contain cha or chss ids

-- odk_routineVisit --------------------------------------- 14.

update lastmile_upload.odk_routineVisit a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.chaID = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_routineVisit' );

-- odk_sickChildForm --------------------------------------- 15.

update lastmile_upload.odk_sickChildForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.chwID = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_sickChildForm' );

-- odk_supervisionVisitLog --------------------------------------- 16.

update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.supervisedCHAID = if( m.cha_id_historical is null, trim( a.supervised_cha_id_inserted ), m.position_id )
    
where ( trim( a.supervised_cha_id_inserted ) like m.position_id ) or ( trim( a.supervised_cha_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chssID = if( m.chss_id_historical is null, trim( a.chss_id_orig_inserted ), m.position_id )
    
where ( trim( a.chss_id_orig_inserted ) like m.position_id ) or ( trim( a.chss_id_orig_inserted ) like m.chss_id_historical )
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_supervisionVisitLog' );


-- odk_vaccineTracker --------------------------------------- 17.

update lastmile_upload.odk_vaccineTracker a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.SupervisedchaID = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;


update lastmile_upload.odk_vaccineTracker a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chssID = if( m.chss_id_historical is null, trim( a.chss_id_inserted ), m.position_id )
    
where ( trim( a.chss_id_inserted ) like m.position_id ) or ( trim( a.chss_id_inserted ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_vaccineTracker' );


-- lastmile_archive table NCHAP ID updates go here.


update lastmile_archive.chwdb_odk_chw_restock a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.supervisedChwID = if( m.cha_id_historical is null, trim( a.cha_id_inserted ), m.position_id )
    
where ( trim( a.cha_id_inserted ) like m.position_id ) or ( trim( a.cha_id_inserted ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'chwdb_odk_chw_restock' );

end; -- end stored procedure

-- call upload_update_nchap_id();
