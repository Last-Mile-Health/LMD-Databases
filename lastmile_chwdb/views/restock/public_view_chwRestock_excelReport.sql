use lastmile_chwdb;

drop view if exists public_view_chwRestock_excelReport;

create view public_view_chwRestock_excelReport as

select
        r.meta_autoDate,
 
        -- pull meta data in from the staging table
        o.meta_dataEntry_startTime,	
        o.meta_dataEntry_endTime,	
        o.meta_dataSource,	
        o.meta_formVersion,	
        o.meta_deviceID,

        r.manualDate,	
        r.chwlID,	
        r.supervisedChwID,
	
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

        null as stockOnHand_ACT100mg,	
        null as restockType_ACT100mg,	
        null as partialRestock_ACT100mg,	
        null as stockOutReason_ACT100mg,	
        null as fullStock_ACT100mg,
	
        r.stockOnHand_Paracetamol120mg,	
        r.restockType_Paracetamol120mg,	
        r.partialRestock_Paracetamol120mg,	
        r.stockOutReason_Paracetamol120mg,	
        r.fullStock_Paracetamol120mg,
	
        null as stockOnHand_Paracetamol250mg,	
        null as restockType_Paracetamol250mg,	
        null as partialRestock_Paracetamol250mg,	
        null as stockOutReason_Paracetamol250mg,	
        null as fullStock_Paracetamol250mg,	

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

        null as stockOnHand_VitaminA_100000,	
        null as restockType_VitaminA_100000,	
        null as fullStock_VitaminA_100000,	
        null as partialRestock_VitaminA_100000,	
        null as stockOutReason_VitaminA_100000,	

        null as stockOnHand_Mebendazole500mg,	
        null as restockType_Mebendazole500mg,	
        null as partialRestock_Mebendazole500mg,	
        null as stockOutReason_Mebendazole500mg,	
        null as fullStock_Mebendazole500mg,	

        null as stockOnHand_microgynon,	
        null as restockType_microgynon,	
        null as partialRestock_microgynon,	
        null as stockOutReason_microgynon,	
        null as fullStock_microgynon,	

        null as stockOnHand_maleCondoms,	
        null as restockType_maleCondoms,	
        null as partialRestock_maleCondoms,	
        null as stockOutReason_maleCondoms,	
        null as fullStock_maleCondoms,	

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

        null as stockOnHand_babyScale,	
        null as restockType_babyScale,	
        null as stockOutReason_babyScale,	
        null as fullStock_babyScale,	

        r.stockOnHand_digitalThermometer,	
        r.restockType_digitalThermometer,	
        r.stockOutReason_digitalThermometer,	
        r.fullStock_digitalThermometer,	

        null as stockOnHand_stopwatch,	
        null as restockType_stopwatch,	
        null as stockOutReason_stopwatch,	
        null as fullStock_stopwatch,
	
        null as stockOnHand_chlorhexadine,	
        null as restockType_chlorhexadine,	
        null as stockOutReason_chlorhexadine,	
        null as fullStock_chlorhexadine,	
        
        r.stockOnHand_disposableGloves,	
        r.restockType_disposableGloves,	
        r.partialRestock_disposableGloves,	
        r.stockOutReason_disposableGloves,	
        r.fullStock_disposableGloves,
	
        r.stockOnHand_plasticCup,	
        r.restockType_plasticCup,	
        r.stockOutReason_plasticCup,	
        r.fullStock_plasticCup,
	
        null as stockOnHand_disposableBags,	
        null as restockType_disposableBags,	
        null as partialRestock_disposableBags,	
        null as stockOutReason_disposableBags,	
        null as fullStock_disposableBags,	

        null as stockOnHand_cotton,	
        null as restockType_cotton,	
        null as stockOutReason_cotton,	
        null as fullStock_cotton,	

        null as stockOnHand_marker,	
        null as restockType_marker,	
        null as stockOutReason_marker,	
        null as fullStock_marker,	

        null as stockOnHand_screeningTool,	
        null as restockType_screeningTool,	
        null as stockOutReason_screeningTool,	
        null as fullStock_screeningTool,	

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

        null as stockOnHand_sicknessScreeningTool,	
        null as restockType_sicknessScreeningTool,	
        null as partialRestock_sicknessScreeningTool,	
        null as stockOutReason_sicknessScreeningTool,	
        null as fullStock_sicknessScreeningTool,	

        r.stockOnHand_sickChildForm,	
        r.restockType_sickChildForm,	
        r.partialRestock_sickChildForm,	
        r.stockOutReason_sickChildForm,	
        r.fullStock_sickChildForm,	

        null as stockOnHand_malariaForm,	
        null as restockType_malariaForm,	
        null as partialRestock_malariaForm,	
        null as stockOutReason_malariaForm,	
        null as fullStock_malariaForm,

        null as stockOnHand_pregnancyTrackingForm,	
        null as restockType_pregnancyTrackingForm,	
        null as partialRestock_pregnancyTrackingForm,	
        null as stockOutReason_pregnancyTrackingForm,	
        null as fullStock_pregnancyTrackingForm,	

        null as stockOnHand_mohReferralForm,	
        null as restockType_mohReferralForm,	
        null as partialRestock_mohReferralForm,	
        null as stockOutReason_mohReferralForm,	
        null as fullStock_mohReferralForm,	

        null as stockOnHand_movementTrackingForm,	
        null as restockType_movementTrackingForm,	
        null as partialRestock_movementTrackingForm,	
        null as stockOutReason_movementTrackingForm,	
        null as fullStock_movementTrackingForm,	

        null as stockOnHand_educationAndScreeningLedger,	
        null as restockType_educationAndScreeningLedger,	
        null as partialRestock_educationAndScreeningLedger,	
        null as stockOutReason_educationAndScreeningLedger,	
        null as fullStock_educationAndScreeningLedger,	

        null as stockOnHand_familyPlanningForm,	
        null as restockType_familyPlanningForm,	
        null as partialRestock_familyPlanningForm,	
        null as stockOutReason_familyPlanningForm,	
        null as fullStock_familyPlanningForm,	

        null as stockOnHand_infantTrackingForm,	
        null as restockType_infantTrackingForm,	
        null as partialRestock_infantTrackingForm,	
        null as stockOutReason_infantTrackingForm,	
        null as fullStock_infantTrackingForm,	

        null as stockOnHand_wellChildForm,	
        null as restockType_wellChildForm,	
        null as partialRestock_wellChildForm,	
        null as stockOutReason_wellChildForm,	
        null as fullStock_wellChildForm,	

        r.stockOnHand_chwWorkPlan,	
        r.restockType_chwWorkPlan,	
        r.fullStock_chwWorkPlan,	
        r.partialRestock_chwWorkPlan,	
        r.stockOutReason_chwWorkPlan,
	
        r.stockOnHand_CommunityReferralForm,	
        r.restockType_CommunityReferralForm,	
        r.fullStock_CommunityReferralForm,	
        r.partialRestock_CommunityReferralForm,	
        r.stockOutReason_CommunityReferralForm,	

        -- pull meta data in from the staging table
        o.meta_lastUpdate_user,	
        o.meta_lastUpdate_datetime,	
        o.meta_insertDatetime,
        
        r.chwRestockID
        
from scm_chwRestock as r
    left outer join staging_odk_chwrestock as o on r.chwRestockID = o.chwRestockID -- note: chwRestockID is pk for all restock tables.
order by r.chwRestockID asc
;