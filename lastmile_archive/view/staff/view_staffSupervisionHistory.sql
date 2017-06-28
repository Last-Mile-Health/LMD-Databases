use lastmile_archive;

drop view if exists view_staffSupervisionHistory;

create view view_staffSupervisionHistory as

--    1) Every CHW who has ever been assigned to a CHWL who has ever been assigned to a CCS.
--    2) Every CHW who has ever been assigned to CHWL who has NEVER been assigned to a CCS.
--    3) Every CHW who has never been assigned to a CHWL

select
      a.chwID, 
      a.chw, 
      a.chwDateOfBirth, 
      a.chwGender, 
      a.chwPhoneNumber,
      a.chwStatus, 
      a.chwDateBegan, 
      a.chwDateEnded,
      
      a.chwlSupervisionStatus, 
      a.chwlSupervisionBegan,
      a.chwlSupervisionEnded,
      
      a.chwlID, 
      a.chwl, 
      a.chwlDateOfBirth, 
      a.chwlGender,
      a.chwlPhoneNumber,
      a.chwlStatus, 
      a.chwlDateBegan, 
      a.chwlDateEnded,
      
      a.ccsSupervisionStatus, 
      a.ccsSupervisionBegan, 
      a.ccsSupervisionEnded,
      
      a.ccsID,
      a.ccs,
      a.ccsDateOfBirth,
      a.ccsGender,
      a.ccsPhoneNumber,

      a.ccsStatus,
      a.ccsDateBegan,
      a.ccsDateEnded

from view_staffSupervisionChwChwlCcsHistory as a

union all

-- Every CHWL who has NEVER had a CHW assigned to her AND has NEVER been assigned to a CCS
select

      null as chwID, 
      null as chw, 
      null as chwDateOfBirth, 
      null as chwGender, 
      null as chwPhoneNumber,
      null as chwStatus, 
      null as chwDateBegan, 
      null as chwDateEnded,
      
      null as chwlSupervisionStatus, 
      null as chwlSupervisionBegan,
      null as chwlSupervisionEnded,

      l.chwlID,
      l.chwl,
      l.chwlDateOfBirth,
      l.chwlGender,
      l.chwlPhoneNumber,
      l.chwlStatus,
      l.chwlDateBegan,
      l.chwlDateEnded,
      
      null as ccsSupervisionStatus, 
      null as ccsSupervisionBegan, 
      null as ccsSupervisionEnded,
      
      null as ccsID,
      null as ccs,
      null as ccsDateOfBirth,
      null as ccsGender,
      null as ccsPhoneNumber,

      null as ccsStatus,
      null as ccsDateBegan,
      null as ccsDateEnded
      
from view_staffSupervisionChwlNeverAssignCcsChw as l

union all

-- Every CCS who has NEVER had a CHWL assigned to them.
select

      null as chwID, 
      null as chw, 
      null as chwDateOfBirth, 
      null as chwGender, 
      null as chwPhoneNumber,
      null as chwStatus, 
      null as chwDateBegan, 
      null as chwDateEnded,
      
      null as chwlSupervisionStatus, 
      null as chwlSupervisionBegan,
      null as chwlSupervisionEnded,

      null as chwlID,
      null as chwl,
      null as chwlDateOfBirth,
      null as chwlGender,
      null as chwlPhoneNumber,
      null as chwlStatus,
      null as chwlDateBegan,
      null as chwlDateEnded,
      
      null as ccsSupervisionStatus, 
      null as ccsSupervisionBegan, 
      null as ccsSupervisionEnded,

      s.ccsID,
      s.ccs,
      s.ccsDateOfBirth,
      s.ccsGender,
      s.ccsPhoneNumber,
      case
          when  not ( ( s.ccsDateBegan is null ) or ( trim( s.ccsDateBegan ) like '' ) ) and 
                    ( ( s.ccsDateEnded is null ) or ( trim( s.ccsDateEnded ) like '' ) ) then 'active'
          when  not ( ( s.ccsDateBegan is null ) or ( trim( s.ccsDateBegan ) like '' ) ) and 
                not ( ( s.ccsDateEnded is null ) or ( trim( s.ccsDateEnded ) like '' ) ) then 'inactive'
          else null
      end as ccsStatus,
      s.ccsDateBegan,
      s.ccsDateEnded

from view_staffSupervisionCCSNeverAssignChwl as s

union all

-- Every CCS who has ever been assigned to a CHWL who has NEVER been assigned a CHW.
select

      null as chwID, 
      null as chw, 
      null as chwDateOfBirth, 
      null as chwGender, 
      null as chwPhoneNumber,
      null as chwStatus, 
      null as chwDateBegan, 
      null as chwDateEnded,
      
      null as chwlSupervisionStatus, 
      null as chwlSupervisionBegan,
      null as chwlSupervisionEnded,


      s.chwlID,
      s.chwl,
      s.chwlDateOfBirth,
      s.chwlGender,
      s.chwlPhoneNumber,	
      s.chwlStatus,
      s.chwlDateBegan,
      s.chwlDateEnded,
      
      s.ccsSupervisionStatus,
      s.ccsSupervisionBegan,
      s.ccsSupervisionEnded,
      
      s.ccsID,
      s.ccs,
      
      p.dateOfBirth             ccsDateOfBirth,
      p.gender                  ccsGender,
      p.phoneNumber             ccsPhoneNumber,
      case
          when  not ( ( p.datePositionBegan is null ) or ( trim( p.datePositionBegan ) like '' ) ) and 
                    ( ( p.datePositionEnded is null ) or ( trim( p.datePositionEnded ) like '' ) ) then 'active'
          when  not ( ( p.datePositionBegan is null ) or ( trim( p.datePositionBegan ) like '' ) ) and 
                not ( ( p.datePositionEnded is null ) or ( trim( p.datePositionEnded ) like '' ) ) then 'inactive'
          else null
      end as ccsStatus,
      p.datePositionBegan       ccsDateBegan,
      p.datePositionEnded       ccsDateEnded

from view_staffSupervisionCCSChwlNeverAssignChw as s
    left outer join view_staffPosition as p on  ( s.ccsID = p.staffID ) and ( trim( p.title ) like 'CCS' )
;