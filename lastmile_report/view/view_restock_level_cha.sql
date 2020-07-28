use lastmile_report;

drop view if exists lastmile_report.view_restock_level_cha;

create view lastmile_report.view_restock_level_cha as
select
      year( manualDate)     as restock_year,
      month( manualDate)    as restock_month,
      manualDate            as restock_date,
      
      if( ( supervisedChaID is null ) or ( trim( supervisedChaID ) like '' ), 
           if( ( chaID is null ) or ( trim( chaID ) like  ''  ), null, trim( chaID ) ), 
           trim( supervisedChaID ) ) 
      as position_id,
      
      -- Commodities
         
      -- stockOnHand_microlut, restockType_microlut, partialRestock_microlut, stockOutReason_microlut, fullStock_microlut 
      restockType_microlut        as microlut_restock_type,
      stockOnHand_microlut        as microlut_stock_on_hand,
      
      case trim( restockType_microlut )
          when null or ''   then 0
          when 'partial'    then partialRestock_microlut
          when 'overstock'  then partialRestock_microlut
          when 'full'       then coalesce( fullStock_microlut, 0 ) - coalesce( stockOnHand_microlut, 0 )
          when 'none'       then 0
          else 0
      end as microlut_quantity_restock,
 
      -- stockOnHand_microgynon, restockType_microgynon, partialRestock_microgynon, stockOutReason_microgynon, fullStock_microgynon
      restockType_microgynon      as microgynon_restock_type,
      stockOnHand_microgynon      as microgynon_stock_on_hand,
      
      case trim( restockType_microgynon )
          when null or ''   then 0
          when 'partial'    then partialRestock_microgynon
          when 'overstock'  then partialRestock_microgynon
          when 'full'       then coalesce( fullStock_microgynon, 0 ) - coalesce( stockOnHand_microgynon, 0 )
          when 'none'       then 0
          else 0
      end as microgynon_quantity_restock,
 
      
      -- OBSOLETE: stockOnHand_maleCondom, restockType_maleCondom, partialRestock_maleCondom, stockOutReason_maleCondom, fullStock_maleCondom 
      -- stockOnHand_maleCondom_box_of_144, restockType_maleCondom_box_of_144, partialRestock_maleCondom_box_of_144, stockOutReason_maleCondom_box_of_144, fullStock_maleCondom_box_of_144 
      -- stockOnHand_maleCondom_box_of_100, restockType_maleCondom_box_of_100, partialRestock_maleCondom_box_of_100, stockOutReason_maleCondom_box_of_100, fullStock_maleCondom_box_of_100 
      
      condom_unit_type, 
      case trim( condom_unit_type )
      
          when null or ''     then null
          when 'box_of_144'   then restockType_maleCondom_box_of_144
          when 'box_of_100'   then restockType_maleCondom_box_of_100
          else null
      end as male_condom_restock_type,
      
      case trim( condom_unit_type )
      
          when null or ''     then null
          when 'box_of_144'   then stockOnHand_maleCondom_box_of_144
          when 'box_of_100'   then stockOnHand_maleCondom_box_of_100
          else null
      end as male_condom_stock_on_hand,
      
      case trim( condom_unit_type )
      
          when null or ''     then null
          when 'box_of_144'   then
                                  case trim( restockType_maleCondom_box_of_144 )
                                      when null or ''   then 0
                                      when 'partial'    then partialRestock_maleCondom_box_of_144
                                      when 'overstock'  then partialRestock_maleCondom_box_of_144
                                      when 'full'       then coalesce( fullStock_maleCondom_box_of_144, 0 ) - coalesce( stockOnHand_maleCondom_box_of_144, 0 )
                                      when 'none'       then 0
                                      else 0
                                  end
          when 'box_of_100'   then 
                                  case trim( restockType_maleCondom_box_of_100 )
                                      when null or ''   then 0
                                      when 'partial'    then partialRestock_maleCondom_box_of_100
                                      when 'overstock'  then partialRestock_maleCondom_box_of_100
                                      when 'full'       then coalesce( fullStock_maleCondom_box_of_100, 0 ) - coalesce( stockOnHand_maleCondom_box_of_100, 0 )
                                      when 'none'       then 0
                                      else 0
                                  end
          else null
      end as male_condom_quantity_restock,
 

      -- stockOnHand_femaleCondom, restockType_femaleCondom, partialRestock_femaleCondom, stockOutReason_femaleCondom, fullStock_femaleCondom
      restockType_femaleCondom      as female_condom_restock_type,
      stockOnHand_femaleCondom      as female_condom_stock_on_hand,
            
      case trim( restockType_femaleCondom )
          when null or ''   then 0
          when 'partial'    then partialRestock_femaleCondom
          when 'overstock'  then partialRestock_femaleCondom
          when 'full'       then coalesce( fullStock_femaleCondom, 0 ) - coalesce( stockOnHand_femaleCondom, 0 )
          when 'none'       then 0
          else 0
      end as female_condom_quantity_restock,
      
      -- stockOnHand_disposableGloves, restockType_disposableGloves, partialRestock_disposableGloves, stockOutReason_disposableGloves, fullStock_disposableGloves
      restockType_disposableGloves      as disposable_gloves_restock_type,
      stockOnHand_disposableGloves      as disposable_gloves_stock_on_hand,
      
      case trim( restockType_disposableGloves )
          when null or ''   then 0
          when 'partial'    then partialRestock_disposableGloves
          when 'overstock'  then partialRestock_disposableGloves
          when 'full'       then coalesce( fullStock_disposableGloves, 0 ) - coalesce( stockOnHand_disposableGloves, 0 )
          when 'none'       then 0
          else 0
      end as disposable_gloves_quantity_restock,


      -- stockOnHand_ACT25mg, restockType_ACT25mg, partialRestock_ACT25mg, stockOutReason_ACT25mg, fullStock_ACT25mg, 
      -- stockOnHand_ACT50mg, restockType_ACT50mg, partialRestock_ACT50mg, stockOutReason_ACT50mg, fullStock_ACT50mg, 
 
      restockType_ACT25mg      as ACT_25mg_restock_type,
      stockOnHand_ACT25mg      as ACT_25mg_stock_on_hand,
      
      case trim( restockType_ACT25mg )
          when null or ''   then 0
          when 'partial'    then partialRestock_ACT25mg
          when 'overstock'  then partialRestock_ACT25mg
          when 'full'       then coalesce( fullStock_ACT25mg, 0 ) - coalesce( stockOnHand_ACT25mg, 0 )
          when 'none'       then 0
          else 0
      end as ACT_25mg_quantity_restock,
      
      restockType_ACT50mg      as ACT_50mg_restock_type,
      stockOnHand_ACT50mg      as ACT_50mg_stock_on_hand,
      
      case trim( restockType_ACT50mg )
          when null or ''   then 0
          when 'partial'    then partialRestock_ACT50mg
          when 'overstock'  then partialRestock_ACT50mg
          when 'full'       then coalesce( fullStock_ACT50mg, 0 ) - coalesce( stockOnHand_ACT50mg, 0 )
          when 'none'       then 0
          else 0
      end as ACT_50mg_quantity_restock,
      
 
      -- stockOnHand_artesunateSuppository, restockType_artesunateSuppository, partialRestock_artesunateSuppository, stockOutReason_artesunateSuppository, fullStock_artesunateSuppository
      restockType_artesunateSuppository      as artesunate_suppository_restock_type,
      stockOnHand_artesunateSuppository      as artesunate_suppository_stock_on_hand,
      
      case trim( restockType_artesunateSuppository )
          when null or ''   then 0
          when 'partial'    then partialRestock_artesunateSuppository
          when 'overstock'  then partialRestock_artesunateSuppository
          when 'full'       then coalesce( fullStock_artesunateSuppository, 0 ) - coalesce( stockOnHand_artesunateSuppository, 0 )
          when 'none'       then 0
          else 0
      end as artesunate_suppository_quantity_restock,
     
     
      -- stockOnHand_Amoxicillin250mg, restockType_Amoxicillin250mg, partialRestock_Amoxicillin250mg, stockOutReason_Amoxicillin250mg, fullStock_Amoxicillin250mg 
 
      restockType_Amoxicillin250mg      as amoxicillin_250mg_restock_type,
      stockOnHand_Amoxicillin250mg      as amoxicillin_250mg_stock_on_hand,
      
      case trim( restockType_Amoxicillin250mg )
          when null or ''   then 0
          when 'partial'    then partialRestock_Amoxicillin250mg
          when 'overstock'  then partialRestock_Amoxicillin250mg
          when 'full'       then coalesce( fullStock_Amoxicillin250mg, 0 ) - coalesce( stockOnHand_Amoxicillin250mg, 0 )
          when 'none'       then 0
          else 0
      end as amoxicillin_250mg_quantity_restock,


     -- stockOnHand_Amoxicillin250mg_strips, restockType_Amoxicillin250mg_strips, partialRestock_Amoxicillin250mg_strips, stockOutReason_Amoxicillin250mg_strips, fullStock_Amoxicillin250mg_strips
     
      restockType_Amoxicillin250mg_strips      as amoxicillin_250mg_strips_restock_type,
      stockOnHand_Amoxicillin250mg_strips      as amoxicillin_250mg_strips_stock_on_hand,
      
      case trim( restockType_Amoxicillin250mg_strips )
          when null or ''   then 0
          when 'partial'    then partialRestock_Amoxicillin250mg_strips
          when 'overstock'  then partialRestock_Amoxicillin250mg_strips
          when 'full'       then coalesce( fullStock_Amoxicillin250mg_strips, 0 ) - coalesce( stockOnHand_Amoxicillin250mg_strips, 0 )
          when 'none'       then 0
          else 0
      end as amoxicillin_250mg_strips_quantity_restock,
     
     
      -- stockOnHand_Amoxicillin250mg_suspension, restockType_Amoxicillin250mg_suspension, partialRestock_Amoxicillin250mg_suspension, stockOutReason_Amoxicillin250mg_suspension, fullStock_Amoxicillin250mg_suspension 
      
      restockType_Amoxicillin250mg_suspension      as amoxicillin_250mg_suspension_restock_type,
      stockOnHand_Amoxicillin250mg_suspension      as amoxicillin_250mg_suspension_stock_on_hand,
      
      case trim( restockType_Amoxicillin250mg_suspension )
          when null or ''   then 0
          when 'partial'    then partialRestock_Amoxicillin250mg_suspension
          when 'overstock'  then partialRestock_Amoxicillin250mg_suspension
          when 'full'       then coalesce( fullStock_Amoxicillin250mg_suspension, 0 ) - coalesce( stockOnHand_Amoxicillin250mg_suspension, 0 )
          when 'none'       then 0
          else 0
      end as amoxicillin_250mg_suspension_quantity_restock,


      -- stockOnHand_ORS, restockType_ORS, partialRestock_ORS, stockOutReason_ORS, fullStock_ORS
      restockType_ORS      as ors_restock_type,
      stockOnHand_ORS      as ors_stock_on_hand,
      
      case trim( restockType_ORS )
          when null or ''   then 0
          when 'partial'    then partialRestock_ORS
          when 'overstock'  then partialRestock_ORS
          when 'full'       then coalesce( fullStock_ORS, 0 ) - coalesce( stockOnHand_ORS, 0 )
          when 'none'       then 0
          else 0
      end as ors_quantity_restock,
   
   
      -- *** Bottle ***
      -- stockOnHand_ZincSulfate, restockType_ZincSulfate, partialRestock_ZincSulfate, stockOutReason_ZincSulfate, fullStock_ZincSulfate_bottle, 
      
      restockType_ZincSulfate      as zinc_sulfate_restock_type,
      stockOnHand_ZincSulfate      as zinc_sulfate_stock_on_hand,
     
      case trim( restockType_ZincSulfate )
          when null or ''   then 0
          when 'partial'    then partialRestock_ZincSulfate
          when 'overstock'  then partialRestock_ZincSulfate
          when 'full'       then coalesce( fullStock_ZincSulfate_bottle, 0 ) - coalesce( stockOnHand_ZincSulfate, 0 )
          when 'none'       then 0
          else 0
      end as zinc_sulfate_quantity_restock,
      
      
      -- *** Strips ***
      -- stockOnHand_ZincSulfate_Infidelity, restockType_ZincSulfate_Infidelity, partialRestock_ZincSulfate_Infidelity, stockOutReason_ZincSulfate_Infidelity, fullStock_ZincSulfate_strips
      -- Not being used in 3.3.3: fullStock_ZincSulfate 
        
      restockType_ZincSulfate_Infidelity      as zinc_sulfate_strips_restock_type,
      stockOnHand_ZincSulfate_Infidelity      as zinc_sulfate_strips_stock_on_hand,
     
      case trim( restockType_ZincSulfate_Infidelity )
          when null or ''   then 0
          when 'partial'    then partialRestock_ZincSulfate_Infidelity
          when 'overstock'  then partialRestock_ZincSulfate_Infidelity
          when 'full'       then coalesce( fullStock_ZincSulfate_strips, 0 ) - coalesce( stockOnHand_ZincSulfate_Infidelity, 0 )
          when 'none'       then 0
          else 0
      end as zinc_sulfate_strips_quantity_restock,
 
  
      -- stockOnHand_Paracetamol100mg, restockType_Paracetamol100mg, partialRestock_Paracetamol100mg, stockOutReason_Paracetamol100mg, fullStock_Paracetamol100mg, 
      -- stockOnHand_Paracetamol100mg_suspension, restockType_Paracetamol100mg_suspension, partialRestock_Paracetamol100mg_suspension, stockOutReason_Paracetamol100mg_suspension, fullStock_Paracetamol100mg_suspension, 
     
      restockType_Paracetamol100mg      as paracetamol_100mg_restock_type,
      stockOnHand_Paracetamol100mg      as paracetamol_100mg_stock_on_hand,
      
      case trim( restockType_Paracetamol100mg )
          when null or ''   then 0
          when 'partial'    then partialRestock_Paracetamol100mg
          when 'overstock'  then partialRestock_Paracetamol100mg
          when 'full'       then coalesce( fullStock_Paracetamol100mg, 0 ) - coalesce( stockOnHand_Paracetamol100mg, 0 )
          when 'none'       then 0
          else 0
      end as paracetamol_100mg_quantity_restock,
      
      restockType_Paracetamol100mg_suspension      as paracetamol_100mg_suspension_restock_type,
      stockOnHand_Paracetamol100mg_suspension      as paracetamol_100mg_suspension_stock_on_hand,

      case trim( restockType_Paracetamol100mg_suspension )
          when null or ''   then 0
          when 'partial'    then partialRestock_Paracetamol100mg_suspension
          when 'overstock'  then partialRestock_Paracetamol100mg_suspension
          when 'full'       then coalesce( fullStock_Paracetamol100mg_suspension, 0 ) - coalesce( stockOnHand_Paracetamol100mg_suspension, 0 )
          when 'none'       then 0
          else 0
      end as paracetamol_100mg_quantity_restock_suspension,
      
      -- stockOnHand_MalariaRDT, restockType_MalariaRDT, partialRestock_MalariaRDT, stockOutReason_MalariaRDT, fullStock_MalariaRDT     
      restockType_MalariaRDT      as malaria_rdt_restock_type,
      stockOnHand_MalariaRDT      as malaria_rdt_stock_on_hand,
      
      case trim( restockType_MalariaRDT )
          when null or ''   then 0
          when 'partial'    then partialRestock_MalariaRDT
          when 'overstock'  then partialRestock_MalariaRDT
          when 'full'       then coalesce( fullStock_MalariaRDT, 0 ) - coalesce( stockOnHand_MalariaRDT, 0 )
          when 'none'       then 0
          else 0
      end as malaria_rdt_quantity_restock,
 
      
      -- stockOnHand_muacStrap, restockType_muacStrap, stockOutReason_muacStrap, fullStock_muacStrap    
      restockType_muacStrap      as muac_strap_restock_type,
      stockOnHand_muacStrap      as muac_strap_stock_on_hand,
      
      case trim( restockType_muacStrap )
          when null or ''   then 0
          when 'full'       then coalesce( fullStock_muacStrap, 0 ) - coalesce( stockOnHand_muacStrap, 0 )
          when 'none'       then 0
          else 0
      end as muac_strap_quantity_restock,
   
   
      -- stockOnHand_dispensingBags, restockType_dispensingBags, partialRestock_dispensingBags, stockOutReason_dispensingBags, fullStock_dispensingBags      
      restockType_dispensingBags      as dispensing_bags_restock_type,
      stockOnHand_dispensingBags      as dispensing_bags_stock_on_hand,
      
      case trim( restockType_dispensingBags )
          when null or ''   then 0
          when 'partial'    then partialRestock_dispensingBags
          when 'overstock'  then partialRestock_dispensingBags
          when 'full'       then coalesce( fullStock_dispensingBags, 0 ) - coalesce( stockOnHand_dispensingBags, 0 )
          when 'none'       then 0
          else 0
      end as dispensing_bags_quantity_restock,
 
 
      -- stockOnHand_safetyBox, restockType_safetyBox, partialRestock_safetyBox, stockOutReason_safetyBox, fullStock_safetyBox 
      restockType_safetyBox      as safety_box_restock_type,
      stockOnHand_safetyBox      as safety_box_stock_on_hand,
      
      case trim( restockType_safetyBox )
          when null or ''   then 0
          when 'partial'    then partialRestock_safetyBox
          when 'overstock'  then partialRestock_safetyBox
          when 'full'       then coalesce( fullStock_safetyBox, 0 ) - coalesce( stockOnHand_safetyBox, 0 )
          when 'none'       then 0
          else 0
      end as safety_box_quantity_restock
      
      -- formRestockNeeded, formRestockType_module1, formRestockType_module2, formRestockType_module3, formRestockType_module4, formRestockType_HouseholdRegistration, formRestockType_routineVisit, formRestockType_Referral
        
                   
from lastmile_upload.odk_chaRestock
where not ( ( ( supervisedChaID is null ) or ( trim( supervisedChaID ) like ''  ) ) and 
            ( ( chaID is null           ) or ( trim( chaID ) like ''            ) )
          )
;


