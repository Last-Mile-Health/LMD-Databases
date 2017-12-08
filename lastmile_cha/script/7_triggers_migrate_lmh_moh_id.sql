use lastmile_upload;

-- set new.cha_id_inserted  = new.cha_id;
-- set new.chss_id_inserted = new.chss_id;

/*
    odk_OSFKAPSurvey, CHECKED!
*/

-- drop trigger if exists odk_OSFKAPSurvey_before_insert;
-- delimiter //
-- CREATE TRIGGER odk_OSFKAPSurvey_before_insert BEFORE INSERT
-- ON odk_OSFKAPSurvey
-- FOR EACH ROW
-- BEGIN
--    set new.meta_insertDatetime = now();   
    -- There is no chss or cha id in this table, nothing to back up in _inserted fields.    
-- END
-- //
-- delimiter ;

/*
    odk_osf_routine -- missing trigger
*/

-- drop trigger if exists odk_osf_routine_before_insert;
-- delimiter //
-- CREATE TRIGGER odk_osf_routine_before_insert BEFORE INSERT
-- ON odk_osf_routine
-- FOR EACH ROW
-- BEGIN
--    set new.meta_insert_date_time = now(); 
    -- There is no chss or cha id in this table, nothing to back up in _inserted fields.   
-- END
-- //
-- delimiter ;

  
/*
      odk_sickChildForm, CHECK!
*/

drop trigger if exists odk_sickChildForm_beforeInsert;

delimiter //
CREATE TRIGGER odk_sickChildForm_beforeInsert BEFORE INSERT
 ON odk_sickChildForm
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();  
    set new.cha_id_inserted  = trim( new.chwID );
    
END
//
delimiter ;


/*
    odk_chaRestock, CHECK!
*/

drop trigger if exists odk_chaRestock_beforeInsert;

delimiter //
CREATE TRIGGER odk_chaRestock_beforeInsert BEFORE INSERT
 ON odk_chaRestock
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
    
    set new.supervised_cha_id_inserted  = trim( new.supervisedChaID );
    set new.cha_id_inserted             = trim( new.chaID );
    set new.chss_id_inserted            = trim( new.chssID );
      
END
//
delimiter ;


/*
    odk_supervisionVisitLog, CHECK!
*/

drop trigger if exists odk_supervisionVisitLog_beforeInsert;

delimiter //
CREATE TRIGGER odk_supervisionVisitLog_beforeInsert BEFORE INSERT
 ON odk_supervisionVisitLog
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
               
    set new.supervised_cha_id_inserted  = trim( new.supervisedCHAID );
    set new.cha_id_inserted             = trim( new.cha_id );

    set new.chss_id_orig_inserted       = trim( new.chssID );
    set new.chss_id_inserted            = trim( new.chss_id );

END
//
delimiter ;


/*
    odk_vaccineTracker, CHECK!
*/

drop trigger if exists odk_vaccineTracker_beforeInsert;

delimiter //
CREATE TRIGGER odk_vaccineTracker_beforeInsert BEFORE INSERT
 ON odk_vaccineTracker
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
        
    set new.cha_id_inserted  = trim( new.SupervisedchaID );
    set new.chss_id_inserted = trim( new.chssID );
    
END
//
delimiter ;


/*
    odk_routineVisit, CHECK!
*/

drop trigger if exists odk_routineVisit_beforeInsert;

delimiter //
CREATE TRIGGER odk_routineVisit_beforeInsert BEFORE INSERT
 ON odk_routineVisit
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
        
    set new.cha_id_inserted  = trim( new.chaID );
    
END
//
delimiter ;


-- de_cha_monthly_service_report, CHECK!

drop trigger if exists de_cha_monthly_service_report_before_insert;

delimiter //
CREATE TRIGGER de_cha_monthly_service_report_before_insert BEFORE INSERT
 ON de_cha_monthly_service_report
 FOR EACH ROW
BEGIN

    set new.meta_insert_date_time = now();
        
    set new.cha_id_inserted  = trim( new.cha_id );
    set new.chss_id_inserted = trim( new.chss_id );

END
//
delimiter ;


-- de_chaHouseholdRegistration, CHECK!

drop trigger if exists de_chaHouseholdRegistration_beforeInsert;

delimiter //
CREATE TRIGGER de_chaHouseholdRegistration_beforeInsert BEFORE INSERT
 ON de_chaHouseholdRegistration
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
        
    set new.cha_id_inserted  = trim( new.chaID );
    set new.chss_id_inserted = trim( new.chssID );
       
END
//
delimiter ;


-- de_chss_monthly_service_report, CHECK!

drop trigger if exists de_chss_monthly_service_report_before_insert;

delimiter //
CREATE TRIGGER de_chss_monthly_service_report_before_insert BEFORE INSERT
 ON de_chss_monthly_service_report
 FOR EACH ROW
BEGIN

    set new.meta_insert_date_time = now();
    
    set new.chss_id_inserted = trim( new.chss_id );
        
    set new.cha_id_1_inserted   = trim( new.cha_id_1 );
    set new.cha_id_2_inserted   = trim( new.cha_id_2 );
    set new.cha_id_3_inserted   = trim( new.cha_id_3 );
    set new.cha_id_4_inserted   = trim( new.cha_id_4 ); 
    set new.cha_id_5_inserted   = trim( new.cha_id_5 );
    set new.cha_id_6_inserted   = trim( new.cha_id_6 );
    set new.cha_id_7_inserted   = trim( new.cha_id_7 );
    set new.cha_id_8_inserted   = trim( new.cha_id_8 );
    set new.cha_id_9_inserted   = trim( new.cha_id_9 );
    set new.cha_id_10_inserted  = trim( new.cha_id_10 );
    set new.cha_id_11_inserted  = trim( new.cha_id_11 );
    set new.cha_id_12_inserted  = trim( new.cha_id_12 );
    set new.cha_id_13_inserted  = trim( new.cha_id_13 );
    set new.cha_id_14_inserted  = trim( new.cha_id_14 );
      
END
//
delimiter ;


-- de_chss_commodity_distribution, CHECK!

drop trigger if exists de_chss_commodity_distribution_before_insert;

delimiter //
CREATE TRIGGER de_chss_commodity_distribution_before_insert BEFORE INSERT
 ON de_chss_commodity_distribution
 FOR EACH ROW
BEGIN

    set new.meta_insert_date_time = now();
       
    set new.chss_id_inserted = trim( new.chss_id );

END
//
delimiter ;


-- de_cha_status_change_form, CHECK!

drop trigger if exists de_cha_status_change_form_before_insert;

delimiter //
CREATE TRIGGER de_cha_status_change_form_before_insert BEFORE INSERT
 ON de_cha_status_change_form
 FOR EACH ROW
BEGIN

    set new.meta_insert_date_time = now();
       
    set new.cha_id_inserted  = trim( new.cha_id );
    set new.chss_id_inserted = trim( new.chss_id );

END
//
delimiter ;


/*
    odk_communityEngagementLog, CHECK!
*/

drop trigger if exists odk_communityEngagementLog_before_insert;

delimiter //
CREATE TRIGGER odk_communityEngagementLog_before_insert BEFORE INSERT
 ON odk_communityEngagementLog
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
        
    set new.data_collector_id_inserted = trim( new.data_collector_id );
    
END
//
delimiter ;


/*
    odk_QAO_CHSSQualityAssuranceForm, CHECK!
*/

drop trigger if exists odk_QAO_CHSSQualityAssuranceForm_before_insert;

delimiter //
CREATE TRIGGER odk_QAO_CHSSQualityAssuranceForm_before_insert BEFORE INSERT
 ON odk_QAO_CHSSQualityAssuranceForm
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
    
    set new.chss_id_inserted = trim( new.chss_id );
    
END
//
delimiter ;

/*
      odk_FieldArrivalLogForm, CHECK!
*/

drop trigger if exists odk_FieldArrivalLogForm_before_insert;

delimiter //
CREATE TRIGGER odk_FieldArrivalLogForm_before_insert BEFORE INSERT
 ON odk_FieldArrivalLogForm
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();
    
    set new.cha_id_inserted = trim( new.SupervisedCHAID );
    set new.lmh_id_inserted = trim( new.LMHID );
    
END
//
delimiter ;



/*
    odk_FieldIncidentReportForm, CHECK!
*/

drop trigger if exists odk_FieldIncidentReportForm_before_insert;

delimiter //
CREATE TRIGGER odk_FieldIncidentReportForm_before_insert BEFORE INSERT
 ON odk_FieldIncidentReportForm
 FOR EACH ROW
BEGIN

    set new.meta_insertDatetime = now();

    set new.id_number_inserted = trim( new.IDNumber );
    
END
//
delimiter ;

/*
de_register_review, CHECK!
*/

drop trigger if exists de_register_review_before_insert;

delimiter //
CREATE TRIGGER de_register_review_before_insert BEFORE INSERT
 ON de_register_review
 FOR EACH ROW
BEGIN

    set new.meta_insert_date_time = now();
        
    set new.cha_id_inserted  = trim( new.cha_id );
    set new.chss_id_inserted = trim( new.chss_id );

END
//
delimiter ;

/*
      de_direct_observation, CHECK!
*/

drop trigger if exists de_direct_observation_before_insert;

delimiter //
CREATE TRIGGER de_direct_observation_before_insert BEFORE INSERT
 ON de_direct_observation
 FOR EACH ROW
BEGIN

    set new.meta_insert_date_time = now();
        
    set new.cha_id_inserted  = trim( new.cha_id );
    set new.chss_id_inserted = trim( new.chss_id );

END
//
delimiter ;

/*
    de_case_scenario, COMPLETED!
*/

drop trigger if exists de_case_scenario_before_insert;

delimiter //
CREATE TRIGGER de_case_scenario_before_insert BEFORE INSERT
 ON de_case_scenario
 FOR EACH ROW
BEGIN

    set new.meta_insert_date_time = now();
    
    set new.cha_id_inserted  = trim( new.cha_id );
    set new.chss_id_inserted = trim( new.chss_id );
      
END
//
delimiter ;


