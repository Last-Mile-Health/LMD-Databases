use lastmile_chwdb;

drop view if exists view_territoryCommunityChwRestock;

-- Show all CHWs who were ever active and associated with a community,
-- along with their associations with CHW-Ls and CCSs  Also, show all
-- communities in the database that  never had a CHW asssociated with 
-- them.

-- If a community exists in the community table and has never had a 
-- CHW associated with it, it may be a good candidate to be removed
-- from the database.

-- We can't be certain that the CHW's CHW-L will always restock him or
-- her so we can't have the CHW-L in query. 

-- Group by every field because we want to have a single record
-- for a each CHW for each community.  Dups will show up when
-- a CHW has more than one CHW-L in any given year.  Another reason
-- to structure it this way is that we can't always be certain that 
-- the same CHW-L will always be the one to do the restock.  He or
-- she could be out sick and another CHW-L may do it.  So just
-- organize by community and CHW and leave CHW-L out of it.

create view view_territoryCommunityChwRestock as
select
      h.country,
      h.county,	
      h.countyID,	
      h.healthDistrict,	
      h.healthDistrictID,	
      h.district,	
      h.districtID,	
      h.community,	
      h.communityID,
      h.dateChwCommunityAssocBegan,	
      h.dateChwCommunityAssocEnded,	
      h.chwID,
      h.chw
--      chwGender,
--      chwDatePositionBegan,	
--      chwDatePositionEnded
from view_territoryCommunityStaffHistory as h
where not ( ( communityID is null ) or ( communityID like '' ) )
group by  h.country,
          h.county,	
          h.countyID,	
          h.healthDistrict,	
          h.healthDistrictID,	
          h.district,	
          h.districtID,	
          h.community,	
          h.communityID,
          h.dateChwCommunityAssocBegan,	
          h.dateChwCommunityAssocEnded,	
          h.chwID,
          h.chw
;

