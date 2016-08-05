use lastmile_chwdb;

drop view if exists view_chwRestockChwIDMasterList;

create view view_chwRestockChwIDMasterList as

select
      chwID 
from view_territoryCommunityStaffHistory 
group by chwID
order by chwID
;
