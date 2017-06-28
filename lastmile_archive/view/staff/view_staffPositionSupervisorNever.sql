use lastmile_archive;

drop view if exists view_staffPositionSupervisorNever;

create view view_staffPositionSupervisorNever as

select
      staffID, 
      staffName,
      `position`    as  staffPosition,
      supervisorID
from view_staffPositionSupervisor
where supervisorID is null
group by staffID, supervisorID
;