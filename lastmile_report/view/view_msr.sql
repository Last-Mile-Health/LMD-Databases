use lastmile_report;

drop view if exists lastmile_report.view_msr;

create view lastmile_report.view_msr as

select
      ( ( trim( u.year_reported ) * 10000 ) + ( trim( u.month_reported ) * 100 ) + 1 )    as date_key,
      trim( cha_id )                                                                      as cha_id, 
      
      trim( u.month_reported  ) as month_reported, 
      trim( u.year_reported   ) as year_reported, 
      
      u.cha_name, 
      u.cha_module, 
      u.chss_name, 
      u.chss_id, 
      u.community, 
      u.community_id, 
      u.district, 
      u.health_facility, 
      
      c.household   as num_catchment_households,
      c.population  as num_catchment_people,
      if( u.cha_module in ( 3, 4 ) , c.population, 0 ) as num_catchment_people_iccm,
      
      u.num_routine_visits, 
      u.num_births, 
      u.num_births_home, 
      u.num_births_facility, 
      u.num_stillbirths, 
      u.num_deaths_neonatal, 
      u.num_deaths_postneonatal, 
      u.num_deaths_child, 
      u.num_deaths_maternal, 
      u.num_deaths_adult, 
      u.num_triggers, 
      u.num_referrals_suspect_hiv_tb_cm_ntd_mh, 
      u.num_pregnant_woman_visits, 
      u.num_active_case_finds, 
      u.num_muac_red, 
      u.num_muac_yellow, 
      u.num_muac_green, 
      u.num_tx_ari, 
      u.num_tx_diarrhea, 
      u.num_tx_malaria, 
      u.num_tx_malaria_under24, 
      u.num_tx_malaria_over24, 
      u.num_tx_malaria_under1, 
      u.num_tx_malaria_over1, 
      u.num_community_triggers, 
      u.num_referred_delivery, 
      u.num_referred_anc, 
      u.num_post_natal_visits, 
      u.num_referred_rmnh_danger_sign, 
      u.num_hbmnc_48_hours_mother, 
      u.num_hbmnc_48_hours_infant, 
      u.num_clients_modern_fp, 
      u.num_hiv_client_visits, 
      u.num_tb_client_visits, 
      u.num_cm_ntd_client_visits, 
      u.num_mental_health_client_visits, 
      u.num_ltfu_hiv_clients_traced, 
      u.num_ltfu_tb_clients_traced,
      
      -- meta
      u.meta_uuid, 
      u.meta_de_init, 
      u.meta_de_date, 
      u.meta_qa_init, 
      u.meta_qa_date, 
      u.meta_form_version, 
      u.meta_insert_date_time, 
      u.meta_de_time_start, 
      u.meta_de_time_end, 
      u.meta_data_source 
      
from lastmile_report.view_msr_union as u
    left outer join lastmile_report.data_mart_snapshot_position_cha as c on
    
                ( ( ( trim( u.year_reported ) * 10000 ) + ( trim( u.month_reported ) * 100 ) + 1 ) = c.date_key ) and 
                  ( trim( u.cha_id ) like c.position_id )
;