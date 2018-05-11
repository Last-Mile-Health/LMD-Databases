use lastmile_upload;

drop view if exists lastmile_upload.view_diagnostic_id;

create view lastmile_upload.view_diagnostic_id as

-- 1. de_case_scenario ----------------------------------------------------------------------------------------

select  
        'de_case_scenario'                  as table_name,
        a.de_case_scenario_id               as pk_id,
        'chss'                              as id_type,
        'chss_id'                           as id_name,
        
        a.chss_id                           as id_value, 
        a.chss_id_inserted                  as id_inserted_value, 
        a.chss_id_inserted_format           as id_inserted_format_value, 
        
        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
        
             
from lastmile_upload.de_case_scenario as a
  
union all

select 
        'de_case_scenario'                  as table_name,
        a.de_case_scenario_id               as pk_id,
        'cha'                               as id_type,
        'cha_id'                            as id_name,

        a.cha_id                            as id_value, 
        a.cha_id_inserted                   as id_inserted_value, 
        a.cha_id_inserted_format            as id_inserted_format_value, 

        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
                
from lastmile_upload.de_case_scenario as a
    
union all

-- 2. de_chaHouseholdRegistration ---------------------------------------------------------------------

select  
        'de_chaHouseholdRegistration'       as table_name,
        a.chaHouseholdRegistrationID        as pk_id,
        'cha'                               as id_type,
        'chaID'                             as id_name,

        a.chaID                             as id_value, 
        a.cha_id_inserted                   as id_inserted_value, 
        a.cha_id_inserted_format            as id_inserted_format_value, 

        a.meta_insertDatetime               as date_time_record_inserted, 
        a.meta_formVersion                  as form_version
        
from lastmile_upload.de_chaHouseholdRegistration as a
    
union all

select  
        'de_chaHouseholdRegistration'       as table_name,
        a.chaHouseholdRegistrationID        as pk_id,
        'chss'                              as id_type,
        'chssID'                            as id_name,

        a.chssID                            as id_value, 
        a.chss_id_inserted                  as id_inserted_value, 
        a.chss_id_inserted_format           as id_inserted_format_value, 

        a.meta_insertDatetime               as date_time_record_inserted, 
        a.meta_formVersion                  as form_version
                
from lastmile_upload.de_chaHouseholdRegistration as a
    
union all

-- 5. de_cha_monthly_service_report -----------------------------------------------------------------------

select  
        'de_cha_monthly_service_report'     as table_name,
        a.cha_monthly_service_report_id     as pk_id,

        'cha'                               as id_type,
        'cha_id'                            as id_name,

        a.cha_id                            as id_value,     
        a.cha_id_inserted                   as id_inserted_value, 
        a.cha_id_inserted_format            as cha_id_inserted_format_value,
  
        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
            
from lastmile_upload.de_cha_monthly_service_report as a
    
union all

select  
        'de_cha_monthly_service_report'     as table_name,
        a.cha_monthly_service_report_id     as pk_id,

        'chss'                              as id_type,
        'chss_id'                           as id_name,

        a.chss_id                           as id_value, 
        a.chss_id_inserted                  as id_inserted_value,
        a.chss_id_inserted_format           as id_inserted_value_format,
 
        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
        
from lastmile_upload.de_cha_monthly_service_report as a
    
union all

-- 6. de_cha_status_change_form ----------------------------------------------------------------------------

select  
        'de_cha_status_change_form'         as table_name,
        a.de_cha_status_change_form_id      as pk_id,
        
        'cha'                               as id_type,
        'cha_id'                            as id_name,

        a.cha_id                            as id_value, 
        a.cha_id_inserted                   as id_inserted_value, 
        a.cha_id_inserted_format            as id_inserted_format_value, 

        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
        
from lastmile_upload.de_cha_status_change_form a

union all

select  
        'de_cha_status_change_form'       as table_name,
        a.de_cha_status_change_form_id    as pk_id,
        'chss'                            as id_type,
        'chss_id'                         as id_name,

        a.chss_id                         as id_value, 
        a.chss_id_inserted                as id_inserted_value, 
        a.chss_id_inserted_format         as id_inserted_format_value,

        a.meta_insert_date_time           as date_time_record_inserted, 
        a.meta_form_version               as form_version
        
from lastmile_upload.de_cha_status_change_form as a
    
union all

-- 7. de_chss_commodity_distribution -------------------------------------------------------------------------
 
select  
        'de_chss_commodity_distribution'    as table_name,
        a.chss_commodity_distribution_id    as pk_id,
        'chss'                              as id_type,
        'chss_id'                           as id_name,

        a.chss_id                           as id_value, 
        a.chss_id_inserted                  as id_inserted_value, 
        a.chss_id_inserted_format           as id_inserted_format_value, 

        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
        
