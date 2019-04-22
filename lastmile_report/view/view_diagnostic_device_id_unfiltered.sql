use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_device_id_unfiltered;

create view lastmile_report.view_diagnostic_device_id_unfiltered as

-- odk_chaRestock --------------------------------------------------------------------------------------------------

select  
        'chss'                                  as id_type,
        trim( a.chssID )                        as id_value,
        a.meta_deviceID                         as meta_device_id     
from lastmile_upload.odk_chaRestock as a

union all

select  
        'chss'                                  as id_type,
        trim( a.user_id )                       as id_value,
        a.meta_deviceID                         as meta_device_id  
from lastmile_upload.odk_chaRestock as a

union all

-- 2. odk_routineVisit(CHA DCT) --------------------------------------------------------------------------------------------

select  
        'cha'                                   as id_type,
        trim( a.chaID )                         as id_value, 
        trim( a.meta_deviceID )                 as meta_device_id   
from lastmile_upload.odk_routineVisit a

union all

-- 3. odk_sickChildForm (CHA DCT) --------------------------------------------------------------------------------------------

select  
        'cha'                                   as id_type,
        trim( a.chwID )                         as id_value,
        trim( a.meta_deviceID )                 as meta_device_id 
from lastmile_upload.odk_sickChildForm a

union all

-- 4. odk_supervisionVisitLog (CHSS DCT) ---------------------------------------------------------------------

select  
        'chss'                                  as id_type,
        trim( a.chssID )                        as id_value, 
        trim( a.meta_deviceID )                 as meta_device_id 
from lastmile_upload.odk_supervisionVisitLog as a

union all

-- 5. odk_vaccineTracker (CHSS DCT)----------------------------------------------------------------------------

select  
        'chss'                                  as id_type,
        trim( a.chssID )                        as id_value, 
        trim( a.meta_deviceID )                 as meta_device_id      
from lastmile_upload.odk_vaccineTracker as a

union all

-- 6. odk_QAOSupervisionChecklistForm ---------------------------------------------------------------------

select      
        'qao'                                   as id_type,       
        trim( a.QAOID )                         as id_value,
        trim( a.meta_deviceID )                 as meta_device_id     
from lastmile_upload.odk_QAOSupervisionChecklistForm as a
;