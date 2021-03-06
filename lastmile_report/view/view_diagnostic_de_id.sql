use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_de_id;

create view lastmile_report.view_diagnostic_de_id as

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
          
from lastmile_report.view_diagnostic_de_id_unfiltered
where 
      -- filter out valid null ID values

      not ( table_name like 'de_chaHouseholdRegistration'     and id_type like 'chss' and id_name like 'chssID'           and   meta_form_version is null                                           and id_original_value is null )
      and
      not ( table_name like 'de_chss_monthly_service_report'  and id_type like 'cha'  and id_name like 'cha\\_id\\_%'     /* filter on all form versions */                                         and id_original_value is null )
;
