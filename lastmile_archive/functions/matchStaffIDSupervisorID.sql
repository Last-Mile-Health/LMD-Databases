use lastmile_chwdb;
 
drop function if exists matchStaffIDSupervisorID;

-- This function takes a staffID and a supervisorID and verifies in the
-- admin_staffSupervisorAssoc table whether the staffID has ever 
-- been supervised by the supervisorID.

-- Return Values:
-- noMatch  - staffID has never been supervised by the supervisorID 
-- active   - staffID is actively being supervised by the supervisorID
-- inactive - staffID was but is no longer being supervised the supervisorID.

create function matchStaffIDSupervisorID( paramStaffID integer, paramSupervisorID integer ) returns varchar( 255 )

begin

declare returnValue             varchar( 255 )  default 'noMatch';
declare returnDateAssocBegan    date            default null;
declare returnDateAssocEnded    date            default null;

-- If the staffID or supervisorID being checked is null or less than or equal to zero, don't bother running the query.
if ( not paramStaffID is null ) and ( paramStaffID > 0 ) and ( not paramSupervisorID is null ) and ( paramSupervisorID > 0 ) then
  
  select 
          dateAssocBegan,
          dateAssocEnded
  from admin_staffSupervisorAssoc
  where ( staffID = paramStaffID ) and ( supervisorID = paramSupervisorID )
  group by  dateAssocBegan,
            dateAssocEnded
  order by  dateAssocBegan desc,
            dateAssocEnded desc
  limit 1 -- Not elegant, but this is an easy way to crop the resultset off at the first row.
  into returnDateAssocBegan, returnDateAssocEnded;
 
   if ( not returnDateAssocBegan is null )     and ( returnDateAssocEnded is null ) then 
  
      set returnValue = 'active';
      
  elseif ( not returnDateAssocBegan is null ) and ( not returnDateAssocEnded is null ) then 
  
      set returnValue = 'inactive';
  
  end if;
 
end if;

return returnValue;

end;