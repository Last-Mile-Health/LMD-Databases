use lastmile_report;

drop view if exists lastmile_report.view_restock_union;

create view lastmile_report.view_restock_union as
select 
      chaRestockID,
      meta_UUID,
      meta_autoDate,
      meta_dataEntry_startTime,
      meta_dataEntry_endTime,
      meta_dataSource,
      meta_formVersion,
      meta_deviceID,
      manualDate,
        
      if( ( isnull( supervisedChaID ) or ( trim( supervisedChaID ) like '' ) ),
          if( ( isnull( chaID ) OR ( trim( chaID ) LIKE '' ) ), null, trim( chaID ) ),
          trim( supervisedChaID )
      ) as supervisedChaID,
        
      communityID,
      stockOnHand_ACT25mg,
      stockOnHand_ACT50mg,
      stockOnHand_Amoxicillin250mg,
      stockOnHand_Amoxicillin250mg_suspension,
      stockOnHand_disposableGloves,
      stockOnHand_MalariaRDT,
      stockOnHand_maleCondom,
      stockOnHand_microgynon,
      stockOnHand_muacStrap,
      stockOnHand_ORS,
      stockOnHand_Paracetamol100mg,
      stockOnHand_Paracetamol100mg_suspension,
      stockOnHand_ZincSulfate,
      stockOnHand_ZincSulfate_Infidelity,
      stockOnHand_artesunateSuppository,
      stockOnHand_dispensingBags,
      stockOnHand_femaleCondom,
      stockOnHand_microlut,
      stockOnHand_safetyBox,
      
      -- COVID-19 PPE 
      stockOnHand_surgicalMask,
      stockOnHand_glovesCovid19
      
from lastmile_upload.odk_chaRestock
where (
        ( 
          ( 
          
            ( isnull( supervisedChaID ) or ( trim( supervisedChaID ) LIKE '' ) ) and 
            ( chaID IS not NULL ) and (not ( ( trim( chaID ) LIKE '' ) ) ) )
            or 
            
            ( ( isnull( chaID ) or ( trim( chaID ) like '' ) ) and 
            ( supervisedChaID is not null ) and ( not ( ( trim( supervisedChaID ) like '' ) ) )
            )
          )           
          and           
          ( 
            ( not ( ( trim( supervisedChaID ) like '999' ) ) ) or ( not ( ( trim( chaID ) like '999' ) ) ) 
          )       
          and  
          ( 
            ( 
              ( isnull( user_id ) or (trim(user_id) LIKE '') ) and 
              ( chssID IS not NULL ) and ( not ( ( trim( chssID ) LIKE '' ) ) ) 
            )
            or 
            ( ( isnull( chssID ) or ( trim( chssID ) like '' ) )
            and ( user_id is not null )
            and ( not ( ( trim( user_id ) like '' ) ) ) )
          )
          and 
          ( 
            ( not ( ( trim( user_id ) like '999' ) ) ) or ( not ( ( trim( chssID ) like '999' ) ) ) 
          )
      ) 
 
union all

select 
      chwRestockID,
      meta_UUID,
      meta_autoDate,
      meta_dataEntry_startTime,
      meta_dataEntry_endTime,
      meta_dataSource,
      meta_formVersion,
      meta_deviceID,
      manualDate,

      if( ( isnull( supervisedChwID ) or ( trim( supervisedChwID ) like '' ) ), null, supervisedChwID ) as supervisedChwID,
      communityID,
      
      stockOnHand_ACT25mg,
      stockOnHand_ACT50mg,
      stockOnHand_amoxicillin250mg,
      null as stockOnHand_Amoxicillin250mg_suspension,
      stockOnHand_disposableGloves,
      stockOnHand_MalariaRDT,
      stockOnHand_maleCondoms,
      stockOnHand_microgynon,
      stockOnHand_muacStrap,
      stockOnHand_ORS,
      stockOnHand_Paracetamol120mg,
      null as stockOnHand_Paracetamol100mg_suspension,
      stockOnHand_ZincSulfate,
      null as stockOnHand_ZincSulfate_Infidelity,
      null as stockOnHand_artesunateSuppository,
      null as stockOnHand_dispensingBags,
      null as stockOnHand_femaleCondom,
      null as stockOnHand_microlut,
      null as stockOnHand_safetyBox,
      
      -- COVID-19 PPE stubs
      null as stockOnHand_surgicalMask,
      null as stockOnHand_glovesCovid19

from lastmile_archive.chwdb_odk_chw_restock
;