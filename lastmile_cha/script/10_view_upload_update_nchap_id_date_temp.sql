use lastmile_upload;

drop view if exists lastmile_upload.view_log_update_nchap_id_last;

create view lastmile_upload.view_log_update_nchap_id_last as
select table_name, max( meta_date_time ) as meta_date_time
from lastmile_upload.log_update_nchap_id
group by table_name
;

drop view if exists lastmile_upload.view_upload_update_nchap_id_date;

create view lastmile_upload.view_upload_update_nchap_id_date as

-- de_case_scenario

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_case_scenario a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_case_scenario'


union all

select  'cha'                     as id_type,
        a.cha_id                  as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_case_scenario a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_case_scenario'


-- de_chaHouseholdRegistration ---------------------------------------

union all

select  'cha'                     as id_type,
        a.chaID                   as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chaHouseholdRegistration a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chaHouseholdRegistration'

union all

select  'chss'                    as id_type,
        a.chssID                  as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chaHouseholdRegistration a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chaHouseholdRegistration'


-- de_cha_monthly_service_report ---------------------------------------

-- cha_id 
-- cha_id_inserted
-- chss_id
-- chss_id_inserted 

union all

select  'cha'                     as id_type,
        a.cha_id                  as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_cha_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_cha_monthly_service_report'

union all

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_cha_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_cha_monthly_service_report'


-- de_cha_status_change_form ---------------------------------------

-- cha_id
-- cha_id_inserted
-- chss_id
-- chss_id_inserted

union all

select  'cha'                     as id_type,
        a.cha_id                  as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_cha_status_change_form a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_cha_status_change_form'

union all

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_cha_status_change_form a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_cha_status_change_form'


-- de_chss_commodity_distribution ---------------------------------------

-- chss_id
-- chss_id_inserted

union all

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_commodity_distribution a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_commodity_distribution'

-- de_chss_monthly_service_report ---------------------------------------

-- chss_id
-- chss_id_inserted

union all

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'


-- CHAs 1-14 go here...

-- 1
-- cha_id_1
-- cha_id_1_inserted
-- and 2..14

union all
select  'cha'                     as id_type,
        a.cha_id_1                as id, 
        a.cha_id_1_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_2                as id, 
        a.cha_id_2_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_3                as id, 
        a.cha_id_3_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_4                as id, 
        a.cha_id_4_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_5                as id, 
        a.cha_id_5_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_6                as id, 
        a.cha_id_6_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_7                as id, 
        a.cha_id_7_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_8                as id, 
        a.cha_id_8_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_9                as id, 
        a.cha_id_9_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_10               as id, 
        a.cha_id_10_inserted      as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_11               as id, 
        a.cha_id_11_inserted      as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_12                as id, 
        a.cha_id_12_inserted       as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_13               as id, 
        a.cha_id_13_inserted      as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'

union all
select  'cha'                     as id_type,
        a.cha_id_14               as id, 
        a.cha_id_14_inserted      as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_chss_monthly_service_report a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_chss_monthly_service_report'




-- de_direct_observation --------------------------------------- checked! 

-- cha_id
-- cha_id_inserted

-- chss_id 
-- chss_id_inserted


union all

select  'cha'                     as id_type,
        a.cha_id                  as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_direct_observation a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_direct_observation'

union all

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_direct_observation a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_direct_observation'



-- de_register_review ---------------------------------------  checked!

-- cha_id
-- cha_id_inserted

-- chss_id
-- chss_id_inserted 


union all

select  'cha'                     as id_type,
        a.cha_id                  as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_register_review a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_register_review'

union all

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insert_date_time   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.de_register_review a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'de_register_review'


-- odk_FieldArrivalLogForm ---------------------------------------  checked!

-- SupervisedCHAID
-- cha_id_inserted
-- chss
-- LMHID
-- lmh_id_inserted

union all

select  'cha'                     as id_type,
        a.SupervisedCHAID         as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_FieldArrivalLogForm a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_FieldArrivalLogForm'

union all

select  'chss'                    as id_type,
        a.LMHID                   as id, 
        a.lmh_id_inserted         as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_FieldArrivalLogForm a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_FieldArrivalLogForm'



-- odk_FieldIncidentReportForm ---------------------------------------  checked!

-- cha
-- IDNumber
-- id_number_inserted
-- chss
-- IDNumber
-- id_number_inserted


union all

select  'cha'                     as id_type,
        a.IDNumber                as id, 
        a.id_number_inserted      as id_inserted, 
        a.meta_insertDatetime   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_FieldIncidentReportForm a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_FieldIncidentReportForm'

union all

