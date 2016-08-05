use lastmile_chwdb;

drop view if exists view_trainingResultsRecord;

create view view_trainingResultsRecord as

select
      -- debug only
      p.formID,
      
      p.participantID,

      if( trim( p.participantPosition ) like 'CHW Leader',  'CHWL',
      if( trim( p.participantPosition ) like 'CHW-L',       'CHWL',
          trim( p.participantPosition ) ) )                             as participantPosition,
      p.trainingType                                                    as participantTrainingType,
      
      p.trainingDate

from program_trainingResultsRecord as p
      left outer join program_trainingResultsRecord as p1 on  ( p.participantID       =   p1.participantID        ) and
                                                              (   (   if( trim( p.participantPosition ) like 'CHW Leader',  'CHWL',  
                                                                      if( trim( p.participantPosition ) like 'CHW-L',       'CHWL',
                                                                          trim( p.participantPosition ) ) ) ) = 
                                                                  (   if( trim( p.participantPosition ) like 'CHW Leader',  'CHWL',  
                                                                      if( trim( p.participantPosition ) like 'CHW-L',       'CHWL',
                                                                          trim( p.participantPosition ) ) ) ) ) and
                                                              ( p.trainingType        =   p1.trainingType         ) and
                                                              ( p.trainingDate        <=  p1.trainingDate )
                                                              -- <= here throws out earlier dates when staff took the same training in the same position
      
where ( not p.participantID       is null ) and 
      ( not p.participantPosition is null ) and  
      ( not p.trainingType        is null ) and
      ( not p.trainingDate        is null )
      
group by  p.participantID,

          if( trim( p.participantPosition ) like 'CHW Leader',  'CHWL',  
          if( trim( p.participantPosition ) like 'CHW-L',       'CHWL',
              trim( p.participantPosition ) ) ),
          
          p.trainingType, 
          p.trainingDate
          
having count( * ) <= 1       
;