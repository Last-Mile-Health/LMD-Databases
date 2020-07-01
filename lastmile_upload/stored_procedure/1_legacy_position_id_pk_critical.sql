use lastmile_upload;

drop procedure if exists lastmile_upload.1_legacy_position_id_pk_critical;
/*  
  Update every LMH ID (pre-nchap) cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_ncha.temp_view_history_position_position_id_cha_update table and the lastmile_ncha.temp_view_history_position_position_id_chss_update 
  view, depending on whether it's a cha or chss.  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.1_legacy_position_id_pk_critical()

begin
-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 1_legacy_position_id_pk_critical' );


-- 1. critical: de_case_scenario_2 --------------------------------------- 

-- alter table lastmile_upload.de_case_scenario_2 add column position_id_pk      integer unsigned null after cha_id;
update lastmile_upload.de_case_scenario_2 a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.cha_id ) like m.position_id )
;

-- alter table lastmile_upload.de_case_scenario_2 add column chss_position_id_pk integer unsigned null after chss_id;
update lastmile_upload.de_case_scenario_2 a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chss_id ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_case_scenario_2' );


-- 2. critical: de_case_scenario --------------------------------------- 

-- alter table lastmile_upload.de_case_scenario add column position_id_pk integer unsigned null after cha_id;
update lastmile_upload.de_case_scenario a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.cha_id ) like m.position_id )
;

-- alter table lastmile_upload.de_case_scenario add column chss_position_id_pk integer unsigned null after chss_id;
update lastmile_upload.de_case_scenario a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chss_id ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_case_scenario' );


-- 3. critical: de_chss_case_scenario ---------------------------------------


-- alter table lastmile_upload.de_chss_case_scenario add column chss_position_id_pk integer unsigned null after chss_id;
update lastmile_upload.de_chss_case_scenario a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chss_id ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_chss_case_scenario' );


-- 4. critical: de_chaHouseholdRegistration --------------------------------------- 


-- alter table lastmile_upload.de_chaHouseholdRegistration add column position_id_pk integer unsigned null after chaID;
update lastmile_upload.de_chaHouseholdRegistration a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.chaID ) like m.position_id )
;

-- alter table lastmile_upload.de_chaHouseholdRegistration add column chss_position_id_pk integer unsigned null after chssID;
update lastmile_upload.de_chaHouseholdRegistration a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chssID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_chaHouseholdRegistration' );


-- 5. critical: de_cha_monthly_service_report --------------------------------------- 

-- alter table lastmile_upload.de_cha_monthly_service_report add column position_id_pk integer unsigned null after cha_id;
update lastmile_upload.de_cha_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.cha_id ) like m.position_id )
;

-- alter table lastmile_upload.de_cha_monthly_service_report add column chss_position_id_pk integer unsigned null after chss_id;
update lastmile_upload.de_cha_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chss_id ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_cha_monthly_service_report' );


-- 6. critical: de_cha_status_change_form ---------------------------------------  

-- alter table lastmile_upload.de_cha_status_change_form add column position_id_pk integer unsigned null after cha_id;
update lastmile_upload.de_cha_status_change_form a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.cha_id ) like m.position_id )
;

-- alter table lastmile_upload.de_cha_status_change_form add column chss_position_id_pk  integer unsigned null after chss_id;
update lastmile_upload.de_cha_status_change_form a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chss_id ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_cha_status_change_form' );


-- 7. critical: de_chss_commodity_distribution --------------------------------------- 

-- alter table lastmile_upload.de_chss_commodity_distribution add column chss_position_id_pk integer unsigned null after chss_id;
update lastmile_upload.de_chss_commodity_distribution a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chss_id ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_chss_commodity_distribution' );


-- 8. critical: de_chss_monthly_service_report ---------------------------------------

-- alter table lastmile_upload.de_chss_monthly_service_report add column chss_position_id_pk integer unsigned null after chss_id;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chss_id ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_1_position_id_pk integer unsigned null after cha_id_1;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_1_position_id_pk = m.position_id_pk
    
where ( a.cha_1_position_id_pk is null ) and ( trim( a.cha_id_1 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_2_position_id_pk integer unsigned null after cha_id_2;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_2_position_id_pk = m.position_id_pk
    
where ( a.cha_2_position_id_pk is null ) and ( trim( a.cha_id_2 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_3_position_id_pk integer unsigned null after cha_id_3;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_3_position_id_pk = m.position_id_pk
    
where ( a.cha_3_position_id_pk is null ) and ( trim( a.cha_id_3 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_4_position_id_pk integer unsigned null after cha_id_4;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_4_position_id_pk = m.position_id_pk
    
where ( a.cha_4_position_id_pk is null ) and ( trim( a.cha_id_4 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_5_position_id_pk integer unsigned null after cha_id_5;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_5_position_id_pk = m.position_id_pk
    
where ( a.cha_5_position_id_pk is null ) and ( trim( a.cha_id_5 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_6_position_id_pk integer unsigned null after cha_id_6;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_6_position_id_pk = m.position_id_pk
    
where ( a.cha_6_position_id_pk is null ) and ( trim( a.cha_id_6 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_7_position_id_pk integer unsigned null after cha_id_7;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_7_position_id_pk = m.position_id_pk
    
where ( a.cha_7_position_id_pk is null ) and ( trim( a.cha_id_7 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_8_position_id_pk integer unsigned null after cha_id_8;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_8_position_id_pk = m.position_id_pk
    
where ( a.cha_8_position_id_pk is null ) and ( trim( a.cha_id_8 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_9_position_id_pk integer unsigned null after cha_id_9;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_9_position_id_pk = m.position_id_pk
    
where ( a.cha_9_position_id_pk is null ) and ( trim( a.cha_id_9 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_10_position_id_pk integer unsigned null after cha_id_10;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_10_position_id_pk = m.position_id_pk
    
where ( a.cha_10_position_id_pk is null ) and ( trim( a.cha_id_10 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_11_position_id_pk integer unsigned null after cha_id_11;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_11_position_id_pk = m.position_id_pk
    
where ( a.cha_11_position_id_pk is null ) and ( trim( a.cha_id_11 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_12_position_id_pk integer unsigned null after cha_id_12;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_12_position_id_pk = m.position_id_pk
    
where ( a.cha_12_position_id_pk is null ) and ( trim( a.cha_id_12 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_13_position_id_pk integer unsigned null after cha_id_13;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_13_position_id_pk = m.position_id_pk
    
where ( a.cha_13_position_id_pk is null ) and ( trim( a.cha_id_13 ) like m.position_id )
;

-- alter table lastmile_upload.de_chss_monthly_service_report add column cha_14_position_id_pk integer unsigned null after cha_id_14;
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_14_position_id_pk = m.position_id_pk
    
where ( a.cha_14_position_id_pk is null ) and ( trim( a.cha_id_14 ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: de_chss_monthly_service_report' );


-- 9. critical: odk_chaRestock ---------------------------------------

-- alter table lastmile_upload.odk_chaRestock add column position_id_pk integer unsigned null after chaID;
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.chaID ) like m.position_id )
;

-- alter table lastmile_upload.odk_chaRestock add column user_position_id_pk integer unsigned null after user_id;
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.user_position_id_pk = m.position_id_pk
    
where ( a.user_position_id_pk is null ) and ( trim( a.user_id ) like m.position_id )
;



-- alter table lastmile_upload.odk_chaRestock add column supervised_cha_position_id_pk integer unsigned null after supervisedChaID;
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.supervised_cha_position_id_pk = m.position_id_pk
    
where ( a.supervised_cha_position_id_pk is null ) and ( trim( a.supervisedChaID ) like m.position_id )
;

-- alter table lastmile_upload.odk_chaRestock add column chss_position_id_pk integer unsigned null after chssID;
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chssID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: odk_chaRestock' );


-- 10. critical: odk_supervisionVisitLog --------------------------------------- 

-- alter table lastmile_upload.odk_supervisionVisitLog add column position_id_pk integer unsigned null after supervisedCHAID;
update lastmile_upload.odk_supervisionVisitLog a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.supervisedCHAID ) like m.position_id )
;

-- alter table lastmile_upload.odk_supervisionVisitLog add column chss_position_id_pk  integer unsigned null after chssID;
update lastmile_upload.odk_supervisionVisitLog a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.chssID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: odk_supervisionVisitLog' );


-- 11. critical: QAO checklist

-- alter table lastmile_upload.odk_QAOSupervisionChecklistForm add column position_id_pk integer unsigned null after CHAID;
update lastmile_upload.odk_QAOSupervisionChecklistForm a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.CHAID ) like m.position_id )
;

-- alter table lastmile_upload.odk_QAOSupervisionChecklistForm add column chss_position_id_pk integer unsigned null after CHSSID;
update lastmile_upload.odk_QAOSupervisionChecklistForm a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_position_id_pk = m.position_id_pk
    
where ( a.chss_position_id_pk is null ) and ( trim( a.CHSSID ) like m.position_id )
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: odk_QAOSupervisionChecklistForm' );


-- 12. critical: QCA GPS

update lastmile_upload.odk_QCA_GPSForm a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.position_id_pk = m.position_id_pk
    
where ( a.position_id_pk is null ) and ( trim( a.Cha_id ) like m.position_id )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'LEGACY: odk_QCA_GPSForm' );



-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 1_legacy_position_id_pk_critical' );

end; -- end stored procedure
