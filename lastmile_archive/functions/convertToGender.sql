use lastmile_chwdb;
 
drop function if exists convertToGender;

-- This function takes a string and attempts to convert it to a valid gender.  In chwdb,
-- the only gender values are recognizes are 'M' or 'F'.  Nevertheless, strings with
-- whitespace and every possible permutation of 'M', 'F', 'MALE, or 'FEMALE', upper or 
-- lower case, will match and be converted to 'M' or 'F'.  Since all whitespace is 
-- stripped before checking the string, sequences of characters like ' m A l E ' 
-- would be considered a match.  This function should always be called before 
-- inserting gender into a chwdb database table.

-- Valid values returned by function:
-- 'M' or 'F'
-- null, failed to match

create function convertToGender( paramValidGender varchar( 255 ) ) returns varchar( 1 )

begin

declare returnValue varchar( 1 ) default null;

case upper( replace( paramValidGender, ' ', '' ) )
    when 'M' then
        set returnValue = 'M';
    when 'F' then
        set returnValue = 'F';
    when 'MALE' then
        set returnValue = 'M';
    when 'FEMALE' then
        set returnValue = 'F';
    else
        set returnValue = null;
end case;

return returnValue;
end;