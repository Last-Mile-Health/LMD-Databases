use lastmile_upload;

drop procedure if exists lastmile_upload.1_id_repair_critical;

/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_cha.temp_view_base_history_moh_lmh_cha_id table and the lastmile_cha.view_base_history_moh_lmh_chss_id view,
  depending on whether it's a cha or chss.
  
  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.1_id_repair_critical()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 1_id_repair_critical' );


-- Reload the table temp_view_base_history_moh_lmh_cha_id.  Note: there is no chss table, the view is fast enough for now.

drop table if exists lastmile_cha.temp_view_base_history_moh_lmh_cha_id;

create table lastmile_cha.temp_view_base_history_moh_lmh_cha_id as 
select * from lastmile_cha.view_base_history_moh_lmh_cha_id;



-- 1. critical: de_case_scenario_2 --------------------------------------- 

update lastmile_upload.de_case_scenario_2 set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_case_scenario_2 set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_case_scenario_2 a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.de_case_scenario_2 a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_case_scenario_2' );


-- 1. critical: de_case_scenario --------------------------------------- 

update lastmile_upload.de_case_scenario set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_case_scenario set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_case_scenario a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.de_case_scenario a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_case_scenario' );


-- 2. critical: de_chss_case_scenario ---------------------------------------

update lastmile_upload.de_chss_case_scenario set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_chss_case_scenario a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_case_scenario' );


-- 3. critical: de_chaHouseholdRegistration --------------------------------------- 

update lastmile_upload.de_chaHouseholdRegistration set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_chaHouseholdRegistration set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_chaHouseholdRegistration g, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set g.chaID = if( m.cha_id_historical is null, trim( g.cha_id_inserted_format ), m.position_id )
    
