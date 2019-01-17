use lastmile_upload;

drop view if exists lastmile_upload.view_diagnostic_de_id_unfiltered;

create view lastmile_upload.view_diagnostic_de_id_unfiltered as

-- 1. de_case_scenario ----------------------------------------------------------------------------------------

select  
        'de_case_scenario'                      as table_name,
        a.de_case_scenario_id                   as pk_id,
        'chss'                                  as id_type,
        'chss_id'                               as id_name,
        
        a.chss_id_original                      as id_original_value,
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value, 
        a.chss_id                               as id_value, 

        a.cha                                   as meta_cha,
        a.cha_id_original		                    as meta_cha_id,
        a.chss		                              as meta_chss,
        null 	                                  as meta_chss_id,
        a.health_facility		                    as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        a.county                                as meta_county,
        a.community		                          as meta_community,
        a.community_id		                      as meta_community_id,
        a.date_form                             as meta_form_date,
       
        a.meta_insert_date_time, 
        a.meta_form_version
                
from lastmile_upload.de_case_scenario as a
  
union all

select 
        'de_case_scenario'                      as table_name,
        a.de_case_scenario_id                   as pk_id,
        'cha'                                   as id_type,
        'cha_id'                                as id_name,

        a.cha_id_original                       as id_original_value, 
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as id_inserted_format_value, 
        a.cha_id                                as id_value,

        a.cha                                   as meta_cha,
        null		                                as meta_cha_id,
        a.chss		                              as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        a.county                                as meta_county,
        a.community		                          as meta_community,
        a.community_id		                      as meta_community_id,
        a.date_form                             as meta_form_date,
       
        a.meta_insert_date_time, 
        a.meta_form_version
                
from lastmile_upload.de_case_scenario as a
    
union all

-- 2. de_chaHouseholdRegistration ---------------------------------------------------------------------

select  
        'de_chaHouseholdRegistration'           as table_name,
        a.chaHouseholdRegistrationID            as pk_id,
        'cha'                                   as id_type,
        'chaID'                                 as id_name,

        a.cha_id_original                       as id_original_value, 
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as id_inserted_format_value,
        a.chaID                                 as id_value, 

        a.chaName 		                          as meta_cha,
        null		                                as meta_cha_id,
        a.chssName		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.healthFacility		                    as meta_facility,
        null                                    as meta_facility_id,
        a.healthDistrict		                    as meta_health_district,
        null                                    as meta_county,
        a.community		                          as meta_community,
        a.communityID		                        as meta_community_id,
        a.registrationDate                      as meta_form_date,
 
        a.meta_insertDatetime, 
        a.meta_formVersion 
        
from lastmile_upload.de_chaHouseholdRegistration as a
    
union all

select  
        'de_chaHouseholdRegistration'           as table_name,
        a.chaHouseholdRegistrationID            as pk_id,
        'chss'                                  as id_type,
        'chssID'                                as id_name,

        a.chss_id_original                      as id_original_value,
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value,
        a.chssID                                as id_value,

        a.chaName 		                          as meta_cha,
        a.cha_id_original		                    as meta_cha_id,
        a.chssName		                          as meta_chss,
        null 	                                  as meta_chss_id,
        a.healthFacility		                    as meta_facility,
        null                                    as meta_facility_id,
        a.healthDistrict		                    as meta_health_district,
        null                                    as meta_county,
        a.community		                          as meta_community,
        a.communityID		                        as meta_community_id,
        a.registrationDate                      as meta_form_date,
   
        a.meta_insertDatetime, 
        a.meta_formVersion 
                
from lastmile_upload.de_chaHouseholdRegistration as a
    
union all

-- 3. de_cha_monthly_service_report -----------------------------------------------------------------------

select  
        'de_cha_monthly_service_report'         as table_name,
        a.cha_monthly_service_report_id         as pk_id,

        'cha'                                   as id_type,
        'cha_id'                                as id_name,
  
        a.cha_id_original                       as id_original_value,
        a.cha_id_inserted                       as id_inserted_value, 
        a.cha_id_inserted_format                as cha_id_inserted_format_value,
        a.cha_id                                as id_value,   
          
        a.cha_name 		                          as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        null                                    as meta_facility_id,
        a.district		                          as meta_health_district,
        null                                    as meta_county,
        a.community		                          as meta_community,
        a.community_id		                      as meta_community_id,
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
         
        a.meta_insert_date_time, 
        a.meta_form_version
            
from lastmile_upload.de_cha_monthly_service_report as a
    
union all

select  
        'de_cha_monthly_service_report'         as table_name,
        a.cha_monthly_service_report_id         as pk_id,

        'chss'                                  as id_type,
        'chss_id'                               as id_name,

        a.chss_id_original                      as id_original_value,
        a.chss_id_inserted                      as id_inserted_value,
        a.chss_id_inserted_format               as id_inserted_value_format,
        a.chss_id                               as id_value,
    
        a.cha_name 		                          as meta_cha,
        a.cha_id_original		                    as meta_cha_id,
        a.chss_name		                          as meta_chss,
        null 	                                  as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        null                                    as meta_facility_id,
        a.district		                          as meta_health_district,
        null                                    as meta_county,
        a.community		                          as meta_community,
        a.community_id		                      as meta_community_id,
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
         
        a.meta_insert_date_time, 
        a.meta_form_version
        
from lastmile_upload.de_cha_monthly_service_report as a


union all


-- 4. de_chss_commodity_distribution -------------------------------------------------------------------------
 
