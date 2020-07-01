use lastmile_upload;

drop procedure if exists lastmile_upload.1_ncha_id_repair_critical;
/*  
  Update every cha and chss ID in the upload tables based on the value in the _inserted field.  Compare _inserted values
  against the lastmile_ncha.temp_view_history_position_position_id_cha_update table and the lastmile_ncha.temp_view_history_position_position_id_chss_update 
  view, depending on whether it's a cha or chss.  This procedure should be called nightly to upload the days inserted records.

*/

create procedure lastmile_upload.1_ncha_id_repair_critical()

begin
-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 1_ncha_id_repair_critical' );


-- 1. critical: de_case_scenario_2 --------------------------------------- 

update lastmile_upload.de_case_scenario_2 
    set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.de_case_scenario_2 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_case_scenario_2 a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id = m.position_id_nchap, a.position_id_pk = m.position_id_pk
   
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )
;

update lastmile_upload.de_case_scenario_2 a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_case_scenario_2' );


-- 2. critical: de_case_scenario --------------------------------------- 

update lastmile_upload.de_case_scenario 
    set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.de_case_scenario 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_case_scenario a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id = m.position_id_nchap, a.position_id_pk = m.position_id_pk 
 
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )
      
;    


update lastmile_upload.de_case_scenario a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_case_scenario' );



-- 3. critical: de_chss_case_scenario ---------------------------------------

update lastmile_upload.de_chss_case_scenario 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_chss_case_scenario a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_case_scenario' );




-- 4. critical: de_chaHouseholdRegistration --------------------------------------- 

update lastmile_upload.de_chaHouseholdRegistration 
    set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.de_chaHouseholdRegistration 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_chaHouseholdRegistration a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.chaID = m.position_id_nchap, a.position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap ) 
      
;  

update lastmile_upload.de_chaHouseholdRegistration a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chssID = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chaHouseholdRegistration' );



-- 5. critical: de_cha_monthly_service_report --------------------------------------- 

update lastmile_upload.de_cha_monthly_service_report 
    set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.de_cha_monthly_service_report 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_cha_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id = m.position_id_nchap, a.position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap ) 
;

update lastmile_upload.de_cha_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_cha_monthly_service_report' );




-- 6. critical: de_cha_status_change_form ---------------------------------------  

update lastmile_upload.de_cha_status_change_form 
    set cha_id_inserted_format   = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.de_cha_status_change_form 
    set chss_id_inserted_format  = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_cha_status_change_form a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id = m.position_id_nchap, a.position_id_pk = m.position_id_pk
 
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )
;      


update lastmile_upload.de_cha_status_change_form a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_cha_status_change_form' );



-- 7. critical: de_chss_commodity_distribution --------------------------------------- 

update lastmile_upload.de_chss_commodity_distribution 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_chss_commodity_distribution a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id =  m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_commodity_distribution' );


-- 8. critical: de_chss_monthly_service_report ---------------------------------------

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_1_inserted_format  = lastmile_upload.nchap_id_format( cha_id_1_inserted ), 
        cha_1_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_2_inserted_format  = lastmile_upload.nchap_id_format( cha_id_2_inserted ), 
        cha_2_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_3_inserted_format  = lastmile_upload.nchap_id_format( cha_id_3_inserted ), 
        cha_3_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_4_inserted_format  = lastmile_upload.nchap_id_format( cha_id_4_inserted ), 
        cha_4_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_5_inserted_format  = lastmile_upload.nchap_id_format( cha_id_5_inserted ), 
        cha_5_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_6_inserted_format  = lastmile_upload.nchap_id_format( cha_id_6_inserted ), 
        cha_6_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_7_inserted_format  = lastmile_upload.nchap_id_format( cha_id_7_inserted ), 
        cha_7_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_8_inserted_format  = lastmile_upload.nchap_id_format( cha_id_8_inserted ), 
        cha_8_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_9_inserted_format  = lastmile_upload.nchap_id_format( cha_id_9_inserted ), 
        cha_9_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_10_inserted_format = lastmile_upload.nchap_id_format( cha_id_10_inserted ), 
        cha_10_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_11_inserted_format = lastmile_upload.nchap_id_format( cha_id_11_inserted ), 
        cha_11_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_12_inserted_format = lastmile_upload.nchap_id_format( cha_id_12_inserted ), 
        cha_12_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_13_inserted_format = lastmile_upload.nchap_id_format( cha_id_13_inserted ), 
        cha_13_position_id_pk = null -- always set to null
