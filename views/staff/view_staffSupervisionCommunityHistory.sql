use lastmile_chwdb;

drop view if exists view_staffSupervisionCommunityHistory;

create view view_staffSupervisionCommunityHistory as

select
      
      s.ccsID,
      s.ccs,
      s.ccsDateOfBirth,
      s.ccsGender,
      s.ccsPhoneNumber,

-- Is the CCS active or inactive
      s.ccsStatus,
      s.ccsDateBegan,
      s.ccsDateEnded, 
 
-- Is the CCS actively supervising CHW-L
      s.ccsSupervisionStatus, 
      s.ccsSupervisionBegan, 
      s.ccsSupervisionEnded,
      
      s.chwlID, 
      s.chwl, 
      s.chwlDateOfBirth, 
      s.chwlGender,
      s.chwlPhoneNumber,

-- Is the CHW-L active or inactive
      s.chwlStatus, 
      s.chwlDateBegan, 
      s.chwlDateEnded,

-- Is CHW-L actively supervising CHW
      s.chwlSupervisionStatus, 
      s.chwlSupervisionBegan,
      s.chwlSupervisionEnded,      

      s.chwID, 
      s.chw, 
      s.chwDateOfBirth, 
      s.chwGender, 
      s.chwPhoneNumber,
      
-- Is the CHW active or inactive      
      s.chwStatus, 
      s.chwDateBegan, 
      s.chwDateEnded,

-- Is CHW actively providing health services to community
      c.communityID,
      c.chwCommunityStatus,
      c.dateAssocBegan,
      c.dateAssocEnded,
      
      t.community,
      t.districtID,
      t.district,
      h.healthFacilityID,
      h.name                  as healthFacility,
      t.healthDistrictID,
      t.healthDistrict,
      t.countyID,
      t.county
      
from view_staffSupervisionHistory as s
      left outer join view_chwCommunityHistory as c on s.chwID = c.chwID
          left outer join view_territoryCommunity as t on c.communityID = t.communityID
                left outer join admin_healthFacility as h on t.healthFacilityID = h.healthFacilityID
;