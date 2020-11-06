use lastmile_report;

drop view if exists lastmile_report.view_sequence_zero_twelve;

create view lastmile_report.view_sequence_zero_twelve as
select 0 as month_minus union all 
select 1  union all 
select 2  union all 
select 3  union all 
select 4  union all 
select 5  union all 
select 6  union all 
select 7  union all 
select 8  union all 
select 9  union all 
select 10 union all 
select 11 union all 
select 12   
;
