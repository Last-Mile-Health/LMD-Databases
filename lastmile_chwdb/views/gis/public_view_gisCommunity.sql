use lastmile_chwdb;

drop view if exists public_view_gisCommunity;

create view public_view_gisCommunity as
select
      c.X                                   as X,
      c.Y                                   as Y,
      c.communityID                         as MYSQL_ID,	
      c.name                                as town_name,
      c.alternativeName                     as alt_name,
      c.status                              as status,
      d.name                                as adm_distri,
      h.name                                as health_dis,
      f.name                                as health_facility,
      c.proximityHealthFacility             as remoteness,
      c.mappingHouseholdCount               as HH_count,
      c.cellReception                       as CD_cell,
      c.notes                               as notes,
      c.miningCommunity                     as miningComm,
      c.LMS_2016                            as LMS_2016

from admin_community as c
    inner join admin_territoryLevel3 as d on c.districtID = d.territoryLevel3ID
        inner join admin_territoryLevel2 as h on d.territoryLevel2ID = h.territoryLevel2ID
    left outer join admin_healthFacility as f on c.healthFacilityID = f.healthFacilityID
;