from lastmile_upload.de_chss_commodity_distribution as a
   
union all

-- XX. de_chss_monthly_service_report --------------------------------------------------------------------------------------

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'chss'                                  as id_type,
        'chss_id'                               as id_name,

        a.chss_id                               as id_value, 
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
   
from lastmile_upload.de_chss_monthly_service_report as a
   
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_1'                              as id_name,

        a.cha_id_1                              as id_value, 
        a.cha_id_1_inserted                     as id_inserted_value, 
        a.cha_id_1_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, a.meta_form_version as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_2'                              as id_name,

        a.cha_id_2                              as id_value, 
        a.cha_id_2_inserted                     as id_inserted_value, 
        a.cha_id_2_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_3'                              as id_name,

        a.cha_id_3                              as id_value, 
        a.cha_id_3_inserted                     as id_inserted_value, 
        a.cha_id_3_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_4'                              as id_name,

        a.cha_id_4                              as id_value, 
        a.cha_id_4_inserted                     as id_inserted_value, 
        a.cha_id_4_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_5'                              as id_name,

        a.cha_id_5                              as id_value, 
        a.cha_id_5_inserted                     as id_inserted_value, 
        a.cha_id_5_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_6'                              as id_name,

        a.cha_id_6                              as id_value, 
        a.cha_id_6_inserted                     as id_inserted_value, 
        a.cha_id_6_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,

        'cha'                                   as id_type,
        'cha_id_7'                              as id_name,

        a.cha_id_7                              as id_value, 
        a.cha_id_7_inserted                     as id_inserted_value, 
        a.cha_id_7_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_8'                              as id_name,

        a.cha_id_8                              as id_value, 
        a.cha_id_8_inserted                     as id_inserted_value, 
        a.cha_id_8_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_9'                              as id_name,

        a.cha_id_9                              as id_value, 
        a.cha_id_9_inserted                     as id_inserted_value, 
        a.cha_id_9_inserted_format              as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_10'                             as id_name,

        a.cha_id_10                             as id_value, 
        a.cha_id_10_inserted                    as id_inserted_value, 
        a.cha_id_10_inserted_format             as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all


select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_11'                             as id_name,

        a.cha_id_11                             as id_value, 
        a.cha_id_11_inserted                    as id_inserted_value, 
        a.cha_id_11_inserted_format             as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_12'                             as id_name,

        a.cha_id_12                             as id_value, 
        a.cha_id_12_inserted                    as id_inserted_value, 
        a.cha_id_12_inserted_format             as id_inserted_format_value, 

        a.meta_insert_date_time                 as date_time_record_inserted, 
        a.meta_form_version                     as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'            as table_name,
        a.chss_monthly_service_report_id            as pk_id,
        
        'cha'                                       as id_type,
        'cha_id_13'                                 as id_name,

        a.cha_id_13                                 as id_value, 
        a.cha_id_13_inserted                        as id_inserted_value, 
        a.cha_id_13_inserted_format                 as id_inserted_format_value, 

        a.meta_insert_date_time                     as date_time_record_inserted, 
        a.meta_form_version                         as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'            as table_name,
        a.chss_monthly_service_report_id            as pk_id,
        
        'cha'                                       as id_type,
        'cha_id_14'                                 as id_name,

        a.cha_id_14                                 as id_value, 
        a.cha_id_14_inserted                        as id_inserted_value, 
        a.cha_id_14_inserted_format                 as id_inserted_format_value, 

        a.meta_insert_date_time                     as date_time_record_inserted, 
        a.meta_form_version                         as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a

union all

-- xx. de_direct_observation ------------------------------------------------------------------------------------------------------------------------

select  
        'de_direct_observation'                   as table_name,
        a.de_direct_observation_id                as pk_id,
        
        'cha'                                     as id_type,
        'cha_id'                                  as id_name,

        a.cha_id                                  as id_value, 
        a.cha_id_inserted                         as id_inserted_value, 
        a.cha_id_inserted_format                  as id_inserted_format_value, 

        a.meta_insert_date_time                   as date_time_record_inserted, 
        a.meta_form_version                       as form_version
            
from lastmile_upload.de_direct_observation as a

union all

select  
        'de_direct_observation'             as table_name,
        a.de_direct_observation_id          as pk_id,
        
        'chss'                              as id_type,
        'chss_id'                           as id_name,

        a.chss_id                           as id_value, 
        a.chss_id_inserted                  as id_inserted_value, 
        a.chss_id_inserted_format           as id_inserted_format_value, 

        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
       
from lastmile_upload.de_direct_observation as a

union all

