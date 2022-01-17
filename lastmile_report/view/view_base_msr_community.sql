use lastmile_report;

drop view if exists lastmile_report.view_base_msr_community;

create view lastmile_report.view_base_msr_community as 
select
      community_id_primary                            as community_id,
      month_reported,
      year_reported,
      
      sum(  1 )                                       as num_reports,
      sum(  num_catchment_households )                as num_catchment_households,
      sum(  num_catchment_people )                    as num_catchment_people,
      sum(  num_catchment_people_iccm )               as num_catchment_people_iccm,
      sum(  num_routine_visits )                      as num_routine_visits,
      sum(  num_births )                              as num_births,
      sum(  num_births_home )                         as num_births_home,
      sum(  num_births_facility )                     as num_births_facility,
      sum(  num_stillbirths )                         as num_stillbirths,
      sum(  num_deaths_neonatal )                     as num_deaths_neonatal,
      sum(  num_deaths_postneonatal )                 as num_deaths_postneonatal,
      sum(  num_deaths_child )                        as num_deaths_child,
      sum(  num_deaths_maternal )                     as num_deaths_maternal,
      sum( num_deaths_adult )                         as num_deaths_adult,
      sum( num_triggers )                             as num_triggers,
      sum( num_referrals_suspect_hiv_tb_cm_ntd_mh )   as num_referrals_suspect_hiv_tb_cm_ntd_mh,
      sum( num_pregnant_woman_visits )                as num_pregnant_woman_visits,
      sum( num_muac_red )                             as num_muac_red,
      sum( num_muac_yellow )                          as num_muac_yellow,
      sum( num_muac_green )                           as num_muac_green,
      sum( num_tx_ari )                               as num_tx_ari,
      sum( num_tx_diarrhea )                          as num_tx_diarrhea,
      sum( num_tx_malaria )                           as num_tx_malaria,
      sum( num_tx_malaria_under24 )                   as num_tx_malaria_under24,
      sum( num_tx_malaria_over24 )                    as num_tx_malaria_over24,
      sum( num_tx_malaria_under24_denominator )       as num_tx_malaria_under24_denominator,
      sum( num_tx_malaria_under1 )                    as num_tx_malaria_under1,
      sum( num_tx_malaria_over1 )                     as num_tx_malaria_over1,
      sum( num_community_triggers )                   as num_community_triggers,
      sum( num_referred_delivery )                    as num_referred_delivery,
      sum( num_referred_anc )                         as num_referred_anc,
      sum( num_post_natal_visits )                    as num_post_natal_visits,
      sum( num_referred_rmnh_danger_sign )            as num_referred_rmnh_danger_sign,
      sum( num_hbmnc_48_hours_mother )                as num_hbmnc_48_hours_mother,
      sum( num_hbmnc_48_hours_infant )                as num_hbmnc_48_hours_infant,
      sum( num_clients_modern_fp )                    as num_clients_modern_fp,
      sum( num_hiv_client_visits )                    as num_hiv_client_visits,
      sum( num_tb_client_visits )                     as num_tb_client_visits,
      sum( num_cm_ntd_client_visits )                 as num_cm_ntd_client_visits,
      sum( num_mental_health_client_visits )          as num_mental_health_client_visits,
      sum( num_ltfu_hiv_clients_traced )              as num_ltfu_hiv_clients_traced,
      sum( num_ltfu_tb_clients_traced )               as num_ltfu_tb_clients_traced 
from lastmile_report.view_base_msr 
group by community_id_primary,  month_reported, year_reported
;