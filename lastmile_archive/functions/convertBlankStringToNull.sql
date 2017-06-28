use lastmile_chwdb;
 
drop function if exists convertBlankStringToNull;

-- A null, empty string, or string of blanks should be treated as a null when the field in question is a 
-- integer in mysql.  Null gets cast to null.  However, an empty string or a string of blanks will get cast
-- to zero, which is not what was intended.  So before storing a blank string into a integer type we should
-- convert it to null.
-- Return Values: null or original string as a varchar.

create function convertBlankStringToNull( paramString varchar( 255 ) ) returns varchar( 255 )

begin

declare returnValue varchar( 255 ) default null;

case replace( paramString, ' ', '' )

    when '' then
        set returnValue = null;  
    else
        set returnValue = paramString;
        
end case;

return returnValue;
end;