use lastmile_chwdb;

drop view if exists view_trainingTypeValue;

create view view_trainingTypeValue as

select 'CHW1' as trainingType
union
select 'CHW2' as trainingType
union
select 'CHW3' as trainingType
union
select 'CHW4' as trainingType
union
select 'LMA1' as trainingType
union
select 'LMA2' as trainingType
union
select 'LMA3' as trainingType
union
select 'LMA4' as trainingType
;
