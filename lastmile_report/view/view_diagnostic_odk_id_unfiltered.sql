use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_odk_id_unfiltered;

create view lastmile_report.view_diagnostic_odk_id_unfiltered as

-- 6. odk_chaRestock --------------------------------------------------------------------------------------------------

select  
        'odk_chaRestock'                        as table_name,
        a.chaRestockID                          as pk_id,

        'cha'                                   as id_type,
        'supervisedChaID'                       as id_name, -- matched with chssID

        a.supervised_cha_id_original            as id_original_value, 
        a.supervised_cha_id_inserted            as id_inserted_value, 
        a.supervised_cha_id_inserted_format     as id_inserted_format_value,
        a.supervisedChaID                       as id_value,

        a.chaName 		                          as meta_cha,
        null		                                as meta_cha_id,
        a.chssName		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID	                          as meta_community_id, 
        a.manualDate                            as meta_form_date,
 
        a.meta_insertDatetime                   as meta_insert_date_time, 
        a.meta_formVersion                      as meta_form_version
               
from lastmile_upload.odk_chaRestock as a

union all

select  
        'odk_chaRestock'                        as table_name,
        a.chaRestockID                          as pk_id,

        'chss'                                  as id_type,
        'chssID'                                as id_name, -- matched with supervisedChaID
        
        a.chss_id_original                      as id_original_value,
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value,
        a.chssID                                as id_value,

        a.chaName 		                          as meta_cha,
        a.cha_id_original		                    as meta_cha_id,
        a.chssName		                          as meta_chss,
        null 	                                  as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID	                          as meta_community_id, 
        a.manualDate                            as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
         
from lastmile_upload.odk_chaRestock as a

union all

select  
        'odk_chaRestock'                        as table_name,
        a.chaRestockID                          as pk_id,

        'cha'                                   as id_type,
        'chaID'                                 as id_name,

        a.cha_id_original                       as id_original_value, 
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as id_inserted_format_value, 
        a.chaID                                 as id_value, 

        a.chaName 		                          as meta_cha,
        null		                                as meta_cha_id,
        a.user_name		                          as meta_chss,
        a.user_id_original 	                    as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID	                          as meta_community_id, 
        a.manualDate                            as meta_form_date,
  
        a.meta_insertDatetime, 
        a.meta_formVersion 
         
from lastmile_upload.odk_chaRestock as a

union all

select  
        'odk_chaRestock'                        as table_name,
        a.chaRestockID                          as pk_id,

        'chss'                                  as id_type,
        'user_id'                               as id_name,
        
        a.user_id_original                      as id_original_value,
        a.user_id_inserted                      as id_inserted_value, 
        a.user_id_inserted_format               as id_inserted_format_value,
        a.user_id                               as id_value,

        a.chaName 		                          as meta_cha,
        a.cha_id_original		                    as meta_cha_id,
        a.user_name		                          as meta_chss,
        null 	                                  as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        
        a.communityID	                          as meta_community_id, 
        a.manualDate                            as meta_form_date,
  
        a.meta_insertDatetime, 
        a.meta_formVersion 
            
from lastmile_upload.odk_chaRestock as a

union all

-- 7. odk_routineVisit --------------------------------------------------------------------------------------------

select  
        'odk_routineVisit'                      as table_name,
        a.routineVisitID                        as pk_id,

        'cha'                                   as id_type,
        'chaID'                                 as id_name,
        
        a.cha_id_original                       as id_original_value,
        a.cha_id_inserted                       as id_inserted_value,
        a.cha_id_inserted_format                as id_inserted_format_value,
        a.chaID                                 as id_value, 

        a.full_name 		                        as meta_cha,
        null		                                as meta_cha_id,
        null		                                as meta_chss,
        null 	                                  as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        a.visitDate                             as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
              
from lastmile_upload.odk_routineVisit a

union all

-- 8. odk_sickChildForm --------------------------------------------------------------------------------------------

select  
        'odk_sickChildForm'                     as table_name,
        a.sickChildFormID                       as pk_id,

        'cha'                                   as id_type,
        'chwID'                                 as id_name,

        a.cha_id_original                       as id_original_value, 
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as id_inserted_format_value, 
        a.chwID                                 as id_value,

        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        null		                                as meta_chss,
        null 	                                  as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID		                        as meta_community_id,
        a.manualDate                            as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
                
