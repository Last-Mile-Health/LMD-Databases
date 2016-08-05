use lastmile_chwdb;
 
drop function if exists convertTrainingPosition;

-- This function takes a string and converts it to a staffing position that exists in the
-- admin_position table.  If the string is not as a valid staffing position, it is 
-- returned unaltered, because the training position value is not constrained by the
-- the values in the admin_postion table, meaning it can be something other than CHW,
-- CHWL, and CCS.

-- Return Values:
-- CHW, CHWL, CCS the string represents a valid position.
-- tTe orginal string passed as a paramter.

create function convertTrainingPosition( paramString varchar( 255 ) ) returns varchar( 255 )

begin

declare returnValue varchar( 255 ) default null;

case upper( trim( paramString ) )
    when 'CHW' then
        set returnValue = 'CHW';
    when 'CHW LEADER' then
        set returnValue = 'CHWL';
    when 'CHW-L' then
        set returnValue = 'CHWL';
    when 'CHWL' then
        set returnValue = 'CHWL'; 
    when 'CCS' then
        set returnValue = 'CCS';    
    else
        set returnValue = trim( paramString );
end case;

return returnValue;
end;