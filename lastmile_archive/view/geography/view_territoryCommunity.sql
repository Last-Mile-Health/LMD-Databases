use lastmile_archive;

drop view if exists view_territoryCommunity;

create view view_territoryCommunity as
select
		ac.name 	                  as country,
		atl1.name 	                as county,
    atl1.territoryLevel1ID      as countyID,
		atl2.name 	                as healthDistrict,
    atl2.territoryLevel2ID      as healthDistrictID,
 		atl3.name 	                as district,
    atl3.territoryLevel3ID      as districtID,
 		c.name 	                    as community,
    c.communityID               as communityID,
    c.mappingHouseholdCount     as mappingHouseholdCount,
    c.healthFacilityID          as healthFacilityID
    
from chwdb_admin_country as ac
	left outer join chwdb_admin_territoryLevel1 as atl1 on ac.countryID = atl1.countryID
		left outer join chwdb_admin_territoryLevel2 as atl2 on atl1.territoryLevel1ID = atl2.territoryLevel1ID
			left outer join chwdb_admin_territoryLevel3 as atl3 on atl2.territoryLevel2ID = atl3.territoryLevel2ID
					left outer join chwdb_admin_community as c on atl3.territoryLevel3ID = c.districtID
;
   