use lastmile_chwdb;

drop view if exists public_view_gisCommunityChw;

create view public_view_gisCommunityChw as
select 
      g.*,
      a.chwID,
      concat( s.firstName, ' ', s.lastName ) as chw
from public_view_gisCommunity as g
    left outer join admin_chwCommunityAssoc as a on g.MYSQL_ID = a.communityID
        left outer join admin_staff as s on a.chwID = s.staffID
where a.DateAssocEnded is null
order by cast( g.MYSQL_ID as unsigned ) asc
;