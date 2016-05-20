use lastmile_chwdb;
 
drop function if exists rowNumber;

-- The rowNumber function mimics the behavior of the Oracle pseudocolumn
-- rownum, generating a sequential integer beginning at 1 for every row in
-- a query.

-- Just add as a field in the query and the function will do the rest.
-- For example, if the table test has 10 rows, the following query 
-- will return a sequence of integers, one for each row, from 1 to 10.

-- select rowNumber() as id from test;

create function rowNumber() returns int( 11 )
deterministic
begin
  return if(@rowNumber, @rowNumber:=@rowNumber+1, @rowNumber:=1);
end;