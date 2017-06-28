-- List of CHW-Ls who have never been supervised by a CCS and have never supervised a CHW.

use lastmile_archive;

drop view if exists view_staffSupervisionChwlNeverAssignCcsChw;

create view view_staffSupervisionChwlNeverAssignCcsChw as
select
      chwlID,
      chwl,
      chwlDateOfBirth,
      chwlGender,
      chwlPhoneNumber,
      chwlStatus,
      chwlDateBegan,
      chwlDateEnded,
      ccsID,
      ccs,
      ccsSupervisionStatus,
      ccsSupervisionBegan,
      ccsSupervisionEnded
from view_staffSupervisionChwlCcsHistory
where ( chwlID in ( select staffID 
                    from view_staffPositionSupervisorNever 
                    where staffPosition like 'CHWL' ) )
      and
      ( not chwlID in ( select chwlID 
                        from view_staffSupervisionChwChwlHistory 
                        where not chwlID is null ) )
 ;      