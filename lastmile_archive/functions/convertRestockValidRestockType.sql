use lastmile_chwdb;
 
drop function if exists convertRestockValidRestockType;

-- This function takes a string of arbitary length with a sequence of characters
-- of arbitrary cases and matches it to a valid restock type and then maps it to 
-- a string the scm_chwRestock restockType fields expect.

-- Note: This function should only be called after the function restockValidRestockType() has determined
-- the string is a valid restock type.

-- restockType:   full, partial, none

-- Return Values: null, '', full, partial, none, or the original string passed as a parameter.

create function convertRestockValidRestockType( paramString varchar( 255 ) ) returns varchar( 255 )

begin

declare returnValue varchar( 255 ) default null;

case lower( replace( paramString, ' ', '' ) )

    when 'full' then
        set returnValue = 'full';
        
    when 'partial' then
        set returnValue = 'partial';
        
    when 'none' then
        set returnValue = 'none';
        
    when '' then
        set returnValue = null;
        
    else
        set returnValue = paramString;
        
end case;

return returnValue;
end;