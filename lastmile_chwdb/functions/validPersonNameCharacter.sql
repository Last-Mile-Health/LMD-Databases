use lastmile_chwdb;

drop function if exists validPersonNameCharacter;

-- The purpose of this function is to take a string and see if it has any invalid characters for a name.

-- Return Values:
-- 1, the string represents a valid name
-- 0, the string contains only valid characters. 

create function validPersonNameCharacter( paramString varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;
declare lcv int default 1;
declare stringLength int default character_length( paramString );

-- If the string being passed is a null or empty, don't bother, just bail.
if ( ( paramString is null ) or trim( paramString ) like '' )  then

  set returnValue = 0;
    
else

    -- Step through string one character at a time and compare to acceptable characters for a name; 
    -- namely, a-z either upper or lower case, a period, a single quote, and a hyphen.
    while lcv <= stringLength do
    
      -- To escape characters in regexp you need to double backslash them.  So period and blank 
      -- character are both preceded by two backslashes.  As for a single quote, in a string, two single
      -- represent one quote.  So the character sequence '  ''  ' is a string with blanks and one single quote.
      if substring( lower( paramString ), lcv, 1 ) regexp '[a-z]+|[0-9]+|\\.+|\\,+|\\ +|\\-+|''+' then
      
        set returnValue = 1;
        set lcv = lcv + 1;
      
      else
      
        set returnValue = 0;
        set lcv = stringLength + 1;
      
      end if;
      
    end while;

end if;

return returnValue;
end;