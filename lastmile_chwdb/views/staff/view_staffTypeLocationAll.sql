use lastmile_chwdb;

drop view if exists view_staffTypeLocationAll;

create view view_staffTypeLocationAll as

select
      'CHW'             as staffType,
      chwID             as staffID,
      chw               as staffName,
      community,
      district,
      healthDistrict,
      healthFacility,
      county
from view_staffSupervisionCommunityHistory

union

select
      'CHW-L'            as staffType,
      chwlID             as staffID,
      chwl               as staffName,
      null               as community,
      district,
      healthDistrict,
      healthFacility,
      county
from view_staffSupervisionCommunityHistory

union

select
      'CCS'             as staffType,
      ccsID             as staffID,
      ccs               as staffName,
      null              as community,
      district,
      healthDistrict,
      healthFacility,
      county
from view_staffSupervisionCommunityHistory
;
