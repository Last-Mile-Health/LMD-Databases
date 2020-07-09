use lastmile_report;

drop view if exists lastmile_report.view_chss_msr;

create view lastmile_report.view_chss_msr as
  
select
        chss_monthly_service_report_id,
       
        meta_uuid,
        meta_de_init,
        meta_de_date,
        meta_de_time_start,
        meta_de_time_end,
        meta_qa_init,
        meta_qa_date,
        meta_data_source,
        meta_form_version,
        meta_insert_date_time,
        meta_fabricated,
        
        ( year_reported * 10000 ) + ( month_reported * 100 ) + 1  as date_key,
        year_reported,
        month_reported,
        
        trim( chss_id ) as chss_id,
        chss_name,
        
        district,
        county,
        health_facility,
        health_facility_id,
  
        cha_id_1, cha_id_2, cha_id_3,  cha_id_4,  cha_id_5,  cha_id_6,  cha_id_7,      
        cha_id_8, cha_id_9, cha_id_10, cha_id_11, cha_id_12, cha_id_13, cha_id_14,
        
        -- Note: we are only using the supervison portion of the form
        5_3_a_supervision_visits_completed,
        5_3_b_number_cha_absences,
        5_3_c_reviews_completed,
        5_3_d_reviews_correct_treatment,
        5_3_e_cha_reports_on_time
        
from lastmile_upload.de_chss_monthly_service_report
;
 