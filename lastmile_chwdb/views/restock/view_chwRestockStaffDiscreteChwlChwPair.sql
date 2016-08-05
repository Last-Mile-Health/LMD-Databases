use lastmile_chwdb;

drop view if exists view_chwRestockStaffDiscreteChwlChwPair;

create view view_chwRestockStaffDiscreteChwlChwPair as

select
      r.chwlID,
      r.chwl,
      r.chwID,
      r.chw,
      r.chwlStatus,
      r.chwlSupervisionStatus,
      r.chwStatus, 
      group_concat( distinct concat( if( r.chwCommunityStatus like 'active', '', 'Inactive' ), ': ', r.communityAndIDList ) order by r.chwCommunityStatus separator '; '  ) as chwCommunityStatusList,
      r.districtList,
      r.healthFacilityList,
      r.healthDistrictList,
      r.countyList
      
from view_chwRestockStaffActiveInactive as r
group by r.chwlID,
        r.chwl,
        r.chwID,
        r.chw,
        r.chwlStatus,
        r.chwlSupervisionStatus,
        r.chwStatus
;
                    