use lastmile_chwdb;

drop view if exists view_staffHistory;

create view view_staffHistory as 

select

      s.staffID,
      s.firstName,
      s.lastName,
      s.gender,
      s.dateOfBirth,
      s.phoneNumber,
      a.datePositionBegan,
      a.datePositionEnded,
      p.title
      
from admin_staff as s
    inner join admin_staffPositionAssoc as a on s.staffID = a.staffID
        inner join admin_position as p on a.positionID = p.positionID
;