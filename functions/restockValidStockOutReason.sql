use lastmile_chwdb;
 
drop function if exists restockValidStockOutReason;


-- The purpose of this function is to take a string and see if it represents a valid
-- stock out reason.  Empty, null, other, outOfStock, noModuleTraining are all valid
-- stock out strings.

-- Note: All whitespace is removed from strings before an attempt is made to match.
-- So strings such as ' o u t O f S t o c k ' would be considered a match.  Likewise,
-- case is ignored, so strings such as 'outofstock or 'OUTOFSTOCK' would also be considerd
-- matches as well.

-- Return Values:
-- 1, the string represents a valid stock out reason.
-- 0, the string does not represent a valid stock out reason.

create function restockValidStockOutReason( paramStrng varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

case 
    when lower( replace( paramStrng, ' ', '' ) ) is null                          then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like ''                          then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like 'other'                     then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like lower( 'outOfStock' )       then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like lower( 'noModuleTraining' ) then
        set returnValue = 1;
    else
        set returnValue = 0;
end case;

return returnValue;
end;