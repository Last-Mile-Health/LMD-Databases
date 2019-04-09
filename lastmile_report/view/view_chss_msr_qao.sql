use lastmile_report;

drop view if exists lastmile_report.view_chss_msr_qao;

create view lastmile_report.view_chss_msr_qao as
  
select

        ( q.year_reported * 10000 ) + ( q.month_reported * 100 ) + 1  as date_key,
        trim( q.chss_id )                                             as chss_position_id,
     
        q.chss_monthly_service_report_id,
        q.meta_uuid,
        q.meta_de_init,
        q.meta_de_date,
        q.meta_de_time_start,
        q.meta_de_time_end,
        q.meta_qa_init,
        q.meta_qa_date,
        q.meta_data_source,
        q.meta_form_version,
        q.meta_insert_date_time,
        q.meta_fabricated,
        q.chss_name,
        
        q.chss_id,
        q.chss_id_inserted,
        q.district,
        q.month_reported,
        q.county,
        q.health_facility,
        q.health_facility_id,
        q.year_reported,
        
        q.cha_id_1,
        q.cha_id_1_inserted,
        q.cha_id_2,
        q.cha_id_2_inserted,
        q.cha_id_3,
        q.cha_id_3_inserted,   
        q.cha_id_4,
        q.cha_id_4_inserted,     
        q.cha_id_5,
        q.cha_id_5_inserted,      
        q.cha_id_6,
        q.cha_id_6_inserted,       
        q.cha_id_7,
        q.cha_id_7_inserted,      
        q.cha_id_8,
        q.cha_id_8_inserted,      
        q.cha_id_9,
        q.cha_id_9_inserted,      
        q.cha_id_10,
        q.cha_id_10_inserted,
        q.cha_id_11,
        q.cha_id_11_inserted,
        q.cha_id_12,
        q.cha_id_12_inserted,
        q.cha_id_13,
        q.cha_id_13_inserted,
        q.cha_id_14,
        q.cha_id_14_inserted,
        
        -- Note: we are only using the supervison portion of the form
        q.5_3_a_supervision_visits_completed,
        q.5_3_b_number_cha_absences,
        q.5_3_c_reviews_completed,
        q.5_3_d_reviews_correct_treatment,
        q.5_3_e_cha_reports_on_time
        
from lastmile_upload.de_chss_monthly_service_report as q
 