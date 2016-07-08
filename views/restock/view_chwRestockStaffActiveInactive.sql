use lastmile_chwdb;

drop view if exists view_chwRestockStaffActiveInactive;

create view view_chwRestockStaffActiveInactive as

select
      h.chwlID, 
      h.chwl,
      h.chwID, 
      h.chw,
      
      h.chwlStatus,
      h.chwlSupervisionStatus,
      h.chwStatus,
      h.chwCommunityStatus,             

      group_concat( distinct concat( h.community, ' (', h.communityID, ') ' ) order by h.community separator ', '  ) as communityAndIDList,
      group_concat( distinct h.district                 separator ', '  ) as districtList,
      group_concat( distinct h.healthFacility           separator ', '  ) as healthFacilityList,
      group_concat( distinct h.healthDistrict           separator ', '  ) as healthDistrictList,
      group_concat( distinct h.county                   separator ', '  ) as countyList
      
from view_staffSupervisionCommunityHistory as h
where   not ( ( ( chwlID is null ) or ( trim( chwlID ) like '' ) ) or
            ( (   chwID  is null ) or ( trim( chwID  ) like '' ) ) ) 
        
group by  h.chwlID, 
          h.chwl,         
          h.chwID, 
          h.chw,
          h.chwlStatus,
          h.chwlSupervisionStatus,
          h.chwStatus,                                
          h.chwCommunityStatus
;
