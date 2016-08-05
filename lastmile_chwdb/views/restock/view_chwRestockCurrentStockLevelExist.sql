use lastmile_chwdb;

drop view if exists view_chwRestockCurrentStockLevelExist;

-- CHW Current Stock Level:  Since there can be more than one restock in a month, only
-- display the last one in a month.  By self-joining on view_chwRestock, we throw out
-- all the records in a group (year, month, chwID) except the latest. 

create view view_chwRestockCurrentStockLevelExist as
select
  r.chwID                                                               as chwID,
  year( r.manualDate )                                                  as chwRestockYear,
  month( r.manualDate )                                                 as chwRestockMonth,
  
  if( r.restockType_ACT25mg like 'full', 
      r.fullStock_ACT25mg, 
  if( r.restockType_ACT25mg like 'partial', 
      r.partialRestock_ACT25mg + r.stockOnHand_ACT25mg , 
      r.stockOnHand_ACT25mg ) )                                   as ACT25mgCurrentStockLevel,
      
  if( r.restockType_ACT50mg like 'full', 
      r.fullStock_ACT50mg, 
  if( r.restockType_ACT50mg like 'partial', 
      r.partialRestock_ACT50mg + r.stockOnHand_ACT50mg , 
      r.stockOnHand_ACT50mg ) )                                   as ACT50mgCurrentStockLevel,
      
  if( r.restockType_ACT100mg like 'full', 
      r.fullStock_ACT100mg, 
  if( r.restockType_ACT100mg like 'partial', 
      r.partialRestock_ACT100mg + r.stockOnHand_ACT100mg , 
      r.stockOnHand_ACT100mg ) )                                   as ACT100mgCurrentStockLevel       
      
from view_chwRestock as r
    left outer join view_chwRestock as r2 on  ( ( r.chwID = r2.chwID           )      and
                                                ( year(  r.manualDate  )  = year(   r2.manualDate  ) )    and
                                                ( month( r.manualDate )   = month(  r2.manualDate  ) ) )  and
                                                ( r.manualDate     <= r2.manualDate                )
group by r.chwID, year( r.manualDate ), month( r.manualDate )
having count( * ) <= 1
order by cast( r.chwID as unsigned ) asc, year( r.manualDate ) asc, month( r.manualDate ) asc;