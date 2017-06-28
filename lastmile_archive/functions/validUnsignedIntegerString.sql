use lastmile_chwdb;

drop function if exists validUnsignedIntegerString;

-- The purpose of this function is to take a string and see if it can be cast to a valid unsinged integer.
 
-- Return Values:
-- 1, the string represents a valid unsigned integer value.
-- 0, the string does not represent a valid unsigned integer value.

create function validUnsignedIntegerString( paramString varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

-- The regular expression below can probably be modified to accomodate these three boundry conditions
if ( ( paramString is null ) or trim( paramString ) like '' )  then
    
  set returnValue = 0; -- false can't be cast to decimal
    
else

  select trim( paramString ) regexp '^[0-9]+$'
  into returnValue;
  
end if;

return returnValue;
end;