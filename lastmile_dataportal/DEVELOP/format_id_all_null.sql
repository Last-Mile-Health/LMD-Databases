-- null out every format field and actual ID

-- 1. -------------------------------------------------------------------------------


-- 263 rows
select 
      de_case_scenario_2_id, 
      cha_id, cha_id_original, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_de_case_scenario_2
union
select 
      de_case_scenario_2_id, 
      cha_id, cha_id_original, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.ncha_de_case_scenario_2
;

-- 405 rows
select 
      de_case_scenario_id, 
      cha_id, cha_id_original, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_de_case_scenario
union
select 
      de_case_scenario_id, 
      cha_id, cha_id_original, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.ncha_de_case_scenario
;

-- 38
select 
      de_chss_case_scenario_id, 
      -- cha_id, cha_id_original, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_de_chss_case_scenario
union
select 
      de_chss_case_scenario_id, 
       chss_id
      -- cha_id, cha_id_original, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.ncha_de_chss_case_scenario
;

-- 1555 rows
select 
       chaHouseholdRegistrationID,
       chaID, cha_id_original, cha_id_inserted, cha_id_inserted_format,
       chssID, 
       chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_de_chaHouseholdRegistration 
union
select 
       chaHouseholdRegistrationID,
       chaID, cha_id_original, cha_id_inserted, cha_id_inserted_format,
       chssID, 
       chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.ncha_de_chaHouseholdRegistration
;

-- 14530 rows
select 
    cha_monthly_service_report_id, 
    cha_id_original, cha_id_inserted, cha_id_inserted_format, cha_id, 
    chss_id_original, chss_id_inserted, chss_id_inserted_format, chss_id
from lastmile_scratchpad.cha_de_cha_monthly_service_report 
union 
select 
    cha_monthly_service_report_id, 
    cha_id_original, cha_id_inserted, cha_id_inserted_format, cha_id, 
    chss_id_original, chss_id_inserted, chss_id_inserted_format, chss_id
from lastmile_scratchpad.ncha_de_cha_monthly_service_report
;

-- 48 rows
select 
      de_cha_status_change_form_id,
      cha_id, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_de_cha_status_change_form  
union
select 
      de_cha_status_change_form_id,
      cha_id, cha_id_inserted, cha_id_inserted_format, 
      chss_id, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.ncha_de_cha_status_change_form 
;


-- 1093 rows
select
     chss_commodity_distribution_id,
     chss_id, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_de_chss_commodity_distribution  
union
select
     chss_commodity_distribution_id,
     chss_id, chss_id_inserted, chss_id_inserted_format
from 
lastmile_scratchpad.ncha_de_chss_commodity_distribution
;

-- 11635 rows
select
    chaRestockID  
    chaID,            cha_id_original,            cha_id_inserted,            cha_id_inserted_format,
    supervisedChaID,  supervised_cha_id_original, supervised_cha_id_inserted, supervised_cha_id_inserted_format,
    chssID, chss_id_original, chss_id_inserted, chss_id_inserted_format,
    user_id, user_id_original, user_id_inserted, user_id_inserted_format
from lastmile_scratchpad.cha_odk_chaRestock
union
select
    chaRestockID  
    chaID,            cha_id_original,            cha_id_inserted,            cha_id_inserted_format,
    supervisedChaID,  supervised_cha_id_original, supervised_cha_id_inserted, supervised_cha_id_inserted_format,
    chssID, chss_id_original, chss_id_inserted, chss_id_inserted_format,
    user_id, user_id_original, user_id_inserted, user_id_inserted_format
from lastmile_scratchpad.ncha_odk_chaRestock
;


-- 20372 rows
select
      supervisionVisitLogID,
      supervisedCHAID, supervised_cha_id_original, supervised_cha_id_inserted, supervised_cha_id_inserted_format, 
      chssID, chss_id_orig_original, chss_id_orig_inserted, chss_id_orig_inserted_format
from lastmile_scratchpad.cha_odk_supervisionVisitLog
union
select
      supervisionVisitLogID,
      supervisedCHAID, supervised_cha_id_original, supervised_cha_id_inserted, supervised_cha_id_inserted_format, 
      chssID, chss_id_orig_original, chss_id_orig_inserted, chss_id_orig_inserted_format
from lastmile_scratchpad.ncha_odk_supervisionVisitLog
;

-- 1610 rows
select
      odk_QAOSupervisionChecklistForm_id,
      CHAID, cha_id_original, cha_id_inserted, cha_id_inserted_format,
      CHSSID, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_odk_QAOSupervisionChecklistForm
union
select
      odk_QAOSupervisionChecklistForm_id,
      CHAID, cha_id_original, cha_id_inserted, cha_id_inserted_format,
      CHSSID, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.ncha_odk_QAOSupervisionChecklistForm
;


