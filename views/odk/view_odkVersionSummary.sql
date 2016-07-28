use lastmile_chwdb;

drop view if exists view_odkVersionSummary;

create view view_odkVersionSummary as

select 
      v.formName,
      v.staffType,
      v.staffID,
      v.formVersion,
      max( v.formDate )      as lastDate,
      count( * )             as numberRecords,
      l.staffName,
      l.district,
      l.healthDistrict,
      l.healthFacility,
      l.county
from view_odkVersion as v
    left outer join view_staffTypeLocation as l on ( v.staffType = l.staffType ) and ( v.staffID = l.staffID )

group by 
       v.formName,
       v.staffType,
       v.staffID,
       v.formVersion
order by 
       v.formName asc,
       v.staffType asc,
       cast( v.staffID as unsigned ) asc,
       cast( v.formVersion as unsigned ) desc
       
