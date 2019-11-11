use lastmile_report;

drop view if exists lastmile_report.view_data_entry;

create view lastmile_report.view_data_entry as 

select 
      'Correct Treatment: Case Scenario'  as `Form name`,
        a.meta_de_init                        as `DE Clerk`,
        year( a.meta_de_date )                as `Year`,
        month( a.meta_de_date )               as `Month`,
        count( 0 )                            as `# records entered`,
        sum( if( ( ( trim( a.meta_qa_init ) like '' ) or isnull( a.meta_qa_init ) ), 0, 1 ) ) as `# records receiving QA`
from lastmile_upload.de_case_scenario as a
group by `Year` , `Month` , a.meta_de_init 

union all

select 
      'Correct Treatment: Case Scenario 2.0'  as `Form name`,
        a.meta_de_init                        as `DE Clerk`,
        year( a.meta_de_date )                as `Year`,
        month( a.meta_de_date )               as `Month`,
        count( 0 )                            as `# records entered`,
        sum( if( ( ( trim( a.meta_qa_init ) like '' ) or isnull( a.meta_qa_init ) ), 0, 1 ) ) as `# records receiving QA`
from lastmile_upload.de_case_scenario_2 as a
group by `Year` , `Month` , a.meta_de_init 

union all

select 
      'Sick Child Form'         as `Form name`,
      a.meta_DE_init            as `DE Clerk`,
      year( a.meta_DE_date )    as `Year`,
      month( a.meta_DE_date )   as `Month`,
      count( 0 )                as `# records entered`,
      sum( if( ( ( trim( a.meta_QA_init ) like '' ) or isnull( a.meta_QA_init ) ), 0, 1 ) ) as `# records receiving QA`
        
from lastmile_archive.tbl_data_fhw_sch_sickchild as a
group by `Year` , `Month` , a.meta_DE_init 
    
union all 
    
select 
        'GCHV Questionnaire'    as `Form name`,
        a.meta_DE_init          as `DE Clerk`,
        year( a.meta_DE_date )  as `Year`,
        month( a.meta_DE_date ) as `Month`,
        count( 0 )              as `# records entered`,
        sum( if( ( ( trim( a.meta_QA_init ) like '' ) or isnull( a.meta_QA_init ) ), 0, 1 ) ) as `# records receiving QA`
from lastmile_archive.tbl_data_prg_chv_gchvquestionnaire as a
group by `Year` , `Month` , a.meta_DE_init
    
    
    
    
    UNION select 
        'Sickness Screening Tool' as `Form name`,
        `lastmile_archive`.`tbl_data_fhw_sst_sicknessscreening`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_archive`.`tbl_data_fhw_sst_sicknessscreening`.`meta_DE_date`) as `Year`,
        month( `lastmile_archive`.`tbl_data_fhw_sst_sicknessscreening`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_archive`.`tbl_data_fhw_sst_sicknessscreening`.`meta_QA_init` = '')
                or isnull( `lastmile_archive`.`tbl_data_fhw_sst_sicknessscreening`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_archive`.`tbl_data_fhw_sst_sicknessscreening`
    group by `Year` , `Month` , `lastmile_archive`.`tbl_data_fhw_sst_sicknessscreening`.`meta_DE_init` 
    UNION select 
        'Household Registration' as `Form name`,
        `lastmile_archive`.`tbl_data_fhw_reg_registration`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_archive`.`tbl_data_fhw_reg_registration`.`meta_DE_date`) as `Year`,
        month( `lastmile_archive`.`tbl_data_fhw_reg_registration`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_archive`.`tbl_data_fhw_reg_registration`.`meta_QA_init` = '')
                or isnull( `lastmile_archive`.`tbl_data_fhw_reg_registration`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_archive`.`tbl_data_fhw_reg_registration`
    group by `Year` , `Month` , `lastmile_archive`.`tbl_data_fhw_reg_registration`.`meta_DE_init` 
    UNION select 
        'Malaria Assessment Tool' as `Form name`,
        `lastmile_archive`.`tbl_data_fhw_mat_malariaassessment`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_archive`.`tbl_data_fhw_mat_malariaassessment`.`meta_DE_date`) as `Year`,
        month( `lastmile_archive`.`tbl_data_fhw_mat_malariaassessment`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_archive`.`tbl_data_fhw_mat_malariaassessment`.`meta_QA_init` = '')
                or isnull( `lastmile_archive`.`tbl_data_fhw_mat_malariaassessment`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_archive`.`tbl_data_fhw_mat_malariaassessment`
    group by `Year` , `Month` , `lastmile_archive`.`tbl_data_fhw_mat_malariaassessment`.`meta_DE_init` 
    UNION select 
        'KPI Assessment' as `Form name`,
        `lastmile_archive`.`tbl_data_fhw_kpi_kpiassessment`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_archive`.`tbl_data_fhw_kpi_kpiassessment`.`meta_DE_date`) as `Year`,
        month( `lastmile_archive`.`tbl_data_fhw_kpi_kpiassessment`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_archive`.`tbl_data_fhw_kpi_kpiassessment`.`meta_QA_init` = '')
                or isnull( `lastmile_archive`.`tbl_data_fhw_kpi_kpiassessment`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_archive`.`tbl_data_fhw_kpi_kpiassessment`
    group by `Year` , `Month` , `lastmile_archive`.`tbl_data_fhw_kpi_kpiassessment`.`meta_DE_init` 
    UNION select 
        'Ebola Education and Screening Tool' as `Form name`,
        `lastmile_archive`.`tbl_data_fhw_ees_ebolaeducationscreening`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_archive`.`tbl_data_fhw_ees_ebolaeducationscreening`.`meta_DE_date`) as `Year`,
        month( `lastmile_archive`.`tbl_data_fhw_ees_ebolaeducationscreening`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_archive`.`tbl_data_fhw_ees_ebolaeducationscreening`.`meta_QA_init` = '')
                or isnull( `lastmile_archive`.`tbl_data_fhw_ees_ebolaeducationscreening`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_archive`.`tbl_data_fhw_ees_ebolaeducationscreening`
    group by `Year` , `Month` , `lastmile_archive`.`tbl_data_fhw_ees_ebolaeducationscreening`.`meta_DE_init` 
    UNION select 
        'Births, Deaths, & Movements Form' as `Form name`,
        `lastmile_archive`.`tbl_data_fhw_bdm_movements`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_archive`.`tbl_data_fhw_bdm_movements`.`meta_DE_date`) as `Year`,
        month( `lastmile_archive`.`tbl_data_fhw_bdm_movements`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_archive`.`tbl_data_fhw_bdm_movements`.`meta_QA_init` = '')
                or isnull( `lastmile_archive`.`tbl_data_fhw_bdm_movements`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_archive`.`tbl_data_fhw_bdm_movements`
    group by `Year` , `Month` , `lastmile_archive`.`tbl_data_fhw_bdm_movements`.`meta_DE_init` 
    UNION select 
        'CHW Monthly Service Report' as `Form name`,
        `lastmile_archive`.`staging_chwMonthlyServiceReportStep1`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_archive`.`staging_chwMonthlyServiceReportStep1`.`meta_DE_date`) as `Year`,
        month( `lastmile_archive`.`staging_chwMonthlyServiceReportStep1`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_archive`.`staging_chwMonthlyServiceReportStep1`.`meta_QA_init` = '')
                or isnull( `lastmile_archive`.`staging_chwMonthlyServiceReportStep1`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_archive`.`staging_chwMonthlyServiceReportStep1`
    group by `Year` , `Month` , `lastmile_archive`.`staging_chwMonthlyServiceReportStep1`.`meta_DE_init` 
    UNION select 
        'CHW Monthly Service Report' as `Form name`,
        `lastmile_upload`.`de_cha_monthly_service_report`.`meta_de_init` as `DE Clerk`,
        year( `lastmile_upload`.`de_cha_monthly_service_report`.`meta_de_date`) as `Year`,
        month( `lastmile_upload`.`de_cha_monthly_service_report`.`meta_de_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_upload`.`de_cha_monthly_service_report`.`meta_qa_init` = '')
                or isnull( `lastmile_upload`.`de_cha_monthly_service_report`.`meta_qa_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_upload`.`de_cha_monthly_service_report`
    group by `Year` , `Month` , `lastmile_upload`.`de_cha_monthly_service_report`.`meta_de_init` 
    UNION select 
        'CHSS Monthly Service Report' as `Form name`,
        `lastmile_upload`.`de_chss_monthly_service_report`.`meta_de_init` as `DE Clerk`,
        year( `lastmile_upload`.`de_chss_monthly_service_report`.`meta_de_date`) as `Year`,
        month( `lastmile_upload`.`de_chss_monthly_service_report`.`meta_de_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_upload`.`de_chss_monthly_service_report`.`meta_qa_init` = '')
                or isnull( `lastmile_upload`.`de_chss_monthly_service_report`.`meta_qa_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_upload`.`de_chss_monthly_service_report`
    group by `Year` , `Month` , `lastmile_upload`.`de_chss_monthly_service_report`.`meta_de_init` 
    UNION 
    
    select 
        'Correct Treatment: Direct Observation' as `Form name`,
        `lastmile_upload`.`de_direct_observation`.`meta_de_init` as `DE Clerk`,
        year( `lastmile_upload`.`de_direct_observation`.`meta_de_date`) as `Year`,
        month( `lastmile_upload`.`de_direct_observation`.`meta_de_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_upload`.`de_direct_observation`.`meta_qa_init` = '')
                or isnull( `lastmile_upload`.`de_direct_observation`.`meta_qa_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_upload`.`de_direct_observation`
    group by `Year` , `Month` , `lastmile_upload`.`de_direct_observation`.`meta_de_init` 
    UNION select 
        'Correct Treatment: Register Review' as `Form name`,
        `lastmile_upload`.`de_register_review`.`meta_de_init` as `DE Clerk`,
        year( `lastmile_upload`.`de_register_review`.`meta_de_date`) as `Year`,
        month( `lastmile_upload`.`de_register_review`.`meta_de_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_upload`.`de_register_review`.`meta_qa_init` = '')
                or isnull( `lastmile_upload`.`de_register_review`.`meta_qa_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_upload`.`de_register_review`
    group by `Year` , `Month` , `lastmile_upload`.`de_register_review`.`meta_de_init` 
    UNION select 
        'CHSS Commodity Distribution Form' as `Form name`,
        `lastmile_upload`.`de_chss_commodity_distribution`.`meta_de_init` as `DE Clerk`,
        year( `lastmile_upload`.`de_chss_commodity_distribution`.`meta_de_date`) as `Year`,
        month( `lastmile_upload`.`de_chss_commodity_distribution`.`meta_de_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_upload`.`de_chss_commodity_distribution`.`meta_qa_init` = '')
                or isnull( `lastmile_upload`.`de_chss_commodity_distribution`.`meta_qa_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_upload`.`de_chss_commodity_distribution`
    group by `Year` , `Month` , `lastmile_upload`.`de_chss_commodity_distribution`.`meta_de_init` 
    UNION select 
        'Household Registration' as `Form name`,
        `lastmile_upload`.`de_chaHouseholdRegistration`.`meta_DE_init` as `DE Clerk`,
        year( `lastmile_upload`.`de_chaHouseholdRegistration`.`meta_DE_date`) as `Year`,
        month( `lastmile_upload`.`de_chaHouseholdRegistration`.`meta_DE_date`) as `Month`,
        count( 0 ) as `# records entered`,
        sum( if( ( (`lastmile_upload`.`de_chaHouseholdRegistration`.`meta_QA_init` = '')
                or isnull( `lastmile_upload`.`de_chaHouseholdRegistration`.`meta_QA_init`)),
            0,
            1)) as `# records receiving QA`
    from
        `lastmile_upload`.`de_chaHouseholdRegistration`
    group by `Year` , `Month` , `lastmile_upload`.`de_chaHouseholdRegistration`.`meta_DE_init`
 

order by `Year` desc, `Month` desc