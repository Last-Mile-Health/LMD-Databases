use lastmile_chwdb;
 
drop function if exists convertRestockValidStockOutReason;

-- This function takes a string of arbitary length with a sequence of characters
-- of arbitrary cases and matches it to a valid stock out reason and then maps it to 
-- a string the scm_chwRestock stockOutReason fields expect.

-- Note: This function should only be called after the function restockValidStockOutReason() has determined
-- the string is a valid stock out reason.

-- Return Values: null, '', other, outOfStock, noModuleTraining, or the original string passed as a parameter.

create function convertRestockValidStockOutReason( paramString varchar( 255 ) ) returns varchar( 255 )

begin

declare returnValue varchar( 255 ) default null;

case lower( replace( paramString, ' ', '' ) )

    when 'other' then
        set returnValue = 'other';
        
    when lower( 'outOfStock' ) then
        set returnValue = 'outOfStock';
        
    when lower( 'noModuleTraining' ) then
        set returnValue = 'noModuleTraining';
        
    when '' then
        set returnValue = null;
        
    else
        set returnValue = paramString;
        
end case;

return returnValue;
end;