;

update lastmile_upload.de_chss_monthly_service_report 
    set cha_id_14_inserted_format = lastmile_upload.nchap_id_format( cha_id_14_inserted ), 
        cha_14_position_id_pk = null -- always set to null
;



update lastmile_upload.de_chss_monthly_service_report 
    set chss_id_inserted_format   = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap
;

-- CHAs 1-14 go here...

-- 1
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_1 = m.position_id_nchap, a.cha_1_position_id_pk = m.position_id_pk

where ( trim( a.cha_id_1_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_1_inserted_format ) like m.position_id_nchap ) 
;


-- 2
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_2 =  m.position_id_nchap, a.cha_2_position_id_pk = m.position_id_pk

where ( trim( a.cha_id_2_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_2_inserted_format ) like m.position_id_nchap ) 
;


-- 3
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_3 = m.position_id_nchap, a.cha_3_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_3_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_3_inserted_format ) like m.position_id_nchap )
;  


-- 4
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_4 = m.position_id_nchap, a.cha_4_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_4_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_4_inserted_format ) like m.position_id_nchap ) 
;  


-- 5
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_5 =  m.position_id_nchap, a.cha_5_position_id_pk = m.position_id_pk 

where ( trim( a.cha_id_5_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_5_inserted_format ) like m.position_id_nchap ) 
;      


-- 6
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_6 = m.position_id_nchap, a.cha_6_position_id_pk = m.position_id_pk

where ( trim( a.cha_id_6_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_6_inserted_format ) like m.position_id_nchap )
;      


-- 7
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_7 = m.position_id_nchap, a.cha_7_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_7_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_7_inserted_format ) like m.position_id_nchap ) 
;  


-- 8
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_8 = m.position_id_nchap, a.cha_8_position_id_pk = m.position_id_pk

where ( trim( a.cha_id_8_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_8_inserted_format ) like m.position_id_nchap )  
;      


-- 9
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_9 = m.position_id_nchap, a.cha_9_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_9_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_9_inserted_format ) like m.position_id_nchap )    
;  


-- 10
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_10 = m.position_id_nchap, a.cha_10_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_10_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_10_inserted_format ) like m.position_id_nchap )   
;  


-- 11
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_11 = m.position_id_nchap, a.cha_11_position_id_pk = m.position_id_pk

where ( trim( a.cha_id_11_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_11_inserted_format ) like m.position_id_nchap )  
;      


-- 12
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_12 = m.position_id_nchap, a.cha_12_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_12_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_12_inserted_format ) like m.position_id_nchap )   
;  


-- 13
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_13 = m.position_id_nchap, a.cha_13_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_13_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_13_inserted_format ) like m.position_id_nchap )   
;  


-- 14
update lastmile_upload.de_chss_monthly_service_report a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id_14 = m.position_id_nchap, a.cha_14_position_id_pk = m.position_id_pk
    
where ( trim( a.cha_id_14_inserted_format ) like m.position_id       ) or 
      ( trim( a.cha_id_14_inserted_format ) like m.position_id_nchap )
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'de_chss_monthly_service_report' );




-- 9. critical: odk_chaRestock ---------------------------------------  12.


update lastmile_upload.odk_chaRestock 
    set cha_id_inserted_format = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.chaID = m.position_id_nchap, a.position_id_pk = m.position_id_pk
   
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )  
;


update lastmile_upload.odk_chaRestock 
    set user_id_inserted_format = lastmile_upload.nchap_id_format( user_id_inserted ), 
        user_position_id_pk = null -- always set to null
;
-- With odk release 3.3.2 in May 2018 the chss_id became obsolete and was replaced with user_id
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.user_id = m.position_id_nchap, a.user_position_id_pk = m.position_id_pk
    
