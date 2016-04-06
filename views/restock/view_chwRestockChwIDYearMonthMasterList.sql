-- Cross join the distinct years that are in view_chwReport with
-- every month to generate a table of years and months.  Then, cross join 
-- that with every chwID from those years to create a master list of every
-- chwID, year, and month.

use lastmile_chwdb;

drop view if exists view_chwRestockChwIDYearMonthMasterList;

create view view_chwRestockChwIDYearMonthMasterList as

select
      h.*,
      y.chwRestockYear      as chwRestockYear,
      m.monthNumber         as chwRestockMonth     
from view_chwRestockYear as y
    cross join view_month as m
        left outer join view_territoryCommunityChwRestock as h on ( ( y.chwRestockYear >= year( h.dateChwCommunityAssocBegan ) ) and 
                                                                    ( ( y.chwRestockYear <= year( h.dateChwCommunityAssocEnded ) ) or 
                                                                      ( ( h.dateChwCommunityAssocEnded is null )          or 
                                                                        ( h.dateChwCommunityAssocEnded like '' ) 
                                                                      ) 
                                                                    ) 
                                                                  )
order by h.communityID, h.chwID, y.chwRestockYear asc, m.monthNumber asc
; 