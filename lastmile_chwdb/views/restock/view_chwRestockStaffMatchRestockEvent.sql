use lastmile_chwdb;

drop view if exists view_chwRestockStaffMatchRestockEvent;

-- This view performs an inner join against all the active and inactive staff who have ever been 
-- associated with each other and the chwlID and chwID columns in the scm_chwRestock table.  
-- It then performs a union and a right outer join against the the scm_chwRestock table to 
-- include the restock records that were not included in the inner join.  Failure to inner join 
-- happened because of missing or incorrect chwlID and chwID in either the staff tables or the 
-- scm_chwRestock table.  Nonetheless, we still want to report these records because they 
-- capture a restock event that happened, even though it was not properly recorded.

create view view_chwRestockStaffMatchRestockEvent as

select
      -- pulled from view_staffSupervisionCommunityHistory
      p.chwlID,
      p.chwl,
      p.chwl                              as adminStaffChwl,
      p.chwID,
      p.chw,
      p.chw                               as adminStaffChw,
      p.chwlStatus,
      p.chwlSupervisionStatus,
      p.chwStatus, 
      p.chwCommunityStatusList,
      p.districtList,
      p.healthFacilityList,
      p.healthDistrictList,
      p.countyList,
      
      -- restock event identifying data
      r.chwRestockID,
      r.chwlID                      as restockChwlID,
      r.chwlName                    as restockChwl,
      r.supervisedChwID             as restockChwID,
      r.communityID                 as restockCommunityID,
      r.meta_autoDate,
      r.manualDate,
      
      -- restock event item data
      r.stockOnHand_ACT25mg,
      r.restockType_ACT25mg,
      r.partialRestock_ACT25mg,
      r.stockOutReason_ACT25mg,
      r.fullStock_ACT25mg,

      r.stockOnHand_ACT50mg,
      r.restockType_ACT50mg,
      r.partialRestock_ACT50mg,
      r.stockOutReason_ACT50mg,
      r.fullStock_ACT50mg,

      r.stockOnHand_Paracetamol120mg,
      r.restockType_Paracetamol120mg,
      r.partialRestock_Paracetamol120mg,
      r.stockOutReason_Paracetamol120mg,
      r.fullStock_Paracetamol120mg,

      r.stockOnHand_ORS,
      r.restockType_ORS,
      r.partialRestock_ORS,
      r.stockOutReason_ORS,
      r.fullStock_ORS,

      r.stockOnHand_ZincSulfate,
      r.restockType_ZincSulfate,
      r.partialRestock_ZincSulfate,
      r.stockOutReason_ZincSulfate,
      r.fullStock_ZincSulfate,

      r.stockOnHand_amoxicillin250mg,
      r.restockType_amoxicillin250mg,
      r.partialRestock_amoxicillin250mg,
      r.stockOutReason_amoxicillin250mg,
      r.fullStock_amoxicillin250mg,

      r.stockOnHand_amoxicillin125mg,
      r.restockType_amoxicillin125mg,
      r.partialRestock_amoxicillin125mg,
      r.stockOutReason_amoxicillin125mg,
      r.fullStock_amoxicillin125mg,

      r.stockOnHand_muacStrap,
      r.restockType_muacStrap,
      r.stockOutReason_muacStrap,
      r.fullStock_muacStrap,

      r.stockOnHand_MalariaRDT,
      r.restockType_MalariaRDT,
      r.partialRestock_MalariaRDT,
      r.stockOutReason_MalariaRDT,
      r.fullStock_MalariaRDT,

      r.stockOnHand_stethoscope,
      r.restockType_stethoscope,
      r.stockOutReason_stethoscope,
      r.fullStock_stethoscope,

      r.stockOnHand_digitalThermometer,
      r.restockType_digitalThermometer,
      r.stockOutReason_digitalThermometer,
      r.fullStock_digitalThermometer,
        
      r.stockOnHand_disposableGloves,
      r.restockType_disposableGloves,
      r.partialRestock_disposableGloves,
      r.stockOutReason_disposableGloves,
      r.fullStock_disposableGloves,
  
      r.stockOnHand_plasticCup,
      r.restockType_plasticCup,
      r.stockOutReason_plasticCup,
      r.fullStock_plasticCup,
  
      r.stockOnHand_doseCard,
      r.restockType_doseCard,
      r.stockOutReason_doseCard,
      r.fullStock_doseCard,

      r.stockOnHand_ebolaScreeningTool,
      r.restockType_ebolaScreeningTool,
      r.stockOutReason_ebolaScreeningTool,
      r.fullStock_ebolaScreeningTool,

      r.stockOnHand_routineVisitForm,
      r.restockType_routineVisitForm,
      r.partialRestock_routineVisitForm,
      r.stockOutReason_routineVisitForm,
      r.fullStock_routineVisitForm,

      r.stockOnHand_sickChildForm,
      r.restockType_sickChildForm,
      r.partialRestock_sickChildForm,
      r.stockOutReason_sickChildForm,
      r.fullStock_sickChildForm,
        
      r.stockOnHand_chwWorkPlan,
      r.restockType_chwWorkPlan,
      r.partialRestock_chwWorkPlan,
      r.stockOutReason_chwWorkPlan,
      r.fullStock_chwWorkPlan,
      

      r.stockOnHand_CommunityReferralForm,
      r.restockType_CommunityReferralForm,
      r.partialRestock_CommunityReferralForm,
      r.stockOutReason_CommunityReferralForm,
      r.fullStock_CommunityReferralForm
      
