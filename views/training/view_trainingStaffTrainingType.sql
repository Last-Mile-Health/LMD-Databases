use lastmile_chwdb;

drop view if exists view_trainingStaffTrainingType;

create view view_trainingStaffTrainingType as
select

      s.staffID,
      s.firstName,
      s.lastName,
      s.gender,
      s.datePositionBegan,
      s.datePositionEnded,
      s.title,
      
      v.trainingType
      
from view_staffHistory as s
    cross join view_trainingTypeValue as v
;