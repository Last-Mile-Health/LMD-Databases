use lastmile_archive;

drop view if exists view_staffSupervisionChwChwlHistory;

create view view_staffSupervisionChwChwlHistory as
select
      c.staffID                 as chwID,
      c.staffName               as chw,
      c.dateOfBirth             as chwDateOfBirth,
      c.gender                  as chwGender,
      c.phoneNumber             as chwPhoneNumber,
      case
          when  not ( ( c.datePositionBegan is null ) or ( trim( c.datePositionBegan ) like '' ) ) and 
                    ( ( c.datePositionEnded is null ) or ( trim( c.datePositionEnded ) like '' ) ) then 'active'
          when  not ( ( c.datePositionBegan is null ) or ( trim( c.datePositionBegan ) like '' ) ) and 
                not ( ( c.datePositionEnded is null ) or ( trim( c.datePositionEnded ) like '' ) ) then 'inactive'
          else null
      end as chwStatus,
      c.datePositionBegan                           as chwDateBegan,
      c.datePositionEnded                           as chwDateEnded,
      
      c.supervisorID                                as chwlID,
      case
          when  not ( ( s.firstName is null ) or ( trim( s.firstName )  like '' ) )  and 
                not ( ( s.lastName  is null ) or ( trim( s.lastName )   like '' ) )  then concat( s.firstName, ' ', s.lastName )
          else null
      end as chwl,
      case
          when  not ( ( c.dateSupervisionBegan is null ) or ( trim( c.dateSupervisionBegan ) like '' ) ) and 
                    ( ( c.dateSupervisionEnded is null ) or ( trim( c.dateSupervisionEnded ) like '' ) ) then 'active'
          when  not ( ( c.dateSupervisionBegan is null ) or ( trim( c.dateSupervisionBegan ) like '' ) ) and 
                not ( ( c.dateSupervisionEnded is null ) or ( trim( c.dateSupervisionEnded ) like '' ) ) then 'inactive'
          else null
      end as chwlSupervisionStatus,
      c.dateSupervisionBegan    as chwlSupervisionBegan,
      c.dateSupervisionEnded    as chwlSupervisionEnded
      
from view_staffPositionSupervisor as c
-- All we want is the CHWL's name with the left outer join
      left outer join chwdb_admin_staff as s on c.supervisorID = s.staffID
where ( c.`position` like 'CHW' )
;