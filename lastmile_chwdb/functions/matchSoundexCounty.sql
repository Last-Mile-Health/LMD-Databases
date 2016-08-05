use lastmile_chwdb;

drop function if exists matchSoundexCounty;

-- The purpose of this function is to try and match a string to the counties in
-- the admin_territoryLevel1 table.

-- Return Values:
-- -1, if any of the parameters are null or empty strings
--  0,  if the name does not match an existing county
--  1,  if the name matches an existing county

create function matchSoundexCounty( paramString varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

if ( paramString is null ) or ( trim( paramString ) like  ''  ) then
    
  set returnValue = -1; -- null or empty string, don't bother
    
else

  select count( * )
  from (  select soundex( t.name )
          from admin_territoryLevel1 as t
          where soundex( t.name ) = soundex( trim( paramString ) )
          group by soundex( t.name ) ) as s
  into returnValue;

end if;

return returnValue;
end;