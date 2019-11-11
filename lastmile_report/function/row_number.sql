use lastmile_report;
 
drop function if exists row_number;

-- row_number is a recursive function that mimics the behavior of the Oracle 
-- pseudocolumn rownum, generating sequential integers beginning at 1 for 
-- every row in a query.

-- Just add the function as a field in the query and it will do the rest.

-- For example, if the table test has 10 rows, the following query 
-- will return a sequence of integers, one for each row, from 1 to 10.

-- select row_number() as id from test;

create function row_number() returns int( 11 )
deterministic
begin
  return if( @row_number, @row_number:= @row_number + 1, @row_number:= 1 );
end;