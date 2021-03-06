use lastmile_report;

drop view if exists view_base_msr_county;

create view view_base_msr_county as
select
        `view_base_msr`.`county` AS `county`,
        `view_base_msr`.`county_id` AS `county_id`,
        `lastmile_report`.`territory_id`(`view_base_msr`.`county_id`, 1) AS `territory_id`,
        `view_base_msr`.`month_reported` AS `month_reported`,
        `view_base_msr`.`year_reported` AS `year_reported`,
        SUM(1) AS `num_reports`,
        SUM(`view_base_msr`.`num_catchment_households`) AS `num_catchment_households`,
        SUM(`view_base_msr`.`num_catchment_people`) AS `num_catchment_people`,
        SUM(`view_base_msr`.`num_catchment_people_iccm`) AS `num_catchment_people_iccm`,
        SUM(`view_base_msr`.`num_routine_visits`) AS `num_routine_visits`,
        SUM(`view_base_msr`.`num_births`) AS `num_births`,
        SUM(`view_base_msr`.`num_births_home`) AS `num_births_home`,
        SUM(`view_base_msr`.`num_births_facility`) AS `num_births_facility`,
        SUM(`view_base_msr`.`num_stillbirths`) AS `num_stillbirths`,
        SUM(`view_base_msr`.`num_deaths_neonatal`) AS `num_deaths_neonatal`,
        SUM(`view_base_msr`.`num_deaths_postneonatal`) AS `num_deaths_postneonatal`,
        SUM(`view_base_msr`.`num_deaths_child`) AS `num_deaths_child`,
        SUM(`view_base_msr`.`num_deaths_maternal`) AS `num_deaths_maternal`,
        SUM(`view_base_msr`.`num_deaths_adult`) AS `num_deaths_adult`,
        SUM(`view_base_msr`.`num_triggers`) AS `num_triggers`,
        SUM(`view_base_msr`.`num_referrals_suspect_hiv_tb_cm_ntd_mh`) AS `num_referrals_suspect_hiv_tb_cm_ntd_mh`,
        SUM(`view_base_msr`.`num_pregnant_woman_visits`) AS `num_pregnant_woman_visits`,
        
        SUM(`view_base_msr`.`num_active_case_finds`) AS `num_active_case_finds`,
        
        SUM(`view_base_msr`.`num_muac_red`) AS `num_muac_red`,
        SUM(`view_base_msr`.`num_muac_yellow`) AS `num_muac_yellow`,
        SUM(`view_base_msr`.`num_muac_green`) AS `num_muac_green`,
        SUM(`view_base_msr`.`num_tx_ari`) AS `num_tx_ari`,
        SUM(`view_base_msr`.`num_tx_diarrhea`) AS `num_tx_diarrhea`,
        SUM(`view_base_msr`.`num_tx_malaria`) AS `num_tx_malaria`,
        SUM(`view_base_msr`.`num_tx_malaria_under24`) AS `num_tx_malaria_under24`,
        SUM(`view_base_msr`.`num_tx_malaria_over24`) AS `num_tx_malaria_over24`,
        SUM(`view_base_msr`.`num_tx_malaria_under24_denominator`) AS `num_tx_malaria_under24_denominator`,
        SUM(`view_base_msr`.`num_tx_malaria_under1`) AS `num_tx_malaria_under1`,
        SUM(`view_base_msr`.`num_tx_malaria_over1`) AS `num_tx_malaria_over1`,
        SUM(`view_base_msr`.`num_community_triggers`) AS `num_community_triggers`,
        SUM(`view_base_msr`.`num_referred_delivery`) AS `num_referred_delivery`,
        SUM(`view_base_msr`.`num_referred_anc`) AS `num_referred_anc`,
        SUM(`view_base_msr`.`num_post_natal_visits`) AS `num_post_natal_visits`,
        SUM(`view_base_msr`.`num_referred_rmnh_danger_sign`) AS `num_referred_rmnh_danger_sign`,
        SUM(`view_base_msr`.`num_hbmnc_48_hours_mother`) AS `num_hbmnc_48_hours_mother`,
        SUM(`view_base_msr`.`num_hbmnc_48_hours_infant`) AS `num_hbmnc_48_hours_infant`,
        SUM(`view_base_msr`.`num_clients_modern_fp`) AS `num_clients_modern_fp`,
        SUM(`view_base_msr`.`num_hiv_client_visits`) AS `num_hiv_client_visits`,
        SUM(`view_base_msr`.`num_tb_client_visits`) AS `num_tb_client_visits`,
        SUM(`view_base_msr`.`num_cm_ntd_client_visits`) AS `num_cm_ntd_client_visits`,
        SUM(`view_base_msr`.`num_mental_health_client_visits`) AS `num_mental_health_client_visits`,
        SUM(`view_base_msr`.`num_ltfu_hiv_clients_traced`) AS `num_ltfu_hiv_clients_traced`,
        SUM(`view_base_msr`.`num_ltfu_tb_clients_traced`) AS `num_ltfu_tb_clients_traced`
    FROM
        `lastmile_report`.`view_base_msr`
    GROUP BY `view_base_msr`.`county_id` , `view_base_msr`.`month_reported` , `view_base_msr`.`year_reported`