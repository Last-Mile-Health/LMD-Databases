use lastmile_archive;

drop view if exists view_staffPosition;

create view view_staffPosition as

select 
      s.staffID,
      concat( s.firstName, ' ', s.lastName ) as staffName,
      s.dateOfBirth,
      s.gender,
      s.phoneNumber,
      
      a.datePositionBegan,
      a.datePositionEnded,
      p.title
from chwdb_admin_staff as s
    left outer join chwdb_admin_staffPositionAssoc as a on s.staffID = a.staffID
        left outer join chwdb_admin_position as p on a.positionID = p.positionID
;