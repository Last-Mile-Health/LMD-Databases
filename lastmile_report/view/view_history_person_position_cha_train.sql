use lastmile_report;

drop view if exists view_history_person_position_cha_train;

create view view_history_person_position_cha_train as 

select

      a.person_id,
      a.full_name,
      a.gender,
      a.birth_date,
      a.phone_number,
      a.phone_number_alternate, 
 
      a.position_id,
      a.position_active,
      a.position_begin_date,
      a.position_end_date,
      a.position_person_active,
      a.position_person_begin_date,
      a.position_person_end_date,
      a.reason_left,
      a.reason_left_description,
      
      a.health_facility_id,
      a.health_facility,
      a.health_district,
      a.county,
      a.cohort,
      
      t.module                    as train_module,
      t.pre_test                  as train_pre_test,
      t.practical_skills_check    as train_practical_skills_check,
      t.post_test                 as train_post_test,
      t.overall_assessment        as train_overall_assessment,
      t.begin_date                as train_begin_date,
      t.end_date                  as train_end_date,
      
      t.participant_name          as train_participant_name,
      t.participant_type          as train_participant_type,
      t.facilitator_1             as train_facilitator_1,
      t.facilitator_2             as train_facilitator_2,
      t.facilitator_3             as train_facilitator_3,
      t.facilitator_4             as train_facilitator_4,
      
      t.health_district           as train_health_district,
      t.county                    as train_county,
      t.gender                    as train_gender,
      t.phone                     as train_phone,
      t.note                      as train_note,
      t.cha_id_inserted           as train_cha_position_id,
    
      t.data_entry_name           as train_data_entry_name,
      t.meta_insert_date_time     as train_meta_insert_date_time,
      t.train_cha_id              as train_cha_table_pk_id
     
from lastmile_cha.view_history_person_position_cha as a
    left outer join lastmile_program.train_cha as t on a.person_id = t.person_id
order by a.full_name asc, a.position_id asc, t.module asc
;