from view_chwRestockStaffDiscreteChwlChwPair as p
    inner join scm_chwRestock as r on ( p.chwlID = r.chwlID ) and ( p.chwID = r.supervisedChwID )
    
union 

select
      -- pulled from view_staffSupervisionCommunityHistory
      p.chwlID,
      p.chwl,
      concat( l.firstName, ' ', l.lastName ) as adminStaffChwl,
      p.chwID,
      p.chw,
      concat( w.firstName, ' ', w.lastName ) as adminStaffChw,
      p.chwlStatus,
      p.chwlSupervisionStatus,
      p.chwStatus, 
      p.chwCommunityStatusList,
      p.districtList,
      p.healthFacilityList,
      p.healthDistrictList,
      p.countyList,
      
      -- restock event identifying data
      r.chwRestockID,               
      r.chwlID                      as restockChwlID,
      r.chwlName                    as restockChwl,
      r.supervisedChwID             as restockChwID,
      r.communityID                 as restockCommunityID,
      r.meta_autoDate,
      r.manualDate,
      
      -- restock event item data
      r.stockOnHand_ACT25mg,
      r.restockType_ACT25mg,
      r.partialRestock_ACT25mg,
      r.stockOutReason_ACT25mg,
      r.fullStock_ACT25mg,

      r.stockOnHand_ACT50mg,
      r.restockType_ACT50mg,
      r.partialRestock_ACT50mg,
      r.stockOutReason_ACT50mg,
      r.fullStock_ACT50mg,

      r.stockOnHand_Paracetamol120mg,
      r.restockType_Paracetamol120mg,
      r.partialRestock_Paracetamol120mg,
      r.stockOutReason_Paracetamol120mg,
      r.fullStock_Paracetamol120mg,

      r.stockOnHand_ORS,
      r.restockType_ORS,
      r.partialRestock_ORS,
      r.stockOutReason_ORS,
      r.fullStock_ORS,

      r.stockOnHand_ZincSulfate,
      r.restockType_ZincSulfate,
      r.partialRestock_ZincSulfate,
      r.stockOutReason_ZincSulfate,
      r.fullStock_ZincSulfate,

      r.stockOnHand_amoxicillin250mg,
      r.restockType_amoxicillin250mg,
      r.partialRestock_amoxicillin250mg,
      r.stockOutReason_amoxicillin250mg,
      r.fullStock_amoxicillin250mg,

      r.stockOnHand_amoxicillin125mg,
      r.restockType_amoxicillin125mg,
      r.partialRestock_amoxicillin125mg,
      r.stockOutReason_amoxicillin125mg,
      r.fullStock_amoxicillin125mg,

      r.stockOnHand_muacStrap,
      r.restockType_muacStrap,
      r.stockOutReason_muacStrap,
      r.fullStock_muacStrap,

      r.stockOnHand_MalariaRDT,
      r.restockType_MalariaRDT,
      r.partialRestock_MalariaRDT,
      r.stockOutReason_MalariaRDT,
      r.fullStock_MalariaRDT,

      r.stockOnHand_stethoscope,
      r.restockType_stethoscope,
      r.stockOutReason_stethoscope,
      r.fullStock_stethoscope,

      r.stockOnHand_digitalThermometer,
      r.restockType_digitalThermometer,
      r.stockOutReason_digitalThermometer,
      r.fullStock_digitalThermometer,
        
      r.stockOnHand_disposableGloves,
      r.restockType_disposableGloves,
      r.partialRestock_disposableGloves,
      r.stockOutReason_disposableGloves,
      r.fullStock_disposableGloves,
  
      r.stockOnHand_plasticCup,
      r.restockType_plasticCup,
      r.stockOutReason_plasticCup,
      r.fullStock_plasticCup,
  
      r.stockOnHand_doseCard,
      r.restockType_doseCard,
      r.stockOutReason_doseCard,
      r.fullStock_doseCard,

      r.stockOnHand_ebolaScreeningTool,
      r.restockType_ebolaScreeningTool,
      r.stockOutReason_ebolaScreeningTool,
      r.fullStock_ebolaScreeningTool,

      r.stockOnHand_routineVisitForm,
      r.restockType_routineVisitForm,
      r.partialRestock_routineVisitForm,
      r.stockOutReason_routineVisitForm,
      r.fullStock_routineVisitForm,

      r.stockOnHand_sickChildForm,
      r.restockType_sickChildForm,
      r.partialRestock_sickChildForm,
      r.stockOutReason_sickChildForm,
      r.fullStock_sickChildForm,
        
      r.stockOnHand_chwWorkPlan,
      r.restockType_chwWorkPlan,
      r.partialRestock_chwWorkPlan,
      r.stockOutReason_chwWorkPlan,
      r.fullStock_chwWorkPlan,
     
      r.stockOnHand_CommunityReferralForm,
      r.restockType_CommunityReferralForm,
      r.partialRestock_CommunityReferralForm,
      r.stockOutReason_CommunityReferralForm,
      r.fullStock_CommunityReferralForm
      
from view_chwRestockStaffDiscreteChwlChwPair as p
    right outer join scm_chwRestock as r on ( p.chwlID = r.chwlID ) and ( p.chwID = r.supervisedChwID )
        -- LOJ in admin_staff values for all restock chwlIDs and supervisedChwIDs.  We don't want
        -- to display the CHWL name string here.  Moreover, there is no name string for CHWs.
        left outer join admin_staff as l on r.chwlID            = l.staffID
        left outer join admin_staff as w on r.supervisedChwID   = w.staffID
;