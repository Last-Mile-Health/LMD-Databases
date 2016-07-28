use lastmile_chwdb;

drop view if exists view_msrTreatmentMalnutrition;
create view view_msrTreatmentMalnutrition as


select    
      s.chwID,
      s.yearReported,      
      s.monthReported,     
      sum( iCCMNutritionMalnutritionCasesTotal )          as numberMalnutritionTreatment,
      l.staffName,
      l.district,
      l.healthDistrict,
      l.healthFacility,
      l.county
      
from staging_chwMonthlyServiceReportStep1 as s
     left outer join view_staffTypeLocation as l on ( s.chwID = l.staffID ) and ( l.staffType like 'CHW' )
where cast(iCCMNutritionMalnutritionCasesTotal as unsigned) > 0

group by 
       s.chwID,
       s.yearReported,      
       s.monthReported  
       
order by 
       cast( s.chwID as unsigned ) asc,
       s.yearReported desc,      
       s.monthReported desc