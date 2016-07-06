use lastmile_chwdb;

drop view if exists view_chwRestockReport;

create view view_chwRestockReport as

select
     
      if( ( e.chwlID  is null ) or ( trim( e.chwlID ) like '' ), e.restockChwlID, e.chwlID  )     as chwlID,
      if( ( e.chwl    is null ) or ( trim( e.chwl   ) like '' ), if( ( e.adminStaffChwl is null ) or ( trim( e.adminStaffChwl ) like '' ), 'Unknown', e.adminStaffChwl ), e.chwl ) as chwl,
      
      if( ( e.chwID   is null ) or ( trim( e.chwID  ) like '' ), e.restockChwID,  e.chwID   )     as chwID,
      if( ( e.chw     is null ) or ( trim( e.chw    ) like '' ), if( ( e.adminStaffChw is null ) or ( trim( e.adminStaffChw ) like '' ), 'Unknown', e.adminStaffChw ), e.chw ) as chw,
       
      if( ( e.chwlStatus              is null ) or ( trim( e.chwlStatus             ) like '' ), 'Unknown',       e.chwlStatus            )        as chwlStatus,
      if( ( e.chwlSupervisionStatus   is null ) or ( trim( e.chwlSupervisionStatus  ) like '' ), 'Unknown',       e.chwlSupervisionStatus )        as chwlSupervisionStatus,
      if( ( e.chwStatus               is null ) or ( trim( e.chwStatus              ) like '' ), 'Unknown',       e.chwStatus             )        as chwStatus,
      
      -- If chwCommunityStatusList is null, there's a high likelihood that chwID is null as well, so use the restockCommuniityID instead.
      if( ( e.chwCommunityStatusList  is null ) or ( trim( e.chwCommunityStatusList ) like '' ), if( ( e.restockCommunityID is null ) or ( trim( e.restockCommunityID ) like '' ), 'Unknown', e.restockCommunityID ), e.chwCommunityStatusList ) as chwCommunityStatusList,
      
      'Coming soon...'                                                                                                                              as healthFacilityList,
      
      if( ( e.districtList            is null ) or ( trim( e.districtList           ) like '' ), 'Unknown',       e.districtList          )         as districtList,
      if( ( e.healthDistrictList      is null ) or ( trim( e.healthDistrictList     ) like '' ), 'Unknown',       e.healthDistrictList    )         as healthDistrictList,
      
      -- If countyList is null, there's a high likelihood that chwID is null as well, so use the restockChwID to figure out the county
      if( ( e.countyList is null ) or ( trim( e.countyList ) like '' ), mapStaffIDToCounty( e.restockChwID ), e.countyList  ) as countyList,
      
      e.chwRestockID,  -- Primary key of chw restock event in the scm_chwRestock table.
      e.restockChwlID,
      e.restockChwl,
      e.restockChwID,
      
      e.restockCommunityID,
      
      e.meta_autoDate,
      e.manualDate,
      if( trim( e.manualDate ) like trim( e.meta_autoDate ), 1, 0 ) as dateMatch,
      
      e.stockOnHand_ACT25mg,
      e.restockType_ACT25mg,
      e.partialRestock_ACT25mg,
      e.stockOutReason_ACT25mg,
      e.fullStock_ACT25mg,

      e.stockOnHand_ACT50mg,
      e.restockType_ACT50mg,
      e.partialRestock_ACT50mg,
      e.stockOutReason_ACT50mg,
      e.fullStock_ACT50mg,

      e.stockOnHand_Paracetamol120mg,
      e.restockType_Paracetamol120mg,
      e.partialRestock_Paracetamol120mg,
      e.stockOutReason_Paracetamol120mg,
      e.fullStock_Paracetamol120mg,

      e.stockOnHand_ORS,
      e.restockType_ORS,
      e.partialRestock_ORS,
      e.stockOutReason_ORS,
      e.fullStock_ORS,

      e.stockOnHand_ZincSulfate,
      e.restockType_ZincSulfate,
      e.partialRestock_ZincSulfate,
      e.stockOutReason_ZincSulfate,
      e.fullStock_ZincSulfate,

      e.stockOnHand_amoxicillin250mg,
      e.restockType_amoxicillin250mg,
      e.partialRestock_amoxicillin250mg,
      e.stockOutReason_amoxicillin250mg,
      e.fullStock_amoxicillin250mg,

      e.stockOnHand_amoxicillin125mg,
      e.restockType_amoxicillin125mg,
      e.partialRestock_amoxicillin125mg,
      e.stockOutReason_amoxicillin125mg,
      e.fullStock_amoxicillin125mg,

      e.stockOnHand_muacStrap,
      e.restockType_muacStrap,
      e.stockOutReason_muacStrap,
      e.fullStock_muacStrap,

      e.stockOnHand_MalariaRDT,
      e.restockType_MalariaRDT,
      e.partialRestock_MalariaRDT,
      e.stockOutReason_MalariaRDT,
      e.fullStock_MalariaRDT,

      e.stockOnHand_stethoscope,
      e.restockType_stethoscope,
      e.stockOutReason_stethoscope,
      e.fullStock_stethoscope,

      e.stockOnHand_digitalThermometer,
      e.restockType_digitalThermometer,
      e.stockOutReason_digitalThermometer,
      e.fullStock_digitalThermometer,
        
      e.stockOnHand_disposableGloves,
      e.restockType_disposableGloves,
      e.partialRestock_disposableGloves,
      e.stockOutReason_disposableGloves,
      e.fullStock_disposableGloves,
  
      e.stockOnHand_plasticCup,
      e.restockType_plasticCup,
      e.stockOutReason_plasticCup,
      e.fullStock_plasticCup,
  
      e.stockOnHand_doseCard,
      e.restockType_doseCard,
      e.stockOutReason_doseCard,
      e.fullStock_doseCard,

      e.stockOnHand_ebolaScreeningTool,
      e.restockType_ebolaScreeningTool,
      e.stockOutReason_ebolaScreeningTool,
      e.fullStock_ebolaScreeningTool,

      e.stockOnHand_routineVisitForm,
      e.restockType_routineVisitForm,
      e.partialRestock_routineVisitForm,
      e.stockOutReason_routineVisitForm,
      e.fullStock_routineVisitForm,

      e.stockOnHand_sickChildForm,
      e.restockType_sickChildForm,
      e.partialRestock_sickChildForm,
      e.stockOutReason_sickChildForm,
      e.fullStock_sickChildForm,
        
      e.stockOnHand_chwWorkPlan,
      e.restockType_chwWorkPlan,
      e.partialRestock_chwWorkPlan,
      e.stockOutReason_chwWorkPlan,
      e.fullStock_chwWorkPlan,
      

      e.stockOnHand_CommunityReferralForm,
      e.restockType_CommunityReferralForm,
      e.partialRestock_CommunityReferralForm,
      e.stockOutReason_CommunityReferralForm,
      e.fullStock_CommunityReferralForm
      
from view_chwRestockStaffMatchRestockEvent as e
;
