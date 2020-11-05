use lastmile_report;

drop view if exists lastmile_report.view_sequence_zero_twelve;

create view lastmile_report.view_sequence_zero_twelve as
select 0  as sequence_number union all 
select 1  as sequence_number union all 
select 2  as sequence_number union all 
select 3  as sequence_number union all 
select 4  as sequence_number union all 
select 5  as sequence_number union all 
select 6  as sequence_number union all 
select 7  as sequence_number union all 
select 8  as sequence_number union all 
select 9  as sequence_number union all 
select 10 as sequence_number union all 
select 11 as sequence_number union all 
select 12 as sequence_number 
;
