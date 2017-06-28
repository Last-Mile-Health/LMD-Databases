use lastmile_archive;

drop view if exists view_chwCommunityHistory;

create view view_chwCommunityHistory as 

select
      a.chwID,
      a.communityID,
      
      case
          when  not ( ( a.DateAssocBegan is null ) or ( trim( a.DateAssocBegan ) like '' ) ) and 
                    ( ( a.DateAssocEnded is null ) or ( trim( a.DateAssocEnded ) like '' ) ) then 'active'
          when  not ( ( a.DateAssocBegan is null ) or ( trim( a.DateAssocBegan ) like '' ) ) and 
                not ( ( a.DateAssocEnded is null ) or ( trim( a.DateAssocEnded ) like '' ) ) then 'inactive'
          else null
      end as chwCommunityStatus,
      
      a.DateAssocBegan      as dateAssocBegan,
      a.DateAssocEnded      as dateAssocEnded
      
from chwdb_admin_chwCommunityAssoc as a
;