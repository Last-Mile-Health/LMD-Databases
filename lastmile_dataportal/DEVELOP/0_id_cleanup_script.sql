select *
from lastmile_report.view_diagnostic_id_invalid
where ( meta_form_date >= '2020-07-01' )  and

  -- not ( id_original like '%999%' )      and
  -- ( id_original like '%999%' )        and

  ( 
  
    ( table_name like 'de_cha_monthly_service_report' )                           or
    
    ( table_name like 'de_chss_monthly_service_report' and id_type like 'chss' )  or 

    ( table_name like 'de_chss_commodity_distribution' )                          or
 
    ( table_name like 'de_case_scenario%' )                                       or
       
    -- DCT
    ( table_name like 'odk_QAOSupervisionChecklistForm' and id_type like 'chss' ) or
    
    ( table_name like 'odk_supervisionVisitLog'                                 ) or 
   
    ( table_name like 'odk_chaRestock' )                                          or                                  
    
    -- ( table_name like 'odk_vaccineTracker' )                                   or
    
    ( table_name like 'odk_QCA_GPSForm' )      
 
  )
  order by id_type asc, table_name asc, id_repair asc
  