where ( trim( g.cha_id_inserted_format ) like m.position_id ) or ( trim( g.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.de_chaHouseholdRegistration g, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set g.chssID = if( m.chss_id_historical is null, trim( g.chss_id_inserted_format ), m.position_id )
    
where ( trim( g.chss_id_inserted_format ) like m.position_id ) or ( trim( g.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chaHouseholdRegistration' );


-- 4. critical: de_cha_monthly_service_report --------------------------------------- 

update lastmile_upload.de_cha_monthly_service_report set cha_id_inserted_format   = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_cha_monthly_service_report set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_cha_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.de_cha_monthly_service_report a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_cha_monthly_service_report' );


-- 5. critical: de_cha_status_change_form ---------------------------------------  

update lastmile_upload.de_cha_status_change_form set cha_id_inserted_format   = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.de_cha_status_change_form set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_cha_status_change_form a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;


update lastmile_upload.de_cha_status_change_form a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_cha_status_change_form' );


-- 6. critical: de_chss_commodity_distribution --------------------------------------- 

update lastmile_upload.de_chss_commodity_distribution set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_chss_commodity_distribution a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_commodity_distribution' );


-- 7. critical: de_chss_monthly_service_report ---------------------------------------

update lastmile_upload.de_chss_monthly_service_report set cha_id_1_inserted_format  = lastmile_upload.nchap_id_format( cha_id_1_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_2_inserted_format  = lastmile_upload.nchap_id_format( cha_id_2_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_3_inserted_format  = lastmile_upload.nchap_id_format( cha_id_3_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_4_inserted_format  = lastmile_upload.nchap_id_format( cha_id_4_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_5_inserted_format  = lastmile_upload.nchap_id_format( cha_id_5_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_6_inserted_format  = lastmile_upload.nchap_id_format( cha_id_6_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_7_inserted_format  = lastmile_upload.nchap_id_format( cha_id_7_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_8_inserted_format  = lastmile_upload.nchap_id_format( cha_id_8_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_9_inserted_format  = lastmile_upload.nchap_id_format( cha_id_9_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_10_inserted_format = lastmile_upload.nchap_id_format( cha_id_10_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_11_inserted_format = lastmile_upload.nchap_id_format( cha_id_11_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_12_inserted_format = lastmile_upload.nchap_id_format( cha_id_12_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_13_inserted_format = lastmile_upload.nchap_id_format( cha_id_13_inserted );

update lastmile_upload.de_chss_monthly_service_report set cha_id_14_inserted_format = lastmile_upload.nchap_id_format( cha_id_14_inserted );


update lastmile_upload.de_chss_monthly_service_report set chss_id_inserted_format   = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

-- CHAs 1-14 go here...

-- 1
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_1 = if( m.cha_id_historical is null, trim( a.cha_id_1_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_1_inserted_format ) like m.position_id ) or ( trim( a.cha_id_1_inserted_format ) like m.cha_id_historical )
;

-- 2
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_2 = if( m.cha_id_historical is null, trim( a.cha_id_2_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_2_inserted_format ) like m.position_id ) or ( trim( a.cha_id_2_inserted_format ) like m.cha_id_historical )
;

-- 3
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_3 = if( m.cha_id_historical is null, trim( a.cha_id_3_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_3_inserted_format ) like m.position_id ) or ( trim( a.cha_id_3_inserted_format ) like m.cha_id_historical )
;

-- 4
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_4 = if( m.cha_id_historical is null, trim( a.cha_id_4_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_4_inserted_format ) like m.position_id ) or ( trim( a.cha_id_4_inserted_format ) like m.cha_id_historical )
;

-- 5
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_5 = if( m.cha_id_historical is null, trim( a.cha_id_5_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_5_inserted_format ) like m.position_id ) or ( trim( a.cha_id_5_inserted_format ) like m.cha_id_historical )
;

-- 6
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_6 = if( m.cha_id_historical is null, trim( a.cha_id_6_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_6_inserted_format ) like m.position_id ) or ( trim( a.cha_id_6_inserted_format ) like m.cha_id_historical )
;

-- 7
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_7 = if( m.cha_id_historical is null, trim( a.cha_id_7_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_7_inserted_format ) like m.position_id ) or ( trim( a.cha_id_7_inserted_format ) like m.cha_id_historical )
;

-- 8
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_8 = if( m.cha_id_historical is null, trim( a.cha_id_8_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_8_inserted_format ) like m.position_id ) or ( trim( a.cha_id_8_inserted_format ) like m.cha_id_historical )
;

-- 9
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_9 = if( m.cha_id_historical is null, trim( a.cha_id_9_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_9_inserted_format ) like m.position_id ) or ( trim( a.cha_id_9_inserted_format ) like m.cha_id_historical )
;

-- 10
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_10 = if( m.cha_id_historical is null, trim( a.cha_id_10_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_10_inserted_format ) like m.position_id ) or ( trim( a.cha_id_10_inserted_format ) like m.cha_id_historical )
;

-- 11
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_11 = if( m.cha_id_historical is null, trim( a.cha_id_11_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_11_inserted_format ) like m.position_id ) or ( trim( a.cha_id_11_inserted_format ) like m.cha_id_historical )
;

-- 12
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_12 = if( m.cha_id_historical is null, trim( a.cha_id_12_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_12_inserted_format ) like m.position_id ) or ( trim( a.cha_id_12_inserted_format ) like m.cha_id_historical )
;

-- 13
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_13 = if( m.cha_id_historical is null, trim( a.cha_id_13_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_13_inserted_format ) like m.position_id ) or ( trim( a.cha_id_13_inserted_format ) like m.cha_id_historical )
;

-- 14
update lastmile_upload.de_chss_monthly_service_report a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id_14 = if( m.cha_id_historical is null, trim( a.cha_id_14_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_14_inserted_format ) like m.position_id ) or ( trim( a.cha_id_14_inserted_format ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_monthly_service_report' );


-- 8. critical: odk_chaRestock ---------------------------------------  12.

update lastmile_upload.odk_chaRestock set supervised_cha_id_inserted_format = lastmile_upload.nchap_id_format( supervised_cha_id_inserted );

update lastmile_upload.odk_chaRestock set cha_id_inserted_format            = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.odk_chaRestock set user_id_inserted_format           = lastmile_upload.nchap_id_format( user_id_inserted );

update lastmile_upload.odk_chaRestock set chss_id_inserted_format           = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.odk_chaRestock a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.supervisedChaID = if( m.cha_id_historical is null, trim( a.supervised_cha_id_inserted_format ), m.position_id )
    
where ( trim( a.supervised_cha_id_inserted_format ) like m.position_id ) or ( trim( a.supervised_cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.odk_chaRestock a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.chaID = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

-- With odk release 3.3.2 in May 2018 the chss_id became obsolete and was replaced with user_id
update lastmile_upload.odk_chaRestock a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.user_id = if( m.chss_id_historical is null, trim( a.user_id_inserted_format ), m.position_id )
    
where ( trim( a.user_id_inserted_format ) like m.position_id ) or ( trim( a.user_id_inserted_format ) like m.chss_id_historical )
;

-- Keep updating this field for as long as odk 3.3.1 restock records keep coming in.
update lastmile_upload.odk_chaRestock a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chssID = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_chaRestock' );


-- 9. critical: odk_supervisionVisitLog --------------------------------------- 16.

update lastmile_upload.odk_supervisionVisitLog set supervised_cha_id_inserted_format = lastmile_upload.nchap_id_format( supervised_cha_id_inserted );

update lastmile_upload.odk_supervisionVisitLog set cha_id_inserted_format            = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.odk_supervisionVisitLog set chss_id_orig_inserted_format      = lastmile_upload.nchap_id_format( chss_id_orig_inserted );

update lastmile_upload.odk_supervisionVisitLog set chss_id_inserted_format           = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.supervisedCHAID = if( m.cha_id_historical is null, trim( a.supervised_cha_id_inserted_format ), m.position_id )
    
where ( trim( a.supervised_cha_id_inserted_format ) like m.position_id ) or ( trim( a.supervised_cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.cha_id = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chssID = if( m.chss_id_historical is null, trim( a.chss_id_orig_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_orig_inserted_format ) like m.position_id ) or ( trim( a.chss_id_orig_inserted_format ) like m.chss_id_historical )
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chss_id = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_supervisionVisitLog' );


-- 10. critical: odk_vaccineTracker --------------------------------------- 17.

update lastmile_upload.odk_vaccineTracker               set cha_id_inserted_format            = lastmile_upload.nchap_id_format( cha_id_inserted );

update lastmile_upload.odk_vaccineTracker               set chss_id_inserted_format           = lastmile_upload.nchap_id_format( chss_id_inserted );


update lastmile_upload.odk_vaccineTracker a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.SupervisedchaID = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

update lastmile_upload.odk_vaccineTracker a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.chssID = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_vaccineTracker' );


-- 11. critical: QAO checklist

update lastmile_upload.odk_QAOSupervisionChecklistForm  set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted );

update lastmile_upload.odk_QAOSupervisionChecklistForm  set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted );


update lastmile_upload.odk_QAOSupervisionChecklistForm a, lastmile_cha.view_base_history_moh_lmh_chss_id m

    set a.CHSSID = if( m.chss_id_historical is null, trim( a.chss_id_inserted_format ), m.position_id )
    
where ( trim( a.chss_id_inserted_format ) like m.position_id ) or ( trim( a.chss_id_inserted_format ) like m.chss_id_historical )
;

update lastmile_upload.odk_QAOSupervisionChecklistForm a, lastmile_cha.temp_view_base_history_moh_lmh_cha_id m

    set a.CHAID = if( m.cha_id_historical is null, trim( a.cha_id_inserted_format ), m.position_id )
    
where ( trim( a.cha_id_inserted_format ) like m.position_id ) or ( trim( a.cha_id_inserted_format ) like m.cha_id_historical )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_QAOSupervisionChecklistForm' );


-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 1_id_repair_critical' );

end; -- end stored procedure
