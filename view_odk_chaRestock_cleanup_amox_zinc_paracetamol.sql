use lastmile_temp;

drop view if exists view_odk_chaRestock_cleanup_amox_zinc_paracetamol;

create view view_odk_chaRestock_cleanup_amox_zinc_paracetamol as

select 
      chaRestockID,
      meta_formVersion,
      
      manualDate,
      meta_autoDate,
     
      stockOnHand_Amoxicillin250mg,
      stockOutReason_Amoxicillin250mg,
      
      stockOnHand_ZincSulfate,
      stockOutReason_ZincSulfate,
   
      stockOnHand_Paracetamol100mg,
      stockOutReason_Paracetamol100mg,
      
      meta_insertDatetime
      
from lastmile_upload.odk_chaRestock
order by manualDate desc, meta_autoDate desc
 ;