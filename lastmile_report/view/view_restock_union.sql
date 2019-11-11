use lastmile_report;

drop view if exists view_restock_union;

create view view_restock_union as

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
      
      /*
      If supervisedChaID is null or an empty string, then check chaID.  If chaID is null or
      an emtpy string then pass null as value.  Otherwise, trim and pass the column with the \
      actual value.
      */
      if( 
          ( supervisedChaID is null ) or ( trim( supervisedChaID ) like '' ) ,
           
          if( 
              ( chaID is null ) or ( trim( chaID ) like '' ), 
              null, 
              trim( chaID )
            ),
            
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
        stockOnHand_safetyBox
    
from lastmile_upload.odk_chaRestock
/*  Filter out position IDs where the CHSSs and CHAs consciously did not know their IDs and entered 999s.  In Winter/Spring 2018, 
    we had over sixty new CHSSs and CHAs in Rivercess who did not have IDs (LMH or NCHAP) for months.  This wrecked havoc on our 
    reporting because records could not be tied together.  The decision was made to filter out all of the 999s for purposes of 
    reporting.
*/
where (
        ( 
          -- Case supervisedChaID is null or an empty string and chaID is not null or an empty string
          ( ( ( supervisedChaID is null ) or ( trim( supervisedChaID ) like '' ) ) and not ( ( chaID is null ) or ( trim( chaID ) like '' ) ) ) or
          -- Case chaID is null or an empty string and supervisedChaID is not null or an empty string
          -- It has to be one or the other.
          ( ( ( chaID is null ) or ( trim( chaID ) like '' ) ) and not ( ( supervisedChaID is null ) or trim( supervisedChaID ) like '' ) ) 
        ) 
        and
        (
          -- So if either supervisedChaID or chaID is not null or an empty string, then be sure it isn't a 999
          not ( trim( supervisedChaID ) like '999' ) or not ( trim( chaID ) like '999' )
        )
      )
      and
      (
        ( -- Case user_id is null or an empty string and chssID is not null or an empty string
          ( ( user_id is null ) or ( trim( user_id ) like '' ) ) and not ( ( chssID is null ) or ( trim( chssID ) like '' )  )  or
          -- Case chssID is null or an empty string and user_id is not null or an empty string
          -- It has to be one or the other.
          ( ( chssID is null ) or ( trim( chssID ) like '' ) ) and not ( ( user_id is null ) or ( trim( user_id ) like '' )  )
        ) 
        and
        (
          -- So if either supervisedChaID or chaID is not null or an empty string, then be sure it isn't a 999
          not ( trim( user_id ) like '999' ) or not ( trim( chssID ) like '999' )
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
                
      /*
        If supervisedChwID is null or an empty string, then pass a null value; 
        Otherwise, trim and pass the column with the actual value.
      */
      if( 
          ( supervisedChwID is null ) or ( trim( supervisedChwID ) like '' ) , 
          null, 
          supervisedChwID
        ) as supervisedChwID,
        
        communityID,
        
        stockOnHand_ACT25mg,
        stockOnHand_ACT50mg,
        stockOnHand_Amoxicillin250mg,
        
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
        null as stockOnHand_safetyBox
        
from lastmile_archive.chwdb_odk_chw_restock
;
