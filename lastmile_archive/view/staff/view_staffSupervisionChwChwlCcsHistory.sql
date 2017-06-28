use lastmile_archive;

drop view if exists view_staffSupervisionChwChwlCcsHistory;

create view view_staffSupervisionChwChwlCcsHistory as
select
      c.chwID, 
      c.chw, 
      c.chwDateOfBirth, 
      c.chwGender, 
      c.chwPhoneNumber,
      c.chwStatus, 
      c.chwDateBegan, 
      c.chwDateEnded,
      
      c.chwlSupervisionStatus, 
      c.chwlSupervisionBegan,
      c.chwlSupervisionEnded,
      
      c.chwlID, 
      c.chwl, 
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

from view_staffSupervisionChwChwlHistory as c
    left outer join view_staffSupervisionChwlCcsHistory as s on c.chwlID = s.chwlID
        left outer join view_staffPosition as p on  ( s.ccsID = p.staffID ) and 
                                                    ( ( trim( p.title ) like 'CCS' ) or  ( trim( p.title ) like '' ) or ( p.title is null ) )
;