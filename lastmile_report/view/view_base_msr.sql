use lastmile_report;

drop view if exists view_base_msr;

create view view_base_msr as
select 
        `a`.`meta_uuid` AS `meta_uuid`,
        `a`.`meta_de_init` AS `meta_de_init`,
        `a`.`meta_de_date` AS `meta_de_date`,
        `a`.`meta_qa_init` AS `meta_qa_init`,
        `a`.`meta_qa_date` AS `meta_qa_date`,
        `a`.`meta_form_version` AS `meta_form_version`,
        `a`.`meta_insert_date_time` AS `meta_insert_date_time`,
        `a`.`meta_de_time_start` AS `meta_de_time_start`,
        `a`.`meta_de_time_end` AS `meta_de_time_end`,
        `a`.`meta_data_source` AS `meta_data_source`,
        
        cast( cast( trim( a.month_reported ) as unsigned ) as char(2) ) as month_reported,
        trim( a.month_reported ) AS month_reported_orig,
        
        `a`.`year_reported` AS `year_reported`,
        `a`.`cha_name` AS `cha_name`,
        `a`.`cha_id` AS `cha_id`,
        `a`.`cha_module` AS `cha_module`,
        `a`.`chss_name` AS `chss_name`,
        `a`.`chss_id` AS `chss_id`,
        `a`.`community` AS `community`,
        `a`.`community_id` AS `community_id`,
        SUBSTRING_INDEX(`e`.`community_id_list`, ',', 1) AS `community_id_primary`,
        `a`.`district` AS `district`,
        `a`.`health_facility` AS `health_facility`,
        `b`.`cohort` AS `cohort`,
        `b`.`health_district_id` AS `health_district_id`,
        `b`.`health_district` AS `health_district`,
        `c`.`county_id` AS `county_id`,
        `c`.`county` AS `county`,
        `d`.`household` AS `num_catchment_households`,
        `d`.`population` AS `num_catchment_people`,
        IF((`a`.`cha_module` IN (3 , 4)),
            `d`.`population`,
            0) AS `num_catchment_people_iccm`,
        `a`.`num_routine_visits` AS `num_routine_visits`,
        `a`.`num_births` AS `num_births`,
        `a`.`num_births_home` AS `num_births_home`,
        `a`.`num_births_facility` AS `num_births_facility`,
        `a`.`num_stillbirths` AS `num_stillbirths`,
        `a`.`num_deaths_neonatal` AS `num_deaths_neonatal`,
        `a`.`num_deaths_postneonatal` AS `num_deaths_postneonatal`,
        `a`.`num_deaths_child` AS `num_deaths_child`,
        `a`.`num_deaths_maternal` AS `num_deaths_maternal`,
        `a`.`num_deaths_adult` AS `num_deaths_adult`,
        `a`.`num_triggers` AS `num_triggers`,
        `a`.`num_referrals_suspect_hiv_tb_cm_ntd_mh` AS `num_referrals_suspect_hiv_tb_cm_ntd_mh`,
        `a`.`num_pregnant_woman_visits` AS `num_pregnant_woman_visits`,
        a.num_active_case_finds                 as num_active_case_finds,
        `a`.`num_muac_red` AS `num_muac_red`,
        `a`.`num_muac_yellow` AS `num_muac_yellow`,
        `a`.`num_muac_green` AS `num_muac_green`,
        `a`.`num_tx_ari` AS `num_tx_ari`,
        `a`.`num_tx_diarrhea` AS `num_tx_diarrhea`,
        `a`.`num_tx_malaria` AS `num_tx_malaria`,
        `a`.`num_tx_malaria_under24` AS `num_tx_malaria_under24`,
        `a`.`num_tx_malaria_over24` AS `num_tx_malaria_over24`,
        (`a`.`num_tx_malaria_under24` + `a`.`num_tx_malaria_over24`) AS `num_tx_malaria_under24_denominator`,
        `a`.`num_tx_malaria_under1` AS `num_tx_malaria_under1`,
        `a`.`num_tx_malaria_over1` AS `num_tx_malaria_over1`,
        `a`.`num_community_triggers` AS `num_community_triggers`,
        `a`.`num_referred_delivery` AS `num_referred_delivery`,
        `a`.`num_referred_anc` AS `num_referred_anc`,
        `a`.`num_post_natal_visits` AS `num_post_natal_visits`,
        `a`.`num_referred_rmnh_danger_sign` AS `num_referred_rmnh_danger_sign`,
        `a`.`num_hbmnc_48_hours_mother` AS `num_hbmnc_48_hours_mother`,
        `a`.`num_hbmnc_48_hours_infant` AS `num_hbmnc_48_hours_infant`,
        `a`.`num_clients_modern_fp` AS `num_clients_modern_fp`,
        `a`.`num_hiv_client_visits` AS `num_hiv_client_visits`,
        `a`.`num_tb_client_visits` AS `num_tb_client_visits`,
        `a`.`num_cm_ntd_client_visits` AS `num_cm_ntd_client_visits`,
        `a`.`num_mental_health_client_visits` AS `num_mental_health_client_visits`,
        `a`.`num_ltfu_hiv_clients_traced` AS `num_ltfu_hiv_clients_traced`,
        `a`.`num_ltfu_tb_clients_traced` AS `num_ltfu_tb_clients_traced`
    FROM
        ((((`lastmile_report`.`view_msr_union` `a`
        LEFT JOIN `lastmile_cha`.`health_district` `b` ON ((`a`.`district` = CONVERT( `b`.`health_district` USING UTF8))))
        LEFT JOIN `lastmile_cha`.`county` `c` ON ((`b`.`county_id` = `c`.`county_id`)))
        LEFT JOIN `lastmile_report`.`data_mart_snapshot_position_cha` `d` ON (((`a`.`cha_id` = `d`.`position_id`)
            AND (CAST(CONCAT(`a`.`year_reported`, '-', `a`.`month_reported`, '-01')
            AS DATE) = `d`.`snapshot_date`))))
        LEFT JOIN `lastmile_cha`.`view_base_cha_basic_info` `e` ON ((`a`.`cha_id` = `e`.`position_id`)))
;