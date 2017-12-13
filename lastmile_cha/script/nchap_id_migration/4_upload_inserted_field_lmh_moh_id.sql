use lastmile_upload;

/*
    This module adds inserted columns to remaining upload tables 
   

    3_base_view_migrate_lmh_moh_id.sql already makes these changes to hhr and training tables, so we do not need
    to run those here.

*/

-- --------------------------------------------------------------------------------------------------------------------
--                        update cha and chss IDs on the upload tables.
-- --------------------------------------------------------------------------------------------------------------------

-- add _inserted columns here...

-- de_case_scenario --------------------------------------- check!

alter table lastmile_upload.de_case_scenario
add column cha_id_inserted varchar( 100 ) after cha_id;

alter table lastmile_upload.de_case_scenario
add column chss_id_inserted varchar( 100 ) after chss_id;

-- de_chaHouseholdRegistration --------------------------------------- check!

-- Already added _inserted columns for this table


-- de_cha_monthly_service_report --------------------------------------- check!

alter table lastmile_upload.de_cha_monthly_service_report
add column cha_id_inserted varchar( 100 ) after cha_id;

alter table lastmile_upload.de_cha_monthly_service_report
add column chss_id_inserted varchar( 100 ) after chss_id;



-- de_cha_status_change_form --------------------------------------- check!

alter table lastmile_upload.de_cha_status_change_form
add column cha_id_inserted varchar( 100 ) after cha_id;

alter table lastmile_upload.de_cha_status_change_form
add column chss_id_inserted varchar( 100 ) after chss_id;


-- de_chss_commodity_distribution --------------------------------------- check!

alter table lastmile_upload.de_chss_commodity_distribution
add column chss_id_inserted varchar( 100 ) after chss_id;



-- de_chss_monthly_service_report --------------------------------------- check!

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_1_inserted varchar( 100 ) after cha_id_1;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_2_inserted varchar( 100 ) after cha_id_2;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_3_inserted varchar( 100 ) after cha_id_3;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_4_inserted varchar( 100 ) after cha_id_4;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_5_inserted varchar( 100 ) after cha_id_5;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_6_inserted varchar( 100 ) after cha_id_6;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_7_inserted varchar( 100 ) after cha_id_7;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_8_inserted varchar( 100 ) after cha_id_8;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_9_inserted varchar( 100 ) after cha_id_9;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_10_inserted varchar( 100 ) after cha_id_10;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_11_inserted varchar( 100 ) after cha_id_11;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_12_inserted varchar( 100 ) after cha_id_12;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_13_inserted varchar( 100 ) after cha_id_13;

alter table lastmile_upload.de_chss_monthly_service_report
add column cha_id_14_inserted varchar( 100 ) after cha_id_14;


alter table lastmile_upload.de_chss_monthly_service_report
add column chss_id_inserted varchar( 100 ) after chss_id;



-- de_direct_observation --------------------------------------- check!

alter table lastmile_upload.de_direct_observation
add column cha_id_inserted varchar( 100 ) after cha_id;

alter table lastmile_upload.de_direct_observation
add column chss_id_inserted varchar( 100 ) after chss_id;



-- de_register_review --------------------------------------- check!

alter table lastmile_upload.de_register_review
add column cha_id_inserted varchar( 100 ) after cha_id;

alter table lastmile_upload.de_register_review
add column chss_id_inserted varchar( 100 ) after chss_id;



-- odk_FieldArrivalLogForm --------------------------------------- check!

alter table lastmile_upload.odk_FieldArrivalLogForm
add column cha_id_inserted varchar( 100 ) after SupervisedCHAID;

-- Need to check the xform to see what could be placed in this field.
alter table lastmile_upload.odk_FieldArrivalLogForm
add column lmh_id_inserted varchar( 100 ) after LMHID;



-- odk_FieldIncidentReportForm --------------------------------------- check!

-- Need to check the xform to see what could be placed in this field.
alter table lastmile_upload.odk_FieldIncidentReportForm
add column id_number_inserted varchar( 100 ) after IDNumber;



-- odk_OSFKAPSurvey --------------------------------------- check!

-- There is no chss or cha id in this table.

-- odk_QAO_CHSSQualityAssuranceForm --------------------------------------- check!

alter table lastmile_upload.odk_QAO_CHSSQualityAssuranceForm
add column chss_id_inserted varchar( 100 ) after chss_id;


-- odk_chaRestock --------------------------------------- check!

alter table lastmile_upload.odk_chaRestock
add column supervised_cha_id_inserted varchar( 100 ) after supervisedChaID;

alter table lastmile_upload.odk_chaRestock
add column cha_id_inserted varchar( 100 ) after chaID;

alter table lastmile_upload.odk_chaRestock
add column chss_id_inserted varchar( 100 ) after chssID;



-- odk_communityEngagementLog --------------------------------------- check!

-- not sure if chss will be filling this in.  Check against both?
alter table lastmile_upload.odk_communityEngagementLog
add column data_collector_id_inserted varchar( 100 ) after data_collector_id;



-- odk_osf_routine --------------------------------------- check!

-- No fields contain cha or chss ids

-- odk_routineVisit --------------------------------------- check!

alter table lastmile_upload.odk_routineVisit
add column cha_id_inserted varchar( 100 ) after chaID;



-- odk_sickChildForm ---------------------------------------

alter table lastmile_upload.odk_sickChildForm
add column cha_id_inserted varchar( 100 ) after chwID;



-- odk_supervisionVisitLog ---------------------------------------

alter table lastmile_upload.odk_supervisionVisitLog
add column supervised_cha_id_inserted varchar( 100 ) after supervisedCHAID;


alter table lastmile_upload.odk_supervisionVisitLog
add column cha_id_inserted varchar( 100 ) after cha_id;


alter table lastmile_upload.odk_supervisionVisitLog
add column chss_id_orig_inserted varchar( 100 ) after chssID;

alter table lastmile_upload.odk_supervisionVisitLog
add column chss_id_inserted varchar( 100 ) after chss_id;



-- odk_vaccineTracker ---------------------------------------

alter table lastmile_upload.odk_vaccineTracker
add column cha_id_inserted varchar( 100 ) after SupervisedchaID;

alter table lastmile_upload.odk_vaccineTracker
add column chss_id_inserted varchar( 100 ) after chssID;



-- What about tables in the archive schema with chw and ccs IDs?

