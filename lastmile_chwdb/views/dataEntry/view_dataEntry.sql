use lastmile_chwdb;

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
from lastmile_db.tbl_data_fhw_sch_sickchild
where not ( ( meta_DE_date is null ) or ( trim( meta_DE_date ) like '' ) )

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
where not ( ( meta_DE_date is null ) or ( trim( meta_DE_date ) like '' ) )

union all

select
      'web',
      'CHA: Household Registration',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      chwID
from staging_householdRegistrationStep1
where not ( ( meta_DE_date is null ) or ( trim( meta_DE_date ) like '' ) )

union all

select
      'web',
      'CHA: Monthly Service Report',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      chwID
from staging_chwMonthlyServiceReportStep1
where not ( ( meta_DE_date is null ) or ( trim( meta_DE_date ) like '' ) )

union all

select
      'web',
      'Training Results Record',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      null
from staging_trainingResultsRecordStep1
where not ( ( meta_DE_date is null ) or ( trim( meta_DE_date ) like '' ) )

union all

select
      'web',
      'Facilitator Evaluation',
      meta_formVersion,
      meta_DE_date,
      meta_DE_init,
      meta_QA_init,                                          
      null
from staging_facilitatorEvaluationRecordStep1
where not ( ( meta_DE_date is null ) or ( trim( meta_DE_date ) like '' ) )

union all

select
      'odk',
      'Arrival Log',
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      chwlID                                            
from staging_odk_arrivalchecklog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'Departure Log'                                         as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      chwlID                                       
from staging_odk_departurechecklog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'CHA Restock'                                           as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      supervisedChwID 
from staging_odk_chwrestock
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'CHA Restock Archive'                                   as formName,
      meta_formVersion,
      meta_insertDatetime,
      null,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      supervisedChwID 
from staging_odk_chwrestock_archive
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'CHA Supervision Report'                                as formName,
      meta_formVersion,
      meta_insertDate,
      null,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      supervisedCHWID 
from staging_odk_chwsupervisionreport
where not ( ( meta_insertDate is null ) or ( trim( meta_insertDate ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'Health Survey'                                         as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      chwID 
from staging_odk_healthsurvey
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'Routine Visit'                                         as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      chwID 
from staging_odk_routinevisit
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'Routine Visit Archive'                                 as formName,
      meta_formVersion,
      meta_insertDate,
      null,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      chwID 
from staging_odk_routinevisit_archive
where not ( ( meta_insertDate is null ) or ( trim( meta_insertDate ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'Sick Child'                                            as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      chwID
from staging_odk_sickChildForm
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'Supervision Visit Log'                                 as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      supervisedCHWID
from staging_odk_supervisionvisitlog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )

union all

select
      'odk'                                                   as formType,
      'vaccine tracker'                                       as formName,
      meta_formVersion,
      meta_insertDatetime,
      meta_uploadUser,
      null,                     -- qualityAssuranceUser is always null for odk                                        
      chwID
from staging_odk_vaccinetracker
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
;