-- xx. de_register_review  ---------------------------------------------------------------------------------------------------

select  
        'de_register_review'                as table_name,
        a.de_register_review_id             as pk_id,
       
        'cha'                               as id_type,
        'cha_id'                            as id_name,

        a.cha_id                            as id_value, 
        a.cha_id_inserted                   as id_inserted_value, 
        a.cha_id_inserted_format            as id_inserted_format_value, 

        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
         
from lastmile_upload.de_register_review as a

union all

select  
        'de_register_review'                as table_name,
        a.de_register_review_id             as pk_id,
        
        'chss'                              as id_type,
        'chss_id'                           as id_name,

        a.chss_id                           as id_value, 
        a.chss_id_inserted                  as id_inserted_value, 
        a.chss_id_inserted_format           as id_inserted_format_value, 

        a.meta_insert_date_time             as date_time_record_inserted, 
        a.meta_form_version                 as form_version
                
from lastmile_upload.de_register_review as a

union all

-- xx. odk_FieldArrivalLogForm ---------------------------------------------------------------------------------------------

select  
        'odk_FieldArrivalLogForm'           as table_name,
        a.fieldArrivalLogForm_id              as pk_id,

        'cha'                               as id_type,
        'SupervisedCHAID'                   as id_name,

        a.SupervisedCHAID                   as id_value, 
        a.cha_id_inserted                   as id_inserted_value, 
        a.cha_id_inserted_format            as id_inserted_format_value, 

        a.meta_insertDatetime               as date_time_record_inserted, a.meta_formVersion as form_version
        
from lastmile_upload.odk_FieldArrivalLogForm as a

union all

select  
        'odk_FieldArrivalLogForm'           as table_name,
        a.fieldArrivalLogForm_id            as pk_id,

        'chss'                              as id_type,
        'LMHID'                             as id_name,

        a.LMHID                             as id_value, 
        a.lmh_id_inserted                   as id_inserted_value, 
        a.lmh_id_inserted_format            as id_inserted_format_value, 

        a.meta_insertDatetime               as date_time_record_inserted, 
        a.meta_formVersion                  as form_version
         
from lastmile_upload.odk_FieldArrivalLogForm as a

union all

-- xx. odk_FieldIncidentReportForm ------------------------------------------------------------------------------------------------------------

select  
        'odk_FieldIncidentReportForm'       as table_name,
        a.fieldIncidentReportForm_id        as pk_id,
        'MIX'                               as id_type,

        'IDNumber'                          as id_name,
        a.IDNumber                          as id_value, 

        a.id_number_inserted                as id_inserted_value, 
        a.id_number_inserted_format         as id_inserted_format_value, 

        a.meta_insertDatetime               as date_time_record_inserted, 
        a.meta_formVersion                  as form_version
        
from lastmile_upload.odk_FieldIncidentReportForm as a

union all

-- XX. odk_QAO_CHSSQualityAssuranceForm -----------------------------------------------------------------------

select 
        'odk_QAO_CHSSQualityAssuranceForm'          as table_name,
        a.odk_QAO_CHSSQualityAssuranceForm_id       as pk_id,
        
        'chss'                                      as id_type,
        'chss_id'                                   as id_name,

        a.chss_id                                   as id_value, 
        a.chss_id_inserted                          as id_inserted_value, 
        a.chss_id_inserted_format                   as id_inserted_format_value, 

        a.meta_insertDatetime                       as date_time_record_inserted, 
        a.meta_formVersion                          as form_version
        
from lastmile_upload.odk_QAO_CHSSQualityAssuranceForm as a

union all

-- XX. odk_chaRestock --------------------------------------------------------------------------------------------------

select  
        'odk_chaRestock'                        as table_name,
        a.chaRestockID                          as pk_id,

        'cha'                                   as id_type,
        'supervisedChaID'                       as id_name,

        a.supervisedChaID                       as id_value, 
        a.supervised_cha_id_inserted            as id_inserted_value, 
        a.supervised_cha_id_inserted_format     as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
         
from lastmile_upload.odk_chaRestock as a

union all

select  
        'odk_chaRestock'                        as table_name,
        a.chaRestockID                          as pk_id,

        'cha'                                   as id_type,
        'chaID'                                 as id_name,

        a.chaID                                 as id_value, 
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
          
from lastmile_upload.odk_chaRestock as a

union all

select  
        'odk_chaRestock'                        as table_name,
        a.chaRestockID                          as pk_id,

        'chss'                                  as id_type,
        'chssID'                                as id_name,
        a.chssID                                as id_value, 
        
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
        
from lastmile_upload.odk_chaRestock as a

union all

-- XX. odk_communityEngagementLog ---------------------------------------------------------------------------------

