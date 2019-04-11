use lastmile_report;

drop view if exists lastmile_report.view_qao_chss_supervision;

create view lastmile_report.view_qao_chss_supervision as 

select
      ( year( trim( q.TodayDate ) ) * 10000 ) + ( month( trim( q.TodayDate )) * 100 ) + 1 as date_key, -- set date_key to first day of mont for every record 
      
      trim( q.QAOID )       as qao_position_id,
      trim( q.TodayDate )   as today_date,
      trim( q.NameQAO )     as qao,
      trim( q.CHSSID )      as chss_position_id,
      trim( q.CHAID )       as position_id,

      q.CHSSWorkplan,
      q.CHSSCheckInProcedure,
      q.DataReviewProcess,
      q.RestockProcess,
      q.RerralProcess,
      q.CommMember,
      q.HomeAndPatientReview,
      q.CoachMentorCHA,
      q.CBISFormsCheck,
      q.DCTUsageForSVL,
      
      q.meta_UUID,
      q.meta_autoDate,
      q.meta_dataEntry_startTime,
      q.meta_dataEntry_endTime,
      q.meta_dataSource,
      q.meta_formVersion,
      q.meta_deviceID,
      q.meta_uploadUser,
      q.meta_insertDatetime,
      q.odk_QAOSupervisionChecklistForm_id

from lastmile_upload.odk_QAOSupervisionChecklistForm as q
;




  
  