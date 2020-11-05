use lastmile_report;

drop view if exists view_twelve_month;

create view view_twelve_month as
select 
      sequence_number, -- zero is current month, one is previous month, and so on...  
      substr( convert( period_add( date_format( current_date(), '%Y%m' ), 0 - sequence_number ), char ), 1, 4 ) as year_report,
      substr( convert( period_add( date_format( current_date(), '%Y%m' ), 0 - sequence_number ), char ), 5, 2 ) as month_report  
  
from lastmile_report.view_sequence_zero_twelve
;
