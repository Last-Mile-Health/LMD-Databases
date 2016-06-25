use lastmile_chwdb;
 
drop function if exists matchStaffID;

-- The purpose of this function is to test if staffID exists in the admin_staff table.  

-- Return Values:
-- -1 if paramStaffID is not an unsigned integer greater than 1
--  0  if the paramStaffID does not match an ID in the admin_staff table
--  1  if the paramStaffID matches an ID in the admin_staff table

create function matchStaffID( paramStaffID integer ) returns integer

begin

declare returnValue integer default 0;

if ( paramStaffID is null ) or ( paramStaffID <= 0 ) then
    
  set returnValue = -1;
    
else

  select count( * ) 
  from admin_staff
  where ( staffID = paramStaffID )
  into returnValue;
  
end if;

return returnValue;
end;