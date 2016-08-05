use lastmile_chwdb;

drop view if exists view_staffActive;

create view view_staffActive as 
select
      s.staffID,
      s.firstName,
      s.lastName,
      s.gender,
      spa.positionID,
      p.title
from admin_staff as s
  inner join admin_staffPositionAssoc as spa on s.staffID = spa.staffID
    inner join admin_position as p on spa.positionID = p.positionID
where not spa.datePositionBegan is null and spa.datePositionEnded is null;