where trim( a.user_id_inserted_format ) like m.position_id_nchap
;


update lastmile_upload.odk_chaRestock 
    set supervised_cha_id_inserted_format = lastmile_upload.nchap_id_format( supervised_cha_id_inserted ), 
        supervised_cha_position_id_pk = null -- always set to null
;
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.supervisedChaID = m.position_id_nchap, a.supervised_cha_position_id_pk = m.position_id_pk
    
where ( trim( a.supervised_cha_id_inserted_format ) like m.position_id        ) or
      ( trim( a.supervised_cha_id_inserted_format ) like m.position_id_nchap  )
;


update lastmile_upload.odk_chaRestock 
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;
-- Keep updating this field for as long as odk 3.3.1 restock records keep coming in.
update lastmile_upload.odk_chaRestock a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chssID = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap   
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_chaRestock' );



-- 10. critical: odk_supervisionVisitLog --------------------------------------- 16.

-- update lastmile_upload.odk_supervisionVisitLog set chss_id_inserted_format           = lastmile_upload.nchap_id_format( chss_id_inserted );
-- update lastmile_upload.odk_supervisionVisitLog set cha_id_inserted_format            = lastmile_upload.nchap_id_format( cha_id_inserted );


update lastmile_upload.odk_supervisionVisitLog 
    set supervised_cha_id_inserted_format = lastmile_upload.nchap_id_format( supervised_cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.odk_supervisionVisitLog 
    set chss_id_orig_inserted_format      = lastmile_upload.nchap_id_format( chss_id_orig_inserted ), 
        chss_position_id_pk = null -- always set to null
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.supervisedCHAID = m.position_id_nchap, a.position_id_pk = m.position_id_pk 
    
where ( trim( a.supervised_cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.supervised_cha_id_inserted_format ) like m.position_id_nchap )      
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chssID = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_orig_inserted_format ) like m.position_id_nchap         
;


/* ***
update lastmile_upload.odk_supervisionVisitLog a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.cha_id = m.position_id_nchap
      
where ( trim( a.cha_id_inserted_format ) like m.position_id_nchap  ) or 
      ( trim( a.cha_id_inserted_format ) like m.position_id       )
;

update lastmile_upload.odk_supervisionVisitLog a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.chss_id = m.position_id
    
where trim( a.chss_id_inserted_format ) like m.position_id
;
*** */

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_supervisionVisitLog' );


-- 11. critical: QAO checklist

update lastmile_upload.odk_QAOSupervisionChecklistForm  
    set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;
update lastmile_upload.odk_QAOSupervisionChecklistForm  
    set chss_id_inserted_format = lastmile_upload.nchap_id_format( chss_id_inserted ), 
        chss_position_id_pk = null -- always set to null
;


update lastmile_upload.odk_QAOSupervisionChecklistForm a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.CHAID = m.position_id_nchap, a.position_id_pk = m.position_id_pk
        
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )  
;

update lastmile_upload.odk_QAOSupervisionChecklistForm a, lastmile_ncha.temp_view_history_position_position_id_chss_update m

    set a.CHSSID = m.position_id_nchap, a.chss_position_id_pk = m.position_id_pk
    
where trim( a.chss_id_inserted_format ) like m.position_id_nchap        
;


insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_QAOSupervisionChecklistForm' );


-- 12. critical: QCA GPS

update lastmile_upload.odk_QCA_GPSForm  
    set cha_id_inserted_format  = lastmile_upload.nchap_id_format( cha_id_inserted ), 
        position_id_pk = null -- always set to null
;

update lastmile_upload.odk_QCA_GPSForm a, lastmile_ncha.temp_view_history_position_position_id_cha_update m

    set a.Cha_id = m.position_id_nchap, a.position_id_pk = m.position_id_pk
        
where ( trim( a.cha_id_inserted_format ) like m.position_id       ) or
      ( trim( a.cha_id_inserted_format ) like m.position_id_nchap )  
;

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'odk_QCA_GPSForm' );



-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 1_ncha_id_repair_critical' );

end; -- end stored procedure
