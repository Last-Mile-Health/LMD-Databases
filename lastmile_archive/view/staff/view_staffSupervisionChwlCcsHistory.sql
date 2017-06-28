use lastmile_archive;

drop view if exists view_staffSupervisionChwlCcsHistory;

create view view_staffSupervisionChwlCcsHistory as
select
      c.staffID                 as chwlID,
      c.staffName               as chwl,
      c.dateOfBirth             as chwlDateOfBirth,
      c.gender                  as chwlGender,
      c.phoneNumber             as chwlPhoneNumber,
      case
          when  not ( ( c.datePositionBegan is null ) or ( trim( c.datePositionBegan ) like '' ) ) and 
                    ( ( c.datePositionEnded is null ) or ( trim( c.datePositionEnded ) like '' ) ) then 'active'
          when  not ( ( c.datePositionBegan is null ) or ( trim( c.datePositionBegan ) like '' ) ) and 
                not ( ( c.datePositionEnded is null ) or ( trim( c.datePositionEnded ) like '' ) ) then 'inactive'
          else null
      end as chwlStatus,
      c.datePositionBegan       as chwlDateBegan,
      c.datePositionEnded       as chwlDateEnded,
      
      c.supervisorID            as ccsID,
      case
          when  not ( ( s.firstName is null ) or ( trim( s.firstName )  like '' ) )  and 
                not ( ( s.lastName  is null ) or ( trim( s.lastName )   like '' ) )  then concat( s.firstName, ' ', s.lastName )
          else null
      end as ccs,
      case
          when  not ( ( c.dateSupervisionBegan is null ) or ( trim( c.dateSupervisionBegan ) like '' ) ) and 
                    ( ( c.dateSupervisionEnded is null ) or ( trim( c.dateSupervisionEnded ) like '' ) ) then 'active'
          when  not ( ( c.dateSupervisionBegan is null ) or ( trim( c.dateSupervisionBegan ) like '' ) ) and 
                not ( ( c.dateSupervisionEnded is null ) or ( trim( c.dateSupervisionEnded ) like '' ) ) then 'inactive'
          else null
      end as ccsSupervisionStatus,
      c.dateSupervisionBegan    as ccsSupervisionBegan,
      c.dateSupervisionEnded    as ccsSupervisionEnded
      
from view_staffPositionSupervisor as c
-- All we want is the CCS's name with the left outer join
      left outer join chwdb_admin_staff as s on c.supervisorID = s.staffID
where ( c.`position` like 'CHWL' )
;