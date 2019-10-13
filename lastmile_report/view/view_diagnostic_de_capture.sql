use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_de_capture;

create view lastmile_report.view_diagnostic_de_capture as

select
      year_capture           as `Year`,
      month_capture          as `Month`,
      'Total'               as Form,
      9999                  as sort_order,
      sum( number_capture )  as `#Records`
      
from lastmile_report.view_diagnostic_de_capture_table
group by `Year`, `Month`

union all

select
      year_capture           as `Year`,
      month_capture          as `Month`,
    
      case
          when table_name like 'de_case_scenario'               then 'Case Scenario'     
          when table_name like 'de_chss_commodity_distribution' then 'CHSS Commodity'
          when table_name like 'de_chss_monthly_service_report' then 'CHSS MSR'
          when table_name like 'de_chaHouseholdRegistration'    then 'CHA HHR'
          when table_name like 'de_cha_monthly_service_report'  then 'CHA MSR'
          else 'Other'
      end as Form,
      
      case
          when table_name like 'de_case_scenario'               then 1
          when table_name like 'de_chss_commodity_distribution' then 2
          when table_name like 'de_chss_monthly_service_report' then 3
          when table_name like 'de_chaHouseholdRegistration'    then 4
          when table_name like 'de_cha_monthly_service_report'  then 5
          
          else 9998
      end as sort_order,
      
      number_capture as `#Records`
      
from lastmile_report.view_diagnostic_de_capture_table

-- order by statement orders the entire result set of union, not just this last query
order by `Year` desc, `Month` desc, sort_order asc
;