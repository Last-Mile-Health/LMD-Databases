use lastmile_chwdb;

drop function if exists validDateFormat;

-- This function takes a string and checks if it conforms to the format 'YYYY/MM/DD', which is the format
-- the datepicker method returns.  If there are blanks spaces but the string is otherwise in the correct
-- format, the function returns true, 1. So ' 2 0 1 6 / 0 1 / 1 4 ' would be considered a valid date.
-- Note: year is always a four digit number and month and day are two.
 
-- Return Values:
-- 1, the string is in valid datepicker format
-- 0, the string is not in valid datepicker format

create function validDateFormat( paramString varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

if  ( paramString is null    )   or
    ( trim( paramString ) like ''    ) then
    
    set returnValue = 0; -- null or empty string, don't bother
    
else

    select replace( paramString, ' ', '' )  regexp '^[0-9]{4}\\-{1}[0-9]{2}\\-{1}[0-9]{2}$'
    into returnValue;
  
end if;

return returnValue;
end;