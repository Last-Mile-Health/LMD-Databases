use lastmile_chwdb;

drop view if exists view_odkSickChildTreatmentPneumonia;

create view view_odkSickChildTreatmentPneumonia as

select    
      s.chwID,
      year( s.meta_autoDate )      as formYear,
      month( s.meta_autoDate )     as formMonth,
      count( * )                   as numberPneumoniaTreatment,
      l.staffName,
      l.district,
      l.healthDistrict,
      l.healthFacility,
      l.county
      
from staging_odk_sickChildForm as s
    left outer join view_staffTypeLocation as l on ( s.chwID = l.staffID ) and ( l.staffType like 'CHW' )
where trim( treatPneumonia ) = '1'

group by 
       s.chwID,
       year( s.meta_autoDate ),      
       month( s.meta_autoDate )  
       
order by 
       cast( s.chwID as unsigned ) asc,
       year( s.meta_autoDate ) desc,      
       month( s.meta_autoDate ) desc
      