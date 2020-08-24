use lastmile_report;



-- drop view if exists lastmile_report.view_restock_union;

-- create view lastmile_report.view_restock_union as
select 
      year( manualDate)     as restock_year,
      month( manualDate)    as restock_month,
      manualDate,
      position_id_pk,
      
      if( ( supervisedChaID is null ) or ( trim( supervisedChaID ) like '' ), if( ( chaID is null ) or ( trim( chaID ) like  ''  ), null, trim( chaID ) ) , trim( supervisedChaID ) ) as position_id,
    
      restockType_microlut    as microlut_restock_type,
      stockOnHand_microlut    as microlut_stock_on_hand,
      
      case trim( restockType_microlut )
          when null or ''   then 0
          when 'partial'    then partialRestock_microlut
          when 'full'       then coalesce( fullStock_microlut, 0 ) - coalesce( stockOnHand_microlut, 0 )
          when 'none'       then 0
          else 0
      end as microlut_quantity_restock
      
      -- stockOnHand_microlut, restockType_microlut, partialRestock_microlut, stockOutReason_microlut, fullStock_microlut, 
      -- stockOnHand_microgynon, restockType_microgynon, partialRestock_microgynon, stockOutReason_microgynon, fullStock_microgynon, stockOnHand_maleCondom, restockType_maleCondom, partialRestock_maleCondom, stockOutReason_maleCondom, fullStock_maleCondom, stockOnHand_femaleCondom, restockType_femaleCondom, partialRestock_femaleCondom, stockOutReason_femaleCondom, fullStock_femaleCondom, stockOnHand_disposableGloves, restockType_disposableGloves, partialRestock_disposableGloves, stockOutReason_disposableGloves, fullStock_disposableGloves, condom_unit_type, stockOnHand_maleCondom_box_of_144, restockType_maleCondom_box_of_144, partialRestock_maleCondom_box_of_144, stockOutReason_maleCondom_box_of_144, fullStock_maleCondom_box_of_144, stockOnHand_maleCondom_box_of_100, restockType_maleCondom_box_of_100, partialRestock_maleCondom_box_of_100, stockOutReason_maleCondom_box_of_100, fullStock_maleCondom_box_of_100, stockOnHand_ACT25mg, restockType_ACT25mg, partialRestock_ACT25mg, stockOutReason_ACT25mg, fullStock_ACT25mg, stockOnHand_ACT50mg, restockType_ACT50mg, partialRestock_ACT50mg, stockOutReason_ACT50mg, fullStock_ACT50mg, stockOnHand_artesunateSuppository, restockType_artesunateSuppository, partialRestock_artesunateSuppository, stockOutReason_artesunateSuppository, fullStock_artesunateSuppository, stockOnHand_Amoxicillin250mg, restockType_Amoxicillin250mg, partialRestock_Amoxicillin250mg, stockOutReason_Amoxicillin250mg, fullStock_Amoxicillin250mg, stockOnHand_Amoxicillin250mg_strips, restockType_Amoxicillin250mg_strips, partialRestock_Amoxicillin250mg_strips, stockOutReason_Amoxicillin250mg_strips, fullStock_Amoxicillin250mg_strips, stockOnHand_Amoxicillin250mg_suspension, restockType_Amoxicillin250mg_suspension, partialRestock_Amoxicillin250mg_suspension, stockOutReason_Amoxicillin250mg_suspension, fullStock_Amoxicillin250mg_suspension, stockOnHand_ZincSulfate, restockType_ZincSulfate, partialRestock_ZincSulfate, stockOutReason_ZincSulfate, fullStock_ZincSulfate_bottle, stockOnHand_ZincSulfate_Infidelity, restockType_ZincSulfate_Infidelity, partialRestock_ZincSulfate_Infidelity, stockOutReason_ZincSulfate_Infidelity, fullStock_ZincSulfate_strips, fullStock_ZincSulfate, stockOnHand_ORS, restockType_ORS, partialRestock_ORS, stockOutReason_ORS, fullStock_ORS, stockOnHand_Paracetamol100mg, restockType_Paracetamol100mg, partialRestock_Paracetamol100mg, stockOutReason_Paracetamol100mg, fullStock_Paracetamol100mg, stockOnHand_Paracetamol100mg_suspension, restockType_Paracetamol100mg_suspension, partialRestock_Paracetamol100mg_suspension, stockOutReason_Paracetamol100mg_suspension, fullStock_Paracetamol100mg_suspension, stockOnHand_MalariaRDT, restockType_MalariaRDT, partialRestock_MalariaRDT, stockOutReason_MalariaRDT, fullStock_MalariaRDT, stockOnHand_muacStrap, restockType_muacStrap, stockOutReason_muacStrap, fullStock_muacStrap, stockOnHand_dispensingBags, restockType_dispensingBags, partialRestock_dispensingBags, stockOutReason_dispensingBags, fullStock_dispensingBags, stockOnHand_safetyBox, restockType_safetyBox, partialRestock_safetyBox, stockOutReason_safetyBox, fullStock_safetyBox, formRestockNeeded, formRestockType_module1, formRestockType_module2, formRestockType_module3, formRestockType_module4, formRestockType_HouseholdRegistration, formRestockType_routineVisit, formRestockType_Referral
from lastmile_upload.odk_chaRestock
where not (
            ( ( supervisedChaID is null ) or ( trim( supervisedChaID ) like ''  ) ) and 
            ( ( chaID is null           ) or ( trim( chaID ) like ''            ) )
      )