select  'chss'                    as id_type,
        a.IDNumber                as id, 
        a.id_number_inserted      as id_inserted, 
        a.meta_insertDatetime   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_FieldIncidentReportForm a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_FieldIncidentReportForm'


-- odk_OSFKAPSurvey ---------------------------------------  checked!

-- There is no chss or cha id in this table.

-- odk_QAO_CHSSQualityAssuranceForm ---------------------------------------  checked!

-- chss_id
-- chss_id_inserted


union all

select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insertDatetime   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_QAO_CHSSQualityAssuranceForm a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_QAO_CHSSQualityAssuranceForm'



-- odk_chaRestock ---------------------------------------  checked!

-- supervisedChaID
-- supervised_cha_id_inserted
-- chaID
-- cha_id_inserted
-- chssID
-- chss_id_inserted

union all

select  'cha'                         as id_type,
        a.supervisedChaID             as id, 
        a.supervised_cha_id_inserted  as id_inserted, 
        a.meta_insertDatetime         as date_time_record_inserted, 
        
        l.meta_date_time              as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_chaRestock a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_chaRestock'

union all

select  'cha'                     as id_type,
        a.chaID                   as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_chaRestock a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_chaRestock'

union all

select  'chss'                  as id_type,
        a.chssID                as id, 
        a.chss_id_inserted      as id_inserted, 
        a.meta_insertDatetime   as date_time_record_inserted, 
        
        l.meta_date_time        as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_chaRestock a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_chaRestock'

-- odk_communityEngagementLog ---------------------------------------  

-- cha

-- data_collector_id
-- data_collector_id_inserted

-- chss

-- data_collector_id
-- data_collector_id_inserted

union all

select  'cha'                         as id_type,
        a.data_collector_id           as id, 
        a.data_collector_id_inserted  as id_inserted, 
        a.meta_insertDatetime         as date_time_record_inserted, 
        
        l.meta_date_time              as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_communityEngagementLog a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_communityEngagementLog'

union all

select  'chss'                        as id_type,
        a.data_collector_id           as id, 
        a.data_collector_id_inserted  as id_inserted, 
        a.meta_insertDatetime         as date_time_record_inserted, 
        
        l.meta_date_time              as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_communityEngagementLog a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_communityEngagementLog'

-- odk_osf_routine --------------------------------------- 

-- No fields contain cha or chss ids

-- odk_routineVisit --------------------------------------- checked!

-- chaID 
-- cha_id_inserted

union all

select  'cha'                     as id_type,
        a.chaID                   as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_routineVisit a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_routineVisit'

-- odk_sickChildForm --------------------------------------- checked!

-- chwID 
-- cha_id_inserted

union all

select  'cha'                     as id_type,
        a.chwID                   as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insertDatetime   as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_sickChildForm a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_sickChildForm'

-- odk_supervisionVisitLog ---------------------------------------

union all

-- supervisedCHAID
-- supervised_cha_id_inserted
select  'cha'                         as id_type,
        a.supervisedCHAID             as id, 
        a.supervised_cha_id_inserted  as id_inserted, 
        a.meta_insertDatetime         as date_time_record_inserted, 
        
        l.meta_date_time              as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_supervisionVisitLog a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_supervisionVisitLog'

union all

-- cha_id
-- cha_id_inserted
select  'cha'                     as id_type,
        a.cha_id                  as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_supervisionVisitLog a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_supervisionVisitLog'

union all

-- chssID
-- chss_id_orig_inserted
select  'chss'                    as id_type,
        a.chssID                  as id, 
        a.chss_id_orig_inserted   as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_supervisionVisitLog a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_supervisionVisitLog'

union all

-- chss_id
-- chss_id_inserted
select  'chss'                    as id_type,
        a.chss_id                 as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_supervisionVisitLog a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_supervisionVisitLog'

-- odk_vaccineTracker ---------------------------------------

-- SupervisedchaID
-- cha_id_inserted

-- chssID
-- chss_id_inserted 

union all

select  'cha'                     as id_type,
        a.SupervisedchaID         as id, 
        a.cha_id_inserted         as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_vaccineTracker a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_vaccineTracker'

union all

select  'chss'                    as id_type,
        a.chssID                  as id, 
        a.chss_id_inserted        as id_inserted, 
        a.meta_insertDatetime     as date_time_record_inserted, 
        
        l.meta_date_time          as date_time_record_id_updated, 
        l.table_name 
from lastmile_upload.odk_vaccineTracker a
    left outer join lastmile_upload.view_log_update_nchap_id_last as l on table_name like 'odk_vaccineTracker'
;

