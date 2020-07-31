use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_id_correct;

create view lastmile_report.view_diagnostic_id_correct as

select       
      d.table_name, 
      d.pk_id, 
      d.id_type, 
      d.id_name, 
      d.id_original_value           as id_original, 
      d.id_inserted_value           as id_repair, 
      d.id_inserted_format_value    as id_formatted, 
      d.id_value, 
            
      if( pr.job like 'CHA', pr.position_id, null ) as db_cha_id,
      if( pr.job like 'CHA', pr.full_name, null )   as db_cha,
      
      d.meta_cha, 
      d.meta_cha_id,
      
      if( pr.job like 'CHSS', pr.position_id, null )  as db_chss_id,
      if( pr.job like 'CHSS', pr.full_name, null )    as db_chss,
      
      d.meta_chss, 
      d.meta_chss_id,
       
      d.meta_facility, 
      d.meta_facility_id, 
      d.meta_health_district, 
      d.meta_county, 
      d.meta_community, 
      d.meta_community_id, 
      d.meta_form_date, 
      d.meta_insert_date_time                         as meta_insert_date_time_original,  
      d.meta_form_version

from lastmile_report.view_diagnostic_id as d
      left outer join lastmile_report.mart_view_history_position_person_aggregate as pr on ( 
                                                    
                                                      trim( d.id_inserted_value ) like pr.position_id and
                                                      d.id_type like lcase( pr.job )
                                                    
                                                    )                                               
where ( 
        ( d.table_name like 'de_chss_commodity_distribution'  ) or 
        ( d.table_name like 'odk_chaRestock'                  ) or
        ( d.table_name like 'de_cha_monthly_service_report'   ) or
        ( d.table_name like 'de_chss_monthly_service_report' and id_type like 'chss' ) or
        ( d.table_name like 'de_case_scenario%'               )  
      )     
;