select  
        'odk_communityEngagementLog'            as table_name,
        a.community_engagement_log_id           as pk_id,
        'MIX'                                   as id_type,
        'data_collector_id'                     as id_name,

        a.data_collector_id                     as id_value, 
        a.data_collector_id_inserted            as id_inserted_value, 
        a.data_collector_id_inserted_format     as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
        
from lastmile_upload.odk_communityEngagementLog a

union all

-- XX. odk_routineVisit --------------------------------------------------------------------------------------------

select  
        'odk_routineVisit'                      as table_name,
        a.routineVisitID                        as pk_id,

        'cha'                                   as id_type,
        'chaID'                                 as id_name,

        a.chaID                                 as id_value, 
        a.cha_id_inserted                       as id_inserted_value,
        a.cha_id_inserted_format                as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
        
from lastmile_upload.odk_routineVisit a

union all

-- XX. odk_sickChildForm --------------------------------------------------------------------------------------------

select  
        'odk_sickChildForm'                     as table_name,
        a.sickChildFormID                       as pk_id,

        'cha'                                   as id_type,
        'chwID'                                 as id_name,

        a.chwID                                 as id_value, 
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
             
from lastmile_upload.odk_sickChildForm a

union all

-- XX. odk_supervisionVisitLog ---------------------------------------------------------------------

select  
        'odk_supervisionVisitLog'               as table_name,
        a.supervisionVisitLogID                 as pk_id,

        'cha'                                   as id_type,
        'supervisedCHAID'                       as id_name,

        a.supervisedCHAID                       as id_value, 
        a.supervised_cha_id_inserted            as id_inserted_value, 
        a.supervised_cha_id_inserted_format     as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
              
from lastmile_upload.odk_supervisionVisitLog as a

union all

select  
        'odk_supervisionVisitLog'               as table_name,
        a.supervisionVisitLogID                 as pk_id,
        'cha'                                   as id_type,
        'cha_id'                                as id_name,

        a.cha_id                                as id_value, 
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as id_inserted_format_value, 
       
        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
        
from lastmile_upload.odk_supervisionVisitLog a

union all

select  
        'odk_supervisionVisitLog'               as table_name,
        a.supervisionVisitLogID                 as pk_id,

        'chss'                                  as id_type,
        'chssID'                                as id_name,

        a.chssID                                as id, 
        a.chss_id_orig_inserted                 as id_inserted_value, 
        a.chss_id_orig_inserted_format          as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
         
from lastmile_upload.odk_supervisionVisitLog as a

union all

select  
        'odk_supervisionVisitLog'               as table_name,
        a.supervisionVisitLogID                 as pk_id,

        'chss'                                  as id_type,
        'chss_id'                               as id_name,

        a.chss_id                               as id_value, 
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version 
       
from lastmile_upload.odk_supervisionVisitLog as a

union all

-- XX. odk_vaccineTracker ----------------------------------------------------------------------------

select  
        'odk_vaccineTracker'                    as table_name,
        a.vaccineTrackerID                      as pk_id,
        'cha'                                   as id_type,
        'SupervisedchaID'                       as id_name,

        a.SupervisedchaID                       as id_value, 
        a.cha_id_inserted                       as id_inserted_value,
        a.cha_id_inserted_format                as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
            
from lastmile_upload.odk_vaccineTracker as a

union all

select  
        'odk_vaccineTracker'                    as table_name,
        a.vaccineTrackerID                      as pk_id,
        'chss'                                  as id_type,
        'chssID'                                as id_name,

        a.chssID                                as id_value, 
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
               
from lastmile_upload.odk_vaccineTracker as a

union all

-- XX. odk_QAOSupervisionChecklistForm ---------------------------------------------------------------------

select
        odk_QAOSupervisionChecklistForm_id      as pk_id,
        'odk_QAOSupervisionChecklistForm'       as table_name,

        'chss'                                  as id_type,       
        'CHSSID'                                as id_name,

        a.CHSSID                                as id_value, 
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value, 

        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
        
from lastmile_upload.odk_QAOSupervisionChecklistForm as a

union all

select  
        odk_QAOSupervisionChecklistForm_id      as pk_id,
        'odk_QAOSupervisionChecklistForm'       as table_name,
        'cha'                                   as id_type,
        'CHAID'                                 as id_name,

        a.CHAID                                 as id_value, 
        a.cha_id_inserted                       as id_inserted_value,
        a.cha_id_inserted_format                as id_inserted_format_value,
        
        a.meta_insertDatetime                   as date_time_record_inserted, 
        a.meta_formVersion                      as form_version
        
from lastmile_upload.odk_QAOSupervisionChecklistForm as a
;