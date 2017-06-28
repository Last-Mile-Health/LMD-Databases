use lastmile_archive;

drop function if exists mapStaffIDToCounty;

create function mapStaffIDToCounty( staffID varchar(255) ) returns varchar( 255 )
begin

  declare county varchar( 255 ) default null;

  if 	( staffID is null ) or ( trim( staffID ) = '' ) then
				
    set county = null;
  
  else
  
    if ( cast( staffID as unsigned ) >= 1 ) and ( cast( staffID as unsigned ) <= 1999 ) then
    
      set county = 'Grand Gedeh';
      
    else
  
      set county = 'Rivercess';
      
  end if; 
        
end if;

return county;

end;