-- 1027 rows
select 
      chss_monthly_service_report_id, 
      chss_id_original, chss_id_inserted, chss_id_inserted_format, chss_id,       
      cha_id_1_original, cha_id_1_inserted, cha_id_1_inserted_format, cha_id_1, 
      cha_id_2_original, cha_id_2_inserted, cha_id_2_inserted_format, cha_id_2, 
      cha_id_3_original, cha_id_3_inserted, cha_id_3_inserted_format, cha_id_3,  
      cha_id_4_original, cha_id_4_inserted, cha_id_4_inserted_format, cha_id_4,  
      cha_id_5_original, cha_id_5_inserted, cha_id_5_inserted_format, cha_id_5, 
      cha_id_6_original, cha_id_6_inserted, cha_id_6_inserted_format, cha_id_6, 
      cha_id_7_original, cha_id_7_inserted, cha_id_7_inserted_format, cha_id_7,  
      cha_id_8_original, cha_id_8_inserted, cha_id_8_inserted_format, cha_id_8,  
      cha_id_9_original, cha_id_9_inserted, cha_id_9_inserted_format, cha_id_9,
      cha_id_10_original, cha_id_10_inserted, cha_id_10_inserted_format, cha_id_10,  
      cha_id_11_original, cha_id_11_inserted, cha_id_11_inserted_format, cha_id_11, 
      cha_id_12_original, cha_id_12_inserted, cha_id_12_inserted_format, cha_id_12, 
      cha_id_13_original, cha_id_13_inserted, cha_id_13_inserted_format, cha_id_13, 
      cha_id_14_original, cha_id_14_inserted, cha_id_14_inserted_format, cha_id_14
from lastmile_scratchpad.cha_de_chss_monthly_service_report
union
select 
      chss_monthly_service_report_id, 
      chss_id_original, chss_id_inserted, chss_id_inserted_format, chss_id,       
      cha_id_1_original, cha_id_1_inserted, cha_id_1_inserted_format, cha_id_1, 
      cha_id_2_original, cha_id_2_inserted, cha_id_2_inserted_format, cha_id_2, 
      cha_id_3_original, cha_id_3_inserted, cha_id_3_inserted_format, cha_id_3,  
      cha_id_4_original, cha_id_4_inserted, cha_id_4_inserted_format, cha_id_4,  
      cha_id_5_original, cha_id_5_inserted, cha_id_5_inserted_format, cha_id_5, 
      cha_id_6_original, cha_id_6_inserted, cha_id_6_inserted_format, cha_id_6, 
      cha_id_7_original, cha_id_7_inserted, cha_id_7_inserted_format, cha_id_7,  
      cha_id_8_original, cha_id_8_inserted, cha_id_8_inserted_format, cha_id_8,  
      cha_id_9_original, cha_id_9_inserted, cha_id_9_inserted_format, cha_id_9,
      cha_id_10_original, cha_id_10_inserted, cha_id_10_inserted_format, cha_id_10,  
      cha_id_11_original, cha_id_11_inserted, cha_id_11_inserted_format, cha_id_11, 
      cha_id_12_original, cha_id_12_inserted, cha_id_12_inserted_format, cha_id_12, 
      cha_id_13_original, cha_id_13_inserted, cha_id_13_inserted_format, cha_id_13, 
      cha_id_14_original, cha_id_14_inserted, cha_id_14_inserted_format, cha_id_14
from lastmile_scratchpad.ncha_de_chss_monthly_service_report
;


-- 2.

-- 282361 rows
select
       routineVisitID,
       chaID,
       cha_id_original,
       cha_id_inserted,
       cha_id_inserted_format

from lastmile_scratchpad.cha_odk_odk_routineVisit
union
select
       routineVisitID,
       chaID,
       cha_id_original,
       cha_id_inserted,
       cha_id_inserted_format

from lastmile_scratchpad.ncha_odk_odk_routineVisit
;


-- 3. ----------------------------------------------------------------------------------------

-- 215528 rows
select sickChildFormID, cha_id_original, cha_id_inserted, cha_id_inserted_format, chwID from cha_odk_sickChildForm
union
select sickChildFormID, cha_id_original, cha_id_inserted, cha_id_inserted_format, chwID from ncha_odk_sickChildForm
;

-- 4. ------------------------------------------------------------------------------------------

-- 535 rows
select
  vaccineTrackerID, 
  SupervisedchaID, cha_id_original, cha_id_inserted, cha_id_inserted_format,
  chssID, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.cha_odk_vaccineTracker 
union
select
  vaccineTrackerID, 
  SupervisedchaID, cha_id_original, cha_id_inserted, cha_id_inserted_format,
  chssID, chss_id_original, chss_id_inserted, chss_id_inserted_format
from lastmile_scratchpad.ncha_odk_vaccineTracker
;

-- 2171 rows
select
     chwRestockID,
     chwlID,
     cha_id_original,
     cha_id_inserted,
     cha_id_inserted_format
from lastmile_scratchpad.cha_chwdb_odk_chw_restock
union 
select
     chwRestockID,
     chwlID,
     cha_id_original,
     cha_id_inserted,
     cha_id_inserted_format
from lastmile_scratchpad.ncha_chwdb_odk_chw_restock
;

-- 1150 rows
select
       vaccineTrackerID,
       chwID,
       cha_id_original,
       cha_id_inserted,
       cha_id_inserted_format

from lastmile_scratchpad.cha_chwdb_odk_vaccine_tracker
union
select
       vaccineTrackerID,
       chwID,
       cha_id_original,
       cha_id_inserted,
       cha_id_inserted_format

from lastmile_scratchpad.ncha_chwdb_odk_vaccine_tracker
;

-- 2760 rows
select
       chwMonthlyServiceReportStep1ID,
        chwID,
        cha_id_original,
        chwID_inserted,
        cha_id_inserted_format
       
from lastmile_scratchpad.cha_staging_chwMonthlyServiceReportStep1  
union

select
       chwMonthlyServiceReportStep1ID,
        chwID,
        cha_id_original,
        chwID_inserted,
        cha_id_inserted_format
       
from lastmile_scratchpad.ncha_staging_chwMonthlyServiceReportStep1
;
