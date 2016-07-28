use lastmile_chwdb;

drop view if exists view_msrTreatmentPneumonia;

create view view_msrTreatmentPneumonia as

select    
      s.chwID,
      s.yearReported,      
      s.monthReported,     
      sum( iCCMNutritionPneumoniaCasesTotal )          as numberPneumoniaTreatment,
      l.staffName,
      l.district,
      l.healthDistrict,
      l.healthFacility,
      l.county
      
from staging_chwMonthlyServiceReportStep1 as s
     left outer join view_staffTypeLocation as l on ( s.chwID = l.staffID ) and ( l.staffType like 'CHW' )
where cast(iCCMNutritionPneumoniaCasesTotal as unsigned) > 0

group by 
       s.chwID,
       s.yearReported,      
       s.monthReported  
       
order by 
       cast( s.chwID as unsigned ) asc,
       s.yearReported desc,      
       s.monthReported desc