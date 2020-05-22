use lastmile_report;

drop view if exists view_msr_union;

create view view_msr_union as
select 
        meta_uuid,
        meta_de_init,
        meta_de_date,
        meta_qa_init,
        meta_qa_date,
        meta_form_version,
        meta_insert_date_time,
        meta_de_time_start,
        meta_de_time_end,
        meta_data_source,
        
        month_reported,
        year_reported,
        cha_name,
        trim( cha_id ) as cha_id,
        cha_module,
        chss_name,
        trim( chss_id ) as chss_id,
        community,
        community_id,
        district,
        health_facility,
        
        1_2_a_routine_household_visits                            as num_routine_visits,
        
        ( coalesce( 1_2_b_births_community_home, 0  ) + 
          coalesce( 1_2_c_births_facility, 0        ) )           as num_births,
                
        1_2_b_births_community_home                               as num_births_home,
        1_2_c_births_facility                                     as num_births_facility,
        1_2_d_still_births                                        as num_stillbirths,
        1_2_e_neonatal_deaths                                     as num_deaths_neonatal,
        1_2_f_post_neonatal_deaths                                as num_deaths_postneonatal,
        1_2_g_child_deaths                                        as num_deaths_child,
        1_2_h_maternal_deaths                                     as num_deaths_maternal,
        1_2_k_adult_deaths                                        as num_deaths_adult,
        1_2_i_community_triggers                                  as num_triggers,
        1_2_j_hiv_tb_cm_ntd_mh_suspect_referrals                  as num_referrals_suspect_hiv_tb_cm_ntd_mh,
        2_1_a_pregnant_woman_visits                               as num_pregnant_woman_visits,
        
        3_1_A_active_case_finds                                   as num_active_case_finds,
        3_1_b_muac_red                                            as num_muac_red,
        3_1_c_muac_yellow                                         as num_muac_yellow,
        3_1_d_muac_green                                          as num_muac_green,
        3_1_h_pneumonia_treated_antibiotics                       as num_tx_ari,
        3_1_m_diarrhea_treated_zinc_ORS                           as num_tx_diarrhea,
        ( coalesce( 3_1_i_malaria_treated_2_11_months, 0  ) + 
          coalesce( 3_1_j_malaria_treated_1_5_years, 0    ) )     as num_tx_malaria,
        3_1_k_malaria_treated_less_24_hours                       as num_tx_malaria_under24,
        3_1_l_malaria_treated_more_24_hours                       as num_tx_malaria_over24,
        
        3_1_i_malaria_treated_2_11_months                         as num_tx_malaria_under1,
        3_1_j_malaria_treated_1_5_years                           as num_tx_malaria_over1,
        1_2_i_community_triggers                                  as num_community_triggers,
        2_1_b_referred_delivery                                   as num_referred_delivery,
        2_1_c_referred_anc                                        as num_referred_anc,
        2_1_d_post_natal_visits                                   as num_post_natal_visits,
        2_1_e_referred_danger_sign                                as num_referred_rmnh_danger_sign,
        2_1_f_hbmnc_48_hours_mother                               as num_hbmnc_48_hours_mother,
        2_1_g_hbmnc_48_hours_infant                               as num_hbmnc_48_hours_infant,
        2_2_a_clients_modern_fp                                   as num_clients_modern_fp,
        4_1_a_hiv_client_visits                                   as num_hiv_client_visits,
        4_1_b_tb_client_visits                                    as num_tb_client_visits,
        4_1_c_cm_ntd_client_visits                                as num_cm_ntd_client_visits,
        4_1_d_mental_health_client_visits                         as num_mental_health_client_visits,
        4_1_e_ltfu_hiv_clients_traced                             as num_ltfu_hiv_clients_traced,
        4_1_f_ltfu_tb_clients_traced                              as num_ltfu_tb_clients_traced

from lastmile_upload.de_cha_monthly_service_report
/*  Filter out position IDs where the CHSSs and CHAs consciously did not know their IDs and entered 999s.  In Winter/Spring 2018, 
    we had over sixty new CHSSs and CHAs in Rivercess who did not have IDs (LMH or NCHAP) for months.  This wrecked havoc on our 
    reporting because records could not be tied together.  The decision was made to filter out all of the 999s for purposes of 
    reporting.
*/
where -- cha_id is not a null or emtpy string and it is not 999
      ( 
        not ( ( cha_id is null ) or ( trim( cha_id ) like '' )  ) and 
        not ( trim( cha_id ) like '999' )
      )
      and
      -- chss_id is not a null or emtpy string and it is not 999
      ( 
        not ( ( chss_id is null ) or ( trim( chss_id ) like '' )  ) and 
        not ( trim( chss_id ) like '999' )
      )
      

union all

select 
        meta_UUID,
        meta_DE_init,
        meta_DE_date,
        meta_QA_init,
        meta_QA_date,
        meta_formVersion,
        meta_insertDatetime,
        meta_DE_startTime,
        meta_DE_endTime,
        meta_dataSource,
        
        monthReported,
        yearReported,
        chwName,
        trim( chwID ) as chwID,
        chwModule,        
        null as chss_name,
        null as chss_id,    
        community,
        communityID,
        district,
        healthFacility,
        
        routineVisitsPopulationNumberOfRoutineVisitsTotal       as routineVisitsPopulationNumberOfRoutineVisitsTotal,
        routineVisitsPopulationBirthsTotal                      as routineVisitsPopulationBirthsTotal,
        maternalNewbornHomeBirthsTotal                          as maternalNewbornHomeBirthsTotal,
        maternalNewbornFacilityBirthsTotal                      as maternalNewbornFacilityBirthsTotal,
        routineVisitsPopulationStillBirthsTotal                 as routineVisitsPopulationStillBirthsTotal,
        routineVisitsPopulationNeonatalDeathsTotal              as routineVisitsPopulationNeonatalDeathsTotal,
        routineVisitsPopulationPostNeonatalDeathsTotal          as routineVisitsPopulationPostNeonatalDeathsTotal,
        routineVisitsPopulationChildDeathsTotal                 as routineVisitsPopulationChildDeathsTotal,
        routineVisitsPopulationMaternalDeathsTotal              as routineVisitsPopulationMaternalDeathsTotal,
        routineVisitsPopulationAdultDeathsTotal                 as routineVisitsPopulationAdultDeathsTotal,        
        null                                                    as num_triggers,
        null                                                    as num_referrals_suspect_hiv_tb_cm_ntd_mh,
        null                                                    as num_pregnant_woman_visits,
        iCCMNutritionActiveCaseFindsTotal                       as num_active_case_finds,
        iCCMNutritionMUACRedTotal                               as iCCMNutritionMUACRedTotal,
        iCCMNutritionMUACYellowTotal                            as iCCMNutritionMUACYellowTotal,
        null                                                    as num_muac_green,
        iCCMNutritionPneumoniaCasesTotal                        as iCCMNutritionPneumoniaCasesTotal,
        iCCMNutritionDiarrheaCasesTotal                         as iCCMNutritionDiarrheaCasesTotal,
        iCCMNutritionMalariaCasesTotal                          as iCCMNutritionMalariaCasesTotal,
        iCCMNutritionMalariaTreatedWithin24HoursTotal           as iCCMNutritionMalariaTreatedWithin24HoursTotal,
        
        ( coalesce( iCCMNutritionMalariaCasesTotal, 0 ) - 
          coalesce( iCCMNutritionMalariaTreatedWithin24HoursTotal, 0 ) )  as num_tx_malaria_over24,
          
        null  as num_tx_malaria_under1,
        null  as num_tx_malaria_over1,
        null  as num_community_triggers,
        null  as num_referred_delivery,
        null  as num_referred_anc,
        null  as num_post_natal_visits,
        null  as num_referred_rmnh_danger_sign,
        null  as num_hbmnc_48_hours_mother,
        null  as num_hbmnc_48_hours_infant,
        null  as num_clients_modern_fp,
        null  as num_hiv_client_visits,
        null  as num_tb_client_visits,
        null  as num_cm_ntd_client_visits,
        null  as num_mental_health_client_visits,
        null  as num_ltfu_hiv_clients_traced,
        null  as num_ltfu_tb_clients_traced        

from lastmile_archive.staging_chwMonthlyServiceReportStep1
;