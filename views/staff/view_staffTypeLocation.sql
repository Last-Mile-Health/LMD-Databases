use lastmile_chwdb;

drop view if exists view_staffTypeLocation;

create view view_staffTypeLocation as

select 
      staffType,
      staffID,
      staffName,
      
      group_concat( distinct district                 separator ', '  ) as district,
      group_concat( distinct healthFacility           separator ', '  ) as healthFacility,
      group_concat( distinct healthDistrict           separator ', '  ) as healthDistrict,
      group_concat( distinct county                   separator ', '  ) as county
    
from view_staffTypeLocationAll
where not ( ( staffID is null ) or ( staffID like '' ) )
group by  staffType,
          staffID,
          staffName