select  
        'de_chss_commodity_distribution'        as table_name,
        a.chss_commodity_distribution_id        as pk_id,
        'chss'                                  as id_type,
        'chss_id'                               as id_name,
 
        a.chss_id_original                      as id_original_value, 
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value,
        a.chss_id                               as id_value,

        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss		                              as meta_chss,
        null 	                                  as meta_chss_id,
        a.health_facility		                    as meta_facility,
        null                                    as meta_facility_id,
        null		                                as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        a.restock_date                          as meta_form_date,
 
        a.meta_insert_date_time, 
        a.meta_form_version
        
from lastmile_upload.de_chss_commodity_distribution as a
   
union all


-- 5. de_chss_monthly_service_report --------------------------------------------------------------------------------------

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'chss'                                  as id_type,
        'chss_id'                               as id_name,

        a.chss_id_original                      as id_original_value,
        a.chss_id_inserted                      as id_inserted_value, 
        a.chss_id_inserted_format               as id_inserted_format_value,
        a.chss_id                               as id_value, 
        
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        null 	                                  as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
 
        a.meta_insert_date_time, 
        a.meta_form_version
   
from lastmile_upload.de_chss_monthly_service_report as a
   
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_1'                              as id_name,

        a.cha_id_1_original                     as id_original_value,
        a.cha_id_1_inserted                     as id_inserted_value, 
        a.cha_id_1_inserted_format              as id_inserted_format_value, 
        a.cha_id_1                              as id_value,
       
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
 
 
        a.meta_insert_date_time, 
        a.meta_form_version as form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_2'                              as id_name,

        a.cha_id_2_original                     as id_original_value,
        a.cha_id_2_inserted                     as id_inserted_value, 
        a.cha_id_2_inserted_format              as id_inserted_format_value, 
        a.cha_id_2                              as id_value,
       
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
                
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
 
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_3'                              as id_name,

        a.cha_id_3_original                     as id_original_value,
        a.cha_id_3_inserted                     as id_inserted_value, 
        a.cha_id_3_inserted_format              as id_inserted_format_value, 
        a.cha_id_3                              as id_value,
       
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_4'                              as id_name,

        a.cha_id_4_original                     as id_original_value,
        a.cha_id_4_inserted                     as id_inserted_value, 
        a.cha_id_4_inserted_format              as id_inserted_format_value, 
        a.cha_id_4                              as id_value,
     
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_5'                              as id_name,

        a.cha_id_5_original                     as id_original_value,
        a.cha_id_5_inserted                     as id_inserted_value, 
        a.cha_id_5_inserted_format              as id_inserted_format_value, 
        a.cha_id_5                              as id_value,
       
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_6'                              as id_name,

        a.cha_id_6_original                     as id_original_value,
        a.cha_id_6_inserted                     as id_inserted_value, 
        a.cha_id_6_inserted_format              as id_inserted_format_value, 
        a.cha_id_6                              as id_value,
   
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
 
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,

        'cha'                                   as id_type,
        'cha_id_7'                              as id_name,

        a.cha_id_7_original                     as id_original_value,
        a.cha_id_7_inserted                     as id_inserted_value, 
        a.cha_id_7_inserted_format              as id_inserted_format_value, 
        a.cha_id_7                              as id_value,
      
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
 
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_8'                              as id_name,

        a.cha_id_8_original                     as id_original_value,
        a.cha_id_8_inserted                     as id_inserted_value, 
        a.cha_id_8_inserted_format              as id_inserted_format_value, 
        a.cha_id_8                              as id_value,
       
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_9'                              as id_name,

        a.cha_id_9_original                     as id_original_value,
        a.cha_id_9_inserted                     as id_inserted_value, 
        a.cha_id_9_inserted_format              as id_inserted_format_value, 
        a.cha_id_9                              as id_value,
        
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
 
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_10'                             as id_name,

        a.cha_id_10_original                    as id_original_value,
        a.cha_id_10_inserted                    as id_inserted_value, 
        a.cha_id_10_inserted_format             as id_inserted_format_value, 
        a.cha_id_10                             as id_value,
        
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_11'                             as id_name,

        a.cha_id_11_original                    as id_original_value,
        a.cha_id_11_inserted                    as id_inserted_value, 
        a.cha_id_11_inserted_format             as id_inserted_format_value, 
        a.cha_id_11                             as id_value,
        
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
 
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_12'                             as id_name,

        a.cha_id_12_original                    as id_original_value,
        a.cha_id_12_inserted                    as id_inserted_value, 
        a.cha_id_12_inserted_format             as id_inserted_format_value, 
        a.cha_id_12                             as id_value, 
        
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_13'                             as id_name,

        a.cha_id_13_original                    as id_original_value,
        a.cha_id_13_inserted                    as id_inserted_value, 
        a.cha_id_13_inserted_format             as id_inserted_format_value, 
        a.cha_id_13                             as id_value,
        
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
    
union all

select  
        'de_chss_monthly_service_report'        as table_name,
        a.chss_monthly_service_report_id        as pk_id,
        
        'cha'                                   as id_type,
        'cha_id_14'                             as id_name,

        a.cha_id_14_original                    as id_original_value,
        a.cha_id_14_inserted                    as id_inserted_value, 
        a.cha_id_14_inserted_format             as id_inserted_format_value, 
        a.cha_id_14                             as id_value,
        
        null 		                                as meta_cha,
        null		                                as meta_cha_id,
        a.chss_name		                          as meta_chss,
        a.chss_id_original 	                    as meta_chss_id,
        a.health_facility		                    as meta_facility, 
        a.health_facility_id                    as meta_facility_id,
        a.district		                          as meta_health_district,
        a.county                                as meta_county,
        null		                                as meta_community,
        null		                                as meta_community_id, 
        
        date_format( concat( a.year_reported, '-', a.month_reported, '-01' ), '%Y-%m-%d' )  as meta_form_date,
  
        a.meta_insert_date_time, 
        a.meta_form_version
       
from lastmile_upload.de_chss_monthly_service_report as a
;
