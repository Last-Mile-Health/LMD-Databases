use lastmile_chwdb;

drop view if exists public_view_sendRecordTotal;

create view public_view_sendRecordTotal as

select
      'web'                                                   as formType,
      'Sick Child'                                            as formName,
      if( fhwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from lastmile_db.tbl_data_fhw_sch_sickchild
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'web'                                                   as formType,
      'Health Survey'                                         as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_kpiAssessmentStep1
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'web'                                                   as formType,
      'Household Registration'                                as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_householdRegistrationStep1
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'web'                                                   as formType,
      'CHA Monthly Service Report'                            as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_chwMonthlyServiceReportStep1
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'Arrival Log'                                           as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_arrivalchecklog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'Departure Log'                                         as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_departurechecklog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'CHA Restock'                                           as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_chwrestock
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'CHA Restock Archive'                                   as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_chwrestock_archive
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'CHA Supervision Report'                                as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDate )                                 as yearRecord,
      month( meta_insertDate )                                as monthRecord,
      count( * )                                              as recordCount
from staging_odk_chwsupervisionreport
where not ( ( meta_insertDate is null ) or ( trim( meta_insertDate ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'Health Survey'                                         as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_healthsurvey
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'Routine Visit'                                         as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_routinevisit
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'Routine Visit Archive'                                 as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDate )                                 as yearRecord,
      month( meta_insertDate )                                as monthRecord,
      count( * )                                              as recordCount
from staging_odk_routinevisit_archive
where not ( ( meta_insertDate is null ) or ( trim( meta_insertDate ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'Sick Child'                                            as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_sickChildForm
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'Supervision Visit Log'                                 as formName,
      if( ccsID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_supervisionvisitlog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'vaccine tracker'                                       as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_vaccinetracker
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by formType, formName, county, yearRecord, monthRecord
;





 










      
      