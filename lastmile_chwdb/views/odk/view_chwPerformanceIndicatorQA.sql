use lastmile_chwdb;

drop view if exists view_chwPerformanceIndicatorQA;

create view view_chwPerformanceIndicatorQA as

select    
     
      s1.chwID,
      s1.yearReported,      
      s1.monthReported,     
      if( s1.iCCMNutritionNumberInitialSickChildVisitsTotal is null,  0, s1.iCCMNutritionNumberInitialSickChildVisitsTotal )  as initialSickChildVisit,
      if( s1.iCCMNutritionReferredForDangerSignTotal is null,         0, s1.iCCMNutritionReferredForDangerSignTotal )         as referredForDangerSign,
      if( s1.professionalismSupervisionVisitAttemptedTotal is null,   0, s1.professionalismSupervisionVisitAttemptedTotal )   as supervisionVisitAttempted,
      if( s1.professionalismCHWAbsentForSupervisionTotal is null,     0, s1.professionalismCHWAbsentForSupervisionTotal )     as CHWAbsentForSupervision,
      if( s1.professionalismExcusedAbsenceTotal is null,              0, s1.professionalismExcusedAbsenceTotal )              as excusedAbsence,
      
      l.staffName,
      l.district,
      l.healthDistrict,
      l.healthFacility,
      l.county
      
from staging_chwMonthlyServiceReportStep1 as s1
      left outer join staging_chwMonthlyServiceReportStep1 as s2 on ( ( s1.chwID = s2.chwID                                                       ) and
                                                                      ( s1.yearReported = s2.yearReported                                         ) and
                                                                      ( s1.monthReported = s2.monthReported                                      ) and
                                                                      ( s1.chwMonthlyServiceReportStep1ID >= s2.chwMonthlyServiceReportStep1ID  )  )

      left outer join view_staffTypeLocation as l on ( s1.chwID = l.staffID ) and ( l.staffType like 'CHW' )

group by 
       s1.chwID,
       s1.yearReported,      
       s1.monthReported
       
having count( * ) >= 1
       
order by 
       cast( s1.chwID as unsigned ) asc,
       s1.yearReported desc,      
       s1.monthReported desc
;   
