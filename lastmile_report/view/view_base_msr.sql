use lastmile_report;

drop view if exists view_base_msr;

create view view_base_msr as
select 
        a.meta_uuid,
        a.meta_de_init,
        a.meta_de_date,
        a.meta_qa_init,
        a.meta_qa_date,
        a.meta_form_version,
        a.meta_insert_date_time,
        a.meta_de_time_start,
        a.meta_de_time_end,
        a.meta_data_source,
        
        cast( cast( trim( a.month_reported ) as unsigned ) as char(2) ) as month_reported,
        trim( a.month_reported ) AS month_reported_orig,
        
        a.year_reported,
        a.cha_name,
        a.cha_id,
        a.cha_module,
        a.chss_name,
        a.chss_id,
        a.community,
        a.community_id,
        
        substring_index( e.community_id_list, ',', 1 ) as community_id_primary,
        -- substring_index( d.community_id_list, ',', 1 ) as community_id_primary,
        
        a.district,
        a.health_facility,
        b.cohort,
        b.health_district_id,
        b.health_district,
        c.county_id,
        c.county,
        d.household as num_catchment_households,
        d.population as num_catchment_people,
        
        if( ( a.cha_module in ( 3 , 4 ) ), d.population, 0 ) as num_catchment_people_iccm,
        
        a.num_routine_visits,
        a.num_births,
        a.num_births_home,
        a.num_births_facility,
        a.num_stillbirths,
        a.num_deaths_neonatal,
        a.num_deaths_postneonatal,
        a.num_deaths_child,
        a.num_deaths_maternal,
        a.num_deaths_adult,
        a.num_triggers,
        a.num_referrals_suspect_hiv_tb_cm_ntd_mh,
        a.num_pregnant_woman_visits,
        a.num_active_case_finds,
        a.num_muac_red,
        a.num_muac_yellow,
        a.num_muac_green,
        a.num_tx_ari,
        a.num_tx_diarrhea,
        a.num_tx_malaria,
        a.num_tx_malaria_under24,
        a.num_tx_malaria_over24,
        
        ( a.num_tx_malaria_under24 + a.num_tx_malaria_over24 ) as num_tx_malaria_under24_denominator,
        
        a.num_tx_malaria_under1,
        a.num_tx_malaria_over1,
        a.num_community_triggers,
        a.num_referred_delivery,
        a.num_referred_anc,
        a.num_post_natal_visits,
        a.num_referred_rmnh_danger_sign,
        a.num_hbmnc_48_hours_mother,
        a.num_hbmnc_48_hours_infant,
        a.num_clients_modern_fp,
        a.num_hiv_client_visits,
        a.num_tb_client_visits,
        a.num_cm_ntd_client_visits,
        a.num_mental_health_client_visits,
        a.num_ltfu_hiv_clients_traced,
        a.num_ltfu_tb_clients_traced
        
  from lastmile_report.view_msr_union as a
      left outer join lastmile_ncha.health_district b on a.district = convert( b.health_district using UTF8 )
          left outer join lastmile_ncha.county c ON b.county_id = c.county_id
        
      left outer join lastmile_report.data_mart_snapshot_position_cha d on  ( a.cha_id like d.position_id ) and                                                                         
                                                                            ( ( cast( concat( trim( a.year_reported ), '-', trim( a.month_reported ), '-01' ) as date ) ) = d.snapshot_date )
        
      left outer join lastmile_report.mart_view_base_position_cha as e on a.cha_id like e.position_id
;