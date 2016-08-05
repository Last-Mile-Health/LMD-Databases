use lastmile_chwdb;
 
drop function if exists matchStaffIDSoundexName;

-- The purpose of this function is to try and match a staffID and first and last names with existing values in the admin_staff.  

-- Return Values:
-- -1 if any of the parameters are null or empty strings
--  0  if the staffID and the soundex value of the staffName do not match
--  1  This can be greater than one 

create function matchStaffIDSoundexName( paramStaffID integer, paramStaffName varchar( 255 ) ) returns integer

begin

declare numberMatch integer default 0;

if ( paramStaffID            is null ) or ( paramStaffID            <= 0      ) or
   ( paramStaffName          is null ) or ( trim( paramStaffName )  like  ''  )
    then
    
  set numberMatch = -1;
    
else

  select count( * ) 
  from admin_staff as s
  where ( s.staffID = paramStaffID ) and
        ( soundex( concat( s.firstName, ' ', s.lastName ) ) = soundex( trim( paramStaffName ) ) ) 
  into numberMatch;
  
end if;

return numberMatch;
end;