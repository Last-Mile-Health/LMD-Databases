use lastmile_chwdb;

drop view if exists view_digit;

create view view_digit as 
select 0 as digit
union
select 1 as digit
union
select 2 as digit
union
select 3 as digit
union
select 4 as digit
union
select 5 as digit
union
select 6 as digit
union
select 7 as digit
union
select 8 as digit
union
select 9 as digit
;
