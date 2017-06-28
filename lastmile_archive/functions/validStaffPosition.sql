use lastmile_chwdb;

drop function if exists validStaffPosition;

-- The purpose of this function is to take a string and see if matches a position
-- the database recognizes.
 
-- Return Values:
-- 1, the string represents a valid position.
-- 0, the string does not represent a valid position.

create function validStaffPosition( paramValidStaffPosition varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

if ( ( paramValidStaffPosition is null ) or trim( paramValidStaffPosition ) like '' )  then
    
  set returnValue = 0; -- empty string or null, don't bother, just bail
    
elseif ( upper( trim( paramValidStaffPosition ) ) like 'CHW' ) then

  set returnValue = 1;

elseif  ( upper( trim( paramValidStaffPosition ) ) like 'CHW LEADER'  ) or 
        ( upper( trim( paramValidStaffPosition ) ) like 'CHW-L'       ) or 
        ( upper( trim( paramValidStaffPosition ) ) like 'CHWL'        ) then 

  set returnValue = 1;
  
elseif ( upper( trim( paramValidStaffPosition ) ) like 'CCS' ) then

  set returnValue = 1;
  
end if;

return returnValue;
end;