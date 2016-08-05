use lastmile_chwdb;

drop view if exists dm_view_trainingResultsRecordMatchParticipantID;
-- only bother to match with admin_staff table is the training record is type CHW[1-4] or LMA[1-4]

create view dm_view_trainingResultsRecordMatchParticipantID as
select
      p.trainingResultsRecordID,
      p.participantID,
      s.staffID,
      p.participantName,
      concat( s.firstName, ' ', s.lastName ) as staffName,
      p.participantPosition
from program_trainingResultsRecord as p
    left outer join admin_staff as s on p.participantID = s.staffID
where trim( trainingType ) like 'CHW%' or trim( trainingType ) like 'LMA%'
order by trim( p.participantName )
