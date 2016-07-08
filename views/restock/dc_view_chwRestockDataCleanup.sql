use lastmile_chwdb;

drop view if exists dc_view_chwRestockDataCleanup;

create view dc_view_chwRestockDataCleanup as
select
      s.ErrorMessage,
 
      q.meta_autoDate,
      q.manualDate,
      
      q.chwlID,
      q.chwlName,
      q.supervisedChwID,
      q.communityID,
  
      q.stockOnHand_ACT25mg,
      q.restockType_ACT25mg,
      q.partialRestock_ACT25mg,
      q.stockOutReason_ACT25mg,
      q.fullStock_ACT25mg,
  
      q.stockOnHand_ACT50mg,
      q.restockType_ACT50mg,
      q.partialRestock_ACT50mg,
      q.stockOutReason_ACT50mg,
      q.fullStock_ACT50mg,
  
      q.stockOnHand_Paracetamol120mg,
      q.restockType_Paracetamol120mg,
      q.partialRestock_Paracetamol120mg,
      q.stockOutReason_Paracetamol120mg,
      q.fullStock_Paracetamol120mg,
  
      q.stockOnHand_ORS,
      q.restockType_ORS,
      q.partialRestock_ORS,
      q.stockOutReason_ORS,
      q.fullStock_ORS,
  
      q.stockOnHand_ZincSulfate,
      q.restockType_ZincSulfate,
      q.partialRestock_ZincSulfate,
      q.stockOutReason_ZincSulfate,
      q.fullStock_ZincSulfate,
  
      q.stockOnHand_amoxicillin250mg,
      q.restockType_amoxicillin250mg,
      q.partialRestock_amoxicillin250mg,
      q.stockOutReason_amoxicillin250mg,
      q.fullStock_amoxicillin250mg,
  
      q.stockOnHand_amoxicillin125mg,
      q.restockType_amoxicillin125mg,
      q.partialRestock_amoxicillin125mg,
      q.stockOutReason_amoxicillin125mg,
      q.fullStock_amoxicillin125mg,
  
      q.stockOnHand_muacStrap,
      q.restockType_muacStrap,
      q.stockOutReason_muacStrap,
      q.fullStock_muacStrap,
  
      q.stockOnHand_MalariaRDT,
      q.restockType_MalariaRDT,
      q.partialRestock_MalariaRDT,
      q.stockOutReason_MalariaRDT,
      q.fullStock_MalariaRDT,
  
      q.stockOnHand_stethoscope,
      q.restockType_stethoscope,
      q.stockOutReason_stethoscope,
      q.fullStock_stethoscope,
  
      q.stockOnHand_digitalThermometer,
      q.restockType_digitalThermometer,
      q.stockOutReason_digitalThermometer,
      q.fullStock_digitalThermometer,
  
      q.stockOnHand_disposableGloves,
      q.restockType_disposableGloves,
      q.partialRestock_disposableGloves,
      q.stockOutReason_disposableGloves,
      q.fullStock_disposableGloves,
  
      q.stockOnHand_plasticCup,
      q.restockType_plasticCup,
      q.stockOutReason_plasticCup,
      q.fullStock_plasticCup,
  
      q.stockOnHand_doseCard,
      q.restockType_doseCard,
      q.stockOutReason_doseCard,
      q.fullStock_doseCard,
  
      q.stockOnHand_ebolaScreeningTool,
      q.restockType_ebolaScreeningTool,
      q.stockOutReason_ebolaScreeningTool,
      q.fullStock_ebolaScreeningTool,
  
      q.stockOnHand_routineVisitForm,
      q.restockType_routineVisitForm,
      q.partialRestock_routineVisitForm,
      q.stockOutReason_routineVisitForm,
      q.fullStock_routineVisitForm,
  
      q.stockOnHand_sickChildForm,
      q.restockType_sickChildForm,
      q.partialRestock_sickChildForm,
      q.stockOutReason_sickChildForm,
      q.fullStock_sickChildForm,
  
      q.stockOnHand_chwWorkPlan,
      q.restockType_chwWorkPlan,
      q.partialRestock_chwWorkPlan,
      q.stockOutReason_chwWorkPlan,
      q.fullStock_chwWorkPlan,
  
      q.stockOnHand_CommunityReferralForm,
      q.restockType_CommunityReferralForm,
      q.partialRestock_CommunityReferralForm,
      q.stockOutReason_CommunityReferralForm,
      q.fullStock_CommunityReferralForm,
  
      q.chwRestockID

from staging_odk_chwRestockDataQualityStatus as s
    inner join staging_odk_chwRestockDataQuality as q on s.chwRestockID = q.chwRestockID 
where s.deleteRecord = 0
;