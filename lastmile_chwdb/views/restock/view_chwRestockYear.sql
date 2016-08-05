use lastmile_chwdb;

drop view if exists view_chwRestockYear;

create view view_chwRestockYear as

select
      year( manualDate ) as chwRestockYear
from view_chwRestock
group by year( manualDate )
order by year( manualDate ) desc
;