from lastmile_upload.odk_sickChildForm a

union all

-- 9. odk_supervisionVisitLog ---------------------------------------------------------------------

select  
        'odk_supervisionVisitLog'               as table_name,
        a.supervisionVisitLogID                 as pk_id,

        'cha'                                   as id_type,
        'supervisedCHAID'                       as id_name,

        a.supervised_cha_id_original            as id_original_value, 
        a.supervised_cha_id_inserted            as id_inserted_value, 
        a.supervised_cha_id_inserted_format     as id_inserted_format_value,
        a.supervisedCHAID                       as id_value,

        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_orig_original 	              as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID		                        as meta_community_id, 
        a.manualDate                            as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
                  
from lastmile_upload.odk_supervisionVisitLog as a

union all

select  
        'odk_supervisionVisitLog'               as table_name,
        a.supervisionVisitLogID                 as pk_id,

        'chss'                                  as id_type,
        'chssID'                                as id_name,

        a.chss_id_orig_original                 as id_original_value, 
        a.chss_id_orig_inserted                 as id_inserted_value, 
        a.chss_id_orig_inserted_format          as id_inserted_format_value,
        a.chssID                                as id_value, 

        a.chss_name 		                        as meta_cha,
        null		                                as meta_cha_id,
        null		                                as meta_chss,
        null 	                                  as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID		                        as meta_community_id, 
        a.manualDate                            as meta_form_date,
  
        a.meta_insertDatetime, 
        a.meta_formVersion 
                 
from lastmile_upload.odk_supervisionVisitLog as a

union all

-- 10. odk_vaccineTracker ----------------------------------------------------------------------------

select  
        'odk_vaccineTracker'                    as table_name,
        a.vaccineTrackerID                      as pk_id,
        'cha'                                   as id_type,
        'SupervisedchaID'                       as id_name,

        a.cha_id_original                       as id_original_value,
        a.cha_id_inserted                       as id_inserted_value,
        a.cha_id_inserted_format                as id_inserted_format_value,
        a.SupervisedchaID                       as id_value,

        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID		                        as meta_community_id, 
        a.manualDate                            as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
                
from lastmile_upload.odk_vaccineTracker as a

union all

select  
        'odk_vaccineTracker'                    as table_name,
        a.vaccineTrackerID                      as pk_id,
        'chss'                                  as id_type,
        'chssID'                                as id_name,

        a.chss_id_original                      as id_original_value, 
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value,
        a.chssID                                as id_value, 

        null 		                                as meta_cha,
        a.cha_id_original		                    as meta_cha_id,
        null		                                as meta_chss,
        null 	                                  as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        a.communityID		                        as meta_community_id, 
        a.manualDate                            as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
                      
from lastmile_upload.odk_vaccineTracker as a

union all

-- 11. odk_QAOSupervisionChecklistForm ---------------------------------------------------------------------

select
        'odk_QAOSupervisionChecklistForm'       as table_name,
        a.odk_QAOSupervisionChecklistForm_id    as pk_id,
       
        'chss'                                  as id_type,       
        'CHSSID'                                as id_name,

        a.chss_id_original                      as id_original_value, 
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value,
        a.CHSSID                                as id_value, 

        null 		                                as meta_cha,
        a.cha_id_original		                    as meta_cha_id,
        null		                                as meta_chss,
        null 	                                  as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        a.TodayDate                             as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
         
from lastmile_upload.odk_QAOSupervisionChecklistForm as a

union all

select  
        'odk_QAOSupervisionChecklistForm'       as table_name,
        a.odk_QAOSupervisionChecklistForm_id    as pk_id,
        'cha'                                   as id_type,
        'CHAID'                                 as id_name,

        a.cha_id_original                       as id_original_value,
        a.cha_id_inserted                       as id_inserted_value,
        a.cha_id_inserted_format                as id_inserted_format_value,
        a.CHAID                                 as id_value, 

        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        null		                                as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        null		                                as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        null                                    as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        a.TodayDate                             as meta_form_date,
         
        a.meta_insertDatetime, 
        a.meta_formVersion 
        
from lastmile_upload.odk_QAOSupervisionChecklistForm as a
;
