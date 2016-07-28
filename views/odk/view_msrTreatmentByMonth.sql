use lastmile_chwdb;

drop view if exists view_msrTreatmentByMonth;

create view view_msrTreatmentByMonth as

select
      chwID,
      yearReported,      
      monthReported,     
      sum( numberTreatment ) as numberTreatment,
      staffName,
      district,
      healthDistrict,
      healthFacility,
      county
from view_msrTreatmentAllType

group by 
      chwID,
      yearReported,      
      monthReported  
       
order by 
      cast( chwID as unsigned ) asc,
      yearReported desc,      
      monthReported desc