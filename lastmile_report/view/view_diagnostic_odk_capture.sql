use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_odk_capture;

create view lastmile_report.view_diagnostic_odk_capture as

select
      year_capture            as `Year`,
      month_capture           as `Month`,
      'Total'                 as Form,
      9999                    as sort_order,
      sum( number_capture )   as `#Records`
      
from lastmile_report.view_diagnostic_odk_capture_table
group by `Year`, `Month`

union all

select
      year_capture           as `Year`,
      month_capture          as `Month`,
    
      case
          when table_name like 'odk_vaccineTracker'               then 'Vaccine Tracker'
          when table_name like 'odk_QAOSupervisionChecklistForm'  then 'QAO Supervision Check List'
          when table_name like 'odk_chaRestock'                   then 'CHA Restock'
          when table_name like 'odk_supervisionVisitLog'          then 'Supervision Visit Log'        
          when table_name like 'odk_sickChildForm'                then 'Sick Child Form'
          when table_name like 'odk_routineVisit'                 then 'Routine Visit Form'
          else 'Other'
      end as Form,
      
      case
          when table_name like 'odk_vaccineTracker'               then 1
          when table_name like 'odk_QAOSupervisionChecklistForm'  then 2
          when table_name like 'odk_chaRestock'                   then 3
          when table_name like 'odk_supervisionVisitLog'          then 4
          when table_name like 'odk_sickChildForm'                then 5
          when table_name like 'odk_routineVisit'                 then 6
          else 7
      end as sort_order,
      
      number_capture as `#Records`
      
from lastmile_report.view_diagnostic_odk_capture_table

-- order by statement orders the entire result set of union, not just this last query
order by `Year` desc, `Month` desc, sort_order asc
;