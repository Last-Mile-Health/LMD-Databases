use lastmile_chwdb;
-- Note: add tables from the LMS survey.

drop view if exists view_dataEntry;

create view view_dataEntry as

select
      'web'                                                   as formType,
      'Sick Child'                                            as formName,
      meta_formVersion                                        as formVersion,
      meta_DE_date                                            as dataEntryDate,
      meta_DE_init                                            as dataEntryUser,
      meta_QA_init                                            as qualityAssuranceUser,
      fhwID                                                   as staffID
      -- No communityID, left outer join view_territoryCommunityChw to fhwID
from lastmile_db.tbl_data_fhw_sch_sickchild

union all

select
      'web',
      'CHA: Health Survey',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,
      chwID
      
from staging_kpiAssessmentStep1
-- where not ( ( meta_DE_date is null ) or ( trim( meta_DE_date ) like '' ) )

union all

select
      'web',
      'CHA: Household Registration',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      chwID
      -- communityID, left outer join view_territoryCommunity to communityID
from staging_householdRegistrationStep1

union all

select
      'web',
      'CHA: Monthly Service Report',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      chwID
       -- communityID, left outer join view_territoryCommunity to communityID
from staging_chwMonthlyServiceReportStep1

union all

select
      'web',
      'Training Results Record',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      null                                                      as staffID
      -- unknown as district
from staging_trainingResultsRecordStep1

union all

select
      'web',
      'Facilitator Evaluation',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      null                                                      as staffID
      -- unknown as district
from staging_facilitatorEvaluationRecordStep1

union all

select
      'odk',
      'Arrival Log',
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                       
      chwlID
      -- No communityID, supervisedChwID is poorly filled, left outer join view_staffSupervisionCommunityiHstory to  chwlID
from staging_odk_arrivalchecklog

union all

select
      'odk'                                                   as formType,
      'Departure Log'                                         as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                   
      chwlID
      -- No communityID or chwID, left outer join view_staffSupervisionCommunityiHstory to  chwlID
from staging_odk_departurechecklog

union all

select
      'odk'                                                   as formType,
      'CHA Restock'                                           as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                        
      supervisedChwID
      -- CommunityID is poorly filled in, left outer join view_staffSupervisionCommunityiHstory to supervisedChwID
from staging_odk_chwrestock

union all

select
      'odk'                                                   as formType,
      'CHA Restock'                                           as formName,
      meta_formVersion,
      meta_insertDatetime,
      null                                                    as dataEntryUser,
      null                                                    as qualityAssuranceUser,                                       
      supervisedChwID
      -- supervisedChwID is poorly filled in, left outer join view_staffSupervisionCommunityiHstory to chwlID
from staging_odk_chwrestock_archive

union all

select
      'odk'                                                   as formType,
      'CHA Supervision Report'                                as formName,
      meta_formVersion,
      meta_insertDate,
      null                                                    as dataEntryUser,
      null                                                    as qualityAssuranceUser,                                        
      supervisedCHWID
      -- No communityID, left outer join view_territoryCommunityChw to supervisedCHWID
from staging_odk_chwsupervisionreport

union all

select
      'odk'                                                   as formType,
      'Health Survey'                                         as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                     
      chwID 
from staging_odk_healthsurvey

union all

select 

      'odk'                                                   as formType,
      'Health Survey: Children'                               as formName,
      null                                                    as meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                                             
      chwID                                                   as staffID

from staging_odk_children
-- use linkUUID to odk health survey table to bring in form version

union all

select 
      'odk'                                                   as formType,
      'Health Survey: Vaccine'                                as formName,
      null                                                    as meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                                             
      chwID                                                   as staffID
from staging_odk_vaccine
-- use linkUUID to odk health survey table to bring in chwID for staffID and form version

union all

select
      'odk'                                                   as formType,
      'Routine Visit'                                         as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                       
      chwID 
from staging_odk_routinevisit

union all

select
      'odk'                                                   as formType,
      'Routine Visit'                                         as formName,
      meta_formVersion,
      meta_insertDate,
      null                                                    as dataEntryUser,
      null                                                    as qualityAssuranceUser,                                        
      chwID                                                   
from staging_odk_routinevisit_archive

union all

select
      'odk'                                                   as formType,
      'Sick Child'                                            as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                    
      chwID
from staging_odk_sickChildForm

union all

select
      'odk'                                                   as formType,
      'Supervision Visit Log'                                 as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                        
      supervisedCHWID
from staging_odk_supervisionvisitlog

union all

select
      'odk'                                                   as formType,
      'vaccine tracker'                                       as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null                                                    as qualityAssuranceUser,                                                             
      chwID
from staging_odk_vaccinetracker
;