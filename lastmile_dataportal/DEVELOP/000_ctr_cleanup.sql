select 
     
      -- county,
      cha_assessed_checkbox,
      chss_assessed_checkbox,
          
      chss,
      chss_id_original,
      chss_id_inserted,
      -- chss_id_inserted_format,
      -- chss_id,
      -- chss_position_id_pk,
      
      cha,
      cha_id_original,
      cha_id_inserted,
      -- cha_id_inserted_format,
      -- cha_id,
      -- position_id_pk,
  
      -- county,
      -- community,
      -- health_facility,
      -- data_collector,
      
      year_report,
      month_report,
      day_report,
      
      de_case_scenario_2_id
      
from lastmile_upload.de_case_scenario_2
where -- meta_insert_date_time >= '2020-01-01'
      -- year_report = 2020 and 
      county like 'River%' -- and
      -- cha like '%tarj%'

order by 
-- county asc, 
-- data_collector asc, 
-- chss asc, 
--      year_report,
--      month_report,
      cha asc