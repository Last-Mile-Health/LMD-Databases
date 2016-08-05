use lastmile_chwdb;

drop view if exists view_trainingStaffCompletedByRows;

create view view_trainingStaffCompletedByRows as
select
      t.staffID,
      t.firstName,
      t.lastName,
      t.gender,
      t.datePositionBegan,
      t.datePositionEnded,
      t.title,
      t.trainingType,
      
      p.participantID,
      p.participantPosition,
      p.participantTrainingType,
      p.trainingDate

from view_trainingStaffTrainingType as t
    left outer join view_trainingResultsRecord as p 
         on ( t.staffID = p.participantID ) and
            ( trim( t.title ) like  ( if( trim( p.participantPosition ) like 'CHW Leader',  'CHWL',
                                      if( trim( p.participantPosition ) like 'CHW-L',       'CHWL',
                                          trim( p.participantPosition ) ) )
                                     )
            )                               and
            ( trim( t.trainingType ) like trim( p.participantTrainingType ) )
;

