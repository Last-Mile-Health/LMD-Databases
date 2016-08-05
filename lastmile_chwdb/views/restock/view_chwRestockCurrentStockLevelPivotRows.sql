use lastmile_chwdb;

drop view if exists view_chwRestockCurrentStockLevelPivotRows;

create view view_chwRestockCurrentStockLevelPivotRows as

select

      p.chwID,                             
      p.chwRestockYear,
      'ACT 25mg'                                                            as inventoryItemDate,                                                       
      if( p.chwRestockMonth like '1',   p.ACT25mgCurrentStockLevel, null )  as january,
      if( p.chwRestockMonth like '2',   p.ACT25mgCurrentStockLevel, null )  as february,
      if( p.chwRestockMonth like '3',   p.ACT25mgCurrentStockLevel, null )  as march,
      if( p.chwRestockMonth like '4',   p.ACT25mgCurrentStockLevel, null )  as april,
      if( p.chwRestockMonth like '5',   p.ACT25mgCurrentStockLevel, null )  as may,
      if( p.chwRestockMonth like '6',   p.ACT25mgCurrentStockLevel, null )  as june,
      if( p.chwRestockMonth like '7',   p.ACT25mgCurrentStockLevel, null )  as july,
      if( p.chwRestockMonth like '8',   p.ACT25mgCurrentStockLevel, null )  as august,
      if( p.chwRestockMonth like '9',   p.ACT25mgCurrentStockLevel, null )  as september,
      if( p.chwRestockMonth like '10',  p.ACT25mgCurrentStockLevel, null )  as october,
      if( p.chwRestockMonth like '11',  p.ACT25mgCurrentStockLevel, null )  as november,
      if( p.chwRestockMonth like '12',  p.ACT25mgCurrentStockLevel, null )  as december

from view_chwRestockCurrentStockLevelByRows as p
group by p.chwID, p.chwRestockYear

union

select

      p.chwID,                             
      p.chwRestockYear,                   
      'ACT 50mg'                                                            as inventoryItemDate,                                                       
      if( p.chwRestockMonth like '1',   p.ACT50mgCurrentStockLevel, null )  as january,
      if( p.chwRestockMonth like '2',   p.ACT50mgCurrentStockLevel, null )  as february,
      if( p.chwRestockMonth like '3',   p.ACT50mgCurrentStockLevel, null )  as march,
      if( p.chwRestockMonth like '4',   p.ACT50mgCurrentStockLevel, null )  as april,
      if( p.chwRestockMonth like '5',   p.ACT50mgCurrentStockLevel, null )  as may,
      if( p.chwRestockMonth like '6',   p.ACT50mgCurrentStockLevel, null )  as june,
      if( p.chwRestockMonth like '7',   p.ACT50mgCurrentStockLevel, null )  as july,
      if( p.chwRestockMonth like '8',   p.ACT50mgCurrentStockLevel, null )  as august,
      if( p.chwRestockMonth like '9',   p.ACT50mgCurrentStockLevel, null )  as september,
      if( p.chwRestockMonth like '10',  p.ACT50mgCurrentStockLevel, null )  as october,
      if( p.chwRestockMonth like '11',  p.ACT50mgCurrentStockLevel, null )  as november,
      if( p.chwRestockMonth like '12',  p.ACT50mgCurrentStockLevel, null )  as december
      
from view_chwRestockCurrentStockLevelByRows as p
group by p.chwID, p.chwRestockYear

union

select

      p.chwID,                             
      p.chwRestockYear,                   
      'ACT 100mg'                                                           as inventoryItemDate,                                                       
      if( p.chwRestockMonth like '1',   p.ACT100mgCurrentStockLevel, null ) as january,
      if( p.chwRestockMonth like '2',   p.ACT100mgCurrentStockLevel, null ) as february,
      if( p.chwRestockMonth like '3',   p.ACT100mgCurrentStockLevel, null ) as march,
      if( p.chwRestockMonth like '4',   p.ACT100mgCurrentStockLevel, null ) as april,
      if( p.chwRestockMonth like '5',   p.ACT100mgCurrentStockLevel, null ) as may,
      if( p.chwRestockMonth like '6',   p.ACT100mgCurrentStockLevel, null ) as june,
      if( p.chwRestockMonth like '7',   p.ACT100mgCurrentStockLevel, null ) as july,
      if( p.chwRestockMonth like '8',   p.ACT100mgCurrentStockLevel, null ) as august,
      if( p.chwRestockMonth like '9',   p.ACT100mgCurrentStockLevel, null ) as september,
      if( p.chwRestockMonth like '10',  p.ACT100mgCurrentStockLevel, null ) as october,
      if( p.chwRestockMonth like '11',  p.ACT100mgCurrentStockLevel, null ) as november,
      if( p.chwRestockMonth like '12',  p.ACT100mgCurrentStockLevel, null ) as december
     
from view_chwRestockCurrentStockLevelByRows as p
group by p.chwID, p.chwRestockYear
;