use lastmile_chwdb;

drop view if exists view_countyStaffHistory;

create view view_countyStaffHistory as

select
      country,	
      county,	
      countyID,
      
      chwID                     as staffID,	
      chw                       as staff,
      chwGender                 as gender,	
      chwPosition               as staffPosition,	
      chwDatePositionBegan      as datePositionBegan,	
      chwDatePositionEnded      as datePositionEnded
      
from view_territoryCommunityStaffHistory
where not ( ( chwID is null ) or ( chwID like '' ) )

union

select

      country,	
      county,	
      countyID,	

      chwlID                    as staffID,	
      chwl                      as staff,
      chwlGender                as gender,	
      chwlPosition              as staffPosition,	
      chwlDatePositionBegan     as datePositionBegan,	
      chwlDatePositionEnded     as datePositionEnded

from view_territoryCommunityStaffHistory
where not ( ( chwlID is null ) or ( chwlID like '' ) )

union

select

      country,	
      county,	
      countyID,		

      ccsID                    as staffID,	
      ccs                      as staff,
      ccsGender                as gender,	
      ccsPosition              as staffPosition,	
      ccsDatePositionBegan     as datePositionBegan,	
      ccsDatePositionEnded     as datePositionEnded

from view_territoryCommunityStaffHistory
where not ( ( ccsID is null ) or ( ccsID like '' ) )