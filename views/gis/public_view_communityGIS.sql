use lastmile_chwdb;

drop view if exists public_view_communityGIS;

create view public_view_communityGIS as
select
      concat( 'Point (', c.X, ' ', c.Y, ')' ) as wkt_geom,
      c.X                                   as X,
      c.Y                                   as Y,
      c.communityID                         as MYSQL_ID,	
      c.name                                as town_name,
      c.alternativeName                     as alt_name,
      d.name                                as adm_distri,
      h.name                                as health_dis,
      c.proximityHealthFacility             as remoteness,
      c.mappingHouseholdCount               as HH_count,
      c.cellReception                       as CD_cell,
      c.dateMapped                          as `time`,
      c.mappingRound                        as mappingRnd,
      c.notes                               as notes,
      c.miningCommunity                     as miningComm,
      rowNumber()                           as id,
      c.LMS_2016                            as LMS_2016

from admin_communityGIS as c
    inner join admin_territoryLevel3 as d on c.districtID = d.territoryLevel3ID
        inner join admin_territoryLevel2 as h on d.territoryLevel2ID = h.territoryLevel2ID
;
