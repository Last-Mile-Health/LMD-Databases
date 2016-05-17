use lastmile_chwdb;

drop view if exists dc_view_trainingResultsRecordDataCleanup;

create view dc_view_trainingResultsRecordDataCleanup as
select
      s.errorMessage,
      
      q.trainingName,
      q.trainingDate,
      q.facilitatorName,
      q.facilitatorID,
      q.county,
      q.city,
      q.trainingType,
  
      q.formRow,
      q.participantID,
      q.gender,
      q.participantName,
      q.participantPosition,
      q.preTest,
      q.postTest,
      q.score_LV,
      q.score_K,
      q.score_PE,
      q.score_total,
      
      -- Rename and group the primary keys so they show up in the far right of the spreadsheet.
      q.trainingResultsRecordStep1ID          as formID,
      q.trainingResultsRecordDataQualityID    as dataQualityID
      
from staging_trainingResultsRecordDataQualityStatus as s
    inner join staging_trainingResultsRecordDataQuality as q on ( s.trainingResultsRecordStep1ID = q.trainingResultsRecordStep1ID ) and 
                                                                ( s.trainingResultsRecordDataQualityID = q.trainingResultsRecordDataQualityID )
where s.deleteRecord = 0;
