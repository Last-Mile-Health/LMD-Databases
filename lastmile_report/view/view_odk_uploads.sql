use lastmile_report;

drop view if exists lastmile_report.view_odk_uploads;

create view lastmile_report.view_odk_uploads as 
select 
      'CHA restock'                                       as `Form type`,
      cast( r.meta_insertDatetime as date )               as `Upload date`,
      date_format( r.meta_insertDatetime, '%h:%i %p' )    as `Upload time`,
      count( * )                                          as `# Records`,
      trim( r.meta_uploadUser )                           as `Upload user`
from lastmile_upload.odk_chaRestock as r
group by `Upload date` , `Upload time`

union all

select 
      'Vaccine Tracker'                                   as `Form type`,
      cast( r.meta_insertDatetime as date )               as `Upload date`,
      date_format( r.meta_insertDatetime, '%h:%i %p' )    as `Upload time`,
      count( * )                                          as `# Records`,
      trim( r.meta_uploadUser )                           as `Upload user`
from lastmile_upload.odk_vaccineTracker as r
group by `Upload date` , `Upload time`

union all

select 
      'Supervision Visit Log'                             as `Form type`,
      cast( r.meta_insertDatetime as date )               as `Upload date`,
      date_format( r.meta_insertDatetime, '%h:%i %p' )    as `Upload time`,
      count( * )                                          as `# Records`,
      trim( r.meta_uploadUser )                           as `Upload user`
from lastmile_upload.odk_supervisionVisitLog as r
group by `Upload date` , `Upload time`

union all

select 
      'Sick Child Form'                                   as `Form type`,
      cast( r.meta_insertDatetime as date )               as `Upload date`,
      date_format( r.meta_insertDatetime, '%h:%i %p' )    as `Upload time`,
      count( * )                                          as `# Records`,
      trim( r.meta_uploadUser )                           as `Upload user`
from lastmile_upload.odk_sickChildForm as r
group by `Upload date` , `Upload time`

union all

select 
      'Routine Visit Form'                                as `Form type`,
      cast( r.meta_insertDatetime as date )               as `Upload date`,
      date_format( r.meta_insertDatetime, '%h:%i %p' )    as `Upload time`,
      count( * )                                          as `# Records`,
      trim( r.meta_uploadUser )                           as `Upload user`
from lastmile_upload.odk_routineVisit as r
group by `Upload date` , `Upload time`

union all

select 
      'QAO Supervision Checklist Form'                    as `Form type`,
      cast( r.meta_insertDatetime as date )               as `Upload date`,
      date_format( r.meta_insertDatetime, '%h:%i %p' )    as `Upload time`,
      count( * )                                          as `# Records`,
      trim( r.meta_uploadUser )                           as `Upload user`
from lastmile_upload.odk_QAOSupervisionChecklistForm as r
group by `Upload date` , `Upload time`
;