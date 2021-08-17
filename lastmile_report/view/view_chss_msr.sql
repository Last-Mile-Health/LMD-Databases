use lastmile_report;

drop view if exists lastmile_report.view_chss_msr;

create view lastmile_report.view_chss_msr as
  
select
        s.chss_monthly_service_report_id,
       
        s.meta_uuid,
        s.meta_de_init,
        s.meta_de_date,
        s.meta_de_time_start,
        s.meta_de_time_end,
        s.meta_qa_init,
        s.meta_qa_date,
        s.meta_data_source,
        s.meta_form_version,
        s.meta_insert_date_time,
        s.meta_fabricated,
        
        ( s.year_reported * 10000 ) + ( s.month_reported * 100 ) + 1  as date_key,
        s.year_reported,
        s.month_reported,
        
        trim( s.chss_id ) as chss_id,
        s.chss_name,
        
        s.district,
        s.county,
        s.health_facility,
        s.health_facility_id,
  
        s.cha_id_1, s.cha_id_2, s.cha_id_3,  s.cha_id_4,  s.cha_id_5,  s.cha_id_6,  s.cha_id_7,      
        s.cha_id_8, s.cha_id_9, s.cha_id_10, s.cha_id_11, s.cha_id_12, s.cha_id_13, s.cha_id_14,
        
        -- Note: we are only using the supervison portion of the form
        s.5_3_a_supervision_visits_completed,
        s.5_3_b_number_cha_absences,
        s.5_3_c_reviews_completed,
        s.5_3_d_reviews_correct_treatment,
        s.5_3_e_cha_reports_on_time
        
from lastmile_upload.de_chss_monthly_service_report as s
    left outer join lastmile_ncha.view_base_position_chss as c on s.chss_id like c.position_id
      
 -- Owen (2021-08-17): temp hack for allowing UNICEF MSRs to be uploaded to the de_chss_monthly_service_report table but still filtered out until we scale up in GG
 where ( c.cohort is null or trim( c.cohort like '' ) ) or not ( c.cohort like 'UNICEF' )
;
 