use lastmile_chwdb;

drop view if exists view_sequentialUnsignedInteger;

create view view_sequentialUnsignedInteger as
select d4.digit * 1000 + d3.digit * 100 + d2.digit * 10 + d1.digit as n
from view_digit as d1
    cross join view_digit as d2
        cross join view_digit as d3
            cross join view_digit as d4
order by n asc;