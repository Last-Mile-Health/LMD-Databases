use lastmile_archive;

drop view if exists view_staffPositionSupervisor;

create view view_staffPositionSupervisor as

select
      s.staffID                               as staffID,
      concat( s.firstName, ' ', s.lastName )  as staffName,
      s.dateOfBirth                           as dateOfBirth,
      s.gender                                as gender,
      s.phoneNumber                           as phoneNumber,
      
      p.title                                 as `position`,
      p.positionID                            as positionID,
      
      spa.datePositionBegan                   as datePositionBegan,
      spa.datePositionEnded                   as datePositionEnded,
      
      ssa.supervisorID                        as supervisorID,
      ssa.dateAssocBegan                      as dateSupervisionBegan,
      ssa.dateAssocEnded                      as dateSupervisionEnded,
      
      p2.positionID                           as supervisorPositionID,
      p2.title                                as supervisorPosition

from chwdb_admin_staff as s
  left outer join chwdb_admin_staffPositionAssoc as spa on s.staffID = spa.staffID
      left outer join chwdb_admin_position as p on spa.positionID = p.positionID
  left outer join chwdb_admin_staffSupervisorAssoc as ssa on s.staffID = ssa.staffID
      left outer join chwdb_admin_staffPositionAssoc as ssap on ssa.supervisorID = ssap.staffID
          left outer join chwdb_admin_position as p2 on ssap.positionID = p2.positionID
where case
          when ( trim( p.title ) like 'CHW'  ) and ( trim( p2.title ) like 'CHWL' ) then ( 1 = 1 ) -- CHW's supervisor is a CHWL force true
          when ( trim( p.title ) like 'CHWL' ) and ( trim( p2.title ) like 'CCS'  ) then ( 1 = 1 ) -- CHWL's supervisor is a CCS force true
          when ( p2.title is null ) or ( trim( p2.title ) like '' )                 then ( 1 = 1 ) -- Case no supervisor has ever been assigned
          else ( 1 = 2 ) -- the record's supervisory hierarchy is wrong (e.g. CCS -> CHW), force false 
      end
;