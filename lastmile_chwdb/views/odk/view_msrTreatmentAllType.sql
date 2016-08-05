use lastmile_chwdb;

drop view if exists view_msrTreatmentAllType;

create view view_msrTreatmentAllType as

select
      chwID,
      yearReported,      
      monthReported,     
      numberPneumoniaTreatment as numberTreatment,
      staffName,
      district,
      healthDistrict,
      healthFacility,
      county
from view_msrTreatmentPneumonia

union all

select
      chwID,
      yearReported,      
      monthReported,     
      numberMalariaTreatment as numberTreatment,
      staffName,
      district,
      healthDistrict,
      healthFacility,
      county
from view_msrTreatmentMalaria

union all

select
      chwID,
      yearReported,      
      monthReported,     
      numberDiarrheaTreatment as numberTreatment,
      staffName,
      district,
      healthDistrict,
      healthFacility,
      county
from view_msrTreatmentDiarrhea

union all

select
      chwID,
      yearReported,      
      monthReported,     
      numberMalnutritionTreatment as numberTreatment,
      staffName,
      district,
      healthDistrict,
      healthFacility,
      county
from view_msrTreatmentMalnutrition


