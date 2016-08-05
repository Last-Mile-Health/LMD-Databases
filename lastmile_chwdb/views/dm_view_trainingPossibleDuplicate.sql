use lastmile_chwdb;

drop view if exists dm_view_trainingPossibleDuplicate;

create view dm_view_trainingPossibleDuplicate as
select
      r.trainingResultsRecordID,
      
      r.staffID,
      r.staffName,
      r.participantPosition,
      r.trainingType,
      r.trainingName,
      r.trainingDate,
      
      r.formID,
      r.formRow,
      
      r.preTest,
      r.postTest,
      r.score_LV,
      r.score_K,
      r.score_PE,
      r.score_total,

      r.facilitatorName,
      r.facilitatorID,
      r.county,
      r.city,
      r.gender

from dm_view_trainingPossibleDuplicateCount as c
    inner join view_trainingResultsRecordStaffReport as r on  ( c.staffID =             r.staffID             ) and 
                                                              ( c.participantPosition = r.participantPosition ) and
                                                              ( c.trainingType =        r.trainingType        )
order by r.staffID, r.participantPosition, r.trainingType
;