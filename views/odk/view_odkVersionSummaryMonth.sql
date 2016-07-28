use lastmile_chwdb;

drop view if exists view_odkVersionSummaryMonth;

create view view_odkVersionSummaryMonth as

select 
      v.formName,
      v.staffType,
      v.staffID,
      v.formVersion,
      year( v.formDate )      as formYear,
      month( v.formDate )     as formMonth,
      count( * )              as numberRecords,
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
       v.formVersion,
       year( v.formDate ),
       month( v.formDate )
order by 
       v.formName asc,
       v.staffType asc,
       cast( v.staffID as unsigned ) asc,
       cast( v.formVersion as unsigned ) desc,
       year( v.formDate ) desc,
       month( v.formDate ) desc
       