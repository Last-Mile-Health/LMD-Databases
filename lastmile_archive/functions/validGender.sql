use lastmile_chwdb;
 
drop function if exists validGender;

-- The purpose of this function is to take a string and see if it is a valid gender
-- recognized in the chwdb data model, which is 'M' or 'F'.  However, here we return
-- true if it is either 'MALE' or 'FEMALE'.  Note we strip out all whitespace so 
-- strings such as ' m a l e ' would match.  Always be sure to extract the
-- first valid character before inserting gender into the table, using the 
-- convertToGender function.  

-- Return Values:
-- 1, the string represents a valid gender.
-- 0, the string does not represent a valid gender.

create function validGender( paramValidGender varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

case upper( replace( paramValidGender, ' ', '' ) )
    when 'M' then
        set returnValue = 1;
    when 'F' then
        set returnValue = 1;
    when 'MALE' then
        set returnValue = 1;
    when 'FEMALE' then
        set returnValue = 1;
    else
        set returnValue = 0;
end case;

return returnValue;
end;