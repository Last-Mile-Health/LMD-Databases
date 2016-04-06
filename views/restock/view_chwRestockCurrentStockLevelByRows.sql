use lastmile_chwdb;

drop view if exists view_chwRestockCurrentStockLevelByRows;

create view view_chwRestockCurrentStockLevelByRows as

select
      m.chwID,                             
      m.chwRestockYear,                   
      m.chwRestockMonth,
      
      e.chwID                               as existChwID,
      e.chwRestockYear                      as existChwRestockYear,
      e.chwRestockMonth                     as existChwRestockMonth,
      
      e.ACT25mgCurrentStockLevel,
      e.ACT50mgCurrentStockLevel,
      e.ACT100mgCurrentStockLevel  
      
from view_chwRestockChwIDYearMonthMasterList as m
    left outer join view_chwRestockCurrentStockLevelExist as e on ( m.chwID = e.chwID                     ) and 
                                                                  ( m.chwRestockYear = e.chwRestockYear   ) and
                                                                  ( m.chwRestockMonth = e.chwRestockMonth )
