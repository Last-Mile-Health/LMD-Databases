select
      d.table_name, 
      d.pk_id, 
      d.id_type, 
      d.id_name, 
      d.id_original_value             as id_original, 
      d.id_inserted_value             as id_repair, 
      d.id_inserted_format_value      as id_formatted, 
      d.id_value, 
      
      z.position_id,
      z.position_id_new,
      
      d.meta_cha,
      d.meta_cha_id,
      d.meta_chss,
      d.meta_chss_id,
      d.meta_facility,
      d.meta_facility_id,
      d.meta_health_district,
      d.meta_county,
      d.meta_community,
      d.meta_community_id,
      d.meta_form_date,
       
      d.meta_insert_date_time         as meta_insert_date_time_original, 
      d.meta_form_version

from lastmile_report.view_diagnostic_id as d

    left outer join (                 
                      select
                            pide.position_id, 
                            b.position_id as position_id_new
                      from lastmile_ncha.position_id as pide
                          left outer join ( select position_id_pk, position_id, begin_date 
                                            from lastmile_ncha.position_id
                                            where begin_date = '2020-01-01' 
                                          ) as b on pide.position_id_pk = b.position_id_pk
where pide. end_date = '2019-12-31' 
    
    
    ) as z on d.id_value like z.position_id


where ( d.meta_form_date >= '2020-01-01' )  and

  not ( d.id_original_value like '%999%' )      and
  -- ( d.id_original_value like '%999%' )        and

  ( 
    -- Paper forms
    ( d.table_name like 'de_cha_monthly_service_report' )                           or
    
    -- ( d.table_name like 'de_chss_monthly_service_report' and d.id_type like 'chss' )  or 

    -- ( d.table_name like 'de_chss_commodity_distribution' )                          or
 
    ( d.table_name like 'de_case_scenario%' )                                       or
    
    -- DCT
    -- ( d.table_name like 'odk_QAOSupervisionChecklistForm' and d.id_type like 'chss' ) or
    
    -- ( d.table_name like 'odk_supervisionVisitLog'                                 ) or 
    
    ( d.table_name like 'odk_chaRestock' )                                          or                                  
    
    ( d.table_name like 'odk_vaccineTracker' )                                      
 
  )
  order by d.id_type asc, d.table_name asc, d.id_inserted_value asc