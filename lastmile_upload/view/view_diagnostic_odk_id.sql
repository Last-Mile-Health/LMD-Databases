use lastmile_upload;

drop view if exists lastmile_upload.view_diagnostic_odk_id;

create view lastmile_upload.view_diagnostic_odk_id as

select  
      table_name, 
      pk_id, 
      id_type, 
      id_name, 
      id_original_value, 
      id_inserted_value, 
      id_inserted_format_value, 
      id_value,
      
      meta_cha,
      meta_cha_id,
      meta_chss,
      meta_chss_id,
      meta_facility,
      meta_facility_id,
      meta_health_district,
      meta_county,
      meta_community,
      meta_community_id,
      meta_form_date,
       
      meta_insert_date_time, 
      meta_form_version
          
from lastmile_upload.view_diagnostic_odk_id_unfiltered
where 
      -- filter out valid null ID values
      not ( table_name like 'odk_chaRestock'                  and id_type like 'cha'  and id_name like 'chaID'            and ( meta_form_version like '3.1.1' or meta_form_version like '3.3.1' )  and id_original_value is null )
      and
      not ( table_name like 'odk_chaRestock'                  and id_type like 'cha'  and id_name like 'supervisedChaID'  and   meta_form_version like '3.2.2'                                      and id_original_value is null )
      and
      not ( table_name like 'odk_chaRestock'                  and id_type like 'chss' and id_name like 'user_id'          and ( meta_form_version like '3.1.1' or meta_form_version like '3.3.1' )  and id_original_value is null )
      and
      not ( table_name like 'odk_chaRestock'                  and id_type like 'chss' and id_name like 'chssID'           and   meta_form_version like '3.2.2'                                      and id_original_value is null )  
;
