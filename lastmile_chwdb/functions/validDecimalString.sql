use lastmile_chwdb;

drop function if exists validDecimalString;
 
-- The purpose of this function is to take a string and see if it can be cast to a valid decimal.
-- Note: casting '1.' and '.1' yields the value 1.0 and 0.1, so even though these are not valid
-- decimal numbers, mysql still handles them as you would initiut it to.

-- Return Values:
-- 1, the string represents a valid decimal value.
-- 0, the string does not represent a valid decimal value.

create function validDecimalString( paramDecimalString varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

-- The regular expression below can probably be modified to accomodate these three boundry conditions
if  ( trim( paramDecimalString ) is null    )   or
    ( trim( paramDecimalString ) like ''    )   or
    ( trim( paramDecimalString ) like '-'   )   or 
    ( trim( paramDecimalString ) like '.'   )   or 
    ( trim( paramDecimalString ) like '-.'  )   then
    
  set returnValue = 0; -- false can't be cast to decimal
    
else

  select paramDecimalString regexp '^[[.-.]]?[0-9]*\\.?[0-9]*$'
  into returnValue;
  
end if;

return returnValue;
end;