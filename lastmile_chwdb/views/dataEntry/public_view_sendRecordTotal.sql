use lastmile_chwdb;

drop view if exists public_view_sendRecordTotal;

create view public_view_sendRecordTotal as 

select
      'odk'                                                   as formType,
      'arrival log'                                           as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_arrivalchecklog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'departure log'                                         as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_departurechecklog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'chw restock'                                           as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_chwrestock
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'chw restock archive'                                   as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_chwrestock_archive
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'chw supervision report'                                as formName,
      if( chwlID >= 2000, 'Rivercess', 'Grand Gedeh' )        as county,
      year( meta_insertDate )                                 as yearRecord,
      month( meta_insertDate )                                as monthRecord,
      count( * )                                              as recordCount
from staging_odk_chwsupervisionreport
where not ( ( meta_insertDate is null ) or ( trim( meta_insertDate ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'health survey'                                         as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_healthsurvey
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'routine visit'                                         as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_routinevisit
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'routine visit archive'                                 as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDate )                                 as yearRecord,
      month( meta_insertDate )                                as monthRecord,
      count( * )                                              as recordCount
from staging_odk_routinevisit_archive
where not ( ( meta_insertDate is null ) or ( trim( meta_insertDate ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'sick child'                                            as formName,
      if( chwID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_sickChildForm
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

union all

select
      'odk'                                                   as formType,
      'supervision visit log'                                 as formName,
      if( ccsID >= 2000, 'Rivercess', 'Grand Gedeh' )         as county,
      year( meta_insertDatetime )                             as yearRecord,
      month( meta_insertDatetime )                            as monthRecord,
      count( * )                                              as recordCount
from staging_odk_supervisionvisitlog
where not ( ( meta_insertDatetime is null ) or ( trim( meta_insertDatetime ) like '' ) )
group by county, yearRecord, monthRecord

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
group by county, yearRecord, monthRecord
;





 










      
      