use lastmile_archive;

drop view if exists view_staffSupervisionCCSNeverAssignChwl;

create view view_staffSupervisionCCSNeverAssignChwl as
select
      s.staffID                   as ccsID,
      s.staffName                 as ccs,
      s.dateOfBirth               as ccsDateOfBirth,
      s.gender                    as ccsGender,
      s.phoneNumber               as ccsPhoneNumber,
      s.datePositionBegan         as ccsDateBegan,
      s.datePositionEnded         as ccsDateEnded
            
from view_staffPositionSupervisor as s
where ( s.`position` like 'CCS' ) and 
      not ( trim( s.staffID ) in (  select trim( ccsID ) 
                                    from view_staffSupervisionChwlCcsHistory
                                    where not ( ( ccsID is null ) or ( trim( ccsID ) like '' ) )
                                    group by trim( ccsID ) ) )
;