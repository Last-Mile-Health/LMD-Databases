use lastmile_datamart;

drop view if exists lastmile_datamart.view_dimension_position_chss;

create view lastmile_datamart.view_dimension_position_chss as 

select
      dp.date_key, 
      dp.chss_position_id,
      dp.qao_position_id,
      dp.chss_position_begin_date,
      dp.chss_position_end_date,
      dp.chss_person_id,
      dp.chss_full_name,
      dp.chss_birth_date,
      dp.chss_gender,
      dp.chss_phone_number,
      dp.chss_phone_number_alternate,
      dp.chss_position_person_begin_date,
      dp.chss_position_person_end_date,
      dp.chss_reason_left,
      dp.chss_reason_left_description
      
from lastmile_datamart.dimension_position as dp
group by dp.date_key, dp.chss_position_id
;