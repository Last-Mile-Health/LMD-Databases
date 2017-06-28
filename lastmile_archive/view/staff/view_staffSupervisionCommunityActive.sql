use lastmile_archive;

drop view if exists view_staffSupervisionCommunityActive;

create view view_staffSupervisionCommunityActive as 

select 

      h.ccsID,
      h.ccs,
      h.ccsDateOfBirth,
      h.ccsGender,
      h.ccsPhoneNumber,
      
      h.chwlID, 
      h.chwl, 
      h.chwlDateOfBirth, 
      h.chwlGender,
      h.chwlPhoneNumber,

      h.chwID, 
      h.chw, 
      h.chwDateOfBirth, 
      h.chwGender, 
      h.chwPhoneNumber,
      
      h.communityID,
      h.community,
      h.districtID,
      h.district,
      h.healthDistrictID,
      h.healthDistrict,
      h.healthFacilityID,
      h.healthFacility,
      h.countyID,
      h.county

from view_staffSupervisionCommunityHistory as h
where 
      -- Is the CCS active or inactive
      ( ( h.ccsStatus               like 'active' ) or ( h.ccsStatus               is null ) ) and
      -- Is the CCS actively supervising CHW-L
      ( ( h.ccsSupervisionStatus    like 'active' ) or ( h.ccsSupervisionStatus    is null ) ) and

      -- Is the CHW-L active or inactive
      ( ( h.chwlStatus              like 'active' ) or ( h.chwlStatus              is null ) ) and
      -- Is CHW-L actively supervising CHW
      ( ( h.chwlSupervisionStatus   like 'active' ) or ( h.chwlSupervisionStatus   is null ) ) and  
      
      -- Is the CHW active or inactive 
      ( ( h.chwStatus               like 'active' ) or ( h.chwStatus               is null ) ) and   
      -- Is CHW actively providing health services to community
      ( ( h.chwCommunityStatus      like 'active' ) or ( h.chwCommunityStatus      is null ) )
;