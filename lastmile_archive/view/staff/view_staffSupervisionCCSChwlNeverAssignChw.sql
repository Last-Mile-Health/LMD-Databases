use lastmile_archive;

drop view if exists view_staffSupervisionCCSChwlNeverAssignChw;

create view view_staffSupervisionCCSChwlNeverAssignChw as

select
      s.chwlID,
      s.chwl,
      s.chwlDateOfBirth,
      s.chwlGender,
      s.chwlPhoneNumber,	
      s.chwlStatus,
      s.chwlDateBegan,
      s.chwlDateEnded,
      s.ccsID,
      s.ccs,
      s.ccsSupervisionStatus,
      s.ccsSupervisionBegan,
      s.ccsSupervisionEnded
  
from view_staffSupervisionChwlCcsHistory as s
where ( not ( trim( s.chwlID ) in ( select trim( chwlID ) 
                                  from view_staffSupervisionChwChwlHistory
                                  where not ( ( chwlID is null ) or ( trim( chwlID ) like '' ) )
                                  group by trim( chwlID ) ) )
      ) and
      not ( ( ccsID is null ) or ( trim( ccsID ) like '' ) )
;

