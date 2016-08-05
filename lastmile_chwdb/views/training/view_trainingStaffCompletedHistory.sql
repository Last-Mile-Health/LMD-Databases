-- Pivot the rows in view_trainingStaffCompletedByRows into columns using group by and the max function.  
-- This is MySQL's clunky way of performing a pivot or crosstab query.

use lastmile_chwdb;

drop view if exists view_trainingStaffCompletedHistory;

create view view_trainingStaffCompletedHistory as
select

      c.staffID,
      mapStaffIDToCounty( c.staffID ) as county,
      c.firstName,
      c.lastName,
      c.gender,
      c.datePositionBegan,
      c.datePositionEnded,
      c.title,
      
      -- It's either going to be a 1, 0, or null so just use max function  
      max( if( ( c.title like 'CHW') &&   ( c.trainingType like 'CHW1' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_CHW1,
      max( if( ( c.title like 'CHW') &&   ( c.trainingType like 'CHW2' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_CHW2,
      max( if( ( c.title like 'CHW') &&   ( c.trainingType like 'CHW3' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_CHW3,
      max( if( ( c.title like 'CHW') &&   ( c.trainingType like 'CHW4' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_CHW4,
      
      max( if( ( c.title like 'CHWL') &&  ( c.trainingType like 'LMA1' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_LMA1,
      max( if( ( c.title like 'CHWL') &&  ( c.trainingType like 'LMA2' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_LMA2,
      max( if( ( c.title like 'CHWL') &&  ( c.trainingType like 'LMA3' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_LMA3,
      max( if( ( c.title like 'CHWL') &&  ( c.trainingType like 'LMA4' ), if( not c.participantID is null, 1, 0 ), null ) ) as received_LMA4

from view_trainingStaffCompletedByRows as c
group by  c.staffID,
          c.firstName,
          c.lastName,
          c.gender,
          c.datePositionBegan,
          c.datePositionEnded,
          c.title
;