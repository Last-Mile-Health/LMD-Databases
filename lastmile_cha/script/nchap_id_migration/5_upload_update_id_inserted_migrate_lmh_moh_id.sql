use lastmile_upload;

/*
    This module is a one shot update of the cha and chss IDs into their [cha, chss]_id_inserted fields.  
    Note: The trigger code will do this on every insert going forward, so it can be adapted into the triggers.

*/

-- de_case_scenario --------------------------------------- 

update lastmile_upload.de_case_scenario
  set cha_id_inserted = trim( cha_id )
;

update lastmile_upload.de_case_scenario
  set chss_id_inserted = trim( chss_id )
;

-- de_chaHouseholdRegistration ---------------------------------------  

-- Already added _inserted columns for this table

-- de_cha_monthly_service_report ---------------------------------------  

update lastmile_upload.de_cha_monthly_service_report
  set cha_id_inserted = trim( cha_id )
;
update lastmile_upload.de_cha_monthly_service_report
  set chss_id_inserted = trim( chss_id )
;

-- de_cha_status_change_form ---------------------------------------  

update lastmile_upload.de_cha_status_change_form
  set cha_id_inserted = trim( cha_id )
;
update lastmile_upload.de_cha_status_change_form
  set chss_id_inserted = trim( chss_id )
;

-- de_chss_commodity_distribution ---------------------------------------  

update lastmile_upload.de_chss_commodity_distribution
  set chss_id_inserted = trim( chss_id )
;

-- de_chss_monthly_service_report ---------------------------------------  

update lastmile_upload.de_chss_monthly_service_report
  set chss_id_inserted = trim( chss_id )
;

-- CHAs 1-14 go here...

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_1_inserted = trim( cha_id_1 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_2_inserted = trim( cha_id_2 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_3_inserted = trim( cha_id_3 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_4_inserted = trim( cha_id_4 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_5_inserted = trim( cha_id_5 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_6_inserted = trim( cha_id_6 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_7_inserted = trim( cha_id_7 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_8_inserted = trim( cha_id_8 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_9_inserted = trim( cha_id_9 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_10_inserted = trim( cha_id_10 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_11_inserted = trim( cha_id_11 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_12_inserted = trim( cha_id_12 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_13_inserted = trim( cha_id_13 )
;

update lastmile_upload.de_chss_monthly_service_report
  set cha_id_14_inserted = trim( cha_id_14 )
;

-- de_direct_observation ---------------------------------------  

update lastmile_upload.de_direct_observation
  set cha_id_inserted = trim( cha_id )
;

update lastmile_upload.de_direct_observation
  set chss_id_inserted = trim( chss_id )
;

-- de_register_review ---------------------------------------  

update lastmile_upload.de_register_review
  set cha_id_inserted = trim( cha_id )
;

update lastmile_upload.de_register_review
  set chss_id_inserted = trim( chss_id )
;

-- odk_FieldArrivalLogForm ---------------------------------------  

update lastmile_upload.odk_FieldArrivalLogForm
  set cha_id_inserted = trim( SupervisedCHAID )
;

update lastmile_upload.odk_FieldArrivalLogForm
  set lmh_id_inserted = trim( LMHID )
;

-- odk_FieldIncidentReportForm ---------------------------------------  

update lastmile_upload.odk_FieldIncidentReportForm
  set id_number_inserted = trim( IDNumber )
;

-- odk_OSFKAPSurvey ---------------------------------------  

-- There is no chss or cha id in this table.

-- odk_QAO_CHSSQualityAssuranceForm ---------------------------------------  

update lastmile_upload.odk_QAO_CHSSQualityAssuranceForm
  set chss_id_inserted = trim( chss_id )
;

-- odk_chaRestock ---------------------------------------  

update lastmile_upload.odk_chaRestock
  set supervised_cha_id_inserted = trim( supervisedChaID )
;

update lastmile_upload.odk_chaRestock
  set cha_id_inserted = trim( chaID )
;

update lastmile_upload.odk_chaRestock
  set chss_id_inserted = trim( chssID )
;

-- odk_communityEngagementLog ---------------------------------------  

update lastmile_upload.odk_communityEngagementLog
  set data_collector_id_inserted = trim( data_collector_id )
;

-- odk_osf_routine --------------------------------------- 

-- No fields contain cha or chss ids

-- odk_routineVisit --------------------------------------- 

update lastmile_upload.odk_routineVisit
  set cha_id_inserted = trim( chaID )
;

-- odk_sickChildForm ---------------------------------------

update lastmile_upload.odk_sickChildForm
  set cha_id_inserted = trim( chwID )
;

-- odk_supervisionVisitLog ---------------------------------------

update lastmile_upload.odk_supervisionVisitLog
  set supervised_cha_id_inserted = trim( supervisedCHAID )
;

update lastmile_upload.odk_supervisionVisitLog
  set cha_id_inserted = trim( cha_id )
;

update lastmile_upload.odk_supervisionVisitLog
  set chss_id_orig_inserted = trim( chssID )
;

update lastmile_upload.odk_supervisionVisitLog
  set chss_id_inserted = trim( chss_id )
;

-- odk_vaccineTracker ---------------------------------------

update lastmile_upload.odk_vaccineTracker
  set cha_id_inserted = trim( SupervisedchaID )
;

update lastmile_upload.odk_vaccineTracker
  set chss_id_inserted = trim( chssID )
;

-- What about tables in the archive schema with chw and ccs IDs?

