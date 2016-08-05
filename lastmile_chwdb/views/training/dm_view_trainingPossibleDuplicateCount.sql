use lastmile_chwdb;

drop view if exists dm_view_trainingPossibleDuplicateCount;

create view dm_view_trainingPossibleDuplicateCount as
select
      r.staffID,
      r.participantPosition,
      r.trainingType,
      count( * )                as duplicateCount
from view_trainingResultsRecordStaffReport as r
group by r.staffID, r.participantPosition, r.trainingType
having count( * ) > 